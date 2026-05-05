# Modelos de Dados (`lib/data/models/`)

Todos os modelos são classes Dart imutáveis com suporte a `copyWith`, `fromJson` e `toJson` (gerado pelo `json_serializable`). Os arquivos `.g.dart` são gerados automaticamente — nunca edite-os manualmente.

Para regenerar após alterar um modelo:
```
dart run build_runner build --delete-conflicting-outputs
```

---

## `AbilityScores`

Os 6 atributos base de D&D 5e.

| Campo | Tipo | Padrão |
|---|---|---|
| `strength` | `int` | 10 |
| `dexterity` | `int` | 10 |
| `constitution` | `int` | 10 |
| `intelligence` | `int` | 10 |
| `wisdom` | `int` | 10 |
| `charisma` | `int` | 10 |

**Getters calculados:** `strengthModifier`, `dexterityModifier`, etc. — usam a fórmula `floor((score - 10) / 2)`.

Suporta acesso por nome via operador `[]`: `scores['strength']`.

---

## `HitPoints`

| Campo | Tipo | Descrição |
|---|---|---|
| `maximum` | `int` | HP máximo do personagem |
| `current` | `int` | HP atual |
| `temporary` | `int` | HP temporário (padrão: 0) |

**Getters:** `isDead` (current ≤ 0 e temporary ≤ 0), `effective` (current + temporary).

---

## `CharacterAppearance`

Aparência física do personagem.

| Campo | Tipo |
|---|---|
| `age` | `int?` |
| `height` | `String` |
| `weight` | `String` |
| `eyes` | `String` |
| `skin` | `String` |
| `hair` | `String` |

---

## `CharacterPersonality`

Os 4 pilares de personalidade do D&D 5e.

| Campo | Tipo |
|---|---|
| `traits` | `String` |
| `ideals` | `String` |
| `bonds` | `String` |
| `flaws` | `String` |

---

## `EquipmentItem`

Um item no inventário do personagem.

| Campo | Tipo | Descrição |
|---|---|---|
| `name` | `String` | Nome do item |
| `category` | `String` | Ex: `"weapon"`, `"armor"`, `"gear"` |
| `quantity` | `int` | Quantidade (padrão: 1) |
| `description` | `String?` | Descrição opcional |
| `isEquipped` | `bool` | Se está equipado no momento |
| `properties` | `Map<String, dynamic>?` | Propriedades extras (dano, peso, etc.) |

---

## `SpellSlots`

Espaços de magia do personagem. Índice 0 = nível 1, índice 8 = nível 9.

| Campo | Tipo | Descrição |
|---|---|---|
| `total` | `List<int>` | Total de slots por nível (9 posições) |
| `used` | `List<int>` | Slots já usados por nível |

**Método:** `remaining(int level)` retorna slots disponíveis para aquele nível.

## `KnownSpell`

Uma magia conhecida ou preparada pelo personagem.

| Campo | Tipo | Descrição |
|---|---|---|
| `name` | `String` | Nome da magia |
| `level` | `int` | Nível (0 = truque) |
| `isPrepared` | `bool` | Se está preparada (classes que preparam) |
| `isAlwaysPrepared` | `bool` | Preparada por feature de classe/subclasse |
| `school` | `String?` | Escola de magia |

---

## `CharacterExtraFeature`

Feature adicionada manualmente (ex: multiclasse). Serialização manual — não usa `json_serializable`.

| Campo | Tipo | Descrição |
|---|---|---|
| `sourceClass` | `String` | Classe de origem da feature |
| `name` | `String` | Nome da feature |
| `level` | `int` | Nível em que foi obtida |
| `type` | `String` | `"active"`, `"passive"`, `"subclass"` ou `"asi"` |
| `description` | `String` | Descrição completa |

---

## `CharacterNote`

Nota livre criada pelo jogador na aba Notes. Usa `json_serializable`.

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | `String` (UUID) | Gerado automaticamente |
| `title` | `String` | Título (padrão: `'Untitled'` se vazio) |
| `content` | `String` | Corpo da nota |
| `createdAt` | `DateTime` | Data de criação |

---

## `Character`

Modelo principal. Compõe todos os modelos acima.

| Campo | Tipo |
|---|---|
| `id` | `String` (UUID) |
| `name` | `String` |
| `playerName` | `String` |
| `race` | `String` |
| `subrace` | `String?` |
| `characterClass` | `String` |
| `subclass` | `String?` |
| `level` | `int` |
| `experiencePoints` | `int` |
| `background` | `String` |
| `alignment` | `String` |
| `abilityScores` | `AbilityScores` |
| `hitPoints` | `HitPoints` |
| `armorClass` | `int` |
| `speed` | `int` |
| `proficiencyBonus` | `int` |
| `savingThrowProficiencies` | `List<String>` |
| `skillProficiencies` | `List<String>` |
| `skillExpertises` | `List<String>` |
| `equipment` | `List<EquipmentItem>` |
| `currency` | `Map<String, int>` | Moedas: CP, SP, EP, GP, PP |
| `spells` | `List<KnownSpell>` |
| `spellSlots` | `SpellSlots` |
| `features` | `List<String>` | Features de classe/raça/background como strings |
| `extraFeatures` | `List<CharacterExtraFeature>` | Features adicionadas manualmente |
| `disabledFeatures` | `List<String>` | Nomes de features desabilitadas (ocultas na UI) |
| `languages` | `List<String>` |
| `personality` | `CharacterPersonality` |
| `appearance` | `CharacterAppearance` |
| `backstory` | `String` |
| `notes` | `List<CharacterNote>` | Notas livres do jogador |
| `imagePath` | `String?` |
| `creationMode` | `CreationMode` |
| `createdAt` | `DateTime` |
| `updatedAt` | `DateTime` |

**Getters calculados:**
- `passivePerception` — 10 + modificador de Wisdom + proficiência (se aplicável) + expertise (se aplicável)
- `initiative` — igual ao modificador de Dexterity

**Enum `CreationMode`:** `random`, `semiRandom`, `guided`, `manual`
