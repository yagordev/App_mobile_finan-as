import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class FinanceProvider extends ChangeNotifier {
  final List<TransactionModel> _transactions = [];
  final List<CategoryModel> _categories = [
    CategoryModel(id: '1', name: 'Comida', iconCode: 0xe1d2, colorValue: 0xFFF44336),
    CategoryModel(id: '2', name: 'Saúde', iconCode: 0xe306, colorValue: 0xFF4CAF50),
    CategoryModel(id: '3', name: 'Dívidas', iconCode: 0xe4b2, colorValue: 0xFF2196F3),
    CategoryModel(id: '4', name: 'Transporte', iconCode: 0xe1d1, colorValue: 0xFFFFEB3B),
    CategoryModel(id: '5', name: 'Lazer', iconCode: 0xe2ad, colorValue: 0xFF9C27B0),
  ];

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<CategoryModel> get categories => List.unmodifiable(_categories);

  /// Adiciona uma nova transação
  void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  /// Remove uma transação
  void removeTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// Filtra transações por mês e ano baseando-se na DATA DE FATURAMENTO (billingDate)
  List<TransactionModel> getTransactionsByMonth(int month, int year) {
    return _transactions.where((t) {
      return t.billingDate.month == month && t.billingDate.year == year;
    }).toList();
  }

  /// Calcula o saldo total (Receitas - Despesas) de um período específico
  double getTotalBalance(int month, int year) {
    final periodTransactions = getTransactionsByMonth(month, year);
    double balance = 0;
    for (var t in periodTransactions) {
      if (t.type == TransactionType.income) {
        balance += t.value;
      } else {
        balance -= t.value;
      }
    }
    return balance;
  }

  /// Retorna o total de Receitas de um período
  double getTotalIncomes(int month, int year) {
    return getTransactionsByMonth(month, year)
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.value);
  }

  /// Retorna o total de Despesas de um período
  double getTotalExpenses(int month, int year) {
    return getTransactionsByMonth(month, year)
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.value);
  }

  /// Adiciona uma nova categoria customizada
  void addCategory(CategoryModel category) {
    _categories.add(category);
    notifyListeners();
  }
}
