import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'app_colors.dart';
import 'models/transaction_model.dart';
import 'models/category_model.dart';
import 'providers/finance_provider.dart';
import 'validators.dart';
import 'widgets/currency_input_formatter.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({super.key});

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TransactionType _type = TransactionType.expense;
  CategoryModel? _selectedCategory;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  DateTime _transactionDate = DateTime.now();
  DateTime _billingDate = DateTime.now();

  @override
  void dispose() {
    _valueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isBillingDate) async {
    final initialDate = isBillingDate ? _billingDate : _transactionDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isBillingDate) {
          _billingDate = picked;
        } else {
          _transactionDate = picked;
          _billingDate = picked;
        }
      });
    }
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final finance = context.read<FinanceProvider>();
    final cleanValue = _valueController.text
        .replaceAll(RegExp(r'[^0-9,]'), '')
        .replaceAll(',', '.');
    final doubleValue = double.parse(cleanValue);

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      value: doubleValue,
      date: _transactionDate,
      billingDate: _billingDate,
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategory!.id,
      type: _type,
      paymentMethod: _paymentMethod,
    );

    finance.addTransaction(transaction);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Lançamento', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Card Principal
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seletor de Tipo Moderno
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Expanded(
                              child: _TypeButton(
                                label: 'Despesa',
                                isSelected: _type == TransactionType.expense,
                                color: AppColors.expense,
                                onTap: () => setState(() => _type = TransactionType.expense),
                              ),
                            ),
                            Expanded(
                              child: _TypeButton(
                                label: 'Receita',
                                isSelected: _type == TransactionType.income,
                                color: AppColors.income,
                                onTap: () => setState(() => _type = TransactionType.income),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Bloco de Valor Destacado
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'VALOR DO LANÇAMENTO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: AppColors.textGrey.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 2),
                            ),
                            child: TextFormField(
                              controller: _valueController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [CurrencyInputFormatter()],
                              textAlign: TextAlign.center,
                              autofocus: true, // Já abre o teclado no valor
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                              ),
                              decoration: InputDecoration(
                                hintText: 'R\$ 0,00',
                                hintStyle: TextStyle(color: AppColors.textGrey.withOpacity(0.2)),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              validator: Validators.validateValue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Divider(height: 1),
                    const SizedBox(height: 24),

                    // Categoria
                    _buildLabel('Categoria'),
                    DropdownButtonFormField<CategoryModel>(
                      value: _selectedCategory,
                      decoration: _inputDecoration(Icons.category_outlined),
                      items: finance.categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat.name));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                      validator: Validators.validateCategory,
                    ),
                    const SizedBox(height: 20),

                    // Método
                    _buildLabel('Forma de Pagamento'),
                    DropdownButtonFormField<PaymentMethod>(
                      value: _paymentMethod,
                      decoration: _inputDecoration(Icons.payments_outlined),
                      items: PaymentMethod.values.map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Text(TransactionModel(
                            id: '', value: 0, date: DateTime.now(), billingDate: DateTime.now(), 
                            categoryId: '', type: TransactionType.income, paymentMethod: method
                          ).paymentMethodName),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                    ),
                    const SizedBox(height: 20),

                    // Datas em Grid
                    Row(
                      children: [
                        Expanded(child: _buildDatePicker('Data da Compra', _transactionDate, () => _selectDate(context, false))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDatePicker('Faturamento', _billingDate, () => _selectDate(context, true))),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Descrição
                    _buildLabel('Descrição'),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _inputDecoration(Icons.edit_note_outlined, hint: 'Ex: Almoço de domingo'),
                      validator: Validators.validateDescription,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Confirmar Lançamento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textGrey)),
    );
  }

  InputDecoration _inputDecoration(IconData icon, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  Widget _buildDatePicker(String label, DateTime date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(DateFormat('dd/MM/yy').format(date), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({required this.label, required this.isSelected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textGrey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
