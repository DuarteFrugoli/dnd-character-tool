import 'package:dnd_character_tool/data/datasources/srd/srd_data_source.dart';
import 'package:dnd_character_tool/data/dice/contextual_roll.dart';
import 'package:dnd_character_tool/data/dice/contextual_spell_roll_builder.dart';
import 'package:dnd_character_tool/data/dice/contextual_weapon_roll_builder.dart';
import 'package:dnd_character_tool/data/feature_choice_engine.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/rulesets/ruleset_ids.dart';
import 'package:dnd_character_tool/data/rulesets/spell_roll_rules.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:dnd_character_tool/data/rulesets/weapon_mastery_rules.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character({
  required String className,
  int level = 1,
  RulesetId ruleset = RulesetId.dnd2024,
  List<CharacterFeatureChoice> choices = const [],
  AbilityScores scores = const AbilityScores(strength: 16, dexterity: 14, charisma: 16),
}) {
  final now = DateTime(2024);
  return Character(
    id: 'hero',
    rulesetId: ruleset,
    contentPackId: ruleset == RulesetId.dnd2024 ? ContentPackId.srd521 : ContentPackId.srd51,
    name: 'Hero',
    race: 'Human',
    characterClass: className,
    level: level,
    classes: [
      CharacterClassEntry(id: 'primary', className: className, level: level, isStartingClass: true),
    ],
    proficiencyBonus: level >= 9 ? 4 : (level >= 5 ? 3 : 2),
    abilityScores: scores,
    hitPoints: const HitPoints(maximum: 12, current: 12),
    featureChoices: choices,
    createdAt: now,
    updatedAt: now,
  );
}

CharacterFeatureChoice _masteries(String className, List<String> weapons) => CharacterFeatureChoice(
  sourceType: FeatureChoiceSourceType.classFeature,
  sourceClass: className,
  sourceClassEntryId: 'primary',
  featureName: WeaponMasteryRules.featureName,
  choiceId: WeaponMasteryRules.choiceId,
  values: weapons,
);

CharacterFeatureChoice _invocations(List<String> values) => CharacterFeatureChoice(
  sourceType: FeatureChoiceSourceType.classFeature,
  sourceClass: 'Warlock',
  sourceClassEntryId: 'primary',
  featureName: SpellRollRules.invocationsFeature,
  choiceId: 'invocations',
  values: values,
);

EquipmentItem _weapon(String name, String mastery, {String damage = '1d8', int bonus = 0}) =>
    EquipmentItem(
      id: name,
      name: name,
      category: 'Martial Melee',
      itemType: ItemType.weapon,
      properties: {
        'damageDice': damage,
        'damageType': 'slashing',
        'mastery': mastery,
        'bonus': bonus,
      },
    );

WeaponAttackStats _stats(Character character, EquipmentItem item) =>
    ContextualWeaponRollBuilder.statsFor(
      character: character,
      item: item,
      weaponProficiencies: const ['Simple weapons', 'Martial weapons'],
    )!;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Weapon Mastery', () {
    test('applies only to the weapon kinds the character chose', () {
      final fighter = _character(
        className: 'Fighter',
        choices: [_masteries('Fighter', ['longsword', 'greataxe', 'handaxe'])],
      );
      final longsword = _weapon('Longsword', 'sap');
      expect(WeaponMasteryRules.masteryOf(fighter, longsword), 'sap');
      expect(WeaponMasteryRules.masteryOf(fighter, _weapon('Rapier', 'vex')), isNull);
      final sap = WeaponMasteryRules.effectFor(fighter, longsword, _stats(fighter, longsword))!;
      expect(sap.mastery, 'sap');
      expect(sap.alternatives, isEmpty, reason: 'Tactical Master starts at Fighter 9');

      final legacy = _character(
        className: 'Fighter',
        ruleset: RulesetId.dnd2014,
        choices: [_masteries('Fighter', ['longsword'])],
      );
      expect(WeaponMasteryRules.masteryOf(legacy, longsword), isNull);
    });

    test('computes Graze, Topple and Cleave values', () {
      final barbarian = _character(
        className: 'Barbarian',
        level: 5,
        choices: [_masteries('Barbarian', ['greataxe', 'maul', 'battleaxe'])],
      );
      final greataxe = _weapon('Greataxe', 'cleave', damage: '1d12', bonus: 1);
      final cleave = WeaponMasteryRules.effectFor(barbarian, greataxe, _stats(barbarian, greataxe))!;
      expect(cleave.cleaveAttackBonus, 3 + 1 + 3);
      expect(cleave.cleaveDamage, '1d12+1', reason: 'no positive Strength, but the magic bonus stays');

      final maul = _weapon('Maul', 'topple', damage: '2d6');
      expect(WeaponMasteryRules.effectFor(barbarian, maul, _stats(barbarian, maul))!.toppleDc, 8 + 3 + 3);

      final battleaxe = _weapon('Battleaxe', 'graze');
      expect(WeaponMasteryRules.effectFor(barbarian, battleaxe, _stats(barbarian, battleaxe))!.grazeDamage, 3);

      final weak = _character(
        className: 'Barbarian',
        choices: [_masteries('Barbarian', ['battleaxe'])],
        scores: const AbilityScores(strength: 8),
      );
      expect(WeaponMasteryRules.effectFor(weak, battleaxe, _stats(weak, battleaxe))!.grazeDamage, 0);
    });

    test('Tactical Master offers Push, Sap and Slow from Fighter level 9', () {
      final fighter = _character(
        className: 'Fighter',
        level: 9,
        choices: [_masteries('Fighter', ['longsword'])],
      );
      final longsword = _weapon('Longsword', 'sap');
      final effect = WeaponMasteryRules.effectFor(fighter, longsword, _stats(fighter, longsword))!;
      expect(effect.alternatives, ['push', 'slow']);
    });

    test('the weapon roll carries the mastery notes', () {
      final fighter = _character(className: 'Fighter');
      const note = ContextualRollNote(title: 'Mastery: Sap', text: 'Disadvantage.');
      final request = ContextualWeaponRollBuilder.build(
        character: fighter,
        item: _weapon('Longsword', 'sap'),
        displayName: 'Longsword',
        attackLabel: 'Attack',
        damageLabel: 'Damage',
        extraDamageLabel: 'Extra',
        versatileGripLabel: 'Grip',
        versatileOneHandedLabel: 'One',
        versatileTwoHandedLabel: 'Two',
        weaponProficiencies: const ['Martial weapons'],
        notes: const [note],
      )!;
      expect(request.notes.single.title, note.title);
    });
  });

  group('Agonizing Blast', () {
    late Map<String, dynamic> spells;

    setUpAll(() async {
      final srd = SrdDataSource.forPack(SrdContentPackRegistry.srd521);
      spells = {for (final spell in await srd.getSpells()) spell.name: spell};
    });

    test('adds the Charisma modifier to the chosen cantrip only', () {
      final warlock = _character(
        className: 'Warlock',
        level: 5,
        choices: [_invocations(['agonizing_blast@Eldritch Blast', 'armor_of_shadows'])],
      );
      expect(SpellRollRules.damageBonus(warlock, 'Eldritch Blast'), 3);
      expect(SpellRollRules.damageBonus(warlock, 'Chill Touch'), 0);
      expect(
        SpellRollRules.damageBonus(_character(className: 'Warlock', level: 5), 'Eldritch Blast'),
        0,
      );
      final request = ContextualSpellRollBuilder.build(
        character: warlock,
        spell: spells['Eldritch Blast'],
        displayName: 'Eldritch Blast',
        attackLabel: 'Attack',
        damageLabel: 'Damage',
        spellSlotChoiceLabel: 'Slot',
        slotLevelLabel: (level) => '$level',
        damageTypeLabel: (type) => type,
        spellAttackBonus: 6,
        damageBonus: SpellRollRules.damageBonus(warlock, 'Eldritch Blast'),
      )!;
      final damage = request.parts.whereType<ContextualExpressionRollPart>().single;
      expect(damage.expression, '1d10+3');
    });

    test('Eldritch Blast beams grow at levels 5, 11 and 17', () {
      expect(SpellRollRules.beams('Eldritch Blast', 4), 1);
      expect(SpellRollRules.beams('Eldritch Blast', 5), 2);
      expect(SpellRollRules.beams('Eldritch Blast', 11), 3);
      expect(SpellRollRules.beams('Eldritch Blast', 17), 4);
      expect(SpellRollRules.beams('Fire Bolt', 17), 1);
    });
  });
}
