# D&D Character Tool

A mobile and web app for creating and managing Dungeons & Dragons 5e characters — built with Flutter.

## Features

### Character Creation
- **Guided wizard** with 7 steps: class, race, background, skills, attributes, name and review
- **Standard Array** and **Point Buy** attribute methods
- **Racial bonuses** applied automatically (PHB) or distributed freely (Tasha's / BG3 style)
- Starting equipment from background applied automatically
- Tool and instrument proficiency selection

### Character Sheet
- **Stats tab**: HP tracker (damage/heal), combat info (AC, speed, initiative), attributes and saving throws
- **Skills tab**: all 18 skills with proficiency/expertise indicators
- **Features tab**: racial traits, background feature, class features by level, extra features
- **Spells tab**: spell slots tracker, known/prepared spells, spell browser with filters
- **Inventory tab**: equipped/carried items, armor class calculation, currencies (CP/SP/EP/GP/PP)
- **Notes tab**: personality traits, ideals, bonds, flaws, backstory

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
- Export as **JSON** or compressed **token** (gzip + base64url)
- **QR code** generation and scanning (camera)
- Import by token, JSON or QR

### Customization
- 8 color themes: System Dark, System Light, Arcane, Nature, Sacred, Sea, Elven Forest, Celestial, Parchment
- Theme picker with color swatch preview

## Tech Stack

- **Flutter** 3.41 / Dart 3.11
- **State management**: flutter_riverpod
- **Navigation**: go_router
- **Persistence**: JSON files via `path_provider` (mobile) and `shared_preferences` (web)
- **Images**: image_picker + image_cropper (Android, iOS and Web via Cropper.js)
- **QR**: qr_flutter + mobile_scanner

## Platforms

| Platform | Status |
|----------|--------|
| Android  | ✅ Supported |
| iOS      | ✅ Supported |
| Web      | ✅ Supported |

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

Aplicativo mobile e web para criar e gerenciar personagens de Dungeons & Dragons 5e — feito com Flutter.

## Funcionalidades

### Criação de Personagem
- **Assistente guiado** com 7 etapas: classe, raça, antecedente, perícias, atributos, nome e revisão
- Métodos de atributos: **Standard Array** e **Point Buy**
- Bônus raciais aplicados automaticamente (PHB) ou distribuídos livremente (Tasha's / BG3)
- Equipamento inicial do antecedente aplicado automaticamente
- Seleção de proficiências em ferramentas e instrumentos

### Ficha do Personagem
- **Aba Stats**: rastreador de HP (dano/cura), informações de combate (CA, deslocamento, iniciativa), atributos e salvaguardas
- **Aba Skills**: as 18 perícias com indicadores de proficiência e expertise
- **Aba Features**: traços raciais, feature do antecedente, features de classe por nível, features extras
- **Aba Spells**: rastreador de espaços de magia, magias conhecidas/preparadas, browser de magias com filtros
- **Aba Inventory**: itens equipados/carregados, cálculo de CA por armadura, moedas (CP/SP/EP/GP/PP)
- **Aba Notes**: traços de personalidade, ideais, vínculos, fraquezas, história

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
- Exportar como **JSON** ou **token** comprimido (gzip + base64url)
- Geração e leitura de **QR Code** (câmera)
- Importar por token, JSON ou QR

### Personalização
- 8 temas de cores: System Dark, System Light, Arcane, Nature, Sacred, Sea, Elven Forest, Celestial, Parchment
- Seletor de tema com preview de swatches de cores

## Tecnologias

- **Flutter** 3.41 / Dart 3.11
- **Gerenciamento de estado**: flutter_riverpod
- **Navegação**: go_router
- **Persistência**: arquivos JSON via `path_provider` (mobile) e `shared_preferences` (web)
- **Imagens**: image_picker + image_cropper (Android, iOS e Web via Cropper.js)
- **QR**: qr_flutter + mobile_scanner

## Plataformas

| Plataforma | Status |
|------------|--------|
| Android    | ✅ Suportado |
| iOS        | ✅ Suportado |
| Web        | ✅ Suportado |

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
