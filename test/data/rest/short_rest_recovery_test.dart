import 'package:dnd_character_tool/data/feature_usage_engine.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/rest/rest_policy.dart';
import 'package:dnd_character_tool/data/rest/short_rest_recovery.dart';
import 'package:dnd_character_tool/data/rulesets/ruleset_ids.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character({
  String cls = 'Wizard',
  int level = 5,
  List<int> slotTotals = const [4, 3, 2],
  List<int> slotUsed = const [4, 3, 2],
  Map<String, int> featureResources = const {},
}) {
  final now = DateTime(2024);
  return Character(
    id: 'caster',
    rulesetId: RulesetId.dnd2024,
    contentPackId: ContentPackId.srd521,
    name: 'Caster',
    race: 'Human',
    characterClass: cls,
    level: level,
    classes: [
      CharacterClassEntry(
        id: 'primary',
        className: cls,
        level: level,
        isStartingClass: true,
      ),
    ],
    abilityScores: const AbilityScores(),
    hitPoints: const HitPoints(maximum: 20, current: 20),
    spellSlots: SpellSlots(
      total: [...slotTotals, ...List.filled(9 - slotTotals.length, 0)],
      used: [...slotUsed, ...List.filled(9 - slotUsed.length, 0)],
    ),
    featureResources: featureResources,
    createdAt: now,
    updatedAt: now,
  );
}

FeatureUsageBinding _binding(
  String id,
  String maxFormula, {
  required String cls,
  required int level,
}) {
  return FeatureUsageBinding(
    resource: FeatureUsageResource(
      id: id,
      name: id,
      maxFormula: maxFormula,
      recharge: 'long_rest',
    ),
    ref: FeatureUsageRef(resourceId: id),
    usageContext: FeatureUsageContext(
      totalCharacterLevel: level,
      sourceClass: cls,
      sourceClassLevel: level,
    ),
  );
}

final _rules = const Rest2024Policy().shortRestRecoveryRules;

void main() {
  group('Arcane Recovery', () {
    final binding = _binding(
      '2024_arcane_recovery',
      '1',
      cls: 'Wizard',
      level: 5,
    );

    test('offers expended slots up to half the class level rounded up', () {
      final options = ShortRestRecoveryEngine.optionsFor(
        character: _character(),
        rules: _rules,
        bindings: [binding],
      );

      final option = options.single;
      expect(option.budget, 3);
      expect(option.recoverableSlots, [4, 3, 2, 0, 0]);
    });

    test('recovers chosen slots and spends the daily use', () {
      final character = _character();
      final options = ShortRestRecoveryEngine.optionsFor(
        character: character,
        rules: _rules,
        bindings: [binding],
      );

      final recovered = ShortRestRecoveryEngine.apply(
        character,
        options: options,
        selections: const [
          ShortRestRecoverySelection.slots('2024_arcane_recovery', [1, 1]),
        ],
      );

      expect(recovered.spellSlots.used.take(3), [3, 2, 2]);
      expect(recovered.featureResources['2024_arcane_recovery'], 0);
    });

    test('rejects slots above the combined level budget', () {
      final character = _character();
      final options = ShortRestRecoveryEngine.optionsFor(
        character: character,
        rules: _rules,
        bindings: [binding],
      );

      expect(
        () => ShortRestRecoveryEngine.apply(
          character,
          options: options,
          selections: const [
            ShortRestRecoverySelection.slots('2024_arcane_recovery', [0, 2]),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('is unavailable once used or with no expended slots', () {
      expect(
        ShortRestRecoveryEngine.optionsFor(
          character: _character(
            featureResources: const {'2024_arcane_recovery': 0},
          ),
          rules: _rules,
          bindings: [binding],
        ),
        isEmpty,
      );
      expect(
        ShortRestRecoveryEngine.optionsFor(
          character: _character(slotUsed: const [0, 0, 0]),
          rules: _rules,
          bindings: [binding],
        ),
        isEmpty,
      );
    });

    test('never recovers slots of level 6 or higher', () {
      final character = _character(
        level: 20,
        slotTotals: const [4, 3, 3, 3, 3, 2],
        slotUsed: const [0, 0, 0, 0, 0, 2],
      );

      expect(
        ShortRestRecoveryEngine.optionsFor(
          character: character,
          rules: _rules,
          bindings: [
            _binding('2024_arcane_recovery', '1', cls: 'Wizard', level: 20),
          ],
        ),
        isEmpty,
      );
    });
  });

  group('Sorcerous Restoration', () {
    final bindings = [
      _binding('2024_sorcerous_restoration', '1', cls: 'Sorcerer', level: 7),
      _binding('2024_sorcery_points', 'sorcerer_level', cls: 'Sorcerer', level: 7),
    ];

    test('regains points up to half the class level rounded down', () {
      final character = _character(
        cls: 'Sorcerer',
        level: 7,
        featureResources: const {'2024_sorcery_points': 1},
      );
      final options = ShortRestRecoveryEngine.optionsFor(
        character: character,
        rules: _rules,
        bindings: bindings,
      );

      expect(options.single.recoverablePoints, 3);

      final recovered = ShortRestRecoveryEngine.apply(
        character,
        options: options,
        selections: const [
          ShortRestRecoverySelection.points('2024_sorcerous_restoration', 3),
        ],
      );
      expect(recovered.featureResources['2024_sorcery_points'], 4);
      expect(recovered.featureResources['2024_sorcerous_restoration'], 0);
    });

    test('limits points to what was spent', () {
      final options = ShortRestRecoveryEngine.optionsFor(
        character: _character(
          cls: 'Sorcerer',
          level: 7,
          featureResources: const {'2024_sorcery_points': 6},
        ),
        rules: _rules,
        bindings: bindings,
      );

      expect(options.single.recoverablePoints, 1);
    });
  });

  test('ignores resources from the other ruleset', () {
    expect(
      ShortRestRecoveryEngine.optionsFor(
        character: _character(),
        rules: _rules,
        bindings: [
          _binding('arcane_recovery', '1', cls: 'Wizard', level: 5),
        ],
      ),
      isEmpty,
    );
  });
}
