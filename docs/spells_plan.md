# Plano — Sistema de Magias

---

## 1. O que já está implementado

### Dados
- `spells.json`: 315 magias (níveis 0–9, SRD 5.1 completo)
- Campos: `name`, `level`, `school`, `castingTime`, `castingTimeType`, `ritual`, `range`, `components`, `material`, `materialCost`, `materialConsumed`, `duration`, `concentration`, `areaOfEffect`, `attackType`, `saveAttribute`, `damageTypes`, `description`, `higherLevels`, `classes`, `subclassSpells` (vazio), `raceSpells` (vazio)
- `SrdSpell` model com todos os campos acima
- `SrdDataSource` com índice por nome

### Engine
- `SpellcastingEngine`: atributo de conjuração, attack bonus, save DC, maxPrepared, maxKnown, maxCantrips, maxSpellLevel por classe e nível
- Tabelas de slots (full / half / pact), cantrips e known spells para todas as classes SRD
- `KnownSpellCasting.classPrepares()` — detecta se a classe usa prepare vs. known

### Modelo do personagem
- `KnownSpell`: `name`, `level`, `isPrepared`, `isAlwaysPrepared`
- `SpellSlots`: `total[9]` e `used[9]`, tracker de slots por nível
- `character.spells: List<KnownSpell>` — magias na ficha

### UI — Aba Spells
- Banner: Attack, Save DC, Cantrips (atual/máx), Prepared (atual/máx) ou Known (atual/máx) por classe
- Tracker de spell slots com botões usar/restaurar por nível
- Lista de magias agrupada por nível com badges (escola, casting time, C, R)
- Toggle de preparar por magia (apenas classes prepare, apenas level > 0)
- Cantrips excluídos do contador de prepared/known e sem toggle de preparar
- Swipe esquerda com confirmação para remover magia (classes known)
- Tap na linha → detail sheet com botão remover (com confirmação)

### UI — Spell Browser (FAB +)
- Busca por nome
- Filtros: nível, escola, casting time, ritual, concentração, "só da minha classe"
- Botão rápido [+] por linha, tap → detail sheet com add/remove
- Remove também pelo browser (atualiza ícone instantaneamente)

---

## 2. Próxima implementação — Prepare-all classes

**Classes afetadas:** Cleric, Druid, Paladin, Artificer, Wizard  
**Regra D&D 5e:** essas classes têm acesso a *todas* as magias da classe até o nível máximo de slot — não precisam "aprender" magias, só precisam preparar as que vão usar no dia.

### Comportamento na aba Spells

A lista deixa de ser construída a partir de `character.spells` e passa a ser construída dinamicamente:

```
lista exibida = todas as SrdSpells da classe com level ≤ engine.maxSpellLevel
                + magias extras do personagem (subclasse, custom)
```

Para cada magia da lista, o estado é derivado assim:

| Estado | Aparência | Origem |
|---|---|---|
| **Preparada** | Normal, com ✓ | Nome está em `character.spells` com `isPrepared = true` |
| **Não preparada** | Normal, sem ✓ | Magia da classe, não está preparada hoje |
| **Sempre preparada** | ✓ fixo, sem toggle | `isAlwaysPrepared = true` (subclasse/domínio) |
| **Desativada pelo DM** | Esmaecida (opacity 0.35) | Nome está em `character.disabledSpells` |

**Nunca** esmaece por "não preparada" — esmaecimento é exclusivo de magias bloqueadas pelo DM.

### Mudanças no modelo

```dart
// Novo campo no Character
final List<String> disabledSpells;  // nomes de magias bloqueadas pelo DM
```

`character.spells` passa a guardar **só as preparadas** para classes prepare-all (não mais toda a lista da classe — ela vem do SRD).

### Interação para desativar/ativar

- **Long-press** numa magia ativa → `AlertDialog` "Desativar esta magia?" → confirma → entra em `disabledSpells`
- **Long-press** numa magia esmaecida → `AlertDialog` "Reativar esta magia?" → confirma → sai de `disabledSpells`
- Sem modo de edição, sem toggle visível

### FAB para prepare-all

Para prepare-all, o FAB `+` abre um browser **reduzido** com apenas duas opções:
- Adicionar magia de subclasse (extra, fora da lista da classe)
- Adicionar magia custom

A lista principal da classe já está sempre visível — o browser não é usado para as magias normais de classe.

### Swipe para remover

- **Classes known** (Bard, Sorcerer, Ranger, Warlock): swipe remove a magia da ficha (comportamento atual)
- **Classes prepare-all**: sem swipe — a magia sempre está na lista. Só esmaece.

---

## 3. Subclass always-prepared (domínios, juramentos, pactos)

**Prioridade:** Alta — implementar logo após prepare-all.

**Regra D&D 5e:** magias de subclasse ficam sempre preparadas e **não contam** contra o limite de prepared.

**Implementação:**
- `subclassSpells` já existe no schema do `spells.json` mas está com arrays vazios — preencher
- O provider, ao construir a lista da aba, filtra magias onde `subclassSpells` contém `character.subclass` e as injeta com `isAlwaysPrepared = true` — sem salvar no JSON do personagem (derivado)
- Na UI: sem toggle de preparar, sem swipe, sem long-press de desativar (sempre presentes por regra)

**Dados a preencher em `subclassSpells`:**

| Subclasse | Classe |
|---|---|
| Life, Light, Trickery, Knowledge, Nature, Tempest, War | Cleric domains |
| Devotion, Ancients, Vengeance | Paladin oaths |
| The Fiend, The Archfey, The Great Old One | Warlock patrons |
| Circle of the Land | Druid circles |

---

## 4. Subclasses conjuradoras (Eldritch Knight, Arcane Trickster)

**Prioridade:** Média.

Fighter e Rogue base não são conjuradores (`SpellcastingEngine.forClass` retorna `null`). Certas subclasses adicionam progressão de **1/3 caster** a partir do nível 3.

| Subclasse | Classe base | Atributo |
|---|---|---|
| Eldritch Knight | Fighter | INT |
| Arcane Trickster | Rogue | INT |

**Tabela de slots (1/3 caster):**

| Nível classe | 1º | 2º | 3º | 4º |
|---|---|---|---|---|
| 1–2 | — | — | — | — |
| 3–5 | 2 | — | — | — |
| 6–8 | 3 | — | — | — |
| 9–10 | 3 | 2 | — | — |
| 11–12 | 3 | 3 | — | — |
| 13–14 | 3 | 3 | 1 | — |
| 15–16 | 3 | 3 | 2 | — |
| 17–18 | 3 | 3 | 3 | 1 |
| 19–20 | 3 | 3 | 3 | 1 |

**Mudanças no engine:**
- Adicionar `SpellProgressionType.third`
- Adicionar tabela `_thirdCasterSlots` e `_thirdCasterMaxSlot`
- `SpellcastingEngine.forClass()` aceita `subclass` opcional; retorna engine para Fighter/Rogue quando subclasse for Eldritch Knight ou Arcane Trickster

**Restrição de escola no browser:**
- Eldritch Knight: só Abjuration e Evocation (exceto 3 magias livres)
- Arcane Trickster: só Enchantment e Illusion (exceto 3 magias livres)
- Implementado como filtro no browser, não no modelo de dados

---

## 5. Magias inatas raciais

**Prioridade:** Baixa — não implementar na mesma sprint que 2 e 3.

Magias inatas (Tiefling, Drow, Gnome, etc.) têm mecanismo completamente diferente da magia de classe:
- Usam atributo próprio (geralmente CHA), independente da classe
- Algumas são à vontade; outras têm limite de 1×/dia
- Não contam contra limite de prepared/known
- Não gastam spell slots da classe (ou podem ser lançadas gastando slots, dependendo da regra)

**Exemplos:**

| Raça | Magia | Limitação |
|---|---|---|
| Tiefling | Thaumaturgy | À vontade |
| Tiefling | Hellish Rebuke | 1×/dia (com slot nível 2) |
| Tiefling | Darkness | 1×/dia (com slot nível 2) |
| Drow | Dancing Lights | À vontade |
| Drow | Faerie Fire | 1×/dia |
| Drow (nível 5+) | Darkness | 1×/dia |
| Forest Gnome | Minor Illusion | À vontade |

**Mudanças necessárias:**
- Novo campo `innateSpells: List<InnateSpell>` no `Character`
- `InnateSpell`: `name`, `usesPerDay` (null = à vontade), `usedToday`
- Seção "Racial Spells" na aba Spells, acima dos cantrips
- Indicador de usos restantes quando limitado (igual spell slots)
- `raceSpells` no `spells.json` a preencher como parte desta fase

---

## 6. Decisões em aberto

- **Multiclasse:** não suportar em v1. Personagem tem uma classe. Documentar como limitação.
- **Warlock Pact Magic:** slots especiais (todos do mesmo nível, recuperados em Short Rest). Requer campo separado no modelo ou lógica especial no engine. Adiar para sprint dedicada.
- **Spellbook do Wizard:** hoje Wizard funciona como prepare normal. Futuramente pode ter `isInSpellbook: bool` no `KnownSpell` para distinguir "no livro" de "preparada hoje". Adiar.
- **Escalonamento de cantrips:** `SpellcastingEngine.cantripBonusDice(level)` já existe. Mostrar na UI qual versão está ativa ("+1d8" no detail sheet) é cosmético — adiar.

---

## 7. Ordem de implementação

- [x] `spells.json` completo (315 magias, SRD 5.1)
- [x] `SrdSpell` model + `SrdDataSource` com índice
- [x] `SpellcastingEngine` (attack, DC, slots, known/prepared/cantrips por classe)
- [x] Aba Spells: banner, spell slots tracker, lista agrupada, toggle prepared, swipe remove
- [x] Spell Browser: busca, filtros, add/remove
- [x] Spell Detail sheet: info completa, add/remove com confirmação
- [x] Cantrips excluídos de prepared/known, contador no banner
- [x] Swipe com `confirmDismiss` (AlertDialog antes de remover)
- [ ] **`disabledSpells` no modelo** + long-press para desativar/ativar (prepare-all)
- [ ] **Lista dinâmica da classe** para prepare-all (Cleric, Druid, Paladin, Artificer, Wizard)
- [ ] **FAB reduzido** para prepare-all (só magias extras)
- [ ] **Preencher `subclassSpells`** no JSON + injeção de always-prepared no provider
- [ ] **Eldritch Knight / Arcane Trickster** — `SpellProgressionType.third` no engine
- [ ] **Magias inatas raciais** — `innateSpells` no modelo + seção na UI
