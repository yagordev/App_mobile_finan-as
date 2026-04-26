import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/validators.dart';

void main() {
  group('Validators - Email', () {
    test('Deve retornar erro se e-mail for vazio', () {
      expect(Validators.validateEmail(''), 'O e-mail é obrigatório');
      expect(Validators.validateEmail(null), 'O e-mail é obrigatório');
    });

    test('Deve retornar erro se e-mail for inválido', () {
      expect(Validators.validateEmail('usuario'), 'E-mail inválido');
      expect(Validators.validateEmail('usuario@'), 'E-mail inválido');
      expect(Validators.validateEmail('usuario@dominio'), 'E-mail inválido');
    });

    test('Deve retornar null para e-mail válido', () {
      expect(Validators.validateEmail('teste@exemplo.com'), null);
    });
  });

  group('Validators - Valor Financeiro (BRL)', () {
    test('Deve retornar erro se o valor for vazio', () {
      expect(Validators.validateValue(''), 'O valor é obrigatório');
    });

    test('Deve retornar erro para valores não numéricos', () {
      expect(Validators.validateValue('abc'), 'Valor inválido');
    });

    test('Deve retornar erro para valores menores ou iguais a zero', () {
      expect(Validators.validateValue('0'), 'O valor deve ser maior que zero');
      expect(Validators.validateValue('-10'), 'O valor deve ser maior que zero');
    });

    test('Deve aceitar valores válidos em formato BRL', () {
      expect(Validators.validateValue('10,50'), null);
      expect(Validators.validateValue('1.250,00'), null);
      expect(Validators.validateValue('R\$ 50,00'), null);
    });
  });

  group('Validators - Descrição', () {
    test('Deve aceitar descrição vazia (opcional)', () {
      expect(Validators.validateDescription(''), null);
      expect(Validators.validateDescription(null), null);
    });

    test('Deve retornar erro se passar de 100 caracteres', () {
      final longa = 'a' * 101;
      expect(Validators.validateDescription(longa), 'A descrição deve ter no máximo 100 caracteres');
    });

    test('Deve aceitar descrição com menos de 100 caracteres', () {
      expect(Validators.validateDescription('Compra de mercado'), null);
    });
  });

  group('Validators - Categoria', () {
    test('Deve retornar erro se nenhuma categoria for selecionada', () {
      expect(Validators.validateCategory(null), 'Selecione uma categoria');
    });

    test('Deve retornar null se uma categoria (objeto) for fornecida', () {
      expect(Validators.validateCategory(Object()), null);
    });
  });
}
