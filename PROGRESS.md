# Progresso da Implementação - App de Finanças

## Legenda
- [ ] Pendente
- [/-] Em andamento
- [x] Concluído

---

## 1. Infraestrutura e Lógica de Base
- [x] Atualizar `pubspec.yaml` (intl, provider).
- [x] Criar `lib/validators.dart` con lógica de validação de moeda e campos.
- [ ] Implementar Testes Unitários para as validações.
- [x] Criar `lib/models/category_model.dart` e `lib/models/transaction_model.dart`.

## 2. Gerenciamento de Estado (Funções)
- [ ] Criar `lib/providers/finance_provider.dart` com lógica de saldo e filtros.
- [ ] Implementar funções de Adição, Edição e Exclusão.

## 3. Interface (UI)
- [ ] Criar Widget de input financeiro com máscara de moeda.
- [ ] Implementar tela de Cadastro de Transação.
- [ ] Redesenhar a `HomePage` para exibir dados reais do Provider.
- [ ] Criar tela de Relatórios com filtros de mês.

## 4. Polimento e Documentação
- [ ] Documentar funções internas no código.
- [ ] Revisar fluxos de navegação e transições de tela.
