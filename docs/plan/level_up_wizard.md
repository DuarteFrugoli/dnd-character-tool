# Level Up Wizard — Plano de Implementação

## Visão geral

Um wizard multi-step disparado pelo botão `Icons.upgrade` no AppBar de `character_detail_screen.dart`.
Abre como `DraggableScrollableSheet` (mesmo padrão do Add Feature / Add Spell).
**Não salva nada até o usuário confirmar no último passo.**
Todo o estado intermediário fica em um `_LevelUpState` local no widget.

---

## Passos do Wizard

Os passos são determinados dinamicamente com base na classe e no nível alvo (`character.level + 1`).

### Passo 1 — Novas features (sempre presente)
- Lista as `classFeatures` e `subclassFeatures` do SRD filtradas por `level == novoNível`.
- Exibição read-only: `ExpansionTile` para cada feature.
- Se não houver nenhuma feature nova, o passo ainda aparece com mensagem informativa (para o jogador saber que não perdeu nada).

### Passo 2 — Escolha de subclasse (condicional)
- Aparece **apenas** se `novoNível == subclassLevel[className]`.
- Tabela estática `_subclassLevel` (ver abaixo).
- Mostra lista de subclasses disponíveis para a classe (do SRD).
- Se o personagem **já tem subclasse**, o passo ainda aparece mas exibe um aviso informando qual subclasse está ativa e pergunta se o jogador tem certeza de que quer continuar com ela (sem trocar). Comportamento similar ao que já é feito na troca manual de nível. O jogador pode confirmar ou trocar.

### Passo 3 — ASI ou Talento (condicional)
- Aparece **apenas** se `novoNível` está em `_asiLevels[className]`.
- Duas opções com rádio:
  - **Melhoria de Atributo**: picker com +2 num atributo ou +1/+1 em dois diferentes. Mostra valor atual + novo valor.
  - **Talento**: abre lista da aba Feats (igual ao `_buildFeatsList` já implementado), filtrando feats já possuídos. Permite selecionar 1.
- O escolhido fica em `_LevelUpState` e **só é aplicado na confirmação**.

### Passo 4 — HP (sempre presente)
- Mostra o dado da hit die da classe.
- Duas opções lado a lado:
  - **Rolar**: simula `1dX + CON mod` com animação de dado. Mínimo 1.
  - **Média**: `ceil(X/2) + 1 + CON mod`. Mínimo 1. (Regra padrão do PHB.)
- O resultado fica em `_LevelUpState.hpGained`.

### Passo 5 — Cantrips (condicional)
- Aparece **apenas** para classes que ganham cantrips adicionais no nível alvo.
- Calcula `cantripsToLearn = engine(novoNível).maxCantrips - engine(atualNível).maxCantrips`.
- Se `cantripsToLearn <= 0`, o passo é pulado.
- Mostra lista de cantrips do SRD (`spellLevel == 0`) da classe, excluindo os já conhecidos.
- O jogador deve selecionar **exatamente** `cantripsToLearn` cantrips. Botão "Próximo" desabilitado até isso.
- Inspirado no fluxo do BG3: cantrips separados das magias.

### Passo 6 — Magias (condicional)
- Aparece **apenas** para `mechanism == SpellcastingMechanism.known || mechanism == SpellcastingMechanism.pact`.
  - Classes: Bard, Ranger, Sorcerer, Warlock, Eldritch Knight, Arcane Trickster.
- Calcula `spellsToLearn = engine(novoNível).maxKnown - engine(atualNível).maxKnown`.
- Calcula `newMaxSpellLevel = engine(novoNível).maxSpellLevel`.
- Se `spellsToLearn <= 0` **e** não for Warlock, o passo é pulado.
- Mostra lista de magias do SRD filtrada por `spellLevel >= 1 && spellLevel <= newMaxSpellLevel`, excluindo as já conhecidas.
- O jogador deve selecionar **exatamente** `spellsToLearn` magias. Botão "Próximo" fica desabilitado até isso.
- **Warlock**: exibe adicionalmente uma seção "Trocar uma magia" — lista das magias atualmente conhecidas, o jogador pode escolher 1 para remover. Opcional (pode pular). A magia removida sai junto com as novas na confirmação.

### Passo 7 — Confirmação (sempre presente)
- Resumo de tudo que será aplicado:
  - Nível: X → X+1
  - HP máximo: +N
  - Features novas (lista)
  - Subclasse escolhida (se aplicável)
  - ASI / Talento (se aplicável)
  - Magias aprendidas (se aplicável)
- Botão **"Confirmar Level Up"** executa tudo de uma vez via `notifier.levelUp(result)`.
- Botão "Cancelar" fecha sem salvar.

---

## Tabelas estáticas

Serão definidas em `lib/data/constants/level_up_rules.dart`.

```dart
// Nível em que cada classe ganha subclasse (SRD 5.1)
const Map<String, int> _subclassLevel = {
  'Barbarian': 3, 'Bard': 3, 'Cleric': 1, 'Druid': 2,
  'Fighter': 3, 'Monk': 3, 'Paladin': 3, 'Ranger': 3,
  'Rogue': 3, 'Sorcerer': 1, 'Warlock': 1, 'Wizard': 2,
};

// Níveis de ASI por classe (SRD 5.1)
const Map<String, List<int>> _asiLevels = {
  'Barbarian': [4, 8, 12, 16, 19],
  'Bard':      [4, 8, 12, 16, 19],
  'Cleric':    [4, 8, 12, 16, 19],
  'Druid':     [4, 8, 12, 16, 19],
  'Fighter':   [4, 6, 8, 12, 14, 16, 19], // Fighter tem mais
  'Monk':      [4, 8, 12, 16, 19],
  'Paladin':   [4, 8, 12, 16, 19],
  'Ranger':    [4, 8, 12, 16, 19],
  'Rogue':     [4, 8, 10, 12, 16, 19], // Rogue tem mais
  'Sorcerer':  [4, 8, 12, 16, 19],
  'Warlock':   [4, 8, 12, 16, 19],
  'Wizard':    [4, 8, 12, 16, 19],
};
```

Hit dice por classe:
```dart
const Map<String, int> _hitDie = {
  'Barbarian': 12, 'Fighter': 10, 'Paladin': 10, 'Ranger': 10,
  'Bard': 8, 'Cleric': 8, 'Druid': 8, 'Monk': 8, 'Rogue': 8, 'Warlock': 8,
  'Sorcerer': 6, 'Wizard': 6,
};
```

---

## Modelo de dados intermediário

```dart
class LevelUpResult {
  final int hpGained;
  final Map<String, int> asiChanges;  // e.g. {'STR': 2} ou {'DEX': 1, 'WIS': 1}
  final SrdFeat? featChosen;
  final String? subclassChosen;
  final List<KnownSpell> spellsLearned;
  final String? spellSwapped;  // nome da magia removida (Warlock)
}
```

---

## Método no provider

```dart
Future<void> levelUp(LevelUpResult result) async {
  final c = state.valueOrNull;
  if (c == null) return;

  // 1. Novo nível
  final newLevel = c.level + 1;

  // 2. HP
  final newMax = c.hitPoints.maximum + result.hpGained;

  // 3. ASI
  AbilityScores newScores = c.abilityScores;
  result.asiChanges.forEach((attr, delta) {
    newScores = newScores.increment(attr, delta);
  });

  // 4. Feat
  List<CharacterExtraFeature> newExtras = [...c.extraFeatures];
  if (result.featChosen != null) {
    final feat = result.featChosen!;
    newExtras.add(CharacterExtraFeature(
      sourceClass: 'Feat', name: feat.name,
      level: newLevel, type: 'passive', description: feat.description,
    ));
  }

  // 5. Subclass
  final newSubclass = result.subclassChosen ?? c.subclass;

  // 6. Magias
  List<KnownSpell> newSpells = [...c.spells];
  if (result.spellSwapped != null) {
    newSpells.removeWhere((s) => s.name == result.spellSwapped);
  }
  newSpells.addAll(result.spellsLearned);

  final updated = c.copyWith(
    level: newLevel,
    hitPoints: c.hitPoints.copyWith(
      maximum: newMax,
      current: c.hitPoints.current + result.hpGained,
    ),
    abilityScores: newScores,
    extraFeatures: newExtras,
    subclass: newSubclass,
    spells: newSpells,
  );

  await _save(updated);
  await syncSpellSlots(); // Atualiza slots com base no novo nível
  if (result.subclassChosen != null) await syncInnateSpells();
}
```

> `AbilityScores.increment(String attr, int delta)` será um método novo a adicionar ao modelo.

---

## Arquivos a criar/modificar

| Arquivo | Ação |
|---|---|
| `lib/data/constants/level_up_rules.dart` | **Criar** — tabelas `_subclassLevel`, `_asiLevels`, `_hitDie`, helpers públicos |
| `lib/data/models/ability_scores.dart` | **Modificar** — adicionar `increment(String attr, int delta)` |
| `lib/features/character_detail/character_detail_provider.dart` | **Modificar** — adicionar `levelUp(LevelUpResult result)` |
| `lib/features/character_detail/level_up_wizard.dart` | **Criar** — widget do wizard (novo arquivo, `part of` da screen) |
| `lib/features/character_detail/character_detail_screen.dart` | **Modificar** — conectar botão Level Up ao wizard |
| `lib/l10n/app_en.arb` (+ 9 outros) | **Modificar** — strings do wizard |
| `assets/data/srd/subclasses.json` | Já existe ✓ |

---

## Strings novas (app_en.arb)

```json
"levelUpTitle": "Level Up",
"levelUpConfirm": "Confirm Level Up",
"levelUpStepFeatures": "New Features",
"levelUpStepSubclass": "Choose Subclass",
"levelUpStepAsi": "Ability Score Improvement",
"levelUpStepHp": "Hit Points",
"levelUpStepSpells": "New Spells",
"levelUpStepSummary": "Summary",
"levelUpNoNewFeatures": "No new class features at this level.",
"levelUpHpRoll": "Roll",
"levelUpHpAverage": "Average",
"levelUpHpGained": "+{n} HP",
"levelUpAsiOption": "Ability Score Improvement",
"levelUpFeatOption": "Choose a Feat",
"levelUpSpellsToLearn": "Choose {n} spell(s) to learn",
"levelUpSpellSwap": "Replace a known spell",
"levelUpSummaryLevel": "Level {level}",
"levelUpSummaryHp": "Max HP +{n}",
"levelUpSummaryAsi": "ASI: {changes}",
"levelUpSummaryFeat": "Feat: {name}",
"levelUpSummarySubclass": "Subclass: {name}",
"levelUpSummarySpells": "Spells learned: {count}"
```

---

## Ordem de implementação

1. `level_up_rules.dart` — tabelas estáticas (sem dependências)
2. `ability_scores.dart` — `increment()` helper
3. `app_*.arb` + `flutter gen-l10n`
4. `character_detail_provider.dart` — `levelUp()`
5. `level_up_wizard.dart` — UI completa
6. `character_detail_screen.dart` — conectar botão
