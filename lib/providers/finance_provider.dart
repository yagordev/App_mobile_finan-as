import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class FinanceProvider extends ChangeNotifier {
  final List<TransactionModel> _transactions = [];
  
  // Estado de navegação temporal
  DateTime _focusedMonth = DateTime.now();

  DateTime get focusedMonth => _focusedMonth;

  // Categorias inicializadas
  final List<CategoryModel> _categories = [
    CategoryModel(id: '1', name: 'Comida', iconCode: 0xe1d2, colorValue: 0xFFF44336, type: TransactionType.expense),
    CategoryModel(id: '2', name: 'Saúde', iconCode: 0xe306, colorValue: 0xFF4CAF50, type: TransactionType.expense),
    CategoryModel(id: '3', name: 'Dívidas', iconCode: 0xe4b2, colorValue: 0xFF2196F3, type: TransactionType.expense),
    CategoryModel(id: '4', name: 'Transporte', iconCode: 0xe1d1, colorValue: 0xFFFFEB3B, type: TransactionType.expense),
    CategoryModel(id: '5', name: 'Lazer', iconCode: 0xe2ad, colorValue: 0xFF9C27B0, type: TransactionType.expense),
    CategoryModel(id: '6', name: 'Salário', iconCode: 0xf051f, colorValue: 0xFF2D6A4F, type: TransactionType.income),
    CategoryModel(id: '7', name: 'Investimentos', iconCode: 0xf04b0, colorValue: 0xFF40916C, type: TransactionType.income),
    CategoryModel(id: '8', name: 'Presente', iconCode: 0xe13f, colorValue: 0xFF52B788, type: TransactionType.income),
  ];

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<CategoryModel> get categories => List.unmodifiable(_categories);

  // --- Navegação ---

  void nextMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    notifyListeners();
  }

  void previousMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    notifyListeners();
  }

  void setFocusedMonth(DateTime date) {
    _focusedMonth = DateTime(date.year, date.month, 1);
    notifyListeners();
  }

  // --- Ações ---

  void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void toggleTransactionConfirmation(String id) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      _transactions[index] = _transactions[index].copyWith(
        isConfirmed: !_transactions[index].isConfirmed,
      );
      notifyListeners();
    }
  }

  void confirmAllInPeriod(int month, int year) {
    for (int i = 0; i < _transactions.length; i++) {
      if (_transactions[i].billingDate.month == month && 
          _transactions[i].billingDate.year == year) {
        _transactions[i] = _transactions[i].copyWith(isConfirmed: true);
      }
    }
    notifyListeners();
  }

  // --- Consultas ---

  List<CategoryModel> getCategoriesByType(TransactionType type) {
    return _categories.where((c) => c.type == type).toList();
  }

  List<TransactionModel> getTransactionsByMonth(int month, int year) {
    return _transactions.where((t) {
      return t.billingDate.month == month && t.billingDate.year == year;
    }).toList();
  }

  // SALDO PREVISTO (Tudo)
  double getProjectedBalance(int month, int year) {
    final periodTransactions = getTransactionsByMonth(month, year);
    double balance = 0;
    for (var t in periodTransactions) {
      balance += (t.type == TransactionType.income ? t.value : -t.value);
    }
    return balance;
  }

  // SALDO REAL (Apenas Confirmados)
  double getRealBalance(int month, int year) {
    final periodTransactions = getTransactionsByMonth(month, year);
    double balance = 0;
    for (var t in periodTransactions) {
      if (t.isConfirmed) {
        balance += (t.type == TransactionType.income ? t.value : -t.value);
      }
    }
    return balance;
  }

  // Auxiliares para UI
  double getTotalIncomes(int month, int year, {bool onlyConfirmed = false}) {
    return getTransactionsByMonth(month, year)
        .where((t) => t.type == TransactionType.income && (!onlyConfirmed || t.isConfirmed))
        .fold(0, (sum, t) => sum + t.value);
  }

  double getTotalExpenses(int month, int year, {bool onlyConfirmed = false}) {
    return getTransactionsByMonth(month, year)
        .where((t) => t.type == TransactionType.expense && (!onlyConfirmed || t.isConfirmed))
        .fold(0, (sum, t) => sum + t.value);
  }

  void addCategory(CategoryModel category) {
    _categories.add(category);
    notifyListeners();
  }
}
