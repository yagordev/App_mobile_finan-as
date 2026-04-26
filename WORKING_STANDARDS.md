# Diretrizes de Trabalho (Working Standards)

Este documento define a metodologia de desenvolvimento, comunicação e controle de qualidade para o projeto de Controle de Finanças.

## 1. Desenvolvimento Iterativo e Incremental
- As alterações serão feitas em **etapas pequenas e focadas**.
- Cada etapa deve resultar em uma versão funcional ou em um avanço lógico claro.
- Evitaremos grandes refatorações em um único turno para minimizar riscos de quebra.

## 2. Pensamento Crítico e Prevenção de Falhas
- O assistente (Gemini) deve identificar e alertar sobre possíveis pontos de falha (bugs, problemas de UX, exceções não tratadas) antes ou durante a implementação.
- Validações de entrada de dados são prioritárias.

## 3. Controle de Versão (Git)
- Após cada implementação bem-sucedida, o assistente orientará os comandos de `git` necessários.
- **Fluxo sugerido:** `git status` -> `git add .` -> `git commit -m "descrição clara"`.
- Isso garante que possamos realizar o `git checkout` para uma versão anterior se algo der errado.

## 4. Documentação e Rastreabilidade
- Todas as novas funcionalidades, modelos e lógicas devem ser documentadas nos arquivos `.md` do projeto.
- O arquivo `PROGRESS.md` deve ser atualizado constantemente.

## 5. Estratégia de Testes
- Foco inicial em lógica de validação.
- Criação e manutenção do arquivo `lib/validators.dart` para centralizar regras de negócio (ex: validação de moeda, datas, campos obrigatórios).
- Implementação de **Testes Unitários** após a estabilização das lógicas centrais para garantir que alterações futuras não quebrem o que já funciona.
