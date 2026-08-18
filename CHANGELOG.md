# Changelog

All notable changes to this project will be documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Added
- **Lista de personagens**: adicionada opcao de duplicar personagem pelo menu de tres pontos, criando copia independente com novo ID, imagem propria e nome sem conflito.
- **Temas**: adicionada lista final com 10 temas: `Crimson`, `Light`, `Parchment`, `Arcane`, `Forest`, `Elven Forest`, `Sea`, `Celestial`, `Sacred` e `Shadow`.

### Changed
- **Temas**: paletas de cores redesenhadas com `ColorScheme` explicito para deixar os temas mais distintos sem alterar layout ou componentes.
- **Temas**: o tema padrao agora e `Crimson`, e os IDs internos antigos foram substituidos por nomes canonicos com fallback para o tema padrao.

### Fixed
- **Inventario**: recipientes com quantidade total zero agora exibem `Vazio` em vez de `1 item`.

---

## [2.0.0] - 2026-08-14

### Added
- **Multiclasse**: o level up agora permite escolher uma classe existente para subir de nível ou adicionar uma nova classe quando os pré-requisitos são cumpridos.
- **Pré-requisitos de multiclasse**: classes bloqueadas mostram o requisito necessário em vez de desaparecerem da lista.
- **Ficha — resumo de classes**: cabeçalho, lista de personagens e aba Identidade exibem resumo como `Wizard 3 / Cleric 2` com nível total.
- **Ficha — hit dice por classe**: a aba Stats mostra pools separados de dados de vida por classe.
- **Descanso curto — hit dice por pool**: personagens multiclasse podem gastar dados de vida do pool de classe correto.
- **Habilidades — origem por classe**: features de classe/subclasse são agrupadas por entrada de classe, com escolhas e usos ligados à origem correta.
- **Magias — spellcasting multiclass**: slots normais são calculados por nível de conjurador multiclass, mantendo Pact Magic separado para Warlock.
- **Ficha — reiniciar níveis**: novo fluxo seguro para reconstruir o personagem a partir do nível 1, com confirmação, escolha de classe inicial e reconstrução opcional pelo wizard de level up.
- **Play Store — avaliação do app**: adicionados botão manual nas configurações e pedido automático discreto após uso real do app.

### Changed
- **Level Up**: ASI, talentos, subclasse, magias, choices, HP, proficiência, slots e CA passam a ser aplicados por uma engine de progressão centralizada.
- **Level Up — fluxo mais limpo**: telas sem escolhas obrigatórias são puladas automaticamente.
- **Recursos de features**: usos como Rage, Ki, Lay on Hands e Bardic Inspiration escalam pelo nível da classe de origem, não pelo nível total do personagem.
- **Identidade**: personagens multiclasse não mostram mais controle manual cru de `+/-` de nível para evitar quebrar a soma das classes.
- **Ficha — cabeçalho**: informações grandes do personagem colapsam ao rolar a tela, deixando mais espaço para as abas.
- **Ficha — tela ligada**: configurações ganharam uma opção para impedir que a tela apague enquanto uma ficha de personagem está aberta.

### Fixed
- **Personagens antigos**: nova migração versionada reconcilia `classes`, nível total, classe/subclasse espelho, hit dice, origens de magias/features, slots e CA.
- **Warlock**: Pact Magic fica separado dos slots normais e continua restaurando no descanso curto.
- **CA**: features desativadas por origem não derrubam outra feature de mesmo nome em uma classe diferente.
- **Habilidades e inventário**: tiles expansíveis agora usam chaves de estado próprias, evitando erro visual de `double`/`bool` ao abrir seções como Características Raciais e Recipientes.
- **Personagens/importações antigas**: leitura de booleanos em JSON ficou mais tolerante a `true/false`, `1/0`, `1.0/0.0` e strings.

### Internal
- **Versionamento**: versão do app atualizada para `2.0.0+24` e `currentCharacterDataVersion` para `9`.
- **Engine de reset**: adicionada `CharacterLevelResetEngine` para aplicar respec/rebuild sem depender da UI.
- **Review do app**: adicionados `AppReviewService`, `ReviewPromptPolicy` e persistência em `SharedPreferences` para controlar quando pedir avaliação na Play Store.
- **Testes**: adicionada cobertura para progressão multiclasse, pré-requisitos, spellcasting/Pact Magic, usos por classe, CA por origem, hit dice por pool, reset/rebuild de níveis e migrações.
- **Testes — review**: adicionada cobertura para a política de pedido de avaliação, incluindo limites de abertura, tempo, cooldown e versão.
- **Documentação de arquitetura**: arquitetura atualizada com multiclasse, reset de níveis, dice engine, review Play Store, preferência de tela ligada, chaves de estado em abas e helpers de JSON.

---

## [1.1.1] - 2026-07-29

### Added
- **Ficha — rolagem de dados**: nova ação para abrir um rolador de dados direto da ficha do personagem.
- **Rolagem — expressões completas**: suporte a expressões como `1d20 + 5`, `2d6 + 1d8`, modificadores, múltiplos dados, vantagem/desvantagem e espaços opcionais na expressão.
- **Rolagem — histórico e ajuda**: o rolador mantém histórico em memória enquanto o app está aberto e inclui ajuda rápida explicando a sintaxe.

### Changed
- **Preparação para multiclasse**: personagens agora têm estrutura interna para múltiplas classes e hit dice por classe, mantendo compatibilidade com personagens single-class atuais.
- **Magias — origem e resumo agregado**: magias conhecidas passam a carregar origem e a aba Magias usa um resumo preparado para spellcasting agregado no futuro.
- **Habilidades — origem e recursos**: escolhas de features, features extras e recursos rastreáveis agora carregam contexto de origem para permitir cálculos por classe quando a multiclasse for ativada.
- **Level Up — organização interna**: estado e enums do wizard foram movidos para `application/level_up`, e o wizard virou uma biblioteca independente em vez de `part of`.
- **Ficha — ações do cabeçalho**: level up, descanso e rolagem de dados agora ficam agrupados em um único menu de ações.
- **Notas — proteção de edição**: fechar uma nota com alterações não salvas agora oferece continuar editando, descartar ou salvar.
- **Configurações — manutenção**: o fluxo de atualização de personagens agora também reporta entradas salvas inválidas, com origem/ID para diagnóstico.

### Fixed
- **Criação — slots de magia**: personagens conjuradores já nascem com slots iniciais sincronizados quando a classe recebe spellcasting no nível 1.
- **Warlock — Pact Magic**: slots de Pact Magic agora são restaurados no descanso curto.
- **CA — bônus de features**: cálculo de Armor Class agora considera Defense Fighting Style e Draconic Resilience.
- **Personagens antigos — dados derivados**: migrações versionadas sincronizam slots, CA, estrutura de classes, hit dice, origens de magias e origens de features.
- **Notas — arrastar para fechar**: arrastar o editor de nota para baixo passa pela mesma confirmação de alterações não salvas.
- **Analyzer — level up**: corrigida a importação do wizard de level up após a separação estrutural.

### Internal
- **Versionamento**: versão do app atualizada para `1.1.1+23`.
- **Engine de rolagem**: adicionados parser, modelo de expressão e roller puros em `lib/data/dice/`.
- **Ficha — modularização**: removido o uso manual de `part`/`part of` na UI de `character_detail`; tabs, sheets e widgets agora são bibliotecas Dart normais com imports explícitos.
- **Ficha — helpers estruturais**: extraídos `EditGuard`, `CharacterTabHost`, helpers de detalhe, suporte de features, helpers de exibição de inventário e tiles/listas de inventário para arquivos próprios.
- **Migrações**: adicionadas migrações versionadas v6 e v7 para preparar personagens antigos para a nova estrutura de regras.
- **Storage**: `StorageBackend` ganhou leitura diagnóstica por registro para isolar personagens corrompidos sem quebrar a manutenção em lote.
- **Feature usages**: `feature_usages.json` passa a ser a fonte canônica de usos rastreáveis; o campo `uses` foi removido dos dados de class features.
- **Testes**: adicionados testes para sync de slots/CA, preparação estrutural de multiclasse, origem de features/magias, Pact Magic, cálculos de recursos por classe e rolagem de dados.
- **Documentação de arquitetura**: arquitetura atualizada para refletir a estrutura modular da ficha e a ausência de `part of` manual em `character_detail`.

---

## [1.1.0] - 2026-07-28

### Changed
- **Inventário — busca de itens**: a busca ao adicionar itens agora pesquisa em todas as categorias SRD ao mesmo tempo, facilitando encontrar itens sem saber previamente o tipo correto.
- **Inventário — munições**: munições de pacotes como flechas agora aparecem sem o sufixo de quantidade do SRD e usam a quantidade escolhida pelo jogador ao adicionar.
- **Inventário — organização**: itens, munições e recipientes agora podem ser reordenados com alça de arrastar; ações secundárias como mover e remover ficam no menu de três pontos.
- **Inventário — conteúdo de recipientes**: itens guardados em recipientes agora abrem em uma folha dedicada, evitando listas aninhadas dentro da lista principal do inventário.
- **Notas — edição rápida**: o menu de três pontos das notas agora também permite editar a nota.
- **Ficha — performance das abas**: abas pesadas de inventário, habilidades, magias e notas foram reorganizadas para reduzir recálculos e evitar remontar listas grandes sem necessidade.
- **Inventário — base interna escalável**: regras de adicionar, remover, equipar, mover, reordenar e ajustar quantidade foram centralizadas em operações puras, reduzindo risco em futuras melhorias de mochilas.
- **Inventário — cálculo de seções**: a aba de inventário agora usa um snapshot dedicado para organizar containers, conteúdos, munições, equipados, carregados e peso total.

### Fixed
- **Inventário — munições zeradas**: ao gastar todas as munições, o item permanece no inventário com quantidade 0 para facilitar reposição futura.
- **Notas — foco da pesquisa**: tocar em notas, filtros ou ações agora tira o foco do campo de pesquisa no Android.
- **Traduções — magias e inventário**: pesquisa de magias, filtros, linhas de magia, confirmações de remoção e nomes em diálogos agora usam as traduções disponíveis em vez de textos internos do SRD.
- **Traduções — habilidades**: confirmações de remoção de ferramentas, talentos e features extras agora mostram os nomes traduzidos.

### Internal
- **Versionamento**: versão do app atualizada para `1.1.0+22`.
- **Migração de inventário**: adicionada a migração versionada `NormalizeEquipmentOrderMigration` (`dataVersion` 5) para preencher ordem explícita de itens e limpar localizações inválidas.
- **View models de abas**: providers/view models do detalhe de personagem foram separados em arquivos menores dentro de `features/character_detail/application/`.
- **Organização da UI de detalhe**: widgets compartilhados, sheets grandes do inventário, seções/sheets de habilidades e widgets auxiliares de magias foram movidos para arquivos menores.
- **Performance de listas**: inventário, magias, habilidades e notas usam snapshots/providers/slivers para reduzir trabalho no build das abas.
- **Cobertura de testes**: adicionados testes unitários para migrações, inventário, backup/importação, feature choices, usos de features, criação de personagem e busca global de itens.
- **Documentação de arquitetura**: arquitetura atualizada para descrever operações puras de inventário, snapshot/cache de busca, migração v5 e estratégia de testes.
- **Roadmap**: roadmap reorganizado para tratar as melhorias de inventário e performance como parte da versão `1.1.0` e reservar `2.0.x` para multiclasse.

---

## [1.0.6]

### Added
- **Notas — tags coloridas**: notas agora podem receber tags padrão ou personalizadas, com escolha de cor para organizar sessões, NPCs, missões, lugares, loot e regras.
- **Notas — busca e filtros**: a aba Notas ganhou pesquisa por título, conteúdo e tag, além de filtro rápido por tag.
- **Notas — fixar notas importantes**: notas podem ser fixadas no topo e aparecem em uma seção separada das demais.

### Changed
- **Notas — reordenação escalável**: a lista de notas agora usa `SliverReorderableList` com alça de arrastar, mantendo notas fixadas e não fixadas em grupos separados.
- **Personagens — reordenação escalável**: a lista de personagens também passou para `SliverReorderableList` com alça explícita de arrastar.
- **Personagens — persistência de ordem**: ao reordenar personagens, o app salva apenas os itens cujo `sortOrder` realmente mudou.
- **Documentação de arquitetura**: arquitetura atualizada para refletir notas com tags/fixação/ordem explícita, containers funcionais e o padrão novo de listas reordenáveis.

### Internal
- **Persistência de notas**: `CharacterNote` agora salva `sortOrder` para manter a ordem de forma explícita e escalável.
- **Migração de personagens**: adicionada a migração versionada `NormalizeNoteOrderMigration` (`dataVersion` 4) para preencher a ordem das notas antigas pelo fluxo de manutenção nas configurações.

---

## [1.0.5] - 2026-07-22

### Added
- **Inventário — mochilas e recipientes**: itens do tipo container agora podem guardar outros itens do inventário, com visualização do conteúdo dentro do próprio recipiente.
- **Inventário — mover itens**: itens carregados podem ser movidos para o inventário principal ou para um recipiente disponível.
- **Usos de features e recursos**: a aba Habilidades agora rastreia recursos limitados de classe, subclasse, raça e talentos, incluindo Fúria, Inspiração de Bardo, Canalizar Divindade, Forma Selvagem, Segundo Fôlego, Surto de Ação, Ki, Sentido Divino, Cura Pelas Mãos, Pontos de Feitiçaria, Dados de Superioridade, Sorte e outros usos por descanso.
- **Dados SRD de usos de features**: adicionado `feature_usages.json` com limites, recargas e custos de recursos, além de overlays traduzíveis por idioma.
- **Criação — Humano Variante**: adicionada a opção de Humano Variante com bônus +1/+1 em atributos diferentes, proficiência em perícia, idioma extra e escolha de talento no nível 1.
- **Criação — escolhas vindas de talentos**: talentos recebidos por feature, como o talento do Humano Variante, agora podem disparar suas próprias escolhas obrigatórias antes de salvar o personagem.
- **Configurações — backup de personagens**: nova área para exportar, compartilhar/baixar e importar um `.dndbackup` com todos os personagens de uma vez.
- **Configurações — importação de backups**: backups `.dndbackup` podem restaurar múltiplos personagens em uma única ação, preservando dados de personagem e imagens quando disponíveis.
- **Configurações — manutenção de personagens**: nova área para verificar personagens antigos, aplicar migrações versionadas e mostrar um relatório do que foi alterado.
- **Web — IndexedDB para personagens**: a versão web agora usa IndexedDB como storage principal de personagens, mantendo a interface `StorageBackend` compartilhada com Android/iOS.
- **Web — imagens no IndexedDB**: fotos de personagens agora são salvas no object store `images`, enquanto o personagem guarda apenas a referência local `indexeddb:image:<id>`.
- **Web — adapters de plataforma**: adicionados helpers condicionais para leitura de arquivos, imagens de avatar e payloads de imagem embutidos em `.dndchar`.
- **Web — fallback de rotas no GitHub Pages**: adicionado `404.html` para redirecionar acessos diretos a rotas internas para o app.

### Changed
- **Inventário — organização por recipientes**: itens guardados em mochilas/recipientes deixam de aparecer duplicados nas seções principais e passam a ser listados dentro do container.
- **Inventário — peso em recipientes especiais**: containers marcados para ignorar peso do conteúdo agora deixam seus itens fora do peso total carregado.
- **Avatar — limite de imagem**: fotos recortadas pelo app agora usam limite de 1024x1024 com JPEG 85 para reduzir uso de memória sem perder tanta qualidade visual.
- **Criação — bônus raciais e regra de Tasha**: distribuição de atributos raciais foi reorganizada para separar bônus fixos, escolhas livres da própria raça e a opção de redistribuição livre pela regra de Tasha.
- **Inventário inicial — kits e packs**: kits de equipamento inicial agora têm conteúdo estruturado e são adicionados como itens individuais ao criar personagens.
- **Migrações — backup preventivo**: antes de aplicar atualizações em personagens antigos, o app abre um `.dndbackup` para o usuário salvar ou compartilhar.
- **Import/export — `.dndchar` como formato principal**: `.dndchar` passa a ser o fluxo oficial para compartilhar/importar personagens individuais; JSON cru fica apenas como fallback avançado sem imagem.
- **Import/export — imagens cross-platform**: exportação de `.dndchar` e `.dndbackup` resolve imagens da Web no IndexedDB e embute `imageData`/`imageMimeType`; importações no Android e na Web recriam a imagem no storage correto.
- **PWA — metadados do app**: `index.html` e `manifest.json` agora usam nome, descrição, cor de tema e orientação adequados ao DnD Character Tool.
- **Documentação**: README e arquitetura foram atualizados para refletir IndexedDB, adapters de plataforma, `.dndchar` como formato principal e JSON cru como fallback avançado.
- **Traduções e dados SRD**: textos de equipamentos, ferramentas, usos de features, backup e manutenção foram revisados/gerados nos idiomas suportados; PT-BR recebeu revisão manual em nomes e descrições de equipamentos.
- **Versionamento**: versão do app atualizada para `1.0.5+19`.

### Fixed
- **Inventário — remoção de recipientes com conteúdo**: ao excluir uma mochila/recipiente com itens dentro, o app permite cancelar, mover o conteúdo para o inventário ou remover tudo junto.
- **Inventário — regras de armazenamento**: containers não podem ser guardados dentro de outros containers, evitando estruturas difíceis de manter por enquanto.
- **Android — recorte de avatar em telas grandes**: removida a orientação fixa da tela do cropper para melhorar compatibilidade com dispositivos grandes e dobráveis.
- **Inventário — itens antigos com peso 0**: migrações versionadas preenchem pesos de itens conhecidos salvos antes da correção dos dados.
- **Inventário — normalização de itens antigos**: itens conhecidos existentes são atualizados com tipo, categoria, peso e propriedades atuais do SRD.
- **Inventário — kits antigos**: personagens antigos que ainda tinham packs como item único podem ser migrados para receber os itens internos.
- **Configurações — área segura inferior**: tela de configurações recebeu espaçamento inferior para evitar que ações fiquem escondidas pela navegação do Android.
- **Importação Android — arquivo direto**: arquivos `.dndchar` e `.dndbackup` abertos por apps externos, como WhatsApp ou gerenciador de arquivos, agora entram no fluxo correto de importação.
- **Web — acesso direto por rota**: URLs como `/create`, `/settings` e `/character/:id` agora são restauradas antes do bootstrap do Flutter no preview hospedado.
- **Web — compatibilidade de build**: removidos imports diretos de `dart:io` de telas/datasources compartilhados, isolando APIs nativas em arquivos `_io`.
- **Fotos — troca mais segura**: ao substituir foto, o app salva a nova imagem antes de apagar a anterior, evitando perda se a gravação falhar.

### Removed
- **Import/export — token e QR**: removido o fluxo antigo de token/QR e suas strings l10n, reduzindo complexidade e mantendo `.dndchar` como caminho único confiável.

### Internal
- **Persistência de inventário**: itens agora salvam `containerId`, permitindo rastrear em qual recipiente cada item está armazenado.
- **Persistência**: personagens agora têm `dataVersion` para controlar migrações e `featureResourcesUsed` para usos rastreáveis de features.
- **Engine de recursos**: adicionada `FeatureUsageEngine` para calcular máximos, recargas e gastos a partir de dados SRD.
- **Migrações de personagem**: adicionadas migrações para preencher pesos, normalizar itens conhecidos e expandir packs.
- **Ferramentas de tradução**: `tools/translate_i18n.py` agora cobre `feature_usages.json`.

---

## [1.0.4] - 2026-07-10

### Added
- **Feature Choices**: novo sistema para registrar escolhas feitas dentro de habilidades, traços raciais e talentos. Cobre estilos de luta, metamagia, inimigos/terrenos favoritos, Pact Boon, manobras, opções do Hunter, proficiências, Magic Initiate, Martial Adept, Weapon Master e outras escolhas semelhantes.
- **Criação de personagem — escolhas de features**: o wizard de criação agora inclui escolhas obrigatórias de nível 1, raça e subraça quando elas existirem.
- **Level Up — escolhas de features**: o wizard agora inclui uma etapa dedicada para escolhas obrigatórias de features/talentos no momento em que elas são recebidas.
- **Aba Habilidades — escolhas salvas**: features, traits e talentos mostram escolhas já feitas, indicam escolhas pendentes e permitem editar posteriormente.
- **Detalhes em chips de escolha**: tocar no chip de uma escolha salva abre uma folha com a descrição da opção escolhida.
- **i18n de Feature Choices**: adicionados overlays `feature_choices.json` por idioma, lookup no `SrdI18nService` e suporte no script `tools/translate_i18n.py`.

### Changed
- **Descrições de regras**: habilidades e escolhas importantes agora mostram números e progressões diretamente, incluindo Ataque Furtivo, Fúria, Inspiração de Bardo, Artes Marciais, Movimento sem Armadura, Destruir Mortos-Vivos, Estilos de Luta, Metamágica e manobras do Battle Master.
- **Level Up — magias restritas e livres**: escolhas de magia com restrição de escola, como Eldritch Knight e Arcane Trickster, agora aparecem em seções separadas e recolhíveis, com instruções claras para magias restritas e magias livres.
- **Level Up — organização de listas de magia**: selecionar uma magia restrita não reorganiza mais a mesma lista de forma confusa; a UI mantém as opções restritas e livres separadas.
- **Aba Habilidades — cards de features**: cards de classe, subclasse, raça e talentos carregam e exibem escolhas relacionadas quando existirem.
- **Traduções PT-BR de habilidades**: termos automáticos ruins foram revisados manualmente para manter nomes e descrições mais naturais em português.
- **Roadmap**: versões futuras foram renumeradas para reservar a série `1.0.x` para correções e melhorias incrementais atuais.

### Fixed
- **Feature Choices — descrições ausentes**: opções como Fighting Style agora têm descrição exibida como subtítulo durante a escolha/edição.
- **Feature Choices — visualização posterior**: escolhas já salvas não ficam mais limitadas ao nome; a descrição pode ser consultada pelo chip na aba Habilidades.
- **Level Up — escolhas persistidas**: escolhas feitas no wizard são salvas no personagem junto com o resultado do level up.
- **i18n — metadados de novas strings**: novas chaves de interface de Feature Choices e listas de magia receberam metadata para geração correta de l10n.

### Internal
- **Persistência**: adicionado modelo `CharacterFeatureChoice` com serialização JSON.
- **Engine de escolhas**: adicionada `FeatureChoiceEngine` para calcular escolhas pendentes por classe, subclasse, raça e talento.
- **Assets**: `feature_choices.json` e `languages.json` foram registrados no `pubspec.yaml`.

---

## [1.0.3] - 2026-06-21

### Added
- **Inventário — tipos de item customizado**: formulário de criação agora muda os campos conforme o tipo escolhido, incluindo suporte a itens equipáveis genéricos e containers para futuras interações de armazenamento.
- **Inventário — detalhes completos do item**: tocar em um item abre a descrição e mostra os atributos relevantes do item, incluindo dados customizados e propriedades mecânicas.
- **Level Up — regras de Eldritch Knight e Arcane Trickster**: subclasses de Fighter/Rogue agora usam a lista de magias de Wizard com suas restrições corretas de escola.

### Changed
- **Itens mágicos equipáveis**: itens mágicos não-armadura foram ajustados para o tipo equipável, permitindo uso junto com armadura quando apropriado.
- **Inventário customizado internacionalizado**: categorias, tipos e detalhes de itens customizados foram traduzidos/internacionalizados.
- **Versionamento**: versão do app atualizada para `1.0.3+17`.

### Fixed
- **Inventário — criação de item customizado**: campos de texto não são mais reiniciados enquanto o usuário digita.
- **Inventário — salvamento ao adicionar item**: o app aguarda o item ser salvo antes de fechar a tela, evitando travamentos aparentes ao adicionar itens.
- **Inventário — consumíveis**: removida a opção redundante `consumeOnUse` do formulário de consumível.
- **Level Up — Paladino e Ranger**: classes sem truques no SRD não caem mais na tabela de cantrips de Eldritch Knight/Arcane Trickster.
- **Level Up — Eldritch Knight**: nível 3 agora oferece 2 truques e 3 magias, com pelo menos 2 magias de abjuração ou evocação.
- **Level Up — Arcane Trickster**: `Mage Hand` é tratado como truque fixo; o jogador escolhe apenas os outros truques e segue as restrições de encantamento/ilusão.
- **Level Up — escolha de subclasse**: o wizard recalcula as páginas de truques/magias imediatamente após escolher a subclasse.
- **CA — Defesa Sem Armadura na criação**: Bárbaro e Monge agora salvam a CA correta já ao criar o personagem.
- **CA — Defesa Sem Armadura ao ganhar/remover habilidades**: adicionar, remover ou desativar `Unarmored Defense` recalcula a CA automaticamente.
- **CA — revisão de criação**: a tela de revisão mostra a CA sem armadura correta para Bárbaro e Monge.

---

## [1.0.2] - 2026-06-19

### Fixed
- **Cálculo de CA (Armor Class)** — refatoração em função compartilhada `calcArmorClass`; corrige CA incorreta para Bárbaro e Monge:
  - **Bárbaro — Unarmored Defense**: CA = 10 + mod DEX + mod CON (sem armadura); escudo ainda conta
  - **Monge — Unarmored Defense**: CA = 10 + mod DEX + mod SAB (sem armadura *e* sem escudo, conforme regras do SRD)

### Added
- **Gerenciamento de proficiências de ferramentas na aba Habilidades**:
  - Botão de exclusão (com diálogo de confirmação) em cada proficiência de ferramenta listada
  - Nova aba **Ferramentas** no painel "Adicionar Habilidade" com lista pesquisável de todas as ferramentas do SRD; marca as já adicionadas com ícone de check

---

## [1.0.1] - 2026-06-10

### Added
- **Warlock — Troca de magia dedicada**: novo passo no wizard de level-up exclusivo para Warlocks, com duas seções — escolher qual magia esquecer (ou nenhuma) e, ao selecionar, escolher a substituta imediatamente na mesma tela; substituição confirmada junto com o level-up
- **Visualizador de foto — estilo WhatsApp**: foto centralizada quando menor que a tela; pan limitado às bordas reais da imagem (sem barras pretas arrastáveis); toque fora da foto fecha o visualizador, toque na foto não fecha
- **Salvar foto na galeria**: botão de download no visualizador de foto salva a imagem na galeria do dispositivo (Android/iOS) ou faz download no navegador (Web)

### Fixed
- Zoom no visualizador de foto agora preenche a tela corretamente sem distorção no primeiro frame
- Duplo toque usa âncora correta para zoom centralizado na área tocada

---

## [1.0.0] - 2026-06-10

### Added
- **Concentração** — badge "C" na magia ativa, banner de aviso ao tentar lançar segunda magia de concentração, botão para encerrar manualmente. Nome da magia exibido no idioma do app
- **Descanso Curto** — gasta Hit Dice (d + mod CON) para recuperar HP, com validação de HD disponíveis
- **Peso do inventário** — barra de carga na aba Inventário (STR × 15 lb); campo de peso ao criar itens customizados
- **Sistema de unidades** — configuração em Settings: Imperial (ft / lb), Métrico (m / kg) ou Squares (sq). Padrão pelo locale do dispositivo (`en` → Imperial, demais → Métrico). Aplicado em velocidade, peso e alcance de magias
- **Alcance de magias localizado** — distâncias convertidas pelo sistema de unidades ativo; rótulos não-numéricos (Self, Touch, Sight, Special, Unlimited) e tipos de área (sphere, cone, cube, cylinder, line, wall, circle) traduzidos nos 10 idiomas
- **Nomes de classe traduzidos** na ficha de detalhe de magia
- **Material de componente traduzido** — campo `material` das magias (ex: "a drop of blood") via JSON de i18n, fallback para inglês. Ferramenta `tools/patch_spell_material.py` para adicionar traduções sem reescrever os JSONs
- **Proteção de edição entre abas** — confirmação de descarte ao mudar de aba com edição em andamento

### Fixed
- **Android** — permissão `READ_MEDIA_IMAGES` removida; usa Photo Picker do sistema (API 33+)
- **Web — cursor pointer** nos elementos interativos: spell slots, equip/unequip, concentração, prepare toggle, avatar
- **Web — ficha de atributos** com largura máxima para evitar cards oversized em telas largas
- **Alcance de magias** — distâncias respeitam o sistema de unidades configurado

### Changed
- Código legado removido: `syncSpellSlots`, `syncInnateSpells` no init, caminhos de imagem sem prefixo


## [0.3.4] - 2026-06-03

### Fixed
- **Web — exportar `.dndchar`**: corrigido import condicional `dart.library.html` → `dart.library.js_interop` (Dart 3+); o arquivo de download agora é corretamente invocado no browser
- **Web — token de compartilhamento**: `GZipCodec` (dart:io) indisponível na web causava crash ao abrir a tela; token na web agora usa `base64url` sem compressão; importação aceita tokens com ou sem gzip (compatibilidade cruzada mobile ↔ web)
- **Cross-platform — imagem ao importar `.dndchar`**: personagens exportados no celular (imagePath como caminho de arquivo) agora preservam a foto ao serem importados na web — imagem é armazenada como data URL (`data:image/jpeg;base64,...`)
- **Cross-platform — imagem ao exportar `.dndchar` na web**: imagem já em formato data URL é corretamente lida e embutida no arquivo `.dndchar` sem usar `dart:io`

---

## [0.3.3] - 2026-06-01

### Added
- **Condições ativas**: nova seção "Condições Ativas" na aba de Atributos. Toque em "+" para abrir o seletor com as 15 condições do SRD 5e; toque num chip para ver a descrição e remover; X no chip para remover diretamente. Traduzidas em todos os 10 idiomas
- **Death saves**: rastreamento de salvaguardas de morte (3 sucessos / 3 falhas) exibido automaticamente quando os PV chegam a 0; indicadores visuais de Estabilizado e Morto; reset automático ao receber cura
- **Saving Throws — valores calculados**: a seção de Salvaguardas agora exibe as 6 habilidades sempre visíveis com o valor total (mod + bônus de proficiência), ícone cheio para proficientes e ícone vazio para os demais

### Fixed
- **Tradução PT — Prone**: "Propenso" corrigido para "Prostrado"

---

## [0.3.2] - 2026-05-22

### Added
- **Export — formato `.dndchar`**: exportar personagem (incluindo foto) para um arquivo `.dndchar` portátil, compartilhável via sistema de arquivos, WhatsApp, e-mail etc. (Android e iOS)
- **Export — Token de compartilhamento**: token compacto e URL-safe gerado a partir dos dados do personagem para compartilhamento rápido via copia/cola
- **Import — exclusividade mútua**: preencher o campo de token desabilita o campo JSON e vice-versa, evitando entrada ambígua
- **Import — dica de campo bloqueado**: tocar num campo bloqueado exibe uma mensagem explicativa fixada no fundo do dialog
- **Import — erros contextuais**: mensagens de erro distintas para "token inválido" vs. "JSON inválido"; `importErrorInvalidToken` e `importFieldLockedHint` adicionados aos 10 idiomas

### Fixed
- **Import — erro sempre dizia "JSON inválido"** mesmo quando o token era inválido; corrigido com source tagging via Dart record `({String json, String source})`
- **Import — race condition na dica de campo bloqueado**: `Future.delayed` acumulado substituído por `Timer` cancelável; duração agora consistente
- **Export — performance**: codificação base64 e serialização JSON movidas para isolate via `compute()`, evitando jank na UI em personagens com foto grande
- **i18n**: filtro de magias, botões de ação, tooltip de inventário, chip de HP temporário, abreviação de habilidade de conjuração, estado vazio de Notas e features de classe/subclasse no Level Up Wizard agora traduzidos corretamente em todos os 10 idiomas

### Internal
- Suporte a abertura de `.dndchar` via Android `MethodChannel` (`dnd.character/file_import`) e iOS `SceneDelegate`
- `importErrorInvalidJson` e `importErrorInvalidToken` são agora chaves l10n distintas em todos os 10 locales

---

## [0.3.1] - 2026-05-21

### Added
- **Inventário — seção Equipáveis**: weapons e armaduras não equipadas ficam agora numa seção própria, separada dos itens carregados
- **Inventário — descrição no tap**: itens com descrição abrem um bottom sheet com o texto completo ao serem tocados
- **Inventário — dica de equipar**: aviso sutil abaixo da seção Equipáveis orienta o usuário a tocar no ícone circular para equipar/desequipar
- **Level Up — alinhamento do secondary**: ícone "já conhecido" e botão Info agora têm o mesmo tamanho base no picker de magias

### Fixed
- Ícone de equipar (CircleAvatar) não aparece mais em itens não-equipáveis (gear, consumíveis)

---

## [0.3.0] - 2026-05-21

### Added
- **Level Up Wizard**: fluxo completo de subida de nível como rota fullscreen com transição slide-up. Cobre HP, ASI/Feats, seleção de subclasse, magias extras e features
- **Rastreamento de XP**: toggle "Rastrear XP" na seção Progressão da aba de Atributos. Quando ativo, exibe barra de progresso, campo para adicionar XP e tabela de níveis SRD 5e expansível
- **Detecção automática de level up**: ao adicionar XP suficiente para o próximo nível, um diálogo pergunta se o usuário quer subir agora ou depois. Estado pendente exibe botão "Pronto para subir de nível!"
- **Strings i18n para o wizard e XP**: 5 novas chaves (`xpTrackingLabel`, `xpReadyToLevelUp`, `xpLevelUpNowTitle`, `xpLevelUpNowMessage`, `xpLevelUpLater`) traduzidas em PT; outros 8 idiomas com fallback em inglês

### Fixed
- **Botões de ação ocultos no SpellDetailSheet em modo leitura**: botões de adicionar/remover magia não eram exibidos ao abrir a folha de detalhes a partir do wizard (modo read-only)
- **Habilidades, talentos e magias não traduzidos no wizard**: lookups de i18n corrigidos para abilities, feats e spells mostrados dentro do Level Up Wizard
- **Strings do wizard não traduzidas em 10 idiomas**: avisos do analyzer na geração de l10n corrigidos; todas as strings do wizard estão presentes nos 10 locales
- **Race condition no botão Adicionar XP**: dois taps rápidos podiam disparar dois `_addXp` simultâneos e mostrar dois diálogos. Corrigido com guard `_xpAddInProgress`
- **Perda de XP ao dizer "Depois"**: XP excedente acima do threshold era descartado. Agora o XP completo é salvo primeiro; só é travado no threshold se o usuário recusar o level up
- **Nível exibido no painel de XP**: painel usava `xpToLevel(xp)` em vez de `character.level`, causando dessincronização quando o nível foi ajustado manualmente com tracking desativado. Corrigido para usar `character.level` como fonte da verdade; barra de progresso clampada em `[0.0, 1.0]`

### Internal
- `kXpThresholds`, `xpToLevel` e `levelToMinXp` movidos para `lib/data/constants/level_up_rules.dart`
- `Character.xpTrackingEnabled` adicionado ao modelo com serialização JSON (`?? false` para retrocompatibilidade)

---

## [0.2.1] - 2026-05-21

### Added
- **Feats SRD**: `assets/data/srd/feats.json` com os 42 talentos do SRD 5.1 (Alert → Weapon Master), incluindo pré-requisitos e descrições com bullets `•`. Traduções geradas para pt, es, fr, de, it, ja, ko, ru, zh via `translate_i18n.py`
- **Stats tab — Dado de Vida**: exibido na seção de HP como "Dado de Vida: d10 × 5" (nível = quantidade de dados disponíveis). Usa `stepHitDieLabel` já traduzido em todos os idiomas
- **Botão Level Up no AppBar**: ícone de upgrade adicionado à barra de ações da ficha (placeholder — wizard completo em versão futura)

### Fixed
- **i18n — nome do subclasse em inglês na criação de personagem**: `_str()`, `_nested2()` e `_nested3()` faziam lookup de campos como `subclassFeatureName` e `higherLevels` sem lowercase, mas `_lowercaseKeys()` já havia convertido todas as chaves dos JSONs de i18n. Corrigido com `.toLowerCase()` no argumento `field` dos três helpers — "Caminho Primitivo" e outros nomes agora aparecem corretamente em todos os idiomas
- **Crítico — writes concorrentes nos focus listeners do stats_tab**: ao navegar entre campos (HP Max → Speed → XP), cada `FocusNode.addListener` ainda chamava `_notifier.updateHpMax()` individualmente após o fix do 0.2.0, gerando até 3 writes async concorrentes. Corrigido substituindo os listeners individuais por uma única função `onFocusLost()` que chama o `saveStatsEdit()` atômico
- **spells_tab — `_loadSpells()` sem tratamento de erro**: chamada fire-and-forget que falhava silenciosamente em caso de erro de leitura (disco cheio, JSON corrompido). Adicionado try/catch com `debugPrint` e guard de `mounted`
- **spells_tab — listas de magias recalculadas a cada `build()`**: `displaySpells`/`byLevel` eram reconstruídos em cada rebuild do widget (toggle de slot, mudança de HP, etc.). Movidos para estado memoizado e recalculados apenas via `didUpdateWidget` quando `character` muda
- **character_list_provider — `catch (_)` silencioso**: erros ao resolver estado atual suprimidos sem log, dificultando diagnóstico. Adicionado `debugPrint` com stack trace
- **Dialog de subclasse não traduzido ao upar/trocar**: `_showSubclassDialog` usava nome e descrição crus do SRD em inglês. Agora recebe `SrdI18nService` e exibe nomes/descrições traduzidos; valor armazenado permanece a chave inglesa
- **Aba de Notas exibia campos de personalidade**: bloco legado (`traits`, `ideals`, `bonds`, `flaws`, `backstory`) era renderizado na aba de Notas. Removido — esses campos pertencem exclusivamente à aba de Identidade
- **Sincronização de imagem lista → ficha**: imagem trocada na tela de lista não atualizava na aba de Identidade sem reiniciar o app. Corrigido com `ref.listen(characterListProvider)` no `build` do `characterDetailProvider` — qualquer atualização na lista agora propaga imediatamente para a ficha aberta
- **i18n — armaduras com sufixo não traduzidas**: `equipmentName()` agora remove sufixos `" armor"`/`" mail"` antes de retry no mapa de i18n, corrigindo "Leather armor", "Hide armor", "Plate armor" e similares que ficavam em inglês na aba de Atributos
- **Aviso na edição manual de nível**: texto informativo adicionado abaixo dos botões ± de nível no modo de edição

### Internal
- `translate_i18n.py`: adicionado extrator `extract_feats()` e locale `pt` ao `LOCALE_LANG`
- versionCode 7

---

## [0.2.0] - 2026-05-19

### Added
- **Stats tab — Painel de Progressão de XP**: barra de progresso de nível, display de nível atual, campo de adição rápida de XP com stepper e botão, tabela colapsável com todos os limiares de XP do D&D 5e
- **Stats tab — Stepper de HP**: seção de HP remodelada com linha `[−][campo][+]` para definir o valor e botões separados de Dano e Cura
- **Stats tab — Inspiração**: banner dedicado com toggle de inspiração
- **Identity tab — Personalidade e Histórico**: novas seções editáveis para Traços, Ideais, Vínculos, Defeitos e Histórico do personagem
- **Identity tab — Aparência**: botão de edição e avatar de foto diretamente na seção de aparência

### Fixed
- **Crítico — corrupção de arquivo / personagem sumindo**: `_saveEditing()` disparava até 6 writes concorrentes no mesmo arquivo JSON (3 focus-listeners + 3 chamadas explícitas). O arquivo corrompido causava o personagem sumir da lista silenciosamente. Corrigido tornando o save atômico via `saveStatsEdit()` e espelhando o padrão correto do `identity_tab` (setar `_isEditing = false` antes de `unfocus()`)
- **Crítico — i18n cross-reference quebrado**: `_lowercaseKeys()` lowercaseia todas as chaves dos JSONs de i18n, mas as lookups de classes e backgrounds usavam TitleCase (`"Barbarian"`) e camelCase (`"startingEquipment"`). Resultado: nenhum item de equipamento de classe ou background era traduzido via cross-reference. Corrigido usando `.toLowerCase()` nas lookups
- **Equipamentos de classe em inglês**: itens como `"Explorer's pack"`, `"any simple weapon"`, `"any martial melee weapon"` passaram a ser traduzidos corretamente
- **Equipamentos de background em inglês**: `"dark common clothes with hood"` e outros itens fixos de background passaram a ser traduzidos
- **Opções de kit/instrumento em inglês**: `backgroundEquipmentName()` agora consulta `equipment.json` e `tools.json` como fallback, traduzindo kits (Disguise, Forgery, Poisoner's), instrumentos (Bagpipes, Drum, etc.) e ferramentas de artesão
- **Race condition no `identity_tab`**: save da identidade tornado atômico para evitar writes concorrentes
- **Subraça no AppBar**: nome da subraça agora é exibido corretamente na barra de título
- **Padding inferior do identity tab**: ajuste de espaçamento

### Changed
- Campo de adição de XP mantém o valor após adicionar (não zera mais)
- Tradução do "Three-Dragon Ante set" simplificada para "Three-Dragon Ante" (nome próprio)
- Removido código morto: `cantripBonusDice`, `kItemType*`, `getSpellByName`, `getCantrips`, `getSpellsByLevel`, `clearCache`, `SpellSlots.remaining`

### Internal
- versionCode 6

---

## [0.1.2] - 2026-05-18

### Fixed
- Features: imagem do personagem não aparecia após ser selecionada (o path absoluto agora é guardado em vez de apenas o filename)
- Features: long-press em qualquer feature (racial, background, classe, subclasse) alterna o estado ativo/inativo sem precisar do modo de edição

### Changed
- Modo de edição: ao entrar via botão de edição a partir de uma aba sem suporte (Spells/Inventory/Notes), redireciona para Skills (tab 2) em vez de Features (tab 3)

### Internal
- versionCode 4

---

## [0.1.1] - 2026-05-18

### Added
- First official release
- 7-step character creation wizard: class, race, background, skills, attributes, name and review
- Attribute methods: Standard Array and Point Buy
- Automatic racial bonuses (PHB) or free distribution (Tasha's)
- Full character sheet with tabs: Stats, Skills, Features, Spells, Inventory, Notes
- HP tracker, spell slot tracker and feature use tracker
- Full SRD spell list with filters
- Support for prepare-all classes, subclasses and innate racial spells
- Export/Import via JSON, compressed token (gzip + base64url) and QR Code
- QR Code scanning via camera
- Pin and drag-to-reorder characters
- 8 color themes with swatch preview
- Android, iOS and Web support
- Character photo: pick from gallery and crop to 1:1
- Bilingual README (EN / PT) and proprietary LICENSE with SRD CC BY 4.0 attribution

### Fixed
- Android: corrected package namespace from `com.example` to `com.duartefrugoli.dnd_character_tool`, fixing crash on launch (ClassNotFoundException)
- Android: configured release signing with upload keystore for Play Store

### Internal
- versionCode 3 (closed testing, first functional build)

---

## [0.1.0] - 2026-05-18

### Internal
- versionCode 1–2: internal and closed testing builds with namespace bug (not distributed to users)
