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

Ordem macro planejada:

1. `1.x`: ficha base, inventario, notas, web e qualidade de vida.
2. `2.0.x`: multiclasse, reset seguro de progressao, polimento visual inicial
   e compatibilidade Android/Play Console.
3. `2.1.x`: fechamento do rework visual e rolagem contextual.
4. `2.2.x`: D&D 2024 / SRD 5.2.1 como modo de regras separado.
5. `3.0.x`: GM Local vitalicio, com ferramentas offline de mestre e homebrew
   local.
6. `3.1.x`: GM Pro por assinatura, com conta, cloud, comunidade e creditos de
   IA.
7. `4.x`: mesa/campanha online mais completa.

---

## Serie 1.x - Fundacao do app

### 1.0.0 - Ficha jogavel em mesa
- [x] Rastreamento de HP, HP temporario, death saves, inspiracao e condicoes.
- [x] Concentracao de magias com aviso ao tentar manter duas magias.
- [x] Descanso curto e longo com recuperacao de HP, hit dice, slots e recursos.
- [x] Peso do inventario, capacidade de carga e sistema de unidades.
- [x] Internacionalizacao de interface, magias, unidades e termos principais.
- [x] Ajustes de UX para web e protecao contra descarte acidental de edicoes.

### 1.0.1 - Foto e level up de Warlock
- [x] Visualizador de foto com zoom/pan.
- [x] Salvar foto na galeria/download.
- [x] Troca de magia dedicada para Warlock no level up.

### 1.0.2 - CA e ferramentas
- [x] Calculo compartilhado de Armor Class.
- [x] Defesa Sem Armadura correta para Barbaro e Monge.
- [x] Gerenciamento de proficiencias de ferramentas na aba Habilidades.

### 1.0.3 - Inventario customizado e subclasses magicas
- [x] Formulario de item customizado por tipo mecanico.
- [x] Itens equipaveis genericos e containers como tipos de item.
- [x] Detalhes completos de item ao tocar no inventario.
- [x] Regras de magia para Eldritch Knight e Arcane Trickster.
- [x] Correcoes de cantrips/magias no level up.

### 1.0.4 - Feature Choices
- [x] Sistema de escolhas em features, racial traits e feats.
- [x] Escolhas obrigatorias na criacao e no level up.
- [x] Visualizacao e edicao posterior das escolhas na aba Habilidades.
- [x] Descricoes localizadas para opcoes como Fighting Style e manobras.
- [x] Listas separadas para magias restritas/livres de Eldritch Knight e
      Arcane Trickster.

### 1.0.5 - Web, backups, migracoes e recursos de features
- [x] Backup/importacao `.dndbackup` para todos os personagens.
- [x] Manutencao de personagens com migracoes versionadas acionadas pelas
      Configuracoes.
- [x] Formato `.dndchar` como caminho principal de compartilhamento individual.
- [x] IndexedDB na web para personagens e imagens.
- [x] Fallback de rotas para GitHub Pages.
- [x] Usos de features e recursos por descanso na aba Habilidades.
- [x] Humano Variante e regra de Tasha revisados na criacao.
- [x] Kits/packs de equipamento inicial expandidos para itens individuais.
- [x] Containers funcionais no inventario, sem container dentro de container.

### 1.0.6 - Notas e ordenacao escalavel
- [x] Tags coloridas em notas.
- [x] Busca por titulo, conteudo e tags.
- [x] Fixar notas importantes.
- [x] Reordenacao escalavel de notas e personagens com alca de arrastar.
- [x] Ordem explicita persistida em notas e personagens.

### 1.1.0 - Inventario escalavel, performance e cobertura de testes
- [x] Busca global ao adicionar item, sem depender da categoria escolhida.
- [x] Municoes de pacote aparecem sem sufixo SRD como `(20)`.
- [x] Municao zerada permanece no inventario.
- [x] Reordenacao de itens, municoes e containers no inventario.
- [x] Acoes secundarias de inventario movidas para menu de tres pontos.
- [x] Containers/mochilas guardam itens, mostram conteudo e respeitam a regra
      atual de nao guardar container dentro de container.
- [x] Ao excluir container com conteudo, o app permite cancelar, mover os itens
      para o inventario ou excluir tudo junto.
- [x] Operacoes puras de inventario para adicionar, remover, equipar, mover,
      reordenar e ajustar quantidade.
- [x] Snapshot dedicado para secoes, containers, conteudos e peso total.
- [x] Conteudo de containers aberto em bottom sheet, sem lista aninhada na
      lista principal do inventario.
- [x] View models derivados por aba e arquivos menores em
      `features/character_detail/application/`.
- [x] Abas de inventario, habilidades, magias e notas reorganizadas com
      providers/slivers/keep-alive para reduzir rebuilds pesados.
- [x] Widgets e sheets grandes do detalhe separados em arquivos menores.
- [x] Migracao v5 para ordem explicita de inventario.
- [x] Testes unitarios para inventario, migracoes, feature choices, feature
      usages, criacao de personagem, busca de inventario e backup/importacao.

### 1.1.1 - Preparacao para multiclasse
- [x] Estrutura interna de classes por personagem com `CharacterClassEntry`.
- [x] Hit dice por classe com `CharacterHitDiePool`.
- [x] Origem explicita em magias conhecidas, features extras e escolhas de
      features.
- [x] Resumo agregado de spellcasting para preparar slots combinados.
- [x] Resumo agregado de features por origem.
- [x] Calculo de recursos de features por contexto de origem/classe.
- [x] Sincronizacao de slots e CA na criacao, level up, edicao manual e
      migracoes.
- [x] Pact Magic restaurado em descanso curto.
- [x] CA considerando Defense Fighting Style e Draconic Resilience.
- [x] Diagnostico de personagens invalidos no fluxo de manutencao.
- [x] Wizard de level up separado de `part of` e com estado isolado.
- [x] Confirmacao ao fechar notas com alteracoes nao salvas.

---

## Serie 2.x - Regras modernas e rolagens

### 2.0.0 - Multiclasse jogavel
- [x] Escolher qual classe sobe de nivel.
- [x] Adicionar uma nova classe com validacao de pre-requisitos.
- [x] Escolher subclasse no nivel correto da classe adicionada.
- [x] Aplicar ASI, talentos, features, spells e choices pelo nivel da classe
      alvo.
- [x] Atualizar HP, hit dice, proficiencia, recursos derivados e XP pelo nivel
      correto.
- [x] Escolher explicitamente quais pools de hit dice gastar no descanso curto.
- [x] Calcular slots combinados do PHB para full, half e third casters.
- [x] Manter Pact Magic separado para Warlock.
- [x] Exibir origem da magia quando houver mais de uma classe conjuradora.
- [x] Header, lista, Identidade e Stats mostram resumo/pools de classes.
- [x] Aba Habilidades agrupa features por classe/subclasse.
- [x] Migracoes versionadas normalizam classes, hit dice, origens, slots e CA.
- [x] Remover edicao manual crua de nivel da ficha.
- [x] Reiniciar niveis com confirmacao, nova classe inicial e rebuild opcional
      pelo wizard de level up.
- [x] Testes unitarios para hit dice por pool, proficiencias de multiclasse e
      reset/rebuild.
- [x] Configuracao para manter a tela ligada enquanto a ficha esta aberta.
- [x] Pedido discreto de avaliacao na Play Store apos uso real do app, com
      botao manual nas Configuracoes.

### 2.0.1 - Polimento visual e revisao da ficha
- [x] Lista final com 12 temas e paletas mais distintas.
- [x] Tema High Contrast renomeado para Eclipse, mantendo as cores.
- [x] Tela inicial, Configuracoes, cabecalho e barra de abas com identidade
      visual renovada.
- [x] Duplicar personagem pelo menu de tres pontos.
- [x] Avatar da lista mais resistente a recarregamentos ao voltar da ficha.
- [x] Organizacao da aba Pericias por atributo, proficientes primeiro ou ordem
      alfabetica, com ordem customizavel dos atributos.
- [x] Atalhos por nivel na aba Magias.
- [x] Ajustes no pedido automatico de avaliacao da Play Store.
- [x] Revisao da criacao com detalhes de itens, dano de armas, propriedades e
      conteudo de packs.
- [x] Correcoes em importacao/exportacao de imagens, recipientes vazios,
      descricoes de magias, textos tecnicos e sistema de unidades.

### 2.0.2 - Compatibilidade Android 15 e Play Console

Objetivo: lancar uma versao tecnica curta para resolver os avisos de
edge-to-edge da Play Console antes de continuar a `2.1.0`.

- [x] Habilitar edge-to-edge corretamente na `MainActivity` para compatibilidade
      com Android 15/API 35 e versoes anteriores.
- [x] Revisar temas Android nativos para remover ou evitar parametros
      descontinuados de status/navigation bar.
- [x] Conferir se telas principais, bottom sheets e formularios respeitam as
      areas seguras em navegacao por gestos e por tres botoes.
- [x] Testar manualmente em Android real antes do envio.
- [x] Atualizar versao para `2.0.2+26` e changelog.
- [x] Preparar notas curtas da Play Store se a versao for enviada para
      producao.

### 2.1.0 - Fechamento visual e rolagem contextual

Objetivo: fechar a renovacao visual iniciada em `2.0.1` e transformar o
rolador em uma ferramenta integrada a ficha.

- [ ] Finalizar ajustes visuais pendentes nas abas do personagem.
- [ ] Revisar consistencia visual entre tela inicial, ficha, sheets e
      Configuracoes.
- [ ] Melhorar microinteracoes e estados vazios que ainda parecam antigos.
- [x] Rolador manual com expressoes, ajuda rapida e historico em memoria.
- [ ] Toggle para habilitar/desabilitar dados virtuais.
- [ ] Rolar atributo, pericia, saving throw, iniciativa e ataque a partir da
      ficha.
- [ ] Rolar dano de arma e magias com base nos dados existentes.
- [ ] Criar presets contextuais por personagem sem poluir a ficha.
- [ ] Preparar estrutura futura para bonus temporarios em CA, iniciativa,
      deslocamento e outros valores derivados.

### 2.2.0 - D&D 2024 / SRD 5.2.1

Objetivo: suportar a versao moderna de D&D como modo de regras separado, sem
misturar silenciosamente com personagens criados no SRD atual.

- [ ] Definir `ruleset` do personagem: `5e_2014` e `5e_2024`.
- [ ] Separar catalogos SRD por ruleset sem duplicar toda a infraestrutura.
- [ ] Adicionar dados do SRD 5.2.1: classes, subclasses, especies, backgrounds,
      feats, magias, equipamentos e regras necessarias.
- [ ] Adaptar criacao de personagem para escolher o ruleset antes das listas.
- [ ] Ajustar level up/progressao para regras de 2024 quando aplicavel.
- [ ] Garantir que personagens antigos continuem como `5e_2014`.
- [ ] Adicionar testes de progressao e criacao para os dois rulesets.
- [ ] Atualizar textos de UI para deixar claro qual ruleset esta em uso.

---

## Serie 3.x - Produto GM

Objetivo: transformar ferramentas de mestre em produto pago separado, mantendo
a ficha de jogador generosa e offline.

### 3.0.0 - GM Local

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

### 3.1.0 - GM Pro

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
