import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/transaction_model.dart';
import 'package:mobile/providers/finance_provider.dart';

void main() {
  late FinanceProvider provider;

  setUp(() {
    provider = FinanceProvider();
  });

  group('FinanceProvider - Lógica de Fluxo de Caixa', () {
    test('Deve iniciar com listas vazias ou padrão', () {
      expect(provider.transactions.isEmpty, true);
      expect(provider.categories.isNotEmpty, true);
    });

    test('Deve calcular Saldo Previsto vs Saldo Real corretamente', () {
      // Receita Confirmada
      provider.addTransaction(TransactionModel(
        id: '1',
        value: 1000.0,
        date: DateTime(2024, 4, 1),
        billingDate: DateTime(2024, 4, 1),
        categoryId: '6',
        type: TransactionType.income,
        paymentMethod: PaymentMethod.pix,
        isConfirmed: true,
      ));

      // Despesa Pendente (Ex: Boleto ainda não pago)
      provider.addTransaction(TransactionModel(
        id: '2',
        value: 200.0,
        date: DateTime(2024, 4, 5),
        billingDate: DateTime(2024, 4, 10),
        categoryId: '3',
        type: TransactionType.expense,
        paymentMethod: PaymentMethod.bankSlip,
        isConfirmed: false,
      ));

      // Saldo Previsto deve considerar tudo (1000 - 200 = 800)
      expect(provider.getProjectedBalance(4, 2024), 800.0);
      
      // Saldo Real deve considerar apenas confirmados (1000)
      expect(provider.getRealBalance(4, 2024), 1000.0);
    });

    test('Deve alternar o status de confirmação e atualizar saldos', () {
      provider.addTransaction(TransactionModel(
        id: '1',
        value: 50.0,
        date: DateTime(2024, 4, 1),
        billingDate: DateTime(2024, 4, 1),
        categoryId: '4',
        type: TransactionType.expense,
        paymentMethod: PaymentMethod.cash,
        isConfirmed: false,
      ));

      expect(provider.getRealBalance(4, 2024), 0.0);
      expect(provider.getProjectedBalance(4, 2024), -50.0);

      // Confirmar a transação
      provider.toggleTransactionConfirmation('1');
      
      expect(provider.getRealBalance(4, 2024), -50.0);
      expect(provider.getProjectedBalance(4, 2024), -50.0);
    });

    test('Deve navegar entre os meses corretamente', () {
      final initialMonth = provider.focusedMonth.month;
      
      provider.nextMonth();
      expect(provider.focusedMonth.month, (initialMonth % 12) + 1);
      
      provider.previousMonth();
      expect(provider.focusedMonth.month, initialMonth);
    });

    test('Deve confirmar todas as transações do período em massa', () {
      provider.addTransaction(TransactionModel(
        id: '1', value: 10, date: DateTime(2024, 4, 1), billingDate: DateTime(2024, 4, 1), 
        categoryId: '1', type: TransactionType.expense, paymentMethod: PaymentMethod.cash, isConfirmed: false
      ));
      provider.addTransaction(TransactionModel(
        id: '2', value: 20, date: DateTime(2024, 4, 2), billingDate: DateTime(2024, 4, 2), 
        categoryId: '1', type: TransactionType.expense, paymentMethod: PaymentMethod.cash, isConfirmed: false
      ));

      expect(provider.getRealBalance(4, 2024), 0.0);

      provider.confirmAllInPeriod(4, 2024);

      expect(provider.getRealBalance(4, 2024), -30.0);
    });
  });
}
