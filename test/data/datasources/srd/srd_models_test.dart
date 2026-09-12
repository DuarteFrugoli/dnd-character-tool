import 'package:dnd_character_tool/data/datasources/srd/srd_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SrdSpell', () {
    test('parses structured roll data', () {
      final spell = SrdSpell.fromJson(const {
        'name': 'Fire Bolt',
        'level': 0,
        'school': 'evocation',
        'castingTime': '1 action',
        'castingTimeType': 'action',
        'ritual': false,
        'range': '120 feet',
        'components': ['V', 'S'],
        'material': null,
        'materialCost': null,
        'materialConsumed': false,
        'duration': 'Instantaneous',
        'concentration': false,
        'areaOfEffect': null,
        'attackType': 'ranged',
        'saveAttribute': null,
        'damageTypes': ['fire'],
        'rolls': [
          {'id': 'attack', 'label': 'Attack', 'kind': 'spell_attack'},
          {
            'id': 'damage',
            'label': 'Damage',
            'kind': 'damage',
            'formula': '1d10',
            'damageType': 'fire',
            'critical': true,
            'characterLevelScaling': {'5': '2d10', '11': '3d10'},
          },
        ],
        'description': 'Make a ranged spell attack.',
        'higherLevels': null,
        'classes': ['sorcerer', 'wizard'],
        'subclassSpells': [],
        'raceSpells': [],
      });

      expect(spell.rolls, hasLength(2));
      expect(spell.rolls.first.kind, 'spell_attack');
      final damage = spell.rolls[1];
      expect(damage.formula, '1d10');
      expect(damage.damageType, 'fire');
      expect(damage.damageTypes, ['fire']);
      expect(damage.critical, isTrue);
      expect(damage.characterLevelScaling, {5: '2d10', 11: '3d10'});
      expect(damage.slotLevelScaling, isEmpty);
    });

    test('parses roll entries with multiple damage types', () {
      final spell = SrdSpell.fromJson(const {
        'name': 'Spirit Guardians',
        'level': 3,
        'school': 'conjuration',
        'castingTime': '1 action',
        'castingTimeType': 'action',
        'ritual': false,
        'range': 'Self',
        'components': ['V', 'S', 'M'],
        'material': 'a holy symbol',
        'materialCost': null,
        'materialConsumed': false,
        'duration': '10 minutes',
        'concentration': true,
        'areaOfEffect': {'type': 'sphere', 'size': 15},
        'attackType': null,
        'saveAttribute': 'WIS',
        'damageTypes': ['radiant', 'necrotic'],
        'rolls': [
          {
            'id': 'damage',
            'label': 'Damage',
            'kind': 'damage',
            'formula': '3d8',
            'damageTypes': ['radiant', 'necrotic'],
            'slotLevelScaling': {'4': '4d8'},
          },
        ],
        'description': 'On a failed save, the creature takes damage.',
        'higherLevels': null,
        'classes': ['cleric'],
        'subclassSpells': [],
        'raceSpells': [],
      });

      final damage = spell.rolls.single;
      expect(damage.damageType, isNull);
      expect(damage.damageTypes, ['radiant', 'necrotic']);
      expect(damage.slotLevelScaling, {4: '4d8'});
    });
  });
}
