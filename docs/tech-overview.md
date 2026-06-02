# Visão Técnica — DnD Character Tool

Documento de referência para apresentar o projeto em entrevistas técnicas.

---

## Stack principal

| Camada | Tecnologia |
|--------|-----------|
| Framework | Flutter 3.x / Dart 3.x |
| Gerência de estado | Riverpod 2 (`flutter_riverpod`) |
| Navegação | GoRouter |
| Persistência local | JSON em disco (Android/iOS/Desktop) via `path_provider`; `SharedPreferences` no Web |
| Serialização | `json_serializable` + `build_runner` (code generation) |
| Internacionalização | Flutter `gen-l10n` (ARB) + camada de i18n própria para dados do SRD |
| Export/Import | `share_plus`, `file_picker`, MethodChannel nativo |
| Imagem | `image_picker`, `image_cropper` |

---

## Arquitetura

O projeto segue uma arquitetura em camadas inspirada em Clean Architecture, adaptada para Flutter mobile:

```
lib/
├── core/          # Infraestrutura transversal (router, tema, locale, utils)
├── data/
│   ├── models/        # Modelos de domínio (Character, HitPoints, AbilityScores…)
│   ├── datasources/   # Acesso a dados: local (JSON/disco) e SRD (assets JSON)
│   └── repositories/  # CharacterRepository — ponto único de acesso a personagens
├── features/      # Telas organizadas por feature (character_list, character_detail, etc.)
├── shared/        # Providers Riverpod compartilhados entre features
└── l10n/          # Arquivos ARB e classes geradas pelo gen-l10n
```

### Fluxo de dados

```
UI (Widget) → Provider (Riverpod) → Repository → DataSource → Disco/Assets
```

- A UI nunca acessa o disco diretamente — sempre via provider.
- O `CharacterRepository` isola as features do datasource concreto, facilitando testes e futura migração para backend remoto.

---

## Gerência de estado — Riverpod

- **`characterListProvider`** — `AsyncNotifierProvider` que mantém a lista de todos os personagens. Carrega do `CharacterRepository` e expõe métodos como `create`, `delete`, `updateSingle`.
- **`characterDetailProvider(id)`** — `AsyncNotifierProvider.family` parametrizado por ID. Contém toda a lógica de edição de um personagem: `adjustHp`, `toggleCondition`, `updateSavingThrows`, `updateDeathSaves`, etc. Usa _optimistic update_: atualiza o estado local imediatamente antes de persistir, evitando jank na UI.
- **`srdDataSourceProvider`** / **`srdI18nProvider`** — Providers que carregam os dados do SRD e as traduções. O `srdI18nProvider` observa o `localeProvider` e recarrega automaticamente ao trocar de idioma.
- **`themeProvider`** / **`localeProvider`** — `NotifierProvider` com estado inicial injetado via `ProviderScope.overrides` no `main()` para evitar flash de tema/idioma incorreto na inicialização.

---

## Persistência local

A camada de storage usa um padrão de **platform-conditional import** do Dart:

```dart
import 'storage_backend_stub.dart'
    if (dart.library.io)         'storage_backend_native.dart'
    if (dart.library.js_interop) 'storage_backend_web.dart';
```

- **Nativo (Android/iOS/Desktop):** cada personagem é um arquivo `.json` na pasta `ApplicationDocuments/dnd_character_tool/characters/`. Imagens ficam em `images/`. Sem banco de dados — arquivos simples facilitam backup e inspeção manual.
- **Web:** usa `SharedPreferences` (localStorage) serializado como JSON, já que não há acesso ao sistema de arquivos.

---

## Serialização — Code Generation

Os modelos usam `@JsonSerializable` com `@JsonSerializable(explicitToJson: true)` para nested objects. O `build_runner` gera os arquivos `.g.dart` com `fromJson`/`toJson`. O modelo principal `Character` tem ~30 campos, incluindo listas e objetos aninhados como `AbilityScores`, `HitPoints`, `SpellSlots`, `EquipmentItem`.

Campos adicionados manualmente ao `.g.dart` seguem o padrão de nullable com fallback:
```dart
activeConditions: (json['activeConditions'] as List<dynamic>?)
    ?.map((e) => e as String).toList() ?? const [],
```

---

## Internacionalização (i18n)

O projeto tem **duas camadas de i18n** independentes:

### 1. UI strings — Flutter gen-l10n
- 10 idiomas: en, pt, es, fr, de, it, ja, ko, ru, zh
- Arquivos `.arb` em `lib/l10n/`
- `flutter gen-l10n` gera classes tipadas em `app_localizations.dart`
- Acessado via `AppLocalizations.of(context)!`

### 2. Dados do SRD — SrdI18nService
- Os dados de jogo (nomes de magias, raças, condições, etc.) vêm de JSONs em inglês nos assets
- `SrdI18nService` carrega overlays de tradução por locale de `assets/data/i18n/{locale}/`
- Padrão: `_str('conditions', 'Blinded', 'name')` → retorna string traduzida ou `null` (fallback para inglês)
- Chaves são normalizadas para lowercase internamente (`_lowercaseKeys`)

---

## Navegação — GoRouter

Rotas declarativas com path parameters:

| Rota | Tela |
|------|------|
| `/` | Lista de personagens |
| `/character/:id` | Detalhe/edição do personagem |
| `/create` | Wizard de criação |
| `/settings` | Configurações |

Inclui `redirect` de segurança para evitar crash quando o Android/iOS passa URIs `content://` ou `file://` diretamente ao router (cenário de abertura de arquivo `.dndchar`).

---

## Export/Import — formato .dndchar

- Arquivo proprietário `.dndchar` = JSON do personagem + imagem em base64, compactado e encodado.
- **Export Android:** `share_plus` abre o seletor de compartilhamento nativo com o arquivo.
- **Import Android:** `MethodChannel` (`dnd.character/file_import`) captura intents de abertura de arquivo e emite via `IncomingFileService.fileStream` (padrão Singleton + Stream broadcast).
- **Import iOS:** `SceneDelegate` repassa a URL para o mesmo canal.
- Codificação base64 e serialização JSON são executadas em isolate separado via `compute()` para não travar a UI thread com personagens de foto grande.
- Também suporta **token de compartilhamento**: string compacta e URL-safe gerada a partir dos dados do personagem.

---

## Temas

- Múltiplos temas `ThemeData` pré-definidos em `app_themes.dart`
- `ThemeNotifier` persiste a escolha em `SharedPreferences`
- Inicializado antes do primeiro frame (`ProviderScope.overrides`) para evitar flash de tema padrão

---

## Features principais implementadas

| Feature | Detalhe técnico relevante |
|---------|--------------------------|
| **Criação de personagem** | Wizard multi-step com seleção de raça, classe, atributos, background e magias a partir dos JSONs do SRD |
| **Level Up Wizard** | Fluxo fullscreen com slide-up: HP, ASI/Feats, subclasse, magias |
| **Rastreamento de XP** | Detecção automática de level-up com guard contra race condition em taps duplos |
| **HP Tracker** | Adjust +/-, HP temporário, death saves (3 sucessos / 3 falhas) com reset automático |
| **Condições Ativas** | 15 condições SRD persistidas como `List<String>` no modelo, UI com chips + bottom sheet de detalhe |
| **Saving Throws** | Valores calculados (mod + bônus de proficiência) com layout unificado entre view e edit mode |
| **Inventário** | Seção de equipáveis separada, descrição no tap, peso de equipamento |
| **Magias** | Filtro por nível/escola, slots por nível, innate spells |
| **Notas** | Campo livre com suporte a múltiplas notas por personagem |
