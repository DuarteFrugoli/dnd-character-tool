# D&D Character Tool

A mobile app for creating and managing Dungeons & Dragons 5e characters — built with Flutter.

[![Get it on Google Play](https://img.shields.io/badge/Google%20Play-Open%20Beta-green?logo=google-play)](https://play.google.com/store/apps/details?id=com.duartefrugoli.dnd_character_tool)
![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart&logoColor=white)
![Version](https://img.shields.io/badge/version-0.3.3-orange)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS-lightgrey)
![License](https://img.shields.io/badge/License-Proprietary-red)
[![Tests](https://github.com/DuarteFrugoli/dnd-character-tool/actions/workflows/test.yml/badge.svg)](https://github.com/DuarteFrugoli/dnd-character-tool/actions/workflows/test.yml)

## Features

### Character Creation
- **Guided wizard** with 7 steps: class, race, background, skills, attributes, name and review
- **Standard Array** and **Point Buy** attribute methods
- **Racial bonuses** applied automatically (PHB) or distributed freely (Tasha's / BG3 style)
- Starting equipment from background applied automatically
- Tool and instrument proficiency selection

### Character Sheet
- **Stats tab**: HP tracker with damage/heal buttons, AC, speed, initiative; Saving Throws with calculated values; Inspiration banner; XP tracking with progress bar and level-up detection; Death Saves (auto-shown at 0 HP); Active Conditions picker with 15 SRD conditions
- **Skills tab**: all 18 skills with proficiency/expertise indicators and calculated bonuses
- **Features tab**: racial traits, background feature, class features by level, 42 SRD feats, extra features
- **Spells tab**: spell slots tracker, known/prepared spells, spell browser with filters
- **Inventory tab**: equipped/carried items, armor class calculation, currencies (CP/SP/EP/GP/PP)
- **Identity tab**: appearance (photo + crop), personality traits, ideals, bonds, flaws, backstory
- **Notes tab**: free-form notes per character

### Level Up
- **Level Up Wizard**: full level-up flow (HP roll, ASI/Feats, subclass selection, extra spells, class features)
- **XP tracking**: optional toggle with progress bar, quick-add field and full SRD XP table
- **Auto level-up prompt**: dialog when accumulated XP reaches the next threshold

### Spell System
- Full SRD spell list with school, casting time, concentration and ritual badges
- Prepare-all classes (Cleric, Druid, Paladin, Artificer, Wizard): dynamic list from SRD with long-press to disable
- Subclass always-prepared spells (domains, oaths, patrons)
- Eldritch Knight and Arcane Trickster (⅓ caster) support
- Innate racial spells with daily use tracker

### Character Management
- Pin characters to the top of the list
- Drag to reorder
- Rename, delete and export per character
- Character photo: pick from gallery, crop 1:1

### Export & Import
- Export as **`.dndchar`** portable file (includes photo), shareable via the system share sheet
- Export as **JSON** or compressed **token** (gzip + base64url)
- Import by `.dndchar` file, token or JSON

### Customization
- 9 color themes: System Dark, System Light, Arcane, Nature, Sacred, Sea, Elven Forest, Celestial, Parchment
- Theme picker with color swatch preview

### Internationalization
- 10 languages: English, Portuguese, German, Spanish, French, Italian, Japanese, Korean, Russian, Chinese
- UI strings via ARB / `AppLocalizations`; SRD content (spell names, class features, races, items, conditions) via locale overlay JSONs in `assets/data/i18n/`

## Tech Stack

- **Flutter** 3.41 / Dart 3.11
- **State management**: flutter_riverpod 2
- **Navigation**: go_router
- **Persistence**: JSON files via `path_provider` (mobile) and `shared_preferences` (web)
- **Serialization**: json_serializable + json_annotation (code-gen)
- **Images**: image_picker + image_cropper (Android, iOS and Web via Cropper.js)
- **QR**: qr_flutter + mobile_scanner
- **Export/Import**: share_plus + file_picker
- **UI utilities**: flutter_sticky_header, uuid, collection

## Platforms

| Platform | Status |
|----------|--------|
| Android  | ✅ Supported |
| iOS      | ✅ Supported |
| Web      | ⚠️ Not available |

## Getting Started

```bash
flutter pub get
flutter run
```

> All D&D 5e content uses the **System Reference Document (SRD)** under the Creative Commons license.

## License

© 2026 Pedro Frugoli. All Rights Reserved.

Unauthorized copying, distribution or use of this software is strictly prohibited.
See [LICENSE](LICENSE) for details.

**Translation contributions** (`assets/data/i18n/`) are licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) — contributions are welcome! By submitting a translation you agree to license it under CC BY 4.0.

> D&D 5e SRD content used under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) © Wizards of the Coast LLC.

---

# D&D Character Tool (Português)

Aplicativo mobile para criar e gerenciar personagens de Dungeons & Dragons 5e — feito com Flutter.

## Funcionalidades

### Criação de Personagem
- **Assistente guiado** com 7 etapas: classe, raça, antecedente, perícias, atributos, nome e revisão
- Métodos de atributos: **Standard Array** e **Point Buy**
- Bônus raciais aplicados automaticamente (PHB) ou distribuídos livremente (Tasha's / BG3)
- Equipamento inicial do antecedente aplicado automaticamente
- Seleção de proficiências em ferramentas e instrumentos

### Ficha do Personagem
- **Aba Stats**: rastreador de HP com botões de Dano e Cura, CA, deslocamento, iniciativa; Salvaguardas com valores calculados; banner de Inspiração; rastreamento de XP com barra de progresso e detecção de level up; Salvaguardas de Morte (exibidas automaticamente ao chegar a 0 PV); seletor de Condições Ativas com 15 condições do SRD
- **Aba Skills**: 18 perícias com indicadores de proficiência/expertise e bônus calculados
- **Aba Features**: traços raciais, feature do antecedente, features de classe por nível, 42 talentos do SRD, features extras
- **Aba Spells**: rastreador de espaços de magia, magias conhecidas/preparadas, browser de magias com filtros
- **Aba Inventory**: itens equipados/carregados, cálculo de CA por armadura, moedas (CP/SP/EP/GP/PP)
- **Aba Identity**: aparência (foto + corte), traços de personalidade, ideais, vínculos, fraquezas, história
- **Aba Notes**: notas livres por personagem

### Subida de Nível
- **Level Up Wizard**: fluxo completo de level up (rolagem de HP, ASI/Talentos, seleção de subclasse, magias extras, features de classe)
- **Rastreamento de XP**: toggle opcional com barra de progresso, campo de adição rápida e tabela completa de XP do SRD
- **Detecção automática de level up**: diálogo ao acumular XP suficiente para o próximo nível

### Sistema de Magias
- Lista completa de magias do SRD com badges de escola, tempo de conjuração, concentração e ritual
- Classes prepare-all (Cleric, Druid, Paladin, Artificer, Wizard): lista dinâmica do SRD com pressão longa para desativar
- Magias always-prepared de subclasse (domínios, juramentos, patronos)
- Suporte a Eldritch Knight e Arcane Trickster (⅓ conjurador)
- Magias inatas raciais com rastreador de usos diários

### Gerenciamento de Personagens
- Fixar personagens no topo da lista
- Reordenar arrastando
- Renomear, excluir e exportar por personagem
- Foto do personagem: escolher da galeria, cortar em 1:1

### Export & Import
- Exportar como arquivo **`.dndchar`** portátil (inclui foto), compartilhável via sistema de compartilhamento do dispositivo
- Exportar como **JSON** ou **token** comprimido (gzip + base64url)
- Importar por arquivo `.dndchar`, token ou JSON

### Personalização
- 9 temas de cores: System Dark, System Light, Arcane, Nature, Sacred, Sea, Elven Forest, Celestial, Parchment
- Seletor de tema com preview de swatches de cores

### Internacionalização
- 10 idiomas: Inglês, Português, Alemão, Espanhol, Francês, Italiano, Japonês, Coreano, Russo, Chinês
- Strings da UI via ARB / `AppLocalizations`; conteúdo SRD (nomes de magias, features de classe, raças, itens, condições) via JSONs de overlay em `assets/data/i18n/`

## Tecnologias

- **Flutter** 3.41 / Dart 3.11
- **Gerenciamento de estado**: flutter_riverpod 2
- **Navegação**: go_router
- **Persistência**: arquivos JSON via `path_provider` (mobile) e `shared_preferences` (web)
- **Serialização**: json_serializable + json_annotation (geração de código)
- **Imagens**: image_picker + image_cropper (Android, iOS e Web via Cropper.js)
- **QR**: qr_flutter + mobile_scanner
- **Export/Import**: share_plus + file_picker
- **Utilitários de UI**: flutter_sticky_header, uuid, collection

## Plataformas

| Plataforma | Status |
|------------|--------|
| Android    | ✅ Suportado |
| iOS        | ✅ Suportado |
| Web        | ⚠️ Indisponível |

## Como rodar

```bash
flutter pub get
flutter run
```

> Todo o conteúdo de D&D 5e utiliza o **System Reference Document (SRD)** sob a licença Creative Commons.

## Licença

© 2026 Pedro Frugoli. Todos os direitos reservados.

É proibida a cópia, distribuição ou uso não autorizado deste software.
Veja [LICENSE](LICENSE) para mais detalhes.

**Contribuições de tradução** (`assets/data/i18n/`) são licenciadas sob [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) — contribuições são bem-vindas! Ao enviar uma tradução você concorda em licenciá-la sob CC BY 4.0.

> Conteúdo SRD de D&D 5e utilizado sob [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) © Wizards of the Coast LLC.
