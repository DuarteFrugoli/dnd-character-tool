# Plano — Sistema de Magias (Sprint 6)

> Documento temporário de planejamento. Quando implementado, migrar o essencial para sprint.md e roadmap.md.

---

## 1. Estado atual

- `spells.json`: 59 magias (20 cantrips, 18 nível 1, 13 nível 2, 8 nível 3)
- Campos existentes: `name`, `level`, `school`, `castingTime`, `range`, `components`, `duration`, `concentration`, `classes`, `description`
- `KnownSpell` (modelo Dart): `name`, `level`, `isPrepared`, `isAlwaysPrepared`, `school`
- `SpellSlots`: tracker de slots por nível já funcional na aba Spells

**O que falta:** ritual como bool, higherLevels, area de efeito, tipo de save/ataque, dano, material detalhado, subclasses, raças, magias níveis 4–9, engine de regras por classe, UI completa do browser.

---

## 2. Schema JSON completo (`spells.json`)

Cada magia terá os seguintes campos:

```json
{
  "name": "Fireball",
  "level": 3,
  "school": "evocation",

  "castingTime": "1 action",
  "castingTimeType": "action",
  "ritual": false,

  "range": "150 feet",

  "components": ["V", "S", "M"],
  "material": "a tiny ball of bat guano and sulfur",
  "materialCost": null,
  "materialConsumed": false,

  "duration": "Instantaneous",
  "concentration": false,

  "areaOfEffect": { "type": "sphere", "size": 20 },

  "attackType": null,
  "saveAttribute": "DEX",
  "damageTypes": ["fire"],

  "description": "...",
  "higherLevels": "When you cast this spell using a spell slot of 4th level or higher, the damage increases by 1d6 for each slot level above 3rd.",

  "classes": ["sorcerer", "wizard"],
  "subclassSpells": [
    { "class": "warlock", "subclass": "The Fiend" }
  ],
  "raceSpells": [
    { "race": "tiefling", "subrace": null }
  ]
}
```

### Detalhes dos campos

| Campo | Tipo | Valores possíveis |
|---|---|---|
| `castingTimeType` | `string` | `action` \| `bonus_action` \| `reaction` \| `minute` \| `hour` \| `special` |
| `ritual` | `bool` | true/false — **separado** do castingTime (não mais `"1 minute (ritual)"`) |
| `areaOfEffect` | `object?` | `{ type: sphere\|cone\|cube\|cylinder\|line, size: int }` ou null |
| `attackType` | `string?` | `melee` \| `ranged` \| null (para magias de save) |
| `saveAttribute` | `string?` | `STR` \| `DEX` \| `CON` \| `INT` \| `WIS` \| `CHA` \| null |
| `damageTypes` | `List<string>` | `fire`, `cold`, `necrotic`, etc. Lista vazia se não faz dano |
| `materialCost` | `int?` | Custo em GP do material (null se não tem custo) |
| `materialConsumed` | `bool` | Se o material é consumido ao lançar |
| `subclassSpells` | `List<object>` | Magias expandidas de subclasse (ex: domínios de clérigo, juramentos de paladino) |
| `raceSpells` | `List<object>` | Magias de traços raciais (ex: Tiefling, Drow) |

---

## 3. Quantidade de magias necessárias

| Nível | SRD estimado | Atual |
|---|---|---|
| 0 (cantrip) | ~25 | 26 ✓ |
| 1 | ~40 | 49 ✓ |
| 2 | ~35 | 51 ✓ |
| 3 | ~30 | 38 ✓ |
| 4 | ~25 | 31 ✓ |
| 5 | ~20 | 35 ✓ |
| 6 | ~15 | 31 ✓ |
| 7 | ~15 | 21 ✓ |
| 8 | ~10 | 17 ✓ |
| 9 | ~10 | 16 ✓ |
| **Total** | **~225** | **315 ✓** |

**Status:** `spells.json` completo com todos os níveis do SRD (OGL 5.1). Campos `subclassSpells` e `raceSpells` estão presentes no schema mas com arrays vazios — preenchimento pendente para fase futura.

---

## 4. Modelo Dart

### `SrdSpell` (novo — dados do JSON, nunca salvo no personagem)

```dart
class SrdSpell {
  final String name;
  final int level;
  final String school;
  final String castingTime;
  final String castingTimeType; // action | bonus_action | reaction | minute | hour | special
  final bool ritual;
  final String range;
  final List<String> components;
  final String? material;
  final int? materialCost;
  final bool materialConsumed;
  final String duration;
  final bool concentration;
  final SpellAreaOfEffect? areaOfEffect;
  final String? attackType;
  final String? saveAttribute;
  final List<String> damageTypes;
  final String description;
  final String? higherLevels;
  final List<String> classes;
  final List<SubclassSpellRef> subclassSpells;
  final List<RaceSpellRef> raceSpells;
}
```

### `KnownSpell` (refatorado — remover apenas `school`)

Manter `level` no modelo — necessário para agrupar a lista por nível de forma síncrona sem `FutureBuilder` em cada linha. Remover apenas `school` (nunca usado na ficha).

```dart
class KnownSpell {
  final String name;           // chave para lookup em SrdSpell
  final int level;             // mantido para agrupamento síncrono
  final bool isPrepared;       // preparada neste dia (classes que preparam)
  final bool isAlwaysPrepared; // de subclasse/domínio/juramento
}
```

> **Migração:** personagens com `school` salvo no JSON continuam funcionando — o campo é ignorado no `fromJson` ao carregar.

---

## 5. Engine de Regras por Classe (`SpellcastingEngine`)

### Atributo de conjuração por classe

| Classe | Atributo |
|---|---|
| Wizard, Artificer, Eldritch Knight, Arcane Trickster | INT |
| Cleric, Druid, Ranger | WIS |
| Bard, Sorcerer, Warlock, Paladin | CHA |

**Fórmulas:**
- **Spell Attack:** `proficiency bonus + ability modifier`
- **Spell Save DC:** `8 + proficiency bonus + ability modifier`

### Mecanismo por classe

| Classe | Progressão | Slots | Cantrips (lv1) | Mecanismo |
|---|---|---|---|---|
| Bard | Full | Standard | 2 | **Known** — número fixo por nível |
| Cleric | Full | Standard | 3 | **Prepare** — todos da lista ≤ nível do slot |
| Druid | Full | Standard | 2 | **Prepare** — todos da lista ≤ nível do slot |
| Sorcerer | Full | Standard | 4 | **Known** — número fixo por nível |
| Warlock | Pact Magic | Especial* | 2 | **Known** — número fixo por nível |
| Wizard | Full | Standard | 3 | **Spellbook** — aprende + prepara |
| Paladin | Half | Standard | 0 | **Prepare** — metade nível + CHA |
| Ranger | Half | Standard | 0 | **Known** — número fixo por nível |
| Artificer | Half | Standard | 2 | **Prepare** |

*Warlock: todos os slots são do mesmo nível, recuperados em Short Rest.

### Número de magias conhecidas/preparadas

**Prepare classes:**
- Cleric/Druid: `ability_modifier + class_level` (mín. 1)
- Paladin: `ability_modifier + floor(class_level / 2)` (mín. 1)
- Wizard: `ability_modifier + class_level` (mín. 1) — mas só prepara do livro

**Known classes (tabela — exemplo Bard):**

| Nível | Cantrips | Magias conhecidas |
|---|---|---|
| 1 | 2 | 4 |
| 2 | 2 | 5 |
| 3 | 2 | 6 |
| 4 | 3 | 7 |
| 5 | 3 | 8 |
| ... | ... | ... |

> Essas tabelas precisam estar em `classes.json` ou em constantes no `SpellcastingEngine`.

### Cantrips

- Escalam com **nível do personagem** (não da classe):
  - Níveis 1–4: versão base
  - Níveis 5–10: +1 dado
  - Níveis 11–16: +2 dados
  - Níveis 17–20: +3 dados
- Não gastam slots
- Não precisam ser preparados

---

## 6. UI — Aba Spells (Fase A e B)

### Fase A (banner + lista + provider) — implementar agora
### Fase B (Spell Browser + Detail sheet) — implementar depois

**Empty state:** usar `SpellcastingEngine.forClass()` para detectar se a classe é conjuradora. Se for, mostrar aba completa com FAB mesmo sem magias. Se não for (Fighter base, Barbarian, etc.), mostrar o empty state atual.

### Layout geral

```
┌──────────────────────────────────────┐
│ SPELLCASTING                         │
│  Ability: WIS (+3)                   │
│  Attack: +5    Save DC: 13           │
│  Preparadas: 5/7                     │ ← só para classes que preparam
│  Conhecidas: 8/10                    │ ← só para classes "known"
├──────────────────────────────────────┤
│ SPELL SLOTS                          │
│  ○○○  ○○  ○                          │ ← visual atual, mantido
├──────────────────────────────────────┤
│ CANTRIPS (3)                         │
│  • Fire Bolt       Evoc  ⚡ 120ft    │
│  • Prestidigitation Tran  ⚡ 10ft    │
├──────────────────────────────────────┤
│ NÍVEL 1  ●●● ○                       │ ← slots usados inline
│  ☑ Burning Hands   Evoc  ⚡ Self     │ ← ☑ = preparada
│  ☐ Detect Magic    Divin ⚡ Self     │ ← ☐ = conhecida/não preparada
├──────────────────────────────────────┤
│ NÍVEL 2  ●○                          │
│  ...                                 │
└──────────────────────────────────────┘
                              [+]  ← FAB: abrir browser
```

### Card de magia (linha)

- **Nome** da magia
- **Badge escola** (cor por escola: vermelho=evoc, roxo=enchan, etc.)
- **Ícone casting time:** ⚡ action, ⚡mini = bonus, 🔄 reaction, ⏱ 1 min+
- **Concentration badge** se aplicável
- **Ritual badge** se aplicável  
- **Range** abreviado
- Para classes que preparam: **toggle preparada** (checkbox ou switch) — tap no card
- **Swipe esquerda** → remover da lista

### Detalhe da magia (bottom sheet ao segurar ou botão ⋮)

- Nome + escola + nível
- Casting time, Range, Duration
- Componentes (V/S/M com descrição do material)
- Concentration / Ritual badges
- Area of effect se houver
- Attack/Save se houver
- Damage types
- Descrição completa
- "Em níveis superiores" se houver

---

## 7. UI — Spell Browser (FAB +)

### Layout

```
┌──────────────────────────────────────┐
│ 🔍 Buscar magia...                   │
├──────────────────────────────────────┤
│ Nível: [C] [1] [2] [3] [4] [5] ...  │ ← chips selecionáveis, múltiplos
│ Escola: [Evoc] [Necro] [+mais]       │
│ [⚡ Ação] [⚡mini Bonus] [🔄 Reação] │
│ [Ritual] [Concentração]              │
│ [Só da minha classe] ← toggle        │
├──────────────────────────────────────┤
│ Cantrips                             │
│  Fire Bolt       Evoc  ⚡ 120ft  [+] │
│  Prestidigitation Tran  ⚡ 10ft  [✓] │ ← ✓ = já adicionada
│ Nível 1                              │
│  Fireball         Evoc  ⚡ 150ft  [+] │
│  ...                                 │
└──────────────────────────────────────┘
```

- **Filtros persistentes** enquanto o sheet está aberto
- **"Só da minha classe"** ligado por padrão — mostra magias da classe do personagem + subclasse + raça
- Desligar mostra todas as magias do SRD
- **Tap no item** → detalhe da magia (sheet sobre o sheet) com botão Adicionar/Remover
- **Botão [+]** direto na linha para adicionar rapidamente sem abrir detalhe

---

## 8. Distinção Known / Prepared na UI

| Classe | O que o browser faz | Toggle na ficha |
|---|---|---|
| Cleric, Druid | Adiciona à lista de magias conhecidas (sempre "pode preparar") | Toggle preparada/desativada |
| Paladin | Idem | Toggle preparada/desativada |
| Wizard | Adiciona ao livro de magias | Toggle preparada/não preparada |
| Bard, Sorcerer, Ranger | Adiciona como magia conhecida permanentemente | Sem toggle (todas "preparadas") |
| Warlock | Idem | Sem toggle |

**Regra geral UI:** se a classe tem o conceito de "preparar", mostra o toggle. Se não tem, todas as magias conhecidas são sempre ativas.

**Magias "sempre preparadas"** (de subclasse, domínio, juramento): aparecem com badge especial, sem toggle, sem botão remover.

---

## 9. Dados adicionais em `classes.json`

Para cada classe, adicionar:

```json
{
  "spellcastingAbility": "WIS",
  "spellcastingMechanism": "prepare",
  "spellProgressionType": "full",
  "cantripsByLevel": [2, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4],
  "spellsKnownByLevel": null,
  "spellsPreparedFormula": "ability_mod + class_level"
}
```

Para classes "known" (Bard, Sorcerer, etc.):
```json
{
  "spellsKnownByLevel": [4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 15, 16, 18, 19, 19, 20, 22, 22, 22],
  "spellsPreparedFormula": null
}
```

---

## 10. Ordem de implementação

- [x] 1. **Expandir `spells.json`** — schema completo com todos os campos
- [x] 2. **Adicionar magias níveis 0–9** — 315 magias SRD 5.1
- [x] 3. **Expandir `SrdSpell` model** + índice por nome em `SrdDataSource`
- [x] 4. **Criar `SpellcastingEngine`** — attack, DC, slots, known/prepared por classe
- [ ] 5. **Refatorar `KnownSpell`** — remover `school`, manter `level`
- [ ] 6. **Adicionar provider actions** — `addSpell`, `removeSpell`, `togglePrepared`
- [ ] 7. **Fase A UI** — banner de stats + spell slots + lista agrupada por nível + toggle prepared + swipe remove
- [ ] 8. **Fase B UI** — Spell Browser (FAB +) com search + filtros + add/remove
- [ ] 9. **Fase B UI** — Spell Detail sheet
- [ ] 10. **Preencher `subclassSpells` / `raceSpells`** no JSON (fase futura)

---

## 11. Decisões em aberto

- [ ] **Multiclasse:** personagem com duas classes spellcaster tem slots combinados (tabela específica de multiclasse). Para v1, não suportar — documentar limitação.
- [ ] **Warlock Pact Magic:** slots especiais (todos do mesmo nível, Short Rest). Precisa de campo separado no modelo ou tratamento especial no engine.
- [ ] **Spellbook do Wizard:** guardar magias "no livro" separado das "preparadas do dia"? Ou usar `isAlwaysPrepared=false, isPrepared=false` para "no livro mas não preparada"? **Decisão recomendada:** terceiro estado via campo `isInSpellbook: bool` no `KnownSpell`.
- [ ] **Escalonamento de cantrips:** mostrar na UI qual versão do cantrip está ativa com base no nível do personagem.
- [ ] **Magias de subclasse:** como o personagem indica qual subclasse tem? Já existe `character.subclass` — usar isso para filtrar `subclassSpells` do JSON.

---

## 12. Magias de Subclasse, Raça e Subclasses Conjuradoras

Os três casos têm mecanismos muito diferentes e devem ser implementados por ordem de prioridade.

---

### Caso 1 — Subclass always-prepared (domínios, juramentos, pactos) · Prioridade Alta

**Exemplos:** Oath of Devotion (Paladin), Life Domain (Cleric), The Fiend (Warlock).

**Regra D&D 5e:** as magias de subclasse ficam **sempre preparadas** e **não contam** contra o limite de magias preparadas do dia.

**Implementação:**
- Os campos `subclassSpells` no `spells.json` já existem no schema. Precisam ser preenchidos (ver seção 10).
- Ao carregar a ficha, o provider itera `spells.json`, filtra magias onde `subclassSpells` contém a subclasse do personagem (`character.subclass`) e as injeta com `isAlwaysPrepared = true` na lista exibida — sem salvar no JSON do personagem (são derivadas).
- Na UI: aparecem sem toggle de preparar e sem botão remover (comportamento já suportado por `isAlwaysPrepared`).

**Dados necessários:** preencher `subclassSpells` no JSON para:
- Cleric domains (Life, Light, Trickery, Knowledge, Nature, Tempest, War)
- Paladin oaths (Devotion, Ancients, Vengeance)
- Warlock patrons (The Fiend, The Archfey, The Great Old One)
- Druid circles que expandem lista (Circle of the Land)

---

### Caso 2 — Subclasses conjuradoras (Eldritch Knight, Arcane Trickster) · Prioridade Média

**Regra D&D 5e:** Fighter e Rogue base não são conjuradores. Certas subclasses adicionam progressão de **1/3 caster** a partir do nível 3 da classe.

| Subclasse | Classe base | Atributo | Progressão |
|---|---|---|---|
| Eldritch Knight | Fighter | INT | 1/3 caster (slots a partir do nível 3) |
| Arcane Trickster | Rogue | INT | 1/3 caster (slots a partir do nível 3) |

**Tabela de slots (1/3 caster — slots equivalentes ao nível de conjurador = floor(class_level / 3)):**

| Nível da classe | Slots nív. 1 | Slots nív. 2 | Slots nív. 3 | Slots nív. 4 |
|---|---|---|---|---|
| 1–2 | — | — | — | — |
| 3–4 | 2 | — | — | — |
| 5–6 | 3 | — | — | — |
| 7–8 | 3 | 2 | — | — |
| 9–10 | 3 | 2 | — | — |
| 11–12 | 3 | 3 | — | — |
| 13–14 | 3 | 3 | 1 | — |
| 15–16 | 3 | 3 | 2 | — |
| 17–18 | 3 | 3 | 3 | 1 |
| 19–20 | 3 | 3 | 3 | 1 |

**Implementação:**
- Adicionar `SpellProgressionType.third` ao enum no `SpellcastingEngine`.
- Adicionar tabela `_thirdCasterSlots` e `_thirdCasterMaxSlot`.
- Expandir `SpellcastingEngine.forClass()` para aceitar `subclass` opcional e retornar engine para Fighter/Rogue quando a subclasse for Eldritch Knight ou Arcane Trickster.
- Eldritch Knight conhece apenas magias de Abjuration e Evocation (exceto os 3 escolhidos livremente). Arcane Trickster conhece apenas Enchantment e Illusion (exceto os 3 escolhidos livremente). Isso é uma restrição de browser, não de dados.

---

### Caso 3 — Magias inatas raciais (Tiefling, Drow, etc.) · Prioridade Baixa

**Regra D&D 5e:** magias inatas têm mecanismo completamente diferente da magia de classe:
- Geralmente usam **Charisma** como atributo (independente da classe).
- Algumas são usadas **1×/dia** sem gastar slot; outras podem ser lançadas gastando slots.
- Não aparecem na lista de spell slots da classe.
- Não contam contra o limite de magias conhecidas/preparadas.

**Exemplos:**
| Raça/Sub-raça | Magia | Limitação |
|---|---|---|
| Tiefling | *Thaumaturgy* | À vontade |
| Tiefling | *Hellish Rebuke* | 1×/dia com slot |
| Tiefling | *Darkness* | 1×/dia com slot |
| Drow | *Dancing Lights* | À vontade |
| Drow | *Faerie Fire* | 1×/dia |
| Drow (nível 5+) | *Darkness* | 1×/dia |
| Forest Gnome | *Minor Illusion* | À vontade |

**Implementação (mais complexa):**
- Requer novo campo `innateSpells` no modelo `Character` (ou seção dedicada na aba Spells).
- Precisa de campo `usesPerDay` e `usedToday` por magia inata para rastrear o cooldown.
- `raceSpells` no `spells.json` já existe no schema mas está vazio — preencher como parte desta fase.
- UI: seção separada "Racial Spells" acima ou abaixo dos cantrips, com indicador de usos restantes quando limitado.
- **Não implementar na mesma sprint que os casos 1 e 2.**
