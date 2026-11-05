# Roadmap

Este documento resume a direcao do app por versao. Ele nao substitui o
`CHANGELOG.md`: aqui entram apenas os blocos grandes de produto e arquitetura.

Principios atuais:

- A ficha de jogador continua generosa: personagens ilimitados, uso offline,
  importacao/exportacao e recursos essenciais sem travas artificiais.
- Recursos de mestre entram como produto pago porque economizam tempo e criam
  valor extra, sem punir quem so quer jogar com a propria ficha.
- Recursos com custo recorrente, como nuvem, comunidade e IA, ficam em plano
  por assinatura.
- Recursos locais/offline de mestre entram como compra unica vitalicia, porque
  nao dependem de servidor ou custo mensal para funcionar.
- IA deve usar creditos: o Pro pode incluir uma pequena cota mensal, mas uso
  pesado e imagens precisam pagar o proprio custo com creditos extras.
- Conteudo publico de comunidade e IA exigem backend, politicas, denuncia e
  moderacao antes de serem lancados.
- Quando houver iOS/web pagos, compras feitas por Play Billing, StoreKit ou web
  checkout devem virar direitos de uso na conta do usuario, para evitar logica
  duplicada por plataforma.

### 3.0.0 - D&D 2024 / SRD 5.2.1

Objetivo: suportar a versao moderna de D&D como modo de regras separado, sem
misturar silenciosamente com personagens criados no SRD atual.

- [x] Definir os IDs `rulesetId` (`dnd_2014` e `dnd_2024`) e
      `contentPackId` (`srd_5_1` e `srd_5_2_1`) no modelo do personagem.
- [ ] Separar catalogos SRD por ruleset sem duplicar toda a infraestrutura.
- [ ] Concluir e revisar os dados e traducoes do SRD 5.2.1: classes,
      subclasses, especies, antecedentes, talentos, magias, equipamentos e
      regras necessarias. Os catalogos em ingles ja estao preparados.
- [ ] Adaptar criacao de personagem para escolher o ruleset antes das listas.
- [ ] Ajustar level up/progressao para regras de 2024 quando aplicavel.
- [ ] Garantir que personagens antigos continuem como `5e_2014`.
- [ ] Adicionar testes de progressao e criacao para os dois rulesets.
- [ ] Atualizar textos de UI para deixar claro qual ruleset esta em uso.

---

## Serie 3.1+x - Produto GM

Objetivo: transformar ferramentas de mestre em produto pago separado, mantendo
a ficha de jogador generosa e offline.

### 3.1.0 - GM Local

Objetivo: criar a primeira camada paga de mestre como compra unica vitalicia,
focada em recursos offline e sem custo recorrente obrigatorio para o app.

Modelo de negocio planejado:

- GM Local vitalicio: compra unica mais cara para desbloquear os recursos locais
  sem cloud, comunidade publica ou IA ilimitada.

Escopo de produto:

- [ ] Estrutura de licenca premium local via Play Billing.
- [ ] Tela "Mestre" separada da ficha de jogador.
- [ ] Criacao local de homebrews: itens, magias, features, feats, especies,
      backgrounds, subclasses e classes quando a base estiver pronta.
- [ ] Importar/exportar pacotes de homebrew por arquivo.
- [ ] Gerenciar pacotes instalados: listar, ver fonte, desativar/remover.
- [ ] Usar homebrew nas listas de criacao, ficha, inventario e magias.
- [ ] Marcar visualmente conteudo homebrew e sua origem.
- [ ] Monstros/NPCs salvos localmente.
- [ ] Geradores locais simples para NPCs, encontros, loot e notas de sessao.

### 3.2.0 - GM Pro

Objetivo: adicionar recursos com custo recorrente real usando assinatura mais
cara que o GM Local.

- [ ] Conta de usuario e backend.
- [ ] Sistema de direitos por conta para reconhecer compras vindas do Android,
      iOS e web quando essas plataformas forem suportadas.
- [ ] Sync em nuvem de personagens, campanhas, notas, imagens e homebrews.
- [ ] Resolucao de conflitos entre dispositivos.
- [ ] Compartilhar personagem/campanha por link.
- [ ] Publicar homebrews em biblioteca da comunidade.
- [ ] Denunciar, ocultar, bloquear e moderar conteudos/usuarios da comunidade.
- [ ] Fila administrativa para revisar denuncias e conteudos escondidos.
- [ ] IA com creditos mensais para historia, NPCs, encontros, loot e descricoes.
- [ ] Geracao de imagem por IA com limite separado ou creditos extras.
- [ ] Pacotes de creditos extras para uso pesado de IA.
- [ ] Relatorio dentro do app para conteudo ofensivo gerado por IA.

---

## Serie 4.x - Mesa compartilhada e ferramentas avancadas

Objetivo: expandir para uma experiencia de mestre e mesa online sem perder a
base offline do app.

### 4.0.0 - Campanhas compartilhadas
- [ ] Campanhas com jogadores convidados.
- [ ] Jogadores entram e controlam seus proprios personagens.
- [ ] Permissoes por jogador/personagem.
- [ ] Sincronizacao simples de HP, condicoes, recursos e notas compartilhadas.

### 4.1.0 - Grid 2D simples
- [ ] Grid de batalha 2D leve, com tokens de personagens, NPCs e monstros.
- [ ] Medidas, posicao, iniciativa e estados simples.
- [ ] Funcionar bem em tablet, web e mobile.

### 4.2.0 - Ferramentas de encontro
- [ ] Encontros salvos por campanha.
- [ ] Monstros prontos e homebrew.
- [ ] Iniciativa compartilhada.
- [ ] Loot e recompensas aleatorias.

---

## Ideias futuras

- Notas de campanha com sessoes, links internos e templates avancados.
- Acessibilidade: tamanho de fonte, contraste e navegacao por teclado/web.
- Companheiros, montarias, familiares e summons recorrentes.
- Biblioteca publica de conteudo aprovado/destacado.
- Suporte a outros sistemas de RPG alem de D&D 5e.
