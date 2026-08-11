import 'package:dnd_character_tool/data/character_progression/character_progression.dart';
import 'package:dnd_character_tool/data/constants/level_up_rules.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_models.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character({
  String cls = 'Fighter',
  String? subclass,
  int level = 1,
  AbilityScores scores = const AbilityScores(),
  HitPoints hp = const HitPoints(maximum: 10, current: 10),
  List<CharacterClassEntry> classes = const [],
  List<CharacterHitDiePool> hitDicePools = const [],
  List<KnownSpell> spells = const [],
  List<CharacterExtraFeature> extraFeatures = const [],
}) {
  final now = DateTime(2024);
  return Character(
    id: 'character-id',
    name: 'Test Hero',
    race: 'Human',
    characterClass: cls,
    subclass: subclass,
    level: level,
    classes: classes,
    abilityScores: scores,
    hitPoints: hp,
    hitDicePools: hitDicePools,
    spells: spells,
    extraFeatures: extraFeatures,
    createdAt: now,
    updatedAt: now,
  );
}

LevelUpResult _levelUpResult({
  String targetClassEntryId = 'primary',
  String targetClassName = 'Fighter',
  int oldTotalLevel = 1,
  int newTotalLevel = 2,
  int oldClassLevel = 1,
  int newClassLevel = 2,
  int targetHitDie = 10,
  int hpGained = 6,
  Map<String, int> asiChanges = const {},
  SrdFeat? featChosen,
  String? subclassChosen,
  List<KnownSpell> cantripsLearned = const [],
  List<KnownSpell> spellsLearned = const [],
  String? spellSwapped,
}) {
  return LevelUpResult(
    targetClassEntryId: targetClassEntryId,
    targetClassName: targetClassName,
    oldTotalLevel: oldTotalLevel,
    newTotalLevel: newTotalLevel,
    oldClassLevel: oldClassLevel,
    newClassLevel: newClassLevel,
    targetHitDie: targetHitDie,
    hpGained: hpGained,
    asiChanges: asiChanges,
    featChosen: featChosen,
    subclassChosen: subclassChosen,
    cantripsLearned: cantripsLearned,
    spellsLearned: spellsLearned,
    spellSwapped: spellSwapped,
  );
}

void main() {
  group('CharacterProgressionEngine.applyLevelUp', () {
    test('updates an existing single-class character', () {
      final character = _character(
        level: 3,
        scores: const AbilityScores(strength: 12),
        hp: const HitPoints(maximum: 25, current: 20),
        classes: const [
          CharacterClassEntry(
            id: 'primary',
            className: 'Fighter',
            level: 3,
            isStartingClass: true,
          ),
        ],
        hitDicePools: const [
          CharacterHitDiePool(
            dieSize: 10,
            total: 3,
            used: 1,
            sourceClass: 'Fighter',
            sourceClassEntryId: 'primary',
          ),
        ],
      );

      final updated = CharacterProgressionEngine.applyLevelUp(
        character,
        _levelUpResult(
          oldTotalLevel: 3,
          newTotalLevel: 4,
          oldClassLevel: 3,
          newClassLevel: 4,
          hpGained: 7,
          asiChanges: const {'strength': 2},
        ),
      );

      expect(updated.level, 4);
      expect(updated.totalLevel, 4);
      expect(updated.characterClass, 'Fighter');
      expect(updated.primaryClassName, 'Fighter');
      expect(updated.classLevel('Fighter'), 4);
      expect(updated.classLevelSummary, 'Fighter 4');
      expect(updated.proficiencyBonus, 2);
      expect(updated.abilityScores.strength, 14);
      expect(updated.hitPoints.maximum, 32);
      expect(updated.hitPoints.current, 27);
      expect(updated.hitDicePools.single.total, 4);
      expect(updated.hitDicePools.single.used, 1);
    });

    test('adds a second class without replacing the starting class mirror', () {
      final character = _character(
        level: 3,
        classes: const [
          CharacterClassEntry(
            id: 'fighter',
            className: 'Fighter',
            level: 3,
            isStartingClass: true,
          ),
        ],
        hitDicePools: const [
          CharacterHitDiePool(
            dieSize: 10,
            total: 3,
            sourceClass: 'Fighter',
            sourceClassEntryId: 'fighter',
          ),
        ],
      );

      final updated = CharacterProgressionEngine.applyLevelUp(
        character,
        _levelUpResult(
          targetClassEntryId: 'wizard',
          targetClassName: 'Wizard',
          oldTotalLevel: 3,
          newTotalLevel: 4,
          oldClassLevel: 0,
          newClassLevel: 1,
          targetHitDie: 6,
          hpGained: 4,
          cantripsLearned: const [
            KnownSpell(name: 'Fire Bolt', level: 0),
          ],
        ),
      );

      expect(updated.isMulticlass, isTrue);
      expect(updated.level, 4);
      expect(updated.totalLevel, 4);
      expect(updated.characterClass, 'Fighter');
      expect(updated.classLevelSummary, 'Fighter 3 / Wizard 1');
      expect(updated.classLevel('Fighter'), 3);
      expect(updated.classLevel('Wizard'), 1);
      expect(updated.hitDicePools, hasLength(2));
      expect(
        updated.hitDicePools.singleWhere(
          (pool) => pool.sourceClassEntryId == 'wizard',
        ).dieSize,
        6,
      );
      expect(updated.spells.single.sourceClassEntryId, 'wizard');
      expect(updated.spells.single.sourceClass, 'Wizard');
      expect(updated.spells.single.sourceType, 'class');
      expect(updated.spellSlots.total[0], 2);
    });

    test('does not duplicate a feat extra feature', () {
      const alert = SrdFeat(
        name: 'Alert',
        description: 'Always on the lookout for danger.',
      );
      final character = _character(
        level: 3,
        extraFeatures: const [
          CharacterExtraFeature(
            sourceClass: 'Feat',
            sourceType: 'feat',
            sourceFeature: 'Alert',
            name: 'Alert',
            level: 1,
            type: 'passive',
            description: 'Always on the lookout for danger.',
          ),
        ],
      );

      final updated = CharacterProgressionEngine.applyLevelUp(
        character,
        _levelUpResult(
          oldTotalLevel: 3,
          newTotalLevel: 4,
          oldClassLevel: 3,
          newClassLevel: 4,
          featChosen: alert,
        ),
      );

      expect(
        updated.extraFeatures
            .where((feature) => feature.name == 'Alert')
            .length,
        1,
      );
    });

    test('removes swapped spell and appends learned spells', () {
      final character = _character(
        cls: 'Warlock',
        level: 2,
        spells: const [
          KnownSpell(name: 'Hex', level: 1),
          KnownSpell(name: 'Armor of Agathys', level: 1),
        ],
      );

      final updated = CharacterProgressionEngine.applyLevelUp(
        character,
        _levelUpResult(
          targetClassName: 'Warlock',
          oldTotalLevel: 2,
          newTotalLevel: 3,
          oldClassLevel: 2,
          newClassLevel: 3,
          targetHitDie: 8,
          spellSwapped: 'Hex',
          spellsLearned: const [
            KnownSpell(name: 'Misty Step', level: 2),
          ],
        ),
      );

      expect(updated.spells.map((spell) => spell.name), [
        'Armor of Agathys',
        'Misty Step',
      ]);
      expect(updated.spellSlots.total[1], 2);
    });
  });

  group('CharacterProgressionEngine helpers', () {
    test('normalizes class entries with one starting class', () {
      final character = _character(
        classes: const [
          CharacterClassEntry(id: '', className: 'Fighter', level: 2),
          CharacterClassEntry(
            id: 'wizard',
            className: 'Wizard',
            level: 1,
            isStartingClass: true,
          ),
        ],
      );

      final entries = CharacterProgressionEngine.normalizeClassEntries(
        character,
      );

      expect(entries.first.id, 'class_1');
      expect(entries.first.isStartingClass, isFalse);
      expect(entries.last.isStartingClass, isTrue);
    });
  });
}
