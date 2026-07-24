import 'package:dnd_character_tool/data/migrations/character_migration.dart';
import 'package:dnd_character_tool/data/migrations/migrations/normalize_equipment_order_migration.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character(List<EquipmentItem> equipment) {
  final now = DateTime(2024);
  return Character(
    id: 'character-id',
    dataVersion: 4,
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
  required String id,
  required String name,
  ItemType type = ItemType.gear,
  String? containerId,
  bool equipped = false,
  int sortOrder = 0,
}) {
  return EquipmentItem(
    id: id,
    name: name,
    category: type.name,
    itemType: type,
    containerId: containerId,
    isEquipped: equipped,
    sortOrder: sortOrder,
  );
}

void main() {
  group('NormalizeEquipmentOrderMigration', () {
    test('assigns local sort order and repairs invalid locations', () {
      final backpack = _item(
        id: 'backpack',
        name: 'Backpack',
        type: ItemType.container,
        containerId: 'bad-parent',
      );
      final lostItem = _item(
        id: 'lost',
        name: 'Lost item',
        containerId: 'missing-container',
      );
      final equippedSword = _item(
        id: 'sword',
        name: 'Sword',
        type: ItemType.weapon,
        containerId: backpack.id,
        equipped: true,
      );
      final rope = _item(id: 'rope', name: 'Rope', containerId: backpack.id);

      final result = const NormalizeEquipmentOrderMigration().migrate(
        _character([backpack, lostItem, equippedSword, rope]),
        const CharacterMigrationContext(itemsByName: {}),
      );
      final byId = {
        for (final item in result.character.equipment) item.id: item,
      };

      expect(byId['backpack']!.containerId, isNull);
      expect(byId['lost']!.containerId, isNull);
      expect(byId['sword']!.containerId, isNull);
      expect(byId['rope']!.containerId, backpack.id);
      expect(byId['backpack']!.sortOrder, 0);
      expect(byId['lost']!.sortOrder, 1);
      expect(byId['sword']!.sortOrder, 2);
      expect(byId['rope']!.sortOrder, 0);
      expect(result.changes.single.code, 'equipment_order_normalized');
    });
  });
}
