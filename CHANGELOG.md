# Changelog

All notable changes to this project will be documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

---

## [0.3.0] - 2026-05-21

### Added
### Fixed
### Internal

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
