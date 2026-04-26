# Análise do Projeto - Mobile (Flutter)

Este documento contém uma análise estrutural e funcional do projeto `mobile`, baseada nos arquivos presentes no diretório raiz e na pasta `lib`.

## 1. Informações Gerais do Projeto

*   **Nome:** mobile
*   **Descrição:** Um novo projeto Flutter.
*   **Versão:** 1.0.0+1
*   **SDK Dart:** `^3.11.0`

## 2. Dependências Principais

As principais dependências do projeto listadas no `pubspec.yaml` são:

*   `flutter` (SDK)
*   `cupertino_icons`: ^1.0.8
*   `google_fonts`: ^6.2.1 (Utilizado para a tipografia do projeto)

## 3. Estrutura de Pastas e Arquivos Principais

O projeto segue a estrutura padrão do Flutter:

*   `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`: Pastas de suporte para diferentes plataformas.
*   `lib/`: Contém o código-fonte Dart do aplicativo.
*   `test/`: Contém os testes do projeto.
*   `pubspec.yaml`: Arquivo de configuração de dependências e metadados.

## 4. Análise do Código-Fonte (`lib/`)

A pasta `lib` contém os seguintes arquivos:

### `app_colors.dart`
Centraliza a paleta de cores do projeto em uma classe `AppColors`.
*   **Cores definidas:** `cream` (#FEFAE0), `primaryGreen` (#4B5320), `secondaryGreen` (#676F53), `textDark` (#1B1B1B), e `cardBorder`.

### `main.dart`
Ponto de entrada do aplicativo.
*   Configura o `MaterialApp` com o tema personalizado utilizando as cores de `AppColors` e a fonte `Darker Grotesque`.
*   Define `LoginPage` como a tela inicial.

### `login_page.dart`
Implementa a tela de login.
*   **Funcionalidades:** Validação de formulário (e-mail e senha), controle de visibilidade da senha e simulação de carregamento.
*   **Navegação:** Utiliza uma transição de esmaecimento (`FadeTransition`) para ir para a `HomePage` após o login bem-sucedido.

### `home_page.dart`
Implementa o Dashboard (tela principal).
*   **Funcionalidades:** Exibe o e-mail do usuário logado, um card de boas-vindas e diversos cards de métricas (Relatórios, Tarefas, Notificações, Usuários).
*   **Navegação:** Permite o "Logout" voltando para a `LoginPage`.

## 5. Estilo Visual e UX

O projeto utiliza o **Material 3** e foca em uma estética limpa com tons de verde oliva e creme. A tipografia `Darker Grotesque` é aplicada em diferentes pesos e tamanhos para criar uma hierarquia visual clara. Os componentes (Cards, Inputs, Botões) possuem bordas arredondadas e sombras suaves, seguindo padrões modernos de design de interfaces móveis.
