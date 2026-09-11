import 'package:dnd_character_tool/data/datasources/srd/srd_models.dart';
import 'package:dnd_character_tool/data/dice/dice.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

SrdClass _srdClass(String name, List<String> weaponProficiencies) {
  return SrdClass(
    name: name,
    hitDie: 8,
    primaryAbility: const ['strength'],
    savingThrows: const [],
    armorProficiencies: const [],
    weaponProficiencies: weaponProficiencies,
    toolProficiencies: const [],
    skillChoices: const SrdSkillChoice(count: 0, from: []),
    subclassLevel: 3,
    subclassFeatureName: 'Subclass',
    startingGoldDice: '1d4',
  );
}

Character _character({
  AbilityScores scores = const AbilityScores(strength: 16, dexterity: 12),
  String characterClass = 'Fighter',
  List<CharacterClassEntry> classes = const [],
  List<String> features = const [],
}) {
  return Character(
    id: 'character-id',
    name: 'Test',
    race: 'Human',
    characterClass: characterClass,
    classes: classes,
    abilityScores: scores,
    hitPoints: const HitPoints(maximum: 10, current: 10),
    proficiencyBonus: 2,
    features: features,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

EquipmentItem _weapon({
  String name = 'Longsword',
  String category = 'martial melee',
  Map<String, dynamic>? properties,
}) {
  return EquipmentItem(
    id: 'weapon-id',
    name: name,
    category: category,
    itemType: ItemType.weapon,
    properties: properties ?? const {'damageDice': '1d8'},
  );
}

ContextualRollRequest? _build(
  Character character,
  EquipmentItem item,
  List<SrdClass> classes,
) {
  return ContextualWeaponRollBuilder.build(
    character: character,
    item: item,
    displayName: item.name,
    attackLabel: 'Attack',
    damageLabel: 'Damage',
    extraDamageLabel: 'Extra damage',
    classes: classes,
  );
}

void main() {
  group('ContextualWeaponRollBuilder', () {
    test('uses ability and proficiency for a proficient starting class weapon', () {
      final request = _build(
        _character(),
        _weapon(),
        [_srdClass('Fighter', const ['simple', 'martial'])],
      )!;

      final attack = request.parts[0] as ContextualD20RollPart;
      final damage = request.parts[1] as ContextualExpressionRollPart;

      expect(attack.d20Modifier, 5);
      expect(damage.expression, '1d8+3');
    });

    test('uses the better Strength or Dexterity modifier for finesse weapons', () {
      final request = _build(
        _character(
          characterClass: 'Rogue',
          scores: const AbilityScores(strength: 10, dexterity: 18),
        ),
        _weapon(
          name: 'Rapier',
          properties: const {
            'damageDice': '1d8',
            'weaponProperties': ['finesse'],
          },
        ),
        [_srdClass('Rogue', const ['simple', 'rapier'])],
      )!;

      final attack = request.parts[0] as ContextualD20RollPart;
      final damage = request.parts[1] as ContextualExpressionRollPart;

      expect(attack.d20Modifier, 6);
      expect(damage.expression, '1d8+4');
    });

    test('does not grant full proficiency from a secondary multiclass class', () {
      final request = _build(
        _character(
          characterClass: 'Wizard',
          classes: const [
            CharacterClassEntry(
              id: 'wizard',
              className: 'Wizard',
              level: 1,
              isStartingClass: true,
            ),
            CharacterClassEntry(
              id: 'fighter',
              className: 'Fighter',
              level: 1,
            ),
          ],
        ),
        _weapon(),
        [
          _srdClass('Wizard', const ['daggers', 'darts']),
          _srdClass('Fighter', const ['simple', 'martial']),
        ],
      )!;

      final attack = request.parts[0] as ContextualD20RollPart;

      expect(attack.d20Modifier, 3);
    });

    test('uses persisted multiclass weapon proficiency feature labels', () {
      final request = _build(
        _character(
          characterClass: 'Wizard',
          features: const ['Weapon Proficiency: martial weapons'],
        ),
        _weapon(),
        [_srdClass('Wizard', const ['daggers', 'darts'])],
      )!;

      final attack = request.parts[0] as ContextualD20RollPart;

      expect(attack.d20Modifier, 5);
    });

    test('does not build a request for weapons without structured damage', () {
      final request = _build(
        _character(),
        _weapon(properties: null).copyWith(properties: const {}),
        [_srdClass('Fighter', const ['simple', 'martial'])],
      );

      expect(request, isNull);
    });
  });
}
