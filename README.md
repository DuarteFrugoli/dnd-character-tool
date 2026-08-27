# DnD Character Tool

A cross-platform app for creating and managing DnD 5e characters — built with Flutter.

[![Get it on Google Play](https://img.shields.io/badge/Google%20Play-Download-green?logo=google-play)](https://play.google.com/store/apps/details?id=com.duartefrugoli.dnd_character_tool)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.11.5-0175C2?logo=dart&logoColor=white)
![Version](https://img.shields.io/badge/version-2.0.1-orange)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web-lightgrey)
![License](https://img.shields.io/badge/License-Proprietary-red)
[![Tests](https://github.com/DuarteFrugoli/dnd-character-tool/actions/workflows/test.yml/badge.svg)](https://github.com/DuarteFrugoli/dnd-character-tool/actions/workflows/test.yml)

## Features

### Character Creation
- **Guided wizard** — class, race, background, skills, attributes, identity and review
- **Standard Array** and **Point Buy** attribute methods
- Racial bonuses can use fixed SRD rules or the optional Tasha-style free assignment
- Variant Human support with ability choices, skill proficiency, extra language and level-1 feat
- Class/background starting equipment, packs and starting gold choices resolved during review
- Feature, feat, tool and instrument choices are collected before the character is saved

### Character Sheet

**Stats tab**
- HP tracker with damage / heal buttons, AC, speed and initiative
- Saving Throws with calculated values (mod + proficiency bonus)
- Inspiration banner
- XP tracking with progress bar and auto level-up detection
- Death Saves (auto-shown at 0 HP) — tracks successes, failures, Stabilized and Dead states
- Active Conditions — 15 SRD conditions with descriptions; add/remove via chip picker
- Short Rest — spend Hit Dice to recover HP
- Concentration tracker — badge on active spell, warning on second attempt, manual end button
- Character actions menu for level up, rests and dice rolling
- Optional setting to keep the Android screen awake while a character sheet is open

**Skills tab** — all 18 skills with proficiency/expertise indicators, calculated bonuses and per-character display organization

**Features tab** — racial traits, background feature, class features by level, SRD feats, extra features, editable feature choices and limited-use resource tracking

**Spells tab** — spell slots tracker, Pact Magic short-rest recovery, concentration tracking, known/prepared spells, level shortcuts and spell browser with filters

**Inventory tab** — global SRD item search, equipped/carried/container sections, armor class calculation, encumbrance bar, currencies (CP/SP/EP/GP/PP), tappable item details, reorderable items, ammunition handling and custom item creation with type-specific fields (weapon, armor, equippable, container, consumable, ammunition, gear)

**Identity tab** — character photo (pick from gallery, crop 1:1, full-screen viewer with zoom/pan and save to gallery), personality traits, ideals, bonds, flaws, backstory

**Notes tab** — free-form notes with colored tags, search, tag filters, pinning, manual ordering and unsaved-change confirmation

### Level Up Wizard
- Full level-up flow as a fullscreen modal with step indicators
- Multiclass support: level an existing class or add a new class when prerequisites are met
- Multiclass spell slots combine full, half and third caster levels while keeping Warlock Pact Magic separate
- Steps: new class features, subclass selection, ASI / Feat choice, HP roll or average, cantrip/spell selection, spell swap (Warlocks), summary
- **Warlock spell swap** — dedicated step: choose which known spell to forget, then immediately pick the replacement in the same screen
- Eldritch Knight and Arcane Trickster spell choices respect Wizard-list and school-restriction rules
- **XP tracking** — optional toggle; quick-add field; full SRD XP table; auto prompt when XP threshold is reached
- Safe level reset/rebuild flow for restarting class progression from level 1

### Dice Roller
- Roll expressions such as `1d20 + 5`, `2d6 + 1d8` and advantage/disadvantage checks
- Optional spaces in expressions
- In-memory history while the app is open
- Help sheet explaining the supported syntax

### Spell System
- Full SRD spell list with school, casting time, concentration and ritual badges
- Prepare-all classes (Cleric, Druid, Paladin): dynamic prepared list from SRD
- Wizard uses a spellbook/manual known-spell flow instead of preparing the entire class list
- Subclass always-prepared spells (domains, oaths, patrons)
- Eldritch Knight and Arcane Trickster (⅓ caster) support
- Innate racial spells with daily use tracker

### Character Management
- Pin characters to the top of the list
- Drag to reorder
- Rename, delete and export per character
- Character maintenance flow in Settings for applying versioned data updates
- Backup export/import for all characters at once
- Manual Play Store rating action in Settings, plus a rare automatic in-app review request after real app usage

### Export & Import
- Export as **`.dndchar`** portable file (includes photo), shareable via the system share sheet
- Export raw **JSON** as an advanced copy/paste fallback
- Export/import **`.dndbackup`** files for all characters
- Import by `.dndchar` file or raw JSON
- Cross-platform: characters exported on mobile import correctly on web and vice-versa
- Web stores characters and character images in IndexedDB; native platforms store local JSON/image files

### Customization
- **12 color themes**: Classic Dark, Crimson, Light, Parchment, Arcane, Forest, Elven Forest, Sea, Celestial, Eclipse, Sacred, Shadow
- **Unit system** — Imperial (ft / lb), Metric (m / kg) or Squares; applied to movement speed, carry weight and all distances throughout the app; defaults to device locale

### Internationalization
- **10 languages**: English, Portuguese, German, Spanish, French, Italian, Japanese, Korean, Russian, Chinese
- UI strings via ARB / `AppLocalizations`
- SRD content (spell names/descriptions/materials, class features, races, items, conditions, feats) via locale overlay JSONs in `assets/data/i18n/`

## Tech Stack

| Layer | Library |
|---|---|
| Framework | Flutter 3.x / Dart 3.11.5 |
| State management | flutter_riverpod 2 |
| Navigation | go_router |
| Persistence | path_provider (mobile) + IndexedDB (web) |
| Serialization | json_serializable + json_annotation |
| Images | image_picker + image_cropper |
| Gallery save | gal |
| Export / Import | share_plus + file_picker |
| Web file download | package:web (dart:js_interop) |
| Store review | in_app_review + package_info_plus |
| UI utilities | flutter_sticky_header, uuid, collection |


## Platforms

| Platform | Status |
|---|---|
| Android | ✅ Supported — [Google Play](https://play.google.com/store/apps/details?id=com.duartefrugoli.dnd_character_tool) |
| iOS | ✅ Supported |
| Web | ⚠️ [Preview (GitHub Pages)](https://duartefrugoli.github.io/dnd-character-tool/) |

## Getting Started

```bash
flutter pub get
flutter run
```

## Documentation

- [Technical Architecture](docs/ARCHITECTURE.md) explains state management, persistence, SRD data loading, inventory item types, notes, dice rolling, level-up rules, review prompts, display preferences, maintenance migrations and import/export flows.
- [Changelog](CHANGELOG.md) tracks release history.

> All DnD 5e content uses the **System Reference Document (SRD)** under the Creative Commons license.

## License

© 2026 Pedro Frugoli. All rights reserved.

Except where otherwise stated, this project is proprietary. See [LICENSE](./LICENSE) for details.

Translation files in `assets/data/i18n/` are licensed under CC BY 4.0, and translation contributions are welcome.

This project includes material from the Dungeons & Dragons System Reference Document 5.1 (“SRD 5.1”) by Wizards of the Coast LLC, licensed under CC BY 4.0.

This project is not affiliated with, endorsed, sponsored, or specifically approved by Wizards of the Coast LLC.

---

# DnD Character Tool (Português)

Aplicativo multiplataforma para criar e gerenciar personagens de DnD 5e — feito com Flutter.

## Funcionalidades

### Criação de Personagem
- **Assistente guiado** com etapas de classe, raça, antecedente, perícias, atributos, identidade e revisão
- Métodos de atributos: **Standard Array** e **Point Buy**
- Bônus raciais por regras fixas do SRD ou distribuição livre no estilo da regra opcional de Tasha
- Suporte a Humano Variante com escolhas de atributos, perícia, idioma extra e talento no nível 1
- Equipamentos iniciais, kits/packs e escolhas de ouro resolvidos na revisão
- Escolhas de features, talentos, ferramentas e instrumentos antes de salvar o personagem

### Ficha do Personagem

**Aba Stats**
- Rastreador de HP com botões de Dano e Cura, CA, deslocamento e iniciativa
- Salvaguardas com valores calculados (mod + bônus de proficiência)
- Banner de Inspiração
- Rastreamento de XP com barra de progresso e detecção automática de level up
- Salvaguardas de Morte (exibidas ao chegar a 0 PV) — rastreia sucessos, falhas, Estabilizado e Morto
- Condições Ativas — 15 condições do SRD com descrições; adicionar/remover via chip picker
- Descanso Curto — gastar Hit Dice para recuperar PV
- Rastreador de Concentração — badge na magia ativa, aviso ao tentar uma segunda magia de concentração, botão para encerrar manualmente
- Menu de ações da ficha para subir de nível, descansar e rolar dados
- Opção para manter a tela do Android ligada enquanto uma ficha está aberta

**Aba Skills** — 18 perícias com indicadores de proficiência/expertise, bônus calculados e organização visual por personagem

**Aba Features** — traços raciais, feature do antecedente, features de classe por nível, talentos do SRD, features extras, escolhas editáveis e rastreamento de recursos com usos limitados

**Aba Spells** — rastreador de espaços de magia, recuperação de Pact Magic no descanso curto, concentração, magias conhecidas/preparadas, atalhos de nível e browser de magias com filtros

**Aba Inventory** — busca global de itens SRD, seções de equipados/carregados/containers, cálculo de CA por armadura, barra de carga, moedas (CP/SP/EP/GP/PP), detalhes ao tocar, itens reordenáveis, suporte a munição e criação de itens customizados com campos por tipo (arma, armadura, equipável, container, consumível, munição, equipamento geral)

**Aba Identity** — foto do personagem (escolher da galeria, cortar 1:1, visualizador em tela cheia com zoom/pan e salvar na galeria), traços de personalidade, ideais, vínculos, fraquezas, história

**Aba Notes** — notas livres com tags coloridas, busca, filtros por tag, fixação, ordenação manual e confirmação de alterações não salvas

### Subida de Nível
- Fluxo completo de level up como modal em tela cheia com indicadores de passo
- Suporte a multiclasse: subir uma classe existente ou adicionar uma nova quando os pré-requisitos são cumpridos
- Slots de magia multiclasse combinam níveis de conjurador completo, meio e terço, mantendo Pact Magic de Warlock separado
- Passos: features novas, seleção de subclasse, ASI / Talento, rolagem de HP, escolha de truques/magias, troca de magia (Warlocks), resumo
- **Troca de magia do Warlock** — passo dedicado: escolha qual magia esquecer e em seguida escolha a substituta na mesma tela
- Escolhas de magia de Eldritch Knight e Arcane Trickster respeitam lista de Wizard e restrições de escola
- **Rastreamento de XP** — toggle opcional; campo de adição rápida; tabela completa de XP do SRD; prompt automático ao atingir o threshold
- Fluxo seguro para reiniciar/reconstruir níveis a partir do nível 1

### Rolagem de Dados
- Expressões como `1d20 + 5`, `2d6 + 1d8` e rolagens com vantagem/desvantagem
- Espaços opcionais nas expressões
- Histórico em memória enquanto o app está aberto
- Ajuda rápida explicando a sintaxe aceita

### Sistema de Magias
- Lista completa de magias do SRD com badges de escola, tempo de conjuração, concentração e ritual
- Classes prepare-all (Cleric, Druid, Paladin): lista de preparação dinâmica do SRD
- Wizard usa fluxo de spellbook/magias conhecidas manualmente, em vez de preparar a lista inteira da classe
- Magias always-prepared de subclasse (domínios, juramentos, patronos)
- Suporte a Eldritch Knight e Arcane Trickster (⅓ conjurador)
- Magias inatas raciais com rastreador de usos diários

### Gerenciamento de Personagens
- Fixar personagens no topo da lista
- Reordenar arrastando
- Renomear, excluir e exportar por personagem
- Fluxo de manutenção nas configurações para aplicar atualizações versionadas nos personagens
- Backup geral para exportar/importar todos os personagens de uma vez
- Ação manual para avaliar na Play Store nas configurações, além de pedido automático raro após uso real do app

### Export & Import
- Exportar como arquivo **`.dndchar`** portátil (inclui foto), compartilhável via sistema de compartilhamento do dispositivo
- Exportar **JSON** cru como fallback avançado de copiar/colar
- Exportar/importar arquivos **`.dndbackup`** com todos os personagens
- Importar por arquivo `.dndchar` ou JSON cru
- Cross-platform: personagens exportados no celular importam corretamente na web e vice-versa
- Na web, personagens e imagens ficam no IndexedDB; nas plataformas nativas, ficam em arquivos JSON/imagem locais

### Personalização
- **12 temas de cores**: Classic Dark, Crimson, Light, Parchment, Arcane, Forest, Elven Forest, Sea, Celestial, Eclipse, Sacred, Shadow
- **Sistema de unidades** — Imperial (ft / lb), Métrico (m / kg) ou Quadrados; aplicado a deslocamento, peso e todas as distâncias no app; padrão conforme o locale do dispositivo

### Internacionalização
- **10 idiomas**: Inglês, Português, Alemão, Espanhol, Francês, Italiano, Japonês, Coreano, Russo, Chinês
- Strings da UI via ARB / `AppLocalizations`
- Conteúdo SRD (nomes/descrições/materiais de magias, features de classe, raças, itens, condições, talentos) via JSONs de overlay em `assets/data/i18n/`

## Tecnologias

| Camada | Biblioteca |
|---|---|
| Framework | Flutter 3.x / Dart 3.11.5 |
| Gerenciamento de estado | flutter_riverpod 2 |
| Navegação | go_router |
| Persistência | path_provider (mobile) + IndexedDB (web) |
| Serialização | json_serializable + json_annotation |
| Imagens | image_picker + image_cropper |
| Salvar na galeria | gal |
| Export / Import | share_plus + file_picker |
| Download web | package:web (dart:js_interop) |
| Avaliação na loja | in_app_review + package_info_plus |
| Utilitários de UI | flutter_sticky_header, uuid, collection |

## Plataformas

| Plataforma | Status |
|---|---|
| Android | ✅ Suportado — [Google Play](https://play.google.com/store/apps/details?id=com.duartefrugoli.dnd_character_tool) |
| iOS | ✅ Suportado |
| Web | ⚠️ [Preview (GitHub Pages)](https://duartefrugoli.github.io/dnd-character-tool/) |

## Como rodar

```bash
flutter pub get
flutter run
```

## Documentação

- [Arquitetura técnica](docs/ARCHITECTURE.md) explica gerenciamento de estado, persistência, dados SRD, tipos de item do inventário, notas, rolagem de dados, regras de level up, pedidos de avaliação, preferências de tela, migrações de manutenção e fluxos de import/export.
- [Changelog](CHANGELOG.md) registra o histórico de versões.

> Todo o conteúdo de DnD 5e utiliza o **System Reference Document (SRD)** sob a licença Creative Commons.

## Licença

© 2026 Pedro Frugoli. Todos os direitos reservados.

Exceto quando indicado de outra forma, este projeto é proprietário. Consulte [LICENSE](./LICENSE) para mais detalhes.

Os arquivos de tradução em `assets/data/i18n/` são licenciados sob CC BY 4.0, e contribuições de tradução são bem-vindas.

Este projeto inclui material do System Reference Document 5.1 (“SRD 5.1”) de Dungeons & Dragons, da Wizards of the Coast LLC, licenciado sob CC BY 4.0.

Este projeto não é afiliado, endossado, patrocinado ou especificamente aprovado pela Wizards of the Coast LLC.
