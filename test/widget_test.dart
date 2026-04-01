import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('Tela de login renderiza corretamente', (WidgetTester tester) async {
    // Inicializa o app
    await tester.pumpWidget(const MyApp());

    // Verifica se os campos e botão estão presentes
    expect(find.text('Entrar'), findsWidgets);
    expect(find.byType(TextFormField), findsNWidgets(2)); // e-mail e senha
  });

  testWidgets('Exibe erro ao tentar entrar com campos vazios', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Tenta clicar em Entrar sem preencher nada
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pump();

    // Verifica mensagens de validação
    expect(find.text('Informe seu e-mail'), findsOneWidget);
    expect(find.text('Informe sua senha'), findsOneWidget);
  });

  testWidgets('Exibe erro de e-mail inválido', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Digita um e-mail sem @
    await tester.enterText(
      find.byType(TextFormField).first,
      'emailinvalido',
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pump();

    expect(find.text('E-mail inválido'), findsOneWidget);
  });

  testWidgets('Exibe erro de senha muito curta', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Digita e-mail válido e senha curta
    await tester.enterText(find.byType(TextFormField).first, 'teste@email.com');
    await tester.enterText(find.byType(TextFormField).last, '123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pump();

    expect(find.text('Senha muito curta'), findsOneWidget);
  });
}
