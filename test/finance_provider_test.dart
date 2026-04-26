import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/transaction_model.dart';
import 'package:mobile/providers/finance_provider.dart';

void main() {
  late FinanceProvider provider;

  setUp(() {
    provider = FinanceProvider();
  });

  group('FinanceProvider - Lógica de Transações e Saldo', () {
    test('Deve iniciar com listas vazias ou padrão', () {
      expect(provider.transactions.isEmpty, true);
      expect(provider.categories.isNotEmpty, true);
    });

    test('Deve calcular o saldo corretamente filtrando por billingDate', () {
      // Compra feita em Abril, faturada em Abril (Ex: Dinheiro)
      provider.addTransaction(TransactionModel(
        id: '1',
        value: 100.0,
        date: DateTime(2024, 4, 15),
        billingDate: DateTime(2024, 4, 15),
        categoryId: '1',
        type: TransactionType.income,
        paymentMethod: PaymentMethod.cash,
      ));

      // Compra feita em Abril, faturada em MAIO (Ex: Cartão de Crédito)
      provider.addTransaction(TransactionModel(
        id: '2',
        value: 50.0,
        date: DateTime(2024, 4, 28),
        billingDate: DateTime(2024, 5, 5),
        categoryId: '2',
        type: TransactionType.expense,
        paymentMethod: PaymentMethod.creditCard,
      ));

      // Verificação Abril: Saldo deve ser 100 (apenas a receita)
      expect(provider.getTotalBalance(4, 2024), 100.0);
      
      // Verificação Maio: Saldo deve ser -50 (apenas a despesa do cartão)
      expect(provider.getTotalBalance(5, 2024), -50.0);
    });

    test('Deve calcular totais de receitas e despesas separadamente', () {
      provider.addTransaction(TransactionModel(
        id: '1',
        value: 200.0,
        date: DateTime(2024, 4, 1),
        billingDate: DateTime(2024, 4, 1),
        categoryId: '1',
        type: TransactionType.income,
        paymentMethod: PaymentMethod.pix,
      ));

      provider.addTransaction(TransactionModel(
        id: '2',
        value: 80.0,
        date: DateTime(2024, 4, 2),
        billingDate: DateTime(2024, 4, 2),
        categoryId: '2',
        type: TransactionType.expense,
        paymentMethod: PaymentMethod.debitCard,
      ));

      expect(provider.getTotalIncomes(4, 2024), 200.0);
      expect(provider.getTotalExpenses(4, 2024), 80.0);
      expect(provider.getTotalBalance(4, 2024), 120.0);
    });
  });
}
