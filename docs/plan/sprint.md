# Sprint 1 — Fundação (concluída)

Objetivo: ter o app rodando com persistência local funcional e dados do SRD disponíveis.

---

## Tarefas

### Modelos de dados
- [x] `AbilityScores`
- [x] `HitPoints`
- [x] `CharacterAppearance`
- [x] `CharacterPersonality`
- [x] `EquipmentItem`
- [x] `SpellSlots` / `KnownSpell`
- [x] `Character` (modelo principal)
- [x] Geração de `fromJson`/`toJson` via `build_runner`

### Persistência local
- [x] `CharacterLocalDataSource` — salvar/carregar/deletar JSON no disco
- [x] `CharacterRepository` — abstração sobre o datasource
- [x] Tratamento de imagem do personagem (salvar arquivo separado, referenciar por caminho)

### Assets SRD
- [x] `races.json` — 9 raças SRD com subraças e bônus de atributo
- [x] `classes.json` — 12 classes com hit die, saving throws, proficiências
- [x] `backgrounds.json` — 13 antecedentes com proficiências e equipamento inicial
- [x] `skills.json` — 18 habilidades com atributo base
- [x] `spells.json` — 20 cantrips + ~30 spells nível 1-3 do SRD
- [x] `equipment.json` — armas simples/marciais e armaduras completas
- [x] `SrdDataSource` — serviço que lê e parseia esses JSONs

### Infraestrutura do app
- [x] Configurar Riverpod (`ProviderScope` no `main.dart`)
- [x] Configurar `go_router` com rotas básicas
- [x] Tela inicial (lista de personagens vazia com botão de criar)

---

## Fora do escopo desta sprint
- Modos de criação de personagem
- Ficha detalhada do personagem
- Export / import
- UI visual final (tema, cores)

---

# Sprint 2 — Criação de personagem (planejada)

Objetivo: permitir criar um personagem completo do zero usando o modo guiado (passo a passo). Os demais modos (aleatório, semi-aleatório e manual) virão em seguida, reaproveitando a mesma estrutura.

---

## Tarefas

### Provider de rascunho
- [x] `CharacterDraftNotifier` — estado mutável do personagem em construção, limpo ao cancelar
- [x] Rota `/create` com parâmetro de modo (`?mode=guided`)

### Fluxo de criação — modo guiado (7 etapas)

**Etapa 1 — Classe**
- [x] Lista das 12 classes com hit die, saving throws e resumo de proficiências
- [x] Seleção persiste no draft

**Etapa 2 — Raça**
- [x] Lista das 9 raças SRD com bônus de atributo e traits
- [x] Se a raça tiver subraça, exibir segundo passo de seleção na mesma tela

**Etapa 3 — Antecedente (Background)**
- [x] Lista dos 13 antecedentes com descrição da feature
- [x] Perícias fixas do background aplicadas automaticamente ao draft

**Etapa 4 — Perícias**
- [x] Exibir perícias fixas do background (somente leitura)
- [x] Escolhas da classe: N perícias dentro da lista permitida por classe

**Etapa 5 — Atributos**
- [x] Usuário escolhe o método: **Standard Array** `[15,14,13,12,10,8]` ou **Point Buy** (27 pts, base 8)
- [x] Interface de distribuição dos valores nos 6 atributos
- [x] Toggle: "Aplicar bônus raciais automaticamente (PHB)" vs "Distribuir livremente (Tasha's / BG3)"
- [x] Cálculo automático dos modificadores em tempo real

**Etapa 6 — Nome**
- [x] Campos: nome do personagem e nome do jogador
- [x] Botão "Definir depois" — preenche com placeholder e segue para revisão

**Etapa 7 — Revisão**
- [x] Resumo de todas as escolhas (classe, raça, background, perícias, atributos, nome)
- [x] Exibir HP máximo calculado: `hitDie + mod CON`
- [x] Botão "Criar Personagem" → salva via `CharacterRepository.save()` e navega para a lista

### Navegação e UX
- [x] Widget `StepIndicator` com barra de progresso por etapa
- [x] Botões "Voltar" e "Continuar" com validação por etapa
- [x] Botão "Cancelar" com diálogo de confirmação antes de descartar o rascunho

### Cálculos automáticos ao salvar
- [x] `proficiencyBonus` = 2 (nível 1, fixo)
- [x] `hitPoints.maximum` = hitDie + mod CON
- [x] `savingThrowProficiencies` da classe
- [x] `skillProficiencies` consolidadas (background + escolhas da classe)
- [x] `armorClass` base = 10 + mod DEX

---

## Fora do escopo desta sprint
- Modo aleatório, semi-aleatório e manual (Sprint 3)
- Ficha detalhada / edição de personagem existente
- Seleção de equipamento e magias iniciais (listas vazias por ora)
- Foto do personagem
- Export / import

---

# Sprint 3 — Ficha do personagem (planejada)

Objetivo: após criar um personagem, o jogador consegue ver e editar sua ficha completa. Inclui navegação da lista para a ficha e rastreamento de HP/spell slots em sessão.

---

## Tarefas

### Navegação
- [x] Rota `/character/:id` no router
- [x] `onTap` do card na lista navega para `/character/:id`

### Tela de ficha (`CharacterDetailScreen`)
- [x] Carrega o personagem por ID via `CharacterRepository`
- [x] Layout com abas:
  - [x] **Stats** — Identidade, HP tracker, Combat (AC, speed, iniciativa, prof bonus, passive perc), Atributos, Saving throws
  - [x] **Skills** — lista das 18 perícias com ícone de proficiência/expertise e valor final
  - [x] **Spells** — spell slots por nível com círculos clicáveis, lista de magias conhecidas
  - [x] **Notes** — personality traits, ideals, bonds, flaws, backstory, features

### Rastreador de HP (sessão)
- [x] Botões `Damage` e `Heal` com campo de quantidade
- [x] HP temporário exibido como chip
- [x] Indicador visual de morte (HP ≤ 0 → "Unconscious / Dying")

### Rastreador de spell slots (sessão)
- [x] Círculos clicáveis por nível (tap para usar, tap novamente para restaurar)
- [x] Botão "Long Rest" — restaura HP máximo e todos os slots

### Edição básica
- [x] Editar nome do personagem (modal)
- [x] Editar nível (recalcula proficiency bonus automaticamente)
- [x] Salvar alterações via `CharacterRepository.save()`

---

## Fora do escopo desta sprint
- Edição completa da ficha (atributos, raça, classe, etc.)
- Foto do personagem
- Export / import
- i18n

---

# Sprint 4 — Inventário & Equipamentos (concluída)

Objetivo: o jogador consegue gerenciar itens, armas, armaduras e moedas do personagem na ficha. O equipamento inicial do background é aplicado automaticamente ao criar.

---

## Tarefas

### Aba Inventory na ficha
- [x] Nova aba **Inventory** no `CharacterDetailScreen` (entre Spells e Notes)
- [x] Listar itens separados em seções **Equipped** e **Carried**
- [x] Ícone de status: equipado (escudo preenchido) ou carregado (backpack)
- [x] Toggle para equipar/desequipar item (tap no ícone)
- [x] Remover item (botão lixeira)

### Adicionar itens
- [x] Botão FAB "+" abre dialog de item custom (nome, categoria, quantidade, descrição)
- [x] Aba "SRD" no dialog: busca/filtra itens de `equipment.json` e `magic_items.json`

### Cálculo de AC com armadura
- [x] Quando armadura é equipada, recalcular AC automaticamente:
  - Couro: 11 + DEX mod
  - Cota de malha: 13 + DEX mod (max +2)
  - Meia-placa: 15 + DEX mod (max +2)
  - Placa completa: 18 (sem DEX)
  - Sem armadura: 10 + DEX mod
- [x] Provider atualiza `character.armorClass` ao equipar/desequipar armadura
- [x] Exibir na aba Stats qual armadura está sendo usada

### Moedas
- [x] Campo de moedas na aba Inventory: CP / SP / EP / GP / PP
- [x] Campos editáveis inline (salva ao perder foco)
- [x] Persistido no modelo `Character` (novo campo `currency: Map<String, int>`)

### Equipamento inicial do background
- [x] Campo `startingEquipment: List<String>` em `SrdBackground` (parsear do JSON)
- [x] Ao finalizar criação (buildAndSave), adicionar itens do background como `EquipmentItem` na lista do personagem
- [x] Opção de incluir/excluir itens do background na etapa de revisão

### Dados SRD de suporte
- [x] `class_features.json` — features por nível para todas as 12 classes
- [x] `magic_items.json` — itens mágicos SRD (poções, wondrous items, armas/armaduras +1/+2/+3)
- [x] Seção `gear` adicionada a `equipment.json` (~65 itens: adventuring gear, containers, kits, munição, etc.)
- [x] Assets registrados no `pubspec.yaml`

### Provider
- [x] `addEquipmentItem(EquipmentItem)` em `CharacterDetailNotifier`
- [x] `removeEquipmentItem(String itemId)` em `CharacterDetailNotifier`
- [x] `toggleEquipped(String itemId)` em `CharacterDetailNotifier`
- [x] `updateCurrency(Map<String, int>)` em `CharacterDetailNotifier`

---

# Sprint 5 — Export/Import, Edição & Features (concluída)

Objetivo: facilitar compartilhamento/backup dos personagens, abrir edição pós-criação, e implementar a aba de Features completa.

---

## Tarefas

### Export / Import
- [x] Ação de **Export JSON** por personagem na lista
- [x] Diálogo com JSON exportado + botão para copiar para clipboard
- [x] Ação global de **Import JSON** na tela de lista
- [x] Importação com persistência e refresh automático da lista
- [x] Validar JSON de importação com mensagens de erro específicas em português
- [x] Correção de async gap no `character_list_screen` (context check após await)

### Edição livre pós-criação
- [x] Toggle de modo de edição no detail (ícone lápis no AppBar, `_editMode`)
- [x] Editar atributos com botões +/- (`_AbilityCardEdit`) — zona "other" descartada por desnecessária
- [~] Editar raça/classe/background — **descartado para v1** (custo alto, caso raro; workaround: export → edita JSON → import)

### Aba Features na ficha
- [x] Nova aba **Features** entre Skills e Spells (6 abas no total)
- [x] Seção **Racial Traits** — chips por trait de raça + subraça
- [x] Seção **Background Feature** — `ExpansionTile` com nome e descrição completa
- [x] Seção **Class Features** — cards expandíveis com badge de tipo (Active/Passive/Subclass/ASI) e info de uso (short rest / long rest)
- [x] Seção **Extra Features** — features adicionadas manualmente (multiclasse), com botão de remoção por card
- [x] Modelo `CharacterExtraFeature` — `{ sourceClass, name, level, type, description }` com `fromJson`/`toJson` manual
- [x] Serialização em `character.g.dart` atualizada manualmente para `extraFeatures`
- [x] Métodos `addExtraFeature` e `removeExtraFeature` no `CharacterDetailNotifier`

### Browser de features (Add Feature Sheet)
- [x] `_AddFeatureSheet` — `DraggableScrollableSheet` com campo de busca
- [x] Sem busca: lista agrupada por classe com sticky headers (12 classes, ordem alfabética)
- [x] Com busca: lista plana filtrando por nome e descrição em todas as classes
- [x] Tap no tile mostra descrição completa em `SnackBar`
- [x] Botão `+` adiciona feature; ícone ✓ indica feature já adicionada

### Proficiências em Ferramentas na criação guiada
- [x] Seção `_ToolProficiencySection` no review final (etapa 7)
- [x] Ferramentas fixas exibidas com ícone (ex: Charlatan → Disguise kit, Forgery kit)
- [x] Ferramentas com escolha exibem `DropdownButtonFormField` por slot:
  - Dwarf (raça) → 1 artisan's tool
  - Backgrounds (ex: Folk Hero → artisan's tool, Entertainer → instrumento)
  - Bard (classe) → 3 instrumentos musicais
  - Monk (classe) → artisan's tool ou instrumento
- [x] Seção invisível quando não há nenhuma tool proficiency
- [x] `chosenToolProficiencies: List<String>` no `CharacterDraft` — reseta ao trocar raça/background/classe
- [x] Salvo em `character.features` como `"Tool Proficiency: Smith's tools"` no `buildAndSave`

---

## Fora do escopo desta sprint
- Peso total / capacidade de carga (strength × 15)
- i18n

---

# Sprint 5.5 — Correções, Polimento & QR Code (concluída)

Objetivo: corrigir bugs acumulados das sprints anteriores, melhorar a UX do export/import e adicionar suporte a QR code.

---

## Correções de bugs

### Export / Import
- [x] **Token comprimido com gzip** — token agora é `base64url(gzip(json))`, reduzindo significativamente o tamanho para QR e clipboard
- [x] **ImportDialog crash no cancelamento** — controllers (`_tokenCtrl`, `_jsonCtrl`) movidos para o `State` e descartados no `dispose()`, evitando o erro `dependents.isEmpty is not true`
- [x] **`_resolveInput()` com fallback** — se o token for inválido, tenta usar o campo JSON diretamente; se o token não tiver gzip, aceita base64 puro como fallback

### Ficha do personagem
- [x] **Botão voltar em modo de edição** — adicionado `PopScope` + `_handleBack()` com diálogo "Sair sem salvar?"; ao confirmar, reverte o personagem para o snapshot anterior e sai do modo edição
- [x] **Saving Throws não apareciam marcados** — normalização case-insensitive em `_SavingThrowsEditorState._normalize()`: compara os valores salvos com `_kAllAbilities` sem distinção de maiúsculas/minúsculas
- [x] **`RadioListTile` deprecated** — removidas as propriedades `groupValue` e `onChanged` deprecated do diálogo de background; substituídas pelo padrão `RadioGroup<String>` ancestor correto

### Criação de personagem
- [x] **Botão de rolar ouro no review** — alterado de `FilledButton.tonal` com texto para ícone-only (`Icons.casino_outlined`), liberando espaço horizontal na linha de ouro inicial

---

## QR Code no Export

- [x] **Geração de QR** — `qr_flutter ^4.1.0` adicionado; diálogo de export exibe QR code do token quando o botão "Mostrar QR Code" é ativado
- [x] **Validação de tamanho** — `QrValidator.validate` verifica se o token cabe no QR antes de renderizar; exibe mensagem de erro se for grande demais
- [x] **Quiet zone correta** — `padding` passado diretamente ao `QrImageView` (não ao `Container` externo) para bordas brancas simétricas
- [x] **QR adaptativo** — usa `LayoutBuilder` para o QR preencher toda a largura disponível no diálogo em vez de tamanho fixo
- [x] **Tap para fullscreen** — tocar no QR abre `_QrFullscreenScreen` com fundo branco e QR em tamanho máximo, facilitando leitura por outro dispositivo

## QR Code no Import (Scanner)

- [x] **`mobile_scanner ^6.0.0`** adicionado; botão no ImportDialog abre `_QrScannerScreen` com câmera ao vivo
- [x] **Permissão de câmera** — `CAMERA` adicionado ao `AndroidManifest.xml`; `NSCameraUsageDescription` adicionado ao `ios/Runner/Info.plist`
- [x] **Resultado do scan preenchido no campo token** — após leitura bem-sucedida, o valor é colocado em `_tokenCtrl` e o `_resolveInput()` processa normalmente

---

## Documentação

- [x] `docs/notes.md` criado — notas técnicas sobre decisões de arquitetura (ex: base45 vs base64url)
- [x] `docs/models.md` atualizado — campos `currency`, `extraFeatures`, `disabledFeatures`, `notes` adicionados ao `Character`; novos modelos `CharacterExtraFeature` e `CharacterNote` documentados
- [x] `docs/sprint.md` e `docs/roadmap.md` atualizados

---

# Sprint 6 — Imagem, Magias, i18n & Temas (em andamento)

Objetivo: completar os itens restantes do v1 — imagem do personagem, browser de magias na ficha, internacionalização PT-BR/EN e seletor de tema.

> **Modos aleatório, semi-aleatório e manual descartados.** O wizard guiado é rápido o suficiente e a edição pós-criação cobre o caso de uso do modo manual. O modo aleatório pode ser revisitado no futuro — a questão em aberto é definir o quão aleatório o personagem deve ser para continuar jogável.

---

## Imagem do personagem

- [x] Botão para escolher imagem da galeria (`image_picker`)
- [x] Salvar cópia local do arquivo no diretório do app (`path_provider`)
- [x] Exibir imagem no card da lista e no topo da ficha
- [x] Botão para remover imagem

## Browser de magias (aba Spells)

- [x] `SpellcastingEngine` — attack bonus, save DC, maxPrepared, maxKnown, maxCantrips, maxSpellLevel por classe e nível
- [x] Aba Spells: banner com Attack, Save DC, Cantrips (atual/máx), Prepared ou Known por classe
- [x] Tracker de spell slots com botões usar/restaurar por nível
- [x] Lista de magias agrupada por nível com badges (escola, casting time, concentração, ritual)
- [x] Toggle de preparar por magia (apenas classes prepare, apenas level > 0)
- [x] Cantrips excluídos do contador de prepared/known e sem toggle de preparar
- [x] `SpellBrowserSheet` — busca, filtros (nível, escola, casting time, ritual, concentração, só da classe), add/remove
- [x] `SpellDetailSheet` — informações completas da magia, botão add/remove com confirmação
- [x] Swipe esquerda com `confirmDismiss` (AlertDialog antes de remover) para classes known
- [x] Remover magia pelo detail sheet com confirmação — acessível da ficha e do browser
- [x] Browser atualiza ícone de ✓ instantaneamente ao remover
- [x] Padding de `viewPadding.bottom` em todos os scrollables dentro de modal sheets

---

# Sprint 7 — Sistema de Magias Completo (branch: feature/spells-prepare-all)

Objetivo: implementar o comportamento correto para classes que conhecem todas as magias da classe (Cleric, Druid, Paladin, Artificer, Wizard), magias de subclasse always-prepared, e subclasses que adicionam magia a classes não-conjuradoras.

> Ver `docs/spells_plan.md` para detalhes de arquitetura e decisões de design.

---

## Prepare-all classes (Cleric, Druid, Paladin, Artificer, Wizard)

- [x] `disabledSpells: List<String>` no modelo `Character` + `fromJson`/`toJson`
- [x] `toggleDisabledSpell()` no `CharacterDetailNotifier`
- [x] Lista da aba Spells construída dinamicamente a partir do SRD para classes prepare-all
- [x] `character.spells` guarda apenas as magias preparadas para essas classes
- [x] Long-press numa magia ativa → AlertDialog "Desativar esta magia?" → entra em `disabledSpells`
- [x] Long-press numa magia desativada → AlertDialog "Reativar esta magia?" → sai de `disabledSpells`
- [x] Magias desativadas aparecem com `Opacity(0.35)` — sem toggle visível, sem modo de edição
- [x] FAB `+` para prepare-all — browser com prepare-all awareness: magias da classe mostram checkbox de preparar; magias fora da classe mantêm botão add
- [x] Swipe desabilitado para prepare-all (a magia sempre está na lista da classe)
- [x] Seção "Magias Extras" separada para magias fora da lista da classe (subclasse custom, etc.)
- [x] Tabelas de progressão de slots (full / half / pact) adicionadas ao `SpellcastingEngine` + getter `slotsPerLevel`
- [x] `_applySlotSync()` no provider — auto-sincroniza totais de slots ao atualizar nível do personagem
- [x] Auto-sync de slots ao abrir a aba Spells pela primeira vez (personagens antigos com totais zerados)

## Subclass always-prepared

- [x] Preencher `subclassSpells` em `spells.json` — 85 magias (7 domínios de Cleric, 3 juramentos de Paladin, 3 patronos de Warlock)
- [x] Provider injeta magias de subclasse com `isAlwaysPrepared = true` ao construir a lista (derivado, não salvo no personagem)
- [x] Magias always-prepared: sem toggle, sem swipe, sem long-press de desativar

## Extras implementados nesta sprint

- [x] "Renomear" personagem pelos 3 pontinhos na lista inicial — AlertDialog com TextField pré-preenchido com o nome atual

## Subclasses conjuradoras (Eldritch Knight, Arcane Trickster)

- [x] `SpellProgressionType.third` no enum do `SpellcastingEngine`
- [x] Tabela `_thirdSlotTable` (1/3 caster, 20 níveis, começa no nível 3)
- [x] `_thirdCasterKnown` e `_thirdCasterCantrips` — tabelas de magias conhecidas e cantrips
- [x] `SpellcastingEngine.forClass()` aceita `subclass` opcional; retorna engine para Fighter/Rogue com Eldritch Knight / Arcane Trickster

## Magias inatas raciais

- [x] `innateSpells: List<InnateSpell>` no modelo `Character`
- [x] `InnateSpell`: `name`, `usesPerDay` (null = à vontade), `usedToday`
- [x] Preencher `raceSpells` no `spells.json`
- [x] Seção "Racial Spells" na aba Spells com tracker de usos

---

# Sprint 8 — Visual & Polimento (concluída)

## Temas visuais

- [x] Tela de configurações acessível pela lista de personagens
- [x] Seletor de tema como bottom sheet (`DraggableScrollableSheet`) com preview de swatches 2×2
- [x] Swatch corrigido: `Container` fixo 22×22 px por célula (primary / secondary / tertiary / surface)
- [x] 8 temas: `system_dark`, `system_light`, `arcane`, `nature` (light), `sacred`, `sea`, `elven_forest`, `celestial`, `parchment`
- [x] Parchment: `surfaceColor` override via `colorScheme.copyWith()` para fundo bege real
- [x] IDs de tema todos em inglês (migração automática para usuários com IDs antigos)
- [x] Persistência da escolha via `shared_preferences`
- [x] `ThemeNotifier` controlado por provider global

## Imagem do personagem

- [x] `CharacterAvatar` widget reutilizável (`lib/shared/widgets/character_avatar.dart`)
- [x] Exibe foto (`FileImage`) se `imagePath` definido, senão exibe letra inicial
- [x] Tap no avatar abre bottom sheet: "Choose photo" / "Remove photo" / "Cancel"
- [x] Pick da galeria via `image_picker`; crop 1:1 via `image_cropper` (JPEG 85%)
- [x] Opção "Change photo" também nos 3 pontinhos do card (popup menu)
- [x] `updateImage(id, path?)` no `CharacterListNotifier` persiste no JSON
- [x] `UCropActivity` declarada no `AndroidManifest.xml`; permissões `READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE` adicionadas
- [x] try-catch no pick e no crop — falha silenciosa, sem crash

## Pin e reordenação

- [x] `isPinned: bool` e `sortOrder: int` no modelo `Character` (serialização com fallback `false`/`0`)
- [x] `togglePin()` e `reorder()` (otimista — sem flash) no `CharacterListNotifier`
- [x] `ReorderableListView.builder` na lista de personagens
- [x] Pin badge no avatar; opções "Pin to top" / "Unpin" nos 3 pontinhos
- [x] Ordem: pinados primeiro → sortOrder → createdAt

## Android

- [x] Ícone adaptativo com foreground transparente (`ic_launcher_foreground.png`) e background preto
- [x] `values-v31/styles.xml` com `windowSplashScreenBackground`, `windowSplashScreenAnimatedIcon` e `windowSplashScreenIconBackgroundColor` (elimina retângulo branco no splash)

---

# Sprint 9 — Internacionalização (em andamento)

Objetivo: suporte completo a Português (pt-BR) e Inglês (en), com idioma persistido e padrão seguindo o sistema.

## Infraestrutura

- [x] Adicionar `flutter_localizations` e `intl` ao `pubspec.yaml`
- [x] Criar `l10n.yaml` na raiz (aponta para `lib/l10n/`, classe `AppLocalizations`)
- [x] Ativar `generate: true` no `pubspec.yaml`
- [x] Criar `lib/l10n/app_en.arb` (strings em inglês — source of truth)
- [x] Criar `lib/l10n/app_pt.arb` (tradução pt-BR)
- [x] Registrar `localizationsDelegates` e `supportedLocales` no `MaterialApp`

## Provider de locale

- [x] `LocaleNotifier extends Notifier<Locale?>` + `localeProvider` (padrão: `null` = sistema)
- [x] Salvar/carregar `'selected_locale'` via `shared_preferences` (valores: `'en'`, `'pt'`, ou ausente)
- [x] Passar `locale: ref.watch(localeProvider)` no `MaterialApp`

## Configurações

- [x] Seção "Language" nas configurações com opções: System default / English / Português
- [x] Bottom sheet com ícone de check na opção atual
- [x] Persistência via `shared_preferences`

## Strings a extrair (~6 arquivos principais)

- [ ] `character_list_screen.dart` — labels do popup menu, diálogos rename/delete, snackbars
- [ ] `settings_screen.dart` — títulos, label do tema, nomes dos temas no picker
- [ ] `character_detail_screen.dart` — títulos de abas, botões HP/slots, Long Rest
- [ ] `character_creation/` — labels de etapas, botões, validações
- [ ] `spell_browser_sheet.dart` — filtros, badges de escola/casting time
- [ ] Diálogos globais — Export, Import, QR scanner

---

# Sprint 10 — Beta Testing

Objetivo: distribuir o app para testadores externos e corrigir os bugs encontrados antes do lançamento.

## Build & distribuição

- [ ] Build de release Android (`.apk` ou `.aab`)
- [ ] Distribuição via Firebase App Distribution ou arquivo direto
- [ ] Checklist de smoke test para os testadores (criação, ficha, magias, export/import, tema, foto, pin)

## Bugs e feedback

- [ ] Canal de reporte (formulário / grupo)
- [ ] Triagem e priorização dos bugs reportados
- [ ] Ciclo de correção + nova build até estabilidade

## Critérios de saída

- [ ] Nenhum crash reproduzível nos fluxos principais
- [ ] Feedback de UX incorporado ou documentado para versões futuras