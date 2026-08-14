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
  SpellSlots spellSlots = const SpellSlots(),
  SpellSlots pactMagicSlots = const SpellSlots(),
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
    spellSlots: spellSlots,
    pactMagicSlots: pactMagicSlots,
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
  List<String> skillProficienciesGained = const [],
  List<String> proficiencyFeatureLabelsGained = const [],
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
    skillProficienciesGained: skillProficienciesGained,
    proficiencyFeatureLabelsGained: proficiencyFeatureLabelsGained,
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
          cantripsLearned: const [KnownSpell(name: 'Fire Bolt', level: 0)],
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
        updated.hitDicePools
            .singleWhere((pool) => pool.sourceClassEntryId == 'wizard')
            .dieSize,
        6,
      );
      expect(updated.spells.single.sourceClassEntryId, 'wizard');
      expect(updated.spells.single.sourceClass, 'Wizard');
      expect(updated.spells.single.sourceType, 'class');
      expect(updated.spellSlots.total[0], 2);
    });

    test('adds multiclass proficiencies without duplicates', () {
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
      ).copyWith(
        skillProficiencies: const ['athletics'],
        features: const ['Armor Proficiency: light armor'],
      );

      final updated = CharacterProgressionEngine.applyLevelUp(
        character,
        _levelUpResult(
          targetClassEntryId: 'rogue',
          targetClassName: 'Rogue',
          oldTotalLevel: 3,
          newTotalLevel: 4,
          oldClassLevel: 0,
          newClassLevel: 1,
          targetHitDie: 8,
          hpGained: 5,
          skillProficienciesGained: const ['stealth', 'athletics'],
          proficiencyFeatureLabelsGained: const [
            'Armor Proficiency: light armor',
            "Tool Proficiency: Thieves' tools",
          ],
        ),
      );

      expect(updated.skillProficiencies, ['athletics', 'stealth']);
      expect(
        updated.features.where((f) => f == 'Armor Proficiency: light armor'),
        hasLength(1),
      );
      expect(updated.features, contains("Tool Proficiency: Thieves' tools"));
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
          spellsLearned: const [KnownSpell(name: 'Misty Step', level: 2)],
        ),
      );

      expect(updated.spells.map((spell) => spell.name), [
        'Armor of Agathys',
        'Misty Step',
      ]);
      expect(updated.spellSlots.total.every((total) => total == 0), isTrue);
      expect(updated.pactMagicSlots.total[1], 2);
    });

    test(
      'keeps standard and pact magic slots separate after multiclassing',
      () {
        final character = _character(
          cls: 'Wizard',
          level: 3,
          classes: const [
            CharacterClassEntry(
              id: 'wizard',
              className: 'Wizard',
              level: 3,
              isStartingClass: true,
            ),
          ],
          hitDicePools: const [
            CharacterHitDiePool(
              dieSize: 6,
              total: 3,
              sourceClass: 'Wizard',
              sourceClassEntryId: 'wizard',
            ),
          ],
          spellSlots: const SpellSlots(
            total: [4, 2, 0, 0, 0, 0, 0, 0, 0],
            used: [1, 0, 0, 0, 0, 0, 0, 0, 0],
          ),
        );

        final updated = CharacterProgressionEngine.applyLevelUp(
          character,
          _levelUpResult(
            targetClassEntryId: 'warlock',
            targetClassName: 'Warlock',
            oldTotalLevel: 3,
            newTotalLevel: 4,
            oldClassLevel: 0,
            newClassLevel: 1,
            targetHitDie: 8,
            hpGained: 5,
          ),
        );

        expect(updated.spellSlots.total, [4, 2, 0, 0, 0, 0, 0, 0, 0]);
        expect(updated.spellSlots.used[0], 1);
        expect(updated.pactMagicSlots.total, [1, 0, 0, 0, 0, 0, 0, 0, 0]);
        expect(updated.pactMagicSlots.used, List<int>.filled(9, 0));
      },
    );
  });

  group('CharacterLevelResetEngine.resetToLevelOne', () {
    test('preserves sheet data and removes identifiable progression data', () {
      final note = CharacterNote(
        id: 'note-1',
        title: 'Plot',
        content: 'Meet the baron.',
        createdAt: DateTime(2024),
      );
      final backpack = EquipmentItem(
        id: 'item-1',
        name: 'Backpack',
        category: 'gear',
        itemType: ItemType.container,
        weight: 5,
      );
      final character = _character(
        cls: 'Wizard',
        subclass: 'School of Evocation',
        level: 5,
        scores: const AbilityScores(dexterity: 16, constitution: 14),
        hp: const HitPoints(maximum: 32, current: 20, hitDiceUsed: 2),
        classes: const [
          CharacterClassEntry(
            id: 'primary',
            className: 'Wizard',
            subclassName: 'School of Evocation',
            level: 5,
            isStartingClass: true,
          ),
        ],
        hitDicePools: const [
          CharacterHitDiePool(
            dieSize: 6,
            total: 5,
            used: 2,
            sourceClass: 'Wizard',
            sourceClassEntryId: 'primary',
          ),
        ],
        spells: const [
          KnownSpell(
            name: 'Magic Missile',
            level: 1,
            sourceType: 'class',
            sourceClass: 'Wizard',
            sourceClassEntryId: 'primary',
          ),
          KnownSpell(
            name: 'Dancing Lights',
            level: 0,
            sourceType: 'raceTrait',
            sourceFeature: 'Drow Magic',
          ),
        ],
        extraFeatures: const [
          CharacterExtraFeature(
            sourceClass: 'Wizard',
            sourceType: 'classFeature',
            sourceClassEntryId: 'primary',
            name: 'Arcane Recovery',
            level: 1,
            type: 'active',
            description: 'Recover spell slots.',
          ),
          CharacterExtraFeature(
            sourceClass: 'Feat',
            sourceType: 'feat',
            sourceFeature: 'Alert',
            name: 'Alert',
            level: 4,
            type: 'passive',
            description: 'ASI feat.',
          ),
          CharacterExtraFeature(
            sourceClass: 'Feat',
            sourceType: 'feat',
            sourceFeature: 'Lucky',
            name: 'Lucky',
            level: 1,
            type: 'passive',
            description: 'Racial feat.',
          ),
          CharacterExtraFeature(
            sourceClass: 'Custom',
            sourceType: 'manual',
            name: 'Campaign Gift',
            level: 1,
            type: 'passive',
            description: 'A manual feature.',
          ),
        ],
      ).copyWith(
        equipment: [backpack],
        currency: const {'cp': 1, 'sp': 2, 'ep': 3, 'gp': 4, 'pp': 5},
        notes: [note],
        imagePath: 'indexeddb:image:abc',
        skillProficiencies: const ['arcana'],
        features: const ['Manual marker'],
        featureChoices: const [
          CharacterFeatureChoice(
            sourceType: 'classFeature',
            sourceClass: 'Wizard',
            sourceClassEntryId: 'primary',
            featureName: 'Arcane Recovery',
            choiceId: 'recovery',
            values: ['slot'],
          ),
          CharacterFeatureChoice(
            sourceType: 'subclassFeature',
            sourceClass: 'Wizard',
            sourceClassEntryId: 'primary',
            sourceSubclass: 'School of Evocation',
            featureName: 'Savant',
            choiceId: 'school',
            values: ['evocation'],
          ),
          CharacterFeatureChoice(
            sourceType: 'raceTrait',
            sourceName: 'Variant Human',
            featureName: 'Feat',
            choiceId: 'feat',
            values: ['lucky'],
          ),
          CharacterFeatureChoice(
            sourceType: 'feat',
            sourceName: 'Lucky',
            featureName: 'Lucky',
            choiceId: 'luck_source',
            values: ['variant_human'],
          ),
        ],
        featureResources: const {'Arcane Recovery': 1},
        disabledFeatures: const ['class:primary:Arcane Recovery'],
        disabledSpells: const ['Magic Missile'],
        concentrationSpell: 'Magic Missile',
      );

      final updated = CharacterLevelResetEngine.resetToLevelOne(
        character,
        const CharacterLevelResetResult(
          className: 'Barbarian',
          hitDie: 12,
          savingThrowProficiencies: ['strength', 'constitution'],
          skillProficiencies: ['athletics'],
          proficiencyFeatureLabels: ["Tool Proficiency: Smith's tools"],
        ),
      );

      expect(updated.name, character.name);
      expect(updated.race, character.race);
      expect(updated.equipment, same(character.equipment));
      expect(updated.currency, character.currency);
      expect(updated.notes, same(character.notes));
      expect(updated.imagePath, character.imagePath);

      expect(updated.level, 1);
      expect(updated.totalLevel, 1);
      expect(updated.characterClass, 'Barbarian');
      expect(updated.subclass, isNull);
      expect(updated.classes.single.className, 'Barbarian');
      expect(updated.classes.single.level, 1);
      expect(updated.experiencePoints, 0);
      expect(updated.proficiencyBonus, 2);
      expect(updated.hitPoints.maximum, 14);
      expect(updated.hitPoints.current, 14);
      expect(updated.hitPoints.hitDiceUsed, 0);
      expect(updated.hitDicePools.single.dieSize, 12);
      expect(updated.hitDicePools.single.total, 1);
      expect(updated.hitDicePools.single.used, 0);
      expect(updated.armorClass, 15);

      expect(updated.savingThrowProficiencies, ['strength', 'constitution']);
      expect(updated.skillProficiencies, ['arcana', 'athletics']);
      expect(updated.features, [
        'Manual marker',
        "Tool Proficiency: Smith's tools",
      ]);
      expect(
        updated.spells.map((spell) => spell.name),
        ['Dancing Lights'],
      );
      expect(
        updated.extraFeatures.map((feature) => feature.name),
        ['Lucky', 'Campaign Gift'],
      );
      expect(
        updated.featureChoices.map((choice) => choice.sourceType),
        ['raceTrait', 'feat'],
      );
      expect(updated.featureChoices.last.sourceName, 'Lucky');
      expect(updated.featureResources, isEmpty);
      expect(updated.disabledFeatures, isEmpty);
      expect(updated.disabledSpells, isEmpty);
      expect(updated.concentrationSpell, isNull);
    });

    test('sets level 1 subclass and syncs class spell slots', () {
      final character = _character(
        cls: 'Fighter',
        level: 8,
        scores: const AbilityScores(constitution: 12),
      );

      final updated = CharacterLevelResetEngine.resetToLevelOne(
        character,
        const CharacterLevelResetResult(
          className: 'Cleric',
          subclassName: 'Life Domain',
          hitDie: 8,
          savingThrowProficiencies: ['wisdom', 'charisma'],
          spells: [KnownSpell(name: 'Sacred Flame', level: 0)],
          featureChoices: [
            CharacterFeatureChoice(
              sourceType: 'subclassFeature',
              sourceClass: 'Cleric',
              sourceClassEntryId: 'primary',
              sourceSubclass: 'Life Domain',
              featureName: 'Bonus Proficiency',
              choiceId: 'proficiency',
              values: ['heavy armor'],
            ),
          ],
        ),
      );

      expect(updated.characterClass, 'Cleric');
      expect(updated.subclass, 'Life Domain');
      expect(updated.primaryClass.subclassName, 'Life Domain');
      expect(updated.hitPoints.maximum, 9);
      expect(updated.spellSlots.total, [2, 0, 0, 0, 0, 0, 0, 0, 0]);
      expect(updated.pactMagicSlots.total, List<int>.filled(9, 0));
      expect(updated.spells.single.sourceType, 'class');
      expect(updated.spells.single.sourceClass, 'Cleric');
      expect(updated.spells.single.sourceSubclass, 'Life Domain');
      expect(updated.spells.single.sourceClassEntryId, 'primary');
      expect(updated.featureChoices.single.choiceId, 'proficiency');
    });

    test('supports atomic rebuild by applying level ups after reset', () {
      final original = _character(
        cls: 'Wizard',
        level: 5,
        scores: const AbilityScores(constitution: 12),
        hp: const HitPoints(maximum: 32, current: 18, hitDiceUsed: 2),
        classes: const [
          CharacterClassEntry(
            id: 'primary',
            className: 'Wizard',
            level: 5,
            isStartingClass: true,
          ),
        ],
        hitDicePools: const [
          CharacterHitDiePool(
            dieSize: 6,
            total: 5,
            used: 2,
            sourceClass: 'Wizard',
            sourceClassEntryId: 'primary',
          ),
        ],
      );

      var rebuilt = CharacterLevelResetEngine.resetToLevelOne(
        original,
        const CharacterLevelResetResult(
          className: 'Fighter',
          hitDie: 10,
          savingThrowProficiencies: ['strength', 'constitution'],
        ),
      );

      rebuilt = CharacterProgressionEngine.applyLevelUp(
        rebuilt,
        _levelUpResult(
          targetClassName: 'Fighter',
          oldTotalLevel: 1,
          newTotalLevel: 2,
          oldClassLevel: 1,
          newClassLevel: 2,
          targetHitDie: 10,
          hpGained: 7,
        ),
      );
      rebuilt = CharacterProgressionEngine.applyLevelUp(
        rebuilt,
        _levelUpResult(
          targetClassEntryId: 'wizard',
          targetClassName: 'Wizard',
          oldTotalLevel: 2,
          newTotalLevel: 3,
          oldClassLevel: 0,
          newClassLevel: 1,
          targetHitDie: 6,
          hpGained: 4,
        ),
      );

      expect(rebuilt.totalLevel, 3);
      expect(rebuilt.characterClass, 'Fighter');
      expect(rebuilt.classEntries.map((entry) => entry.className), [
        'Fighter',
        'Wizard',
      ]);
      expect(rebuilt.classEntries.map((entry) => entry.level), [2, 1]);
      expect(rebuilt.hitDicePools.map((pool) => pool.dieSize), [10, 6]);
      expect(rebuilt.hitDicePools.map((pool) => pool.total), [2, 1]);
      expect(rebuilt.hitPoints.maximum, 22);
      expect(rebuilt.hitPoints.current, 22);
      expect(rebuilt.spellSlots.total, [2, 0, 0, 0, 0, 0, 0, 0, 0]);
      expect(rebuilt.pactMagicSlots.total, List<int>.filled(9, 0));
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
