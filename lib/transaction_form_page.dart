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
  bool _isConfirmed = true;

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
          if (_paymentMethod != PaymentMethod.creditCard) {
            _billingDate = picked;
          }
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
      billingDate: _paymentMethod == PaymentMethod.creditCard ? _billingDate : _transactionDate,
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategory!.id,
      type: _type,
      paymentMethod: _paymentMethod,
      isConfirmed: _isConfirmed,
    );

    finance.addTransaction(transaction);
    Navigator.of(context).pop();
  }

  /// Retorna o nome amigável do método baseado no tipo de transação
  String _getPaymentMethodLabel(PaymentMethod method, TransactionType type) {
    if (type == TransactionType.income) {
      switch (method) {
        case PaymentMethod.cash: return 'Dinheiro em Mãos';
        case PaymentMethod.pix: return 'Pix';
        case PaymentMethod.bankSlip: return 'Transferência / Depósito';
        case PaymentMethod.creditCard: return 'Cartão de Crédito';
        case PaymentMethod.debitCard: return 'Cartão de Débito';
        default: return 'Outro';
      }
    }
    return TransactionModel(
      id: '', value: 0, date: DateTime.now(), billingDate: DateTime.now(), 
      categoryId: '', type: type, paymentMethod: method
    ).paymentMethodName;
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final filteredCategories = finance.getCategoriesByType(_type);
    final isIncome = _type == TransactionType.income;

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
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: Offset(0, 10))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seletor de Tipo
                    Center(
                      child: Container(
                        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Expanded(
                              child: _TypeButton(
                                label: 'Despesa',
                                isSelected: !isIncome,
                                color: AppColors.expense,
                                onTap: () {
                                  setState(() {
                                    _type = TransactionType.expense;
                                    _selectedCategory = null;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: _TypeButton(
                                label: 'Receita',
                                isSelected: isIncome,
                                color: AppColors.income,
                                onTap: () {
                                  setState(() {
                                    _type = TransactionType.income;
                                    _selectedCategory = null;
                                    // Se estava em cartão, muda para algo comum em receita
                                    if (_paymentMethod == PaymentMethod.creditCard || _paymentMethod == PaymentMethod.debitCard) {
                                      _paymentMethod = PaymentMethod.pix;
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Valor
                    Center(
                      child: Column(
                        children: [
                          Text('VALOR DO LANÇAMENTO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppColors.textGrey.withOpacity(0.8))),
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
                              autofocus: true,
                              style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: AppColors.textDark),
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
                      items: filteredCategories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat.name));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                      validator: Validators.validateCategory,
                    ),
                    const SizedBox(height: 20),

                    // Método Dinâmico
                    _buildLabel(isIncome ? 'Receber via' : 'Forma de Pagamento'),
                    DropdownButtonFormField<PaymentMethod>(
                      value: _paymentMethod,
                      decoration: _inputDecoration(Icons.payments_outlined),
                      items: PaymentMethod.values.where((m) {
                        // Filtra métodos que não fazem sentido para receita comum
                        if (isIncome) {
                          return m != PaymentMethod.creditCard && m != PaymentMethod.debitCard;
                        }
                        return true;
                      }).map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Text(_getPaymentMethodLabel(method, _type)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _paymentMethod = val!;
                          if (_paymentMethod != PaymentMethod.creditCard) {
                            _billingDate = _transactionDate;
                            _isConfirmed = true; 
                          } else {
                            _isConfirmed = false;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Datas
                    _buildDatePicker('Data da Transação', _transactionDate, () => _selectDate(context, false)),
                    
                    if (_paymentMethod == PaymentMethod.creditCard) ...[
                      const SizedBox(height: 16),
                      _buildDatePicker('Data de Faturamento (Fatura)', _billingDate, () => _selectDate(context, true), isHighlight: true),
                    ],
                    
                    const SizedBox(height: 24),

                    // Confirmação Dinâmica
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isIncome ? 'Recebimento Confirmado' : 'Lançamento Confirmado', 
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)
                                ),
                                Text(
                                  isIncome ? 'O dinheiro já caiu na conta' : 'Já entrou/saiu da conta', 
                                  style: const TextStyle(fontSize: 12, color: AppColors.textGrey)
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: _isConfirmed,
                            activeColor: AppColors.primary,
                            onChanged: (val) => setState(() => _isConfirmed = val),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

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
    return Padding(padding: const EdgeInsets.only(bottom: 8, left: 4), child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textGrey)));
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

  Widget _buildDatePicker(String label, DateTime date, VoidCallback onTap, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isHighlight ? AppColors.primary.withOpacity(0.05) : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: isHighlight ? Border.all(color: AppColors.primary.withOpacity(0.2)) : null,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_outlined, size: 18, color: isHighlight ? AppColors.primary : AppColors.textGrey),
                const SizedBox(width: 12),
                Text(DateFormat('dd/MM/yyyy').format(date), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isHighlight ? AppColors.primary : AppColors.textDark)),
                const Spacer(),
                const Icon(Icons.edit_calendar_outlined, size: 16, color: AppColors.textGrey),
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
        decoration: BoxDecoration(color: isSelected ? color : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.textGrey, fontWeight: FontWeight.bold, fontSize: 14))),
      ),
    );
  }
}
