# Changelog

All notable changes to this project will be documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

---

## [0.3.5] - 2026-06-10

### Added
- **Sistema de unidades** — configuração em Settings: Imperial (ft / lb), Métrico (m / kg) ou Squares (sq/lb|kg). Padrão determinado pelo locale do dispositivo (`en` → Imperial, demais → Métrico). Aplicado em velocidade (Speed), peso do inventário e alcance de magias
- **Alcance de magias localizado** — distâncias convertidas pelo sistema de unidades ativo; nomes não-numéricos (Self, Touch, Sight, Special, Unlimited) e tipos de área (sphere, cone, cube, cylinder, line, wall, circle) traduzidos nos 10 idiomas
- **Nomes de classe traduzidos** na ficha de magia — "bard, cleric" agora aparece no idioma do app
- **Material de componente traduzido** — campo `material` das magias traduzido via JSON de i18n com fallback para inglês. Ferramenta `tools/patch_spell_material.py` adiciona traduções de material sem reescrever os JSONs existentes
- **Proteção de edição entre abas** — ao tentar mudar de aba enquanto em modo de edição, exibe confirmação de descarte

### Fixed
- **Web — cursor pointer** nos elementos interativos: spell slots, equip/unequip, concentração, prepare toggle, avatar do personagem
- **Web — ficha de atributos** com largura máxima para evitar cards oversized em telas largas
- **Alcance de magias na ficha** — distâncias agora respeitam o sistema de unidades configurado (regressão da v0.3.x)

### Changed
- **Versão 0.3.5** — Open Beta na Play Store


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
