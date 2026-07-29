import 'package:dnd_character_tool/data/constants/armor_class.dart';
import 'package:dnd_character_tool/data/models/ability_scores.dart';
import 'package:dnd_character_tool/data/models/character.dart';
import 'package:dnd_character_tool/data/models/character_extra_feature.dart';
import 'package:dnd_character_tool/data/models/character_feature_choice.dart';
import 'package:dnd_character_tool/data/models/equipment_item.dart';
import 'package:dnd_character_tool/data/models/hit_points.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character({
  String cls = 'Fighter',
  String? subclass,
  AbilityScores scores = const AbilityScores(),
  List<EquipmentItem> equipment = const [],
  List<CharacterExtraFeature> extraFeatures = const [],
  List<CharacterFeatureChoice> featureChoices = const [],
  List<String> disabledFeatures = const [],
}) {
  final now = DateTime(2024);
  return Character(
    id: 'test-id',
    name: 'Test Hero',
    race: 'Human',
    characterClass: cls,
    subclass: subclass,
    abilityScores: scores,
    hitPoints: const HitPoints(maximum: 10, current: 10),
    equipment: equipment,
    extraFeatures: extraFeatures,
    featureChoices: featureChoices,
    disabledFeatures: disabledFeatures,
    createdAt: now,
    updatedAt: now,
  );
}

EquipmentItem _shield() {
  return EquipmentItem(
    name: 'Shield',
    category: 'armor',
    itemType: ItemType.armor,
    isEquipped: true,
    properties: const {'isShield': true, 'acBonus': 2},
  );
}

EquipmentItem _leatherArmor() {
  return EquipmentItem(
    name: 'Leather',
    category: 'armor',
    itemType: ItemType.armor,
    isEquipped: true,
    properties: const {
      'baseAC': 11,
      'addDexModifier': true,
      'maxDexBonus': null,
    },
  );
}

EquipmentItem _chainMail() {
  return EquipmentItem(
    name: 'Chain Mail',
    category: 'armor',
    itemType: ItemType.armor,
    isEquipped: true,
    properties: const {'baseAC': 16, 'addDexModifier': false},
  );
}

void main() {
  group('calcArmorClass', () {
    test('barbarian uses Constitution for Unarmored Defense', () {
      final c = _character(
        cls: 'Barbarian',
        scores: const AbilityScores(dexterity: 14, constitution: 16),
      );

      expect(calcArmorClass(c), 15);
    });

    test('barbarian keeps Unarmored Defense with a shield', () {
      final c = _character(
        cls: 'Barbarian',
        scores: const AbilityScores(dexterity: 14, constitution: 16),
        equipment: [_shield()],
      );

      expect(calcArmorClass(c), 17);
    });

    test('monk uses Wisdom for Unarmored Defense without a shield', () {
      final c = _character(
        cls: 'Monk',
        scores: const AbilityScores(dexterity: 16, wisdom: 14),
      );

      expect(calcArmorClass(c), 15);
    });

    test('monk loses Unarmored Defense with a shield', () {
      final c = _character(
        cls: 'Monk',
        scores: const AbilityScores(dexterity: 16, wisdom: 14),
        equipment: [_shield()],
      );

      expect(calcArmorClass(c), 15);
    });

    test('body armor overrides Unarmored Defense base', () {
      final c = _character(
        cls: 'Barbarian',
        scores: const AbilityScores(dexterity: 14, constitution: 16),
        equipment: [_leatherArmor()],
      );

      expect(calcArmorClass(c), 13);
    });

    test('Defense Fighting Style adds AC while wearing body armor', () {
      final c = _character(
        cls: 'Fighter',
        equipment: [_chainMail()],
        featureChoices: const [
          CharacterFeatureChoice(
            sourceType: 'classFeature',
            sourceClass: 'Fighter',
            featureName: 'Fighting Style',
            choiceId: 'fighting_style',
            values: ['defense'],
          ),
        ],
      );

      expect(calcArmorClass(c), 17);
    });

    test('Defense Fighting Style does not apply without body armor', () {
      final c = _character(
        cls: 'Fighter',
        scores: const AbilityScores(dexterity: 14),
        featureChoices: const [
          CharacterFeatureChoice(
            sourceType: 'classFeature',
            sourceClass: 'Fighter',
            featureName: 'Fighting Style',
            choiceId: 'fighting_style',
            values: ['defense'],
          ),
        ],
      );

      expect(calcArmorClass(c), 12);
    });

    test('Draconic Resilience uses 13 plus Dexterity without armor', () {
      final c = _character(
        cls: 'Sorcerer',
        subclass: 'Draconic Bloodline',
        scores: const AbilityScores(dexterity: 16),
      );

      expect(calcArmorClass(c), 16);
    });

    test('extra barbarian feature enables Unarmored Defense', () {
      final c = _character(
        cls: 'Fighter',
        scores: const AbilityScores(dexterity: 14, constitution: 16),
        extraFeatures: const [
          CharacterExtraFeature(
            sourceClass: 'Barbarian',
            name: 'Unarmored Defense',
            level: 1,
            type: 'passive',
            description: '',
          ),
        ],
      );

      expect(calcArmorClass(c), 15);
    });

    test('disabled Unarmored Defense falls back to normal unarmored AC', () {
      final c = _character(
        cls: 'Barbarian',
        scores: const AbilityScores(dexterity: 14, constitution: 16),
        disabledFeatures: const ['Unarmored Defense'],
      );

      expect(calcArmorClass(c), 12);
    });
  });
}
