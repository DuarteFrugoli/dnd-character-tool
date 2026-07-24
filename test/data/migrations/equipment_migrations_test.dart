import 'package:dnd_character_tool/data/datasources/srd/srd_models.dart';
import 'package:dnd_character_tool/data/migrations/character_migration.dart';
import 'package:dnd_character_tool/data/migrations/migrations/backfill_equipment_weights_migration.dart';
import 'package:dnd_character_tool/data/migrations/migrations/expand_equipment_packs_migration.dart';
import 'package:dnd_character_tool/data/migrations/migrations/normalize_equipment_items_migration.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character(List<EquipmentItem> equipment) {
  final now = DateTime(2024);
  return Character(
    id: 'character-id',
    dataVersion: 0,
    name: 'Test Hero',
    race: 'Human',
    characterClass: 'Fighter',
    abilityScores: const AbilityScores(),
    hitPoints: const HitPoints(maximum: 10, current: 10),
    equipment: equipment,
    createdAt: now,
    updatedAt: now,
  );
}

EquipmentItem _item({
  required String name,
  String category = 'gear',
  ItemType type = ItemType.gear,
  int quantity = 1,
  double weight = 0,
  bool equipped = false,
  Map<String, dynamic>? properties,
}) {
  return EquipmentItem(
    id: name,
    name: name,
    category: category,
    itemType: type,
    quantity: quantity,
    weight: weight,
    isEquipped: equipped,
    properties: properties,
  );
}

CharacterMigrationContext _context({
  Map<String, SrdItemData> items = const {},
}) {
  return CharacterMigrationContext(itemsByName: items);
}

void main() {
  group('BackfillEquipmentWeightsMigration', () {
    test('updates known zero-weight items without touching custom items', () {
      final result = const BackfillEquipmentWeightsMigration().migrate(
        _character([_item(name: 'Torch'), _item(name: 'Custom Relic')]),
        _context(
          items: const {
            'torch': SrdItemData(
              itemType: 'gear',
              category: 'adventuring gear',
              weight: 1,
            ),
          },
        ),
      );

      expect(result.character.equipment[0].weight, 1);
      expect(result.character.equipment[1].weight, 0);
      expect(result.changes.single.code, 'equipment_weights_backfilled');
      expect(result.changes.single.count, 1);
    });

    test('uses singular fallback for simple old plural item names', () {
      final result = const BackfillEquipmentWeightsMigration().migrate(
        _character([_item(name: 'Arrows')]),
        _context(
          items: const {
            'arrow': SrdItemData(
              itemType: 'ammunition',
              category: 'ammunition',
              weight: 0.05,
            ),
          },
        ),
      );

      expect(result.character.equipment.single.weight, 0.05);
    });
  });

  group('NormalizeEquipmentItemsMigration', () {
    test('normalizes type, category, weight and merges properties', () {
      final result = const NormalizeEquipmentItemsMigration().migrate(
        _character([
          _item(
            name: 'Longsword',
            category: 'old',
            type: ItemType.gear,
            weight: 0,
            properties: const {'custom': true},
          ),
        ]),
        _context(
          items: const {
            'longsword': SrdItemData(
              itemType: 'weapon',
              category: 'martial melee weapons',
              weight: 3,
              properties: {'damageDice': '1d8', 'damageType': 'slashing'},
            ),
          },
        ),
      );

      final item = result.character.equipment.single;
      expect(item.itemType, ItemType.weapon);
      expect(item.category, 'martial melee weapons');
      expect(item.weight, 3);
      expect(item.properties, {
        'custom': true,
        'damageDice': '1d8',
        'damageType': 'slashing',
      });
      expect(result.changes.single.code, 'equipment_items_normalized');
    });
  });

  group('ExpandEquipmentPacksMigration', () {
    test('replaces known packs with their contents and stacks equal items', () {
      final result = const ExpandEquipmentPacksMigration().migrate(
        _character([
          _item(name: 'Dungeoneer Pack', quantity: 2),
          _item(
            name: 'Torch',
            category: 'adventuring gear',
            quantity: 1,
            weight: 1,
          ),
        ]),
        _context(
          items: const {
            'dungeoneer pack': SrdItemData(
              itemType: 'container',
              category: 'container',
              weight: 5,
              contents: [
                SrdPackContent(name: 'Torch', quantity: 10),
                SrdPackContent(name: 'Rope', quantity: 1),
              ],
            ),
            'torch': SrdItemData(
              itemType: 'gear',
              category: 'adventuring gear',
              weight: 1,
            ),
            'rope': SrdItemData(
              itemType: 'gear',
              category: 'adventuring gear',
              weight: 10,
            ),
          },
        ),
      );

      final byName = {
        for (final item in result.character.equipment) item.name: item,
      };
      expect(byName.containsKey('Dungeoneer Pack'), isFalse);
      expect(byName['Torch']!.quantity, 21);
      expect(byName['Rope']!.quantity, 2);
      expect(result.changes.single.code, 'equipment_packs_expanded');
      expect(result.changes.single.count, 2);
    });

    test('does not stack equipped items while expanding packs', () {
      final result = const ExpandEquipmentPacksMigration().migrate(
        _character([
          _item(name: 'Gear Pack'),
          _item(
            name: 'Torch',
            category: 'adventuring gear',
            quantity: 1,
            equipped: true,
          ),
        ]),
        _context(
          items: const {
            'gear pack': SrdItemData(
              itemType: 'container',
              category: 'container',
              contents: [SrdPackContent(name: 'Torch', quantity: 1)],
            ),
            'torch': SrdItemData(
              itemType: 'gear',
              category: 'adventuring gear',
              weight: 1,
            ),
          },
        ),
      );

      expect(
        result.character.equipment.where((item) => item.name == 'Torch'),
        hasLength(2),
      );
      expect(
        result.character.equipment.where((item) => item.isEquipped),
        hasLength(1),
      );
    });
  });
}
