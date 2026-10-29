import 'package:dnd_character_tool/data/feature_usage_engine.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/rest/rest_policy.dart';
import 'package:dnd_character_tool/data/rulesets/ruleset_ids.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2024);

Character _character({
  RulesetId rulesetId = RulesetId.dnd2014,
  String cls = 'Fighter',
  int level = 4,
  HitPoints hitPoints = const HitPoints(maximum: 30, current: 10),
  List<CharacterHitDiePool>? hitDicePools,
  SpellSlots spellSlots = const SpellSlots(),
  SpellSlots pactMagicSlots = const SpellSlots(),
  List<InnateSpell> innateSpells = const [],
  bool inspiration = false,
  int exhaustionLevel = 0,
  String? concentrationSpell,
}) {
  return Character(
    id: 'rest-hero',
    rulesetId: rulesetId,
    contentPackId: rulesetId == RulesetId.dnd2024
        ? ContentPackId.srd521
        : ContentPackId.srd51,
    name: 'Rest Hero',
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
    hitPoints: hitPoints,
    hitDicePools:
        hitDicePools ??
        [
          CharacterHitDiePool(
            dieSize: 10,
            total: level,
            used: level,
            sourceClass: cls,
            sourceClassEntryId: 'primary',
          ),
        ],
    spellSlots: spellSlots,
    pactMagicSlots: pactMagicSlots,
    innateSpells: innateSpells,
    inspiration: inspiration,
    exhaustionLevel: exhaustionLevel,
    concentrationSpell: concentrationSpell,
    createdAt: _now,
    updatedAt: _now,
  );
}

SpellSlots _slots(List<int> total, List<int> used) => SpellSlots(
  total: [...total, ...List.filled(9 - total.length, 0)],
  used: [...used, ...List.filled(9 - used.length, 0)],
);

void main() {
  test('policy follows the character ruleset', () {
    expect(
      RestPolicy.forCharacter(_character()),
      isA<Rest2014Policy>(),
    );
    expect(
      RestPolicy.forCharacter(_character(rulesetId: RulesetId.dnd2024)),
      isA<Rest2024Policy>(),
    );
  });

  group('2014 long rest', () {
    test('recovers half of the hit dice rounded down and resets innate spells', () {
      final rested = const Rest2014Policy().applyLongRest(
        _character(
          level: 5,
          hitPoints: const HitPoints(
            maximum: 40,
            current: 12,
            temporary: 5,
            hitDiceUsed: 5,
          ),
          innateSpells: const [
            InnateSpell(name: 'Darkness', usesPerDay: 1, usedToday: 1),
          ],
          concentrationSpell: 'Bless',
        ),
        featureResources: const {'action_surge': 1},
      );

      expect(rested.hitPoints.current, 40);
      expect(rested.hitPoints.temporary, 0);
      expect(rested.hitDicePools.single.used, 3);
      expect(rested.innateSpells.single.usedToday, 0);
      expect(rested.concentrationSpell, isNull);
      expect(rested.featureResources, {'action_surge': 1});
      expect(rested.inspiration, isFalse);
    });

    test('recovers at least one hit die', () {
      final rested = const Rest2014Policy().applyLongRest(
        _character(level: 1),
        featureResources: const {},
      );

      expect(rested.hitDicePools.single.used, 0);
    });

    test('leaves the 2024 exhaustion level untouched', () {
      final rested = const Rest2014Policy().applyLongRest(
        _character(exhaustionLevel: 2),
        featureResources: const {},
      );

      expect(rested.exhaustionLevel, 2);
    });

    test('does not grant inspiration from a 2024 species trait name', () {
      final rested = const Rest2014Policy().applyLongRest(
        _character(),
        featureResources: const {},
        raceTraits: const ['Resourceful'],
      );

      expect(rested.inspiration, isFalse);
    });
  });

  group('2024 long rest', () {
    test('recovers every spent hit die across pools', () {
      final rested = const Rest2024Policy().applyLongRest(
        _character(
          rulesetId: RulesetId.dnd2024,
          level: 5,
          hitDicePools: const [
            CharacterHitDiePool(dieSize: 10, total: 3, used: 3),
            CharacterHitDiePool(dieSize: 6, total: 2, used: 1),
          ],
          hitPoints: const HitPoints(
            maximum: 40,
            current: 3,
            temporary: 4,
            hitDiceUsed: 4,
          ),
        ),
        featureResources: const {},
      );

      expect(rested.hitDicePools.map((pool) => pool.used), [0, 0]);
      expect(rested.hitPoints.hitDiceUsed, 0);
      expect(rested.hitPoints.current, 40);
      expect(rested.hitPoints.temporary, 0);
    });

    test('restores spell slots, Pact Magic and ends concentration', () {
      final rested = const Rest2024Policy().applyLongRest(
        _character(
          rulesetId: RulesetId.dnd2024,
          cls: 'Warlock',
          spellSlots: _slots([2], [2]),
          pactMagicSlots: _slots([1], [1]),
          concentrationSpell: 'Hex',
        ),
        featureResources: const {},
      );

      expect(rested.spellSlots.used, List.filled(9, 0));
      expect(rested.spellSlots.total.first, 2);
      expect(rested.pactMagicSlots.used, List.filled(9, 0));
      expect(rested.pactMagicSlots.total.first, 1);
      expect(rested.concentrationSpell, isNull);
    });

    test('clears death saves once HP is regained', () {
      final rested = const Rest2024Policy().applyLongRest(
        _character(
          rulesetId: RulesetId.dnd2024,
          hitPoints: const HitPoints(
            maximum: 20,
            current: 1,
            deathSaveSuccesses: 2,
            deathSaveFailures: 1,
          ),
        ),
        featureResources: const {},
      );

      expect(rested.hitPoints.deathSaveSuccesses, 0);
      expect(rested.hitPoints.deathSaveFailures, 0);
    });

    test('removes one Exhaustion level', () {
      final policy = const Rest2024Policy();
      Character rest(int level) => policy.applyLongRest(
        _character(rulesetId: RulesetId.dnd2024, exhaustionLevel: level),
        featureResources: const {},
      );

      expect(rest(3).exhaustionLevel, 2);
      expect(rest(1).exhaustionLevel, 0);
      expect(rest(0).exhaustionLevel, 0);
    });

    test('Resourceful grants Heroic Inspiration', () {
      final rested = const Rest2024Policy().applyLongRest(
        _character(rulesetId: RulesetId.dnd2024),
        featureResources: const {},
        raceTraits: const ['Skillful', 'Resourceful', 'Versatile'],
      );

      expect(rested.inspiration, isTrue);
    });

    test('keeps unspent Heroic Inspiration without Resourceful', () {
      final policy = const Rest2024Policy();
      final kept = policy.applyLongRest(
        _character(rulesetId: RulesetId.dnd2024, inspiration: true),
        featureResources: const {},
        raceTraits: const ['Darkvision'],
      );
      final none = policy.applyLongRest(
        _character(rulesetId: RulesetId.dnd2024),
        featureResources: const {},
        raceTraits: const ['Darkvision'],
      );

      expect(kept.inspiration, isTrue);
      expect(none.inspiration, isFalse);
    });
  });

  group('2024 short rest', () {
    test('spends hit dice by pool and clamps HP to the maximum', () {
      final rested = const Rest2024Policy().applyShortRest(
        _character(
          rulesetId: RulesetId.dnd2024,
          hitDicePools: const [
            CharacterHitDiePool(dieSize: 10, total: 3, used: 1),
            CharacterHitDiePool(dieSize: 6, total: 2),
          ],
          hitPoints: const HitPoints(maximum: 30, current: 25),
        ),
        hitDiceSpentByPool: const [5, 1],
        hpGained: 20,
      );

      expect(rested.hitDicePools.map((pool) => pool.used), [3, 1]);
      expect(rested.hitPoints.hitDiceUsed, 4);
      expect(rested.hitPoints.current, 30);
    });

    test('recovers only Pact Magic and keeps saved slot totals', () {
      final rested = const Rest2024Policy().applyShortRest(
        _character(
          rulesetId: RulesetId.dnd2024,
          cls: 'Warlock',
          spellSlots: _slots([2], [1]),
          pactMagicSlots: _slots([1], [1]),
        ),
        hitDiceSpentByPool: const [],
        hpGained: 0,
      );

      expect(rested.pactMagicSlots.used, List.filled(9, 0));
      expect(rested.pactMagicSlots.total.first, 1);
      expect(rested.spellSlots.used.first, 1);
      expect(rested.spellSlots.total.first, 2);
    });

    test('has no 2014 Sorcerous Restoration bonus', () {
      const context = FeatureUsageContext(
        totalCharacterLevel: 20,
        sourceClass: 'Sorcerer',
        sourceClassLevel: 20,
      );
      const resource = FeatureUsageResource(
        id: 'sorcery_points',
        name: 'Sorcery Points',
        maxFormula: 'sorcerer_level',
        recharge: 'long_rest',
      );

      expect(
        const Rest2014Policy().shortRestBonusRecovery(
          resource: resource,
          usageContext: context,
          current: 10,
          max: 20,
        ),
        14,
      );
      expect(
        const Rest2024Policy().shortRestBonusRecovery(
          resource: resource,
          usageContext: context,
          current: 10,
          max: 20,
        ),
        isNull,
      );
    });
  });

  test('2024 dialog never builds pools from the 2014 hit die table', () {
    expect(
      const Rest2024Policy().hitDicePoolsFor(
        _character(rulesetId: RulesetId.dnd2024, hitDicePools: const []),
      ),
      isEmpty,
    );
    expect(
      const Rest2014Policy()
          .hitDicePoolsFor(_character(hitDicePools: const []))
          .single
          .dieSize,
      10,
    );
  });
}
