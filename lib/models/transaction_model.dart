enum TransactionType { income, expense }

enum PaymentMethod { cash, pix, creditCard, debitCard, bankSlip }

class TransactionModel {
  final String id;
  final double value;
  final DateTime date; // Data em que a compra foi feita
  final DateTime billingDate; // Data em que o gasto será contabilizado (fatura/caixa)
  final String? description;
  final String categoryId;
  final TransactionType type;
  final PaymentMethod paymentMethod;
  final bool isConfirmed; // Status de confirmação (fluxo de caixa)

  TransactionModel({
    required this.id,
    required this.value,
    required this.date,
    required this.billingDate,
    this.description,
    required this.categoryId,
    required this.type,
    required this.paymentMethod,
    this.isConfirmed = false,
  });

  /// Retorna o nome amigável do método de pagamento
  String get paymentMethodName {
    switch (paymentMethod) {
      case PaymentMethod.cash: return 'Dinheiro';
      case PaymentMethod.pix: return 'Pix';
      case PaymentMethod.creditCard: return 'Cartão de Crédito';
      case PaymentMethod.debitCard: return 'Cartão de Débito';
      case PaymentMethod.bankSlip: return 'Boleto Bancário';
    }
  }

  TransactionModel copyWith({
    String? id,
    double? value,
    DateTime? date,
    DateTime? billingDate,
    String? description,
    String? categoryId,
    TransactionType? type,
    PaymentMethod? paymentMethod,
    bool? isConfirmed,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      value: value ?? this.value,
      date: date ?? this.date,
      billingDate: billingDate ?? this.billingDate,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}
