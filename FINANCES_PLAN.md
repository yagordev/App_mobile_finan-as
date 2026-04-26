# Plano de Transformação: App de Controle de Finanças (Versão Sênior)

Este documento detalha as etapas para transformar o projeto atual em um sistema de gestão financeira, com foco em lógica de negócio e interface.

## 1. Objetivo do Aplicativo
Controle financeiro simples através de registros de receitas e despesas, com validações rigorosas e relatórios mensais.

## 2. Requisitos Técnicos e Regras de Negócio

### A. Regras de Validação (Obrigatórias)
- **Moeda:** Exclusivo para BRL (Real Brasileiro).
- **Valores:** Devem ser sempre positivos.
- **Datas:** 
    - `date`: Data real da transação.
    - `billingDate`: Data de faturamento (essencial para cartões de crédito).
- **Categorias:** Obrigatórias.
- **Descrições:** Máximo de 100 caracteres.

### B. Gestão de Estado (In-Memory)
- Utilizaremos `Provider` para gerenciar as listas de transações e categorias durante a sessão.

### C. Interface (UX)
- Formatação automática de moeda (R$) enquanto o usuário digita.
- Feedback visual claro para sucesso ou erro em operações.

---

## 3. Etapas de Implementação (Foco em UI e Lógica)

### Passo 1: Infraestrutura de Validação e Modelos
- Criação do `lib/validators.dart` com testes de lógica.
- Modelagem de `Transaction` e `Category`.

### Passo 2: Funcionalidades Core (Serviços e Providers)
- Lógica de cálculo de saldo total, total de receitas e total de despesas.
- Lógica de agrupamento por categoria.

### Passo 3: Desenvolvimento de Telas
- Home customizada com resumo financeiro.
- Formulário de cadastro com validações em tempo real.

### Passo 4: Relatórios e Filtros
- Implementação de filtros temporais (mês/ano) baseados no estado em memória.
