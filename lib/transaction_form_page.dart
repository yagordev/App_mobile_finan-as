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

  /// Abre o seletor de data e atualiza o estado
  Future<void> _selectDate(BuildContext context, bool isBillingDate) async {
    final initialDate = isBillingDate ? _billingDate : _transactionDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isBillingDate) {
          _billingDate = picked;
        } else {
          _transactionDate = picked;
          // Por padrão, ao mudar a data da compra, sugerimos a mesma para faturamento
          _billingDate = picked;
        }
      });
    }
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final finance = context.read<FinanceProvider>();
    
    // Converte o valor formatado (R$ 0,00) de volta para double
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
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Nova Transação'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seletor de Tipo (Receita/Despesa)
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(value: TransactionType.income, label: Text('Receita'), icon: Icon(Icons.add_circle_outline)),
                  ButtonSegment(value: TransactionType.expense, label: Text('Despesa'), icon: Icon(Icons.remove_circle_outline)),
                ],
                selected: {_type},
                onSelectionChanged: (newSelection) {
                  setState(() => _type = newSelection.first);
                },
              ),
              const SizedBox(height: 20),

              // Campo Valor
              TextFormField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateValue,
              ),
              const SizedBox(height: 16),

              // Seleção de Categoria
              DropdownButtonFormField<CategoryModel>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: finance.categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: Validators.validateCategory,
              ),
              const SizedBox(height: 16),

              // Métodos de Pagamento
              DropdownButtonFormField<PaymentMethod>(
                value: _paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Método de Pagamento',
                  prefixIcon: Icon(Icons.payment),
                  border: OutlineInputBorder(),
                ),
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
              const SizedBox(height: 16),

              // Datas
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Data da Compra'),
                      subtitle: Text(dateFormat.format(_transactionDate)),
                      leading: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Faturamento'),
                      subtitle: Text(dateFormat.format(_billingDate)),
                      leading: const Icon(Icons.event_note),
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Descrição
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateDescription,
              ),
              const SizedBox(height: 30),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('SALVAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
