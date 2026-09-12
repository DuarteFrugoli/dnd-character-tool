import '../datasources/srd/srd_models.dart';
import '../models/models.dart';
import '../spellcasting_engine.dart';
import 'contextual_roll.dart';

class ContextualSpellRollBuilder {
  const ContextualSpellRollBuilder._();

  static ContextualRollRequest? build({
    required Character character,
    required SrdSpell spell,
    required String displayName,
    required String attackLabel,
    required String damageLabel,
    required String spellSlotChoiceLabel,
    required String Function(int level) slotLevelLabel,
    required String Function(String damageType) damageTypeLabel,
    SpellcastingEngine? spellcastingEngine,
    Set<int>? availableSlotLevels,
    String? subtitle,
  }) {
    if (spell.rolls.isEmpty) return null;

    final parts = <ContextualRollPart>[];
    for (final roll in spell.rolls) {
      switch (roll.kind) {
        case 'spell_attack':
          final attackBonus = spellcastingEngine?.spellAttack;
          if (attackBonus == null) break;
          parts.add(
            ContextualRollPart.d20(
              id: roll.id,
              label: attackLabel,
              d20Modifier: attackBonus,
            ),
          );
        case 'damage':
          final formula = _formulaFor(roll, character.totalLevel);
          if (formula == null || _isZeroExpression(formula)) break;
          final choices = _slotChoices(
            spell: spell,
            roll: roll,
            baseFormula: formula,
            availableSlotLevels: availableSlotLevels,
            slotLevelLabel: slotLevelLabel,
          );
          parts.add(
            ContextualRollPart.expression(
              id: roll.id,
              label: _damageLabel(roll, damageLabel, damageTypeLabel),
              expression: formula,
              critical: roll.critical,
              choiceLabel: choices.isEmpty ? null : spellSlotChoiceLabel,
              choices: choices,
            ),
          );
      }
    }

    if (parts.isEmpty) return null;
    return ContextualRollRequest(
      key: 'spell:${spell.name.toLowerCase()}',
      title: displayName,
      subtitle: subtitle,
      parts: parts,
    );
  }

  static String? _formulaFor(SrdSpellRoll roll, int characterLevel) {
    var formula = roll.formula;
    final scaling = roll.characterLevelScaling.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final entry in scaling) {
      if (characterLevel >= entry.key) {
        formula = entry.value;
      }
    }
    return formula;
  }

  static List<ContextualRollExpressionChoice> _slotChoices({
    required SrdSpell spell,
    required SrdSpellRoll roll,
    required String baseFormula,
    required Set<int>? availableSlotLevels,
    required String Function(int level) slotLevelLabel,
  }) {
    if (spell.level <= 0 || roll.slotLevelScaling.isEmpty) return const [];

    final formulasByLevel = <int, String>{spell.level: baseFormula};
    final scaling = roll.slotLevelScaling.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final entry in scaling) {
      if (entry.key > spell.level) {
        formulasByLevel[entry.key] = entry.value;
      }
    }
    if (formulasByLevel.length <= 1) return const [];

    final choices = <ContextualRollExpressionChoice>[];
    for (final entry in formulasByLevel.entries) {
      if (availableSlotLevels != null &&
          availableSlotLevels.isNotEmpty &&
          !availableSlotLevels.contains(entry.key)) {
        continue;
      }
      choices.add(
        ContextualRollExpressionChoice(
          key: 'slot_${entry.key}',
          label: '${slotLevelLabel(entry.key)} (${entry.value})',
          expression: entry.value,
        ),
      );
    }
    if (choices.length == 1 && choices.single.key == 'slot_${spell.level}') {
      return const [];
    }
    return choices;
  }

  static String _damageLabel(
    SrdSpellRoll roll,
    String damageLabel,
    String Function(String damageType) damageTypeLabel,
  ) {
    if (roll.damageTypes.isEmpty) return damageLabel;
    final types = roll.damageTypes.map(damageTypeLabel).join('/');
    return '$damageLabel ($types)';
  }

  static bool _isZeroExpression(String expression) {
    return int.tryParse(expression.trim()) == 0;
  }
}
