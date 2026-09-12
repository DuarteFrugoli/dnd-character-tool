import 'package:dnd_character_tool/data/datasources/srd/srd_models.dart';
import 'package:dnd_character_tool/data/dice/dice.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/spellcasting_engine.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character({
  int level = 1,
  int proficiencyBonus = 2,
  AbilityScores scores = const AbilityScores(intelligence: 16),
}) {
  return Character(
    id: 'character-id',
    name: 'Test',
    race: 'Human',
    characterClass: 'Wizard',
    level: level,
    abilityScores: scores,
    hitPoints: const HitPoints(maximum: 10, current: 10),
    proficiencyBonus: proficiencyBonus,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

SrdSpell _spell({
  required String name,
  required int level,
  required List<SrdSpellRoll> rolls,
}) {
  return SrdSpell(
    name: name,
    level: level,
    school: 'evocation',
    castingTime: '1 action',
    castingTimeType: 'action',
    ritual: false,
    range: '120 feet',
    components: const ['V', 'S'],
    materialConsumed: false,
    duration: 'Instantaneous',
    concentration: false,
    damageTypes: const [],
    rolls: rolls,
    description: 'Test spell.',
    classes: const ['wizard'],
    subclassSpells: const [],
    raceSpells: const [],
  );
}

ContextualRollRequest? _build({
  required Character character,
  required SrdSpell spell,
  SpellcastingEngine? engine,
  Set<int>? availableSlotLevels,
}) {
  return ContextualSpellRollBuilder.build(
    character: character,
    spell: spell,
    displayName: spell.name,
    attackLabel: 'Attack',
    damageLabel: 'Damage',
    spellSlotChoiceLabel: 'Spell slots',
    slotLevelLabel: (level) => 'Lvl $level',
    damageTypeLabel: (type) => type,
    spellcastingEngine: engine,
    availableSlotLevels: availableSlotLevels,
  );
}

void main() {
  group('ContextualSpellRollBuilder', () {
    test('uses spellcasting attack bonus and cantrip level scaling', () {
      final character = _character(level: 5, proficiencyBonus: 3);
      final engine = SpellcastingEngine.forClass(
        className: 'Wizard',
        classLevel: 5,
        abilityScores: character.abilityScores,
        proficiencyBonus: character.proficiencyBonus,
      );
      final request = _build(
        character: character,
        engine: engine,
        spell: _spell(
          name: 'Fire Bolt',
          level: 0,
          rolls: const [
            SrdSpellRoll(
              id: 'attack',
              label: 'Attack',
              kind: 'spell_attack',
            ),
            SrdSpellRoll(
              id: 'damage',
              label: 'Damage',
              kind: 'damage',
              formula: '1d10',
              damageType: 'fire',
              damageTypes: ['fire'],
              critical: true,
              characterLevelScaling: {5: '2d10', 11: '3d10'},
            ),
          ],
        ),
      )!;

      final attack = request.parts[0] as ContextualD20RollPart;
      final damage = request.parts[1] as ContextualExpressionRollPart;

      expect(attack.d20Modifier, 6);
      expect(damage.expression, '2d10');
      expect(damage.critical, isTrue);
      expect(damage.label, 'Damage (fire)');
    });

    test('adds slot-level choices only for available spell slots', () {
      final request = _build(
        character: _character(level: 5, proficiencyBonus: 3),
        availableSlotLevels: const {3, 4},
        spell: _spell(
          name: 'Fireball',
          level: 3,
          rolls: const [
            SrdSpellRoll(
              id: 'damage',
              label: 'Damage',
              kind: 'damage',
              formula: '8d6',
              damageType: 'fire',
              damageTypes: ['fire'],
              slotLevelScaling: {4: '9d6', 5: '10d6'},
            ),
          ],
        ),
      )!;

      final damage = request.parts.single as ContextualExpressionRollPart;

      expect(damage.expression, '8d6');
      expect(damage.choiceLabel, 'Spell slots');
      expect(damage.choices.map((choice) => choice.key), [
        'slot_3',
        'slot_4',
      ]);
      expect(damage.choices.map((choice) => choice.expression), ['8d6', '9d6']);
    });

    test('keeps a single higher pact slot choice instead of base damage', () {
      final request = _build(
        character: _character(level: 9, proficiencyBonus: 4),
        availableSlotLevels: const {5},
        spell: _spell(
          name: 'Armor of Agathys',
          level: 1,
          rolls: const [
            SrdSpellRoll(
              id: 'damage',
              label: 'Damage',
              kind: 'damage',
              formula: '5',
              damageType: 'cold',
              damageTypes: ['cold'],
              slotLevelScaling: {2: '10', 3: '15', 4: '20', 5: '25'},
            ),
          ],
        ),
      )!;

      final damage = request.parts.single as ContextualExpressionRollPart;

      expect(damage.choices.map((choice) => choice.key), ['slot_5']);
      expect(damage.choices.single.expression, '25');
    });

    test('does not build complex spells without structured rolls', () {
      final request = _build(
        character: _character(),
        spell: _spell(name: 'Magic Missile', level: 1, rolls: const []),
      );

      expect(request, isNull);
    });
  });
}
