/// Classe central de validações de regras de negócio.
class Validators {
  /// Valida se o valor de uma transação é positivo e maior que zero.
  static String? validateValue(String? value) {
    if (value == null || value.isEmpty) {
      return 'O valor é obrigatório';
    }
    
    // Remove formatação de moeda mas mantém o sinal de menos para validação
    final cleanValue = value.replaceAll(RegExp(r'[^0-9\-,]'), '').replaceAll(',', '.');
    final doubleValue = double.tryParse(cleanValue);

    if (doubleValue == null) {
      return 'Valor inválido';
    }
    if (doubleValue <= 0) {
      return 'O valor deve ser maior que zero';
    }
    return null;
  }

  /// Valida a descrição (opcional, mas com limite de caracteres).
  static String? validateDescription(String? value) {
    if (value != null && value.length > 100) {
      return 'A descrição deve ter no máximo 100 caracteres';
    }
    return null;
  }

  /// Valida se uma categoria foi selecionada.
  static String? validateCategory(Object? value) {
    if (value == null) {
      return 'Selecione uma categoria';
    }
    return null;
  }

  /// Valida o formato de e-mail.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'O e-mail é obrigatório';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }
}
