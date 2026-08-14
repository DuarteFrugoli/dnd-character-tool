import 'package:dnd_character_tool/data/json_helpers.dart';
import 'package:dnd_character_tool/data/models/ability_scores.dart';
import 'package:dnd_character_tool/data/models/character.dart';
import 'package:dnd_character_tool/data/models/character_class_entry.dart';
import 'package:dnd_character_tool/data/models/character_note.dart';
import 'package:dnd_character_tool/data/models/equipment_item.dart';
import 'package:dnd_character_tool/data/models/hit_points.dart';
import 'package:dnd_character_tool/data/models/spell.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('readBool', () {
    test('accepts bool, numeric, and string representations', () {
      expect(readBool(true), isTrue);
      expect(readBool(1), isTrue);
      expect(readBool(1.0), isTrue);
      expect(readBool('true'), isTrue);
      expect(readBool('1'), isTrue);
      expect(readBool(false), isFalse);
      expect(readBool(0), isFalse);
      expect(readBool(0.0), isFalse);
      expect(readBool('false'), isFalse);
      expect(readBool('0'), isFalse);
    });
  });

  group('model bool compatibility', () {
    test('loads saved character data with numeric bool values', () {
      final now = DateTime(2024);
      final json = Character(
        id: 'hero',
        name: 'Hero',
        race: 'Human',
        characterClass: 'Fighter',
        abilityScores: const AbilityScores(),
        hitPoints: const HitPoints(maximum: 10, current: 10),
        createdAt: now,
        updatedAt: now,
        classes: const [
          CharacterClassEntry(
            id: 'fighter',
            className: 'Fighter',
            level: 1,
            isStartingClass: true,
          ),
        ],
        equipment: [
          EquipmentItem(
            name: 'Leather',
            category: 'light',
            itemType: ItemType.armor,
            isEquipped: true,
          ),
        ],
        spells: const [
          KnownSpell(name: 'Shield', level: 1, isPrepared: true),
        ],
        notes: [
          CharacterNote(title: 'Note', content: 'Content', isPinned: true),
        ],
        inspiration: true,
        isPinned: true,
        xpTrackingEnabled: true,
      ).toJson();

      json['inspiration'] = 1.0;
      json['isPinned'] = 'true';
      json['xpTrackingEnabled'] = 1;
      json['weightTrackingEnabled'] = 0.0;
      final classJson =
          (json['classes'] as List<dynamic>).first as Map<String, dynamic>;
      final equipmentJson =
          (json['equipment'] as List<dynamic>).first as Map<String, dynamic>;
      final spellJson =
          (json['spells'] as List<dynamic>).first as Map<String, dynamic>;
      final noteJson =
          (json['notes'] as List<dynamic>).first as Map<String, dynamic>;
      classJson['isStartingClass'] = 1.0;
      equipmentJson['isEquipped'] = 1.0;
      spellJson['isPrepared'] = 'true';
      spellJson['isAlwaysPrepared'] = 0.0;
      noteJson['isPinned'] = 1.0;

      final restored = Character.fromJson(json);

      expect(restored.inspiration, isTrue);
      expect(restored.isPinned, isTrue);
      expect(restored.xpTrackingEnabled, isTrue);
      expect(restored.weightTrackingEnabled, isFalse);
      expect(restored.classes.single.isStartingClass, isTrue);
      expect(restored.equipment.single.isEquipped, isTrue);
      expect(restored.spells.single.isPrepared, isTrue);
      expect(restored.spells.single.isAlwaysPrepared, isFalse);
      expect(restored.notes.single.isPinned, isTrue);
    });
  });
}
