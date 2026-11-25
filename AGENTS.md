# Instruções do projeto

## Fluxo de branches

- `developer` é a branch de desenvolvimento e teste aberto. Faça as alterações
  e os commits diretamente nela e confira a branch atual antes de começar.
- `main` é a branch de lançamentos. Promova as mudanças validadas de `developer`
  para `main` quando o usuário solicitar o lançamento da versão.
- O fluxo é manual por enquanto. Não configure automações de promoção,
  publicação ou teste aberto sem uma nova solicitação do usuário.
- Ao concluir uma promoção para `main`, volte para `developer` para continuar
  o desenvolvimento.
