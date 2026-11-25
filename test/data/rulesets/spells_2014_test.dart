import 'package:dnd_character_tool/data/datasources/srd/srd_data_source.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_models.dart';
import 'package:dnd_character_tool/data/dice/dice.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:flutter_test/flutter_test.dart';

ContextualRollRequest _roll(SrdSpell spell, {int level = 5, Set<int>? slots}) {
  return ContextualSpellRollBuilder.build(
    character: Character(
      id: 'caster',
      name: 'Test',
      race: 'Human',
      characterClass: 'Druid',
      level: level,
      abilityScores: const AbilityScores(wisdom: 16),
      hitPoints: const HitPoints(maximum: 38, current: 38),
      proficiencyBonus: 3,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    ),
    spell: spell,
    displayName: spell.name,
    attackLabel: 'Attack',
    damageLabel: 'Damage',
    spellSlotChoiceLabel: 'Spell slots',
    slotLevelLabel: (level) => 'Level $level',
    damageTypeLabel: (type) => type,
    availableSlotLevels: slots,
    spellAttackBonus: 6,
  )!;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final source = SrdDataSource.forPack(SrdContentPackRegistry.srd51);

  test(
    'all missing PHB spells are selectable from their 2014 class lists',
    () async {
      // PHB class lists, excluding optional lists introduced in later books.
      const expected = {
        'bard': ['Dissonant Whispers', 'Phantasmal Force'],
        'druid': ['Beast Sense', 'Grasping Vine', 'Thorn Whip'],
        'paladin': [
          'Aura of Life',
          'Aura of Purity',
          'Aura of Vitality',
          'Banishing Smite',
          'Blinding Smite',
          'Circle of Power',
          'Compelled Duel',
          "Crusader's Mantle",
          'Destructive Wave',
          'Elemental Weapon',
          'Searing Smite',
          'Staggering Smite',
          'Thunderous Smite',
        ],
        'ranger': [
          'Beast Sense',
          'Conjure Barrage',
          'Conjure Volley',
          'Cordon of Arrows',
          'Ensnaring Strike',
          'Grasping Vine',
          'Hail of Thorns',
          'Lightning Arrow',
          'Swift Quiver',
        ],
        'sorcerer': ['Chromatic Orb', 'Phantasmal Force', 'Ray of Sickness'],
        'warlock': ['Armor of Agathys', 'Arms of Hadar', 'Hunger of Hadar'],
        'wizard': ['Chromatic Orb', 'Phantasmal Force', 'Ray of Sickness'],
        'cleric': <String>[],
      };
      final additions = expected.values.expand((names) => names).toSet();
      final spells = await source.getSpells();
      expect(additions, hasLength(30));
      expect(spells.map((spell) => spell.name), containsAll(additions));
      expect(
        spells.map((spell) => spell.name).toSet(),
        hasLength(spells.length),
      );
      for (final entry in expected.entries) {
        final available = await source.getSpellsForClass(entry.key);
        expect(
          available.map((spell) => spell.name).where(additions.contains),
          unorderedEquals(entry.value),
          reason: '${entry.key} PHB spell list',
        );
      }
    },
  );

  test(
    'new spells retain expanded subclass access outside their base class',
    () async {
      final spells = {
        for (final spell in await source.getSpells()) spell.name: spell,
      };
      const grants = {
        'Destructive Wave': [('cleric', 'Tempest Domain')],
        "Crusader's Mantle": [('cleric', 'War Domain')],
        'Ensnaring Strike': [('paladin', 'Oath of the Ancients')],
        'Dissonant Whispers': [('warlock', 'The Great Old One')],
        'Phantasmal Force': [
          ('warlock', 'The Archfey'),
          ('warlock', 'The Great Old One'),
        ],
      };
      for (final entry in grants.entries) {
        expect(
          spells[entry.key]!.subclassSpells.map(
            (ref) => (ref.className, ref.subclass),
          ),
          containsAll(entry.value),
          reason: entry.key,
        );
      }
    },
  );

  test(
    '2014 smites keep concentration and do not gain 2024 upcasting',
    () async {
      final spells = {
        for (final spell in await source.getSpells()) spell.name: spell,
      };
      for (final name in [
        'Banishing Smite',
        'Blinding Smite',
        'Staggering Smite',
        'Thunderous Smite',
      ]) {
        final spell = spells[name]!;
        expect(spell.castingTimeType, 'bonus_action', reason: name);
        expect(spell.concentration, isTrue, reason: name);
        expect(spell.higherLevels, isNull, reason: name);
        expect(spell.rolls.single.slotLevelScaling, isEmpty, reason: name);
      }
      for (final name in [
        'Conjure Barrage',
        'Conjure Volley',
        'Hunger of Hadar',
      ]) {
        expect(spells[name]!.higherLevels, isNull, reason: name);
        expect(
          spells[name]!.rolls.every((roll) => roll.slotLevelScaling.isEmpty),
          isTrue,
        );
      }
      expect(spells['Grasping Vine']!.rolls, isEmpty);
      expect(spells['Beast Sense']!.ritual, isTrue);
      expect(spells['Beast Sense']!.components, ['S']);
    },
  );

  test(
    'Hail of Thorns caps at 6d10 while Searing Smite scales its initial hit',
    () async {
      final spells = {
        for (final spell in await source.getSpells()) spell.name: spell,
      };
      final hail =
          _roll(spells['Hail of Thorns']!, slots: {9}).parts.single
              as ContextualExpressionRollPart;
      expect(hail.choices.single.expression, '6d10');
      expect(hail.critical, isFalse);
      final searing =
          _roll(spells['Searing Smite']!, slots: {5}).parts.single
              as ContextualExpressionRollPart;
      expect(searing.choices.single.expression, '5d6');
      expect(searing.critical, isTrue);
      expect(
        spells['Cordon of Arrows']!.rolls.single.slotLevelScaling,
        isEmpty,
      );
    },
  );

  test(
    'Thorn Whip rolls a melee spell attack with total-level cantrip damage',
    () async {
      final spell = (await source.getSpells()).singleWhere(
        (spell) => spell.name == 'Thorn Whip',
      );
      expect(spell.attackType, 'melee');
      expect(spell.rangeInFeet, 30);
      final request = _roll(spell, level: 17);
      expect((request.parts.first as ContextualD20RollPart).d20Modifier, 6);
      final damage = request.parts.last as ContextualExpressionRollPart;
      expect(damage.expression, '4d6');
      expect(damage.choices, isEmpty);
      expect(damage.critical, isTrue);
    },
  );

  test(
    'Chromatic Orb requires a reusable diamond and Ray of Sickness retains its save',
    () async {
      final spells = {
        for (final spell in await source.getSpells()) spell.name: spell,
      };
      final orb = spells['Chromatic Orb']!;
      expect(orb.materialCost, 50);
      expect(orb.materialConsumed, isFalse);
      expect(orb.requiresMaterial, isTrue);
      expect(orb.damageTypes, [
        'acid',
        'cold',
        'fire',
        'lightning',
        'poison',
        'thunder',
      ]);
      final damage =
          _roll(orb, slots: {3}).parts.last as ContextualExpressionRollPart;
      expect(damage.choices.single.expression, '5d8');
      final ray = spells['Ray of Sickness']!;
      expect(ray.attackType, 'ranged');
      expect(ray.saveAttribute, 'CON');
      expect(_roll(ray).parts.first, isA<ContextualD20RollPart>());
      expect(spells['Destructive Wave']!.rolls.map((roll) => roll.formula), [
        '5d6',
        '5d6',
      ]);
    },
  );

  test(
    'Armor of Agathys is available to 2014 warlocks with legacy rules',
    () async {
      final spells = await source.getSpellsForClass('Warlock');
      final spell = spells.singleWhere(
        (spell) => spell.name == 'Armor of Agathys',
      );

      expect(spell.level, 1);
      expect(spell.school, 'abjuration');
      expect(spell.castingTime, '1 action');
      expect(spell.castingTimeType, 'action');
      expect(spell.range, 'Self');
      expect(spell.duration, '1 hour');
      expect(spell.concentration, isFalse);
      expect(spell.ritual, isFalse);
      expect(spell.components, ['V', 'S', 'M']);
      expect(spell.material, 'a cup of water');
      expect(spell.materialConsumed, isFalse);
      expect(spell.classes, ['warlock']);
      expect(spell.attackType, isNull);
      expect(spell.saveAttribute, isNull);
      expect(spell.damageTypes, ['cold']);
      expect(
        (await source.getSpellsForClass(
          'Wizard',
        )).where((spell) => spell.name == 'Armor of Agathys'),
        isEmpty,
      );
    },
  );

  test(
    'Armor of Agathys uses fixed cold damage at the available pact slot',
    () async {
      final spell = (await source.getSpells()).singleWhere(
        (spell) => spell.name == 'Armor of Agathys',
      );
      final character = Character(
        id: 'warlock',
        name: 'Test',
        race: 'Human',
        characterClass: 'Warlock',
        level: 5,
        abilityScores: const AbilityScores(charisma: 16),
        hitPoints: const HitPoints(maximum: 38, current: 38),
        proficiencyBonus: 3,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final request = ContextualSpellRollBuilder.build(
        character: character,
        spell: spell,
        displayName: spell.name,
        attackLabel: 'Attack',
        damageLabel: 'Damage',
        spellSlotChoiceLabel: 'Spell slots',
        slotLevelLabel: (level) => 'Level $level',
        damageTypeLabel: (type) => type,
        availableSlotLevels: {3},
      )!;
      final damage = request.parts.single as ContextualExpressionRollPart;

      expect(damage.expression, '5');
      expect(damage.critical, isFalse);
      expect(damage.label, 'Damage (cold)');
      expect(damage.choices.single.key, 'slot_3');
      expect(damage.choices.single.expression, '15');
      expect(spell.rolls.single.slotLevelScaling[9], '45');
    },
  );
}
