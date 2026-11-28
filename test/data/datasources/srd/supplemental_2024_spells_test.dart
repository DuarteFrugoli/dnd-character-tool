import 'package:dnd_character_tool/data/datasources/srd/srd_data_source.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_models.dart';
import 'package:dnd_character_tool/data/dice/dice.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/rulesets/ruleset_ids.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, SrdSpell> spells;

  setUpAll(() async {
    final list = await SrdDataSource.forPack(SrdContentPackRegistry.srd521).getSpells();
    spells = {for (final spell in list) spell.name: spell};
    expect(spells, hasLength(list.length), reason: 'spell names must be unique');
  });

  test('the 2024 catalog has the 391 Player\'s Handbook spells', () {
    expect(spells, hasLength(391));
    for (final name in [
      'Blade Ward', 'Thunderclap', 'Toll the Dead', 'Word of Radiance',
      'Armor of Agathys', 'Witch Bolt', 'Arcane Vigor', 'Summon Undead',
      'Jallarzi\'s Storm of Radiance', 'Tasha\'s Bubbling Cauldron',
      'Power Word Fortify', 'Telepathy',
    ]) {
      expect(spells, contains(name));
    }
    // Dropped or renamed in 2024.
    for (final name in ['Branding Smite', 'Whirlwind', 'Feeblemind', 'Shadow Blade']) {
      expect(spells, isNot(contains(name)));
    }
  });

  test('new spells join their 2024 class lists', () {
    List<String> listOf(String cls) => [
      for (final spell in spells.values)
        if (spell.classes.contains(cls)) spell.name,
    ];
    expect(listOf('paladin'), containsAll([
      'Thunderous Smite', 'Wrathful Smite', 'Blinding Smite', 'Staggering Smite',
      'Banishing Smite', 'Compelled Duel', 'Aura of Vitality', 'Circle of Power',
    ]));
    expect(listOf('ranger'), containsAll([
      'Hail of Thorns', 'Cordon of Arrows', 'Lightning Arrow', 'Conjure Barrage',
      'Elemental Weapon', 'Grasping Vine', 'Summon Elemental', 'Swift Quiver',
    ]));
    expect(listOf('warlock'), containsAll([
      'Armor of Agathys', 'Toll the Dead', 'Summon Fiend', 'Synaptic Static',
    ]));
    expect(spells['Thunderclap']!.classes, isNot(contains('cleric')));
    expect(spells['Feign Death']!.ritual, isTrue);
  });

  test('Witch Bolt rolls its attack and damage by spell slot', () {
    final character = Character(
      id: 'caster',
      rulesetId: RulesetId.dnd2024,
      contentPackId: ContentPackId.srd521,
      name: 'Caster',
      race: 'Human',
      characterClass: 'Wizard',
      abilityScores: const AbilityScores(intelligence: 16),
      hitPoints: const HitPoints(maximum: 6, current: 6),
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
    final request = ContextualSpellRollBuilder.build(
      character: character,
      spell: spells['Witch Bolt']!,
      displayName: 'Witch Bolt',
      attackLabel: 'Attack',
      damageLabel: 'Damage',
      spellSlotChoiceLabel: 'Slot',
      slotLevelLabel: (level) => 'Level $level',
      damageTypeLabel: (type) => type,
      spellAttackBonus: 5,
    )!;
    expect((request.parts.first as ContextualD20RollPart).d20Modifier, 5);
    final damage = request.parts[1] as ContextualExpressionRollPart;
    expect(damage.expression, '2d12');
    expect(damage.critical, isTrue);
    expect(
      {for (final choice in damage.choices) choice.key: choice.expression},
      containsPair('slot_3', '4d12'),
    );

    final wave = spells['Destructive Wave']!.rolls;
    expect(wave.map((roll) => roll.damageTypes), [
      ['thunder'],
      ['radiant', 'necrotic'],
    ]);
  });
}
