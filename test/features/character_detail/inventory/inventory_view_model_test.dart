import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/features/character_detail/inventory/inventory_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

EquipmentItem _item({
  required String id,
  required String name,
  ItemType type = ItemType.gear,
  int quantity = 1,
  double weight = 0,
  String? containerId,
  bool equipped = false,
  int sortOrder = 0,
  Map<String, dynamic>? properties,
}) {
  return EquipmentItem(
    id: id,
    name: name,
    category: type.name,
    itemType: type,
    quantity: quantity,
    weight: weight,
    containerId: containerId,
    isEquipped: equipped,
    sortOrder: sortOrder,
    properties: properties,
  );
}

void main() {
  group('InventorySnapshot', () {
    test('keeps container contents out of root sections', () {
      final backpack = _item(
        id: 'backpack',
        name: 'Backpack',
        type: ItemType.container,
        sortOrder: 1,
      );
      final rope = _item(id: 'rope', name: 'Rope', containerId: backpack.id);
      final torch = _item(id: 'torch', name: 'Torch', sortOrder: 0);

      final snapshot = InventorySnapshot.fromEquipment([backpack, rope, torch]);

      expect(snapshot.rootItems.map((item) => item.id), ['torch', 'backpack']);
      expect(snapshot.contentsByContainer[backpack.id]!.single.id, 'rope');
      expect(snapshot.carried.map((item) => item.id), ['torch']);
    });

    test('keeps empty containers with an empty contents list', () {
      final waterskin = _item(
        id: 'waterskin',
        name: 'Waterskin',
        type: ItemType.container,
      );

      final snapshot = InventorySnapshot.fromEquipment([waterskin]);

      expect(snapshot.containers.single.id, waterskin.id);
      expect(snapshot.contentsByContainer[waterskin.id], isEmpty);
      expect(
        inventoryItemsTotalQuantity(
          snapshot.contentsByContainer[waterskin.id]!,
        ),
        0,
      );
    });

    test('shows invalid container items at root without mutating them', () {
      final item = _item(
        id: 'lost',
        name: 'Lost item',
        containerId: 'missing-container',
      );

      final snapshot = InventorySnapshot.fromEquipment([item]);

      expect(snapshot.rootItems.single.id, item.id);
      expect(snapshot.rootItems.single.containerId, 'missing-container');
    });

    test('ignores contents weight when the container says so', () {
      final pouch = _item(
        id: 'pouch',
        name: 'Magic pouch',
        type: ItemType.container,
        weight: 2,
        properties: {'contentsWeightIgnored': true},
      );
      final coins = _item(
        id: 'coins',
        name: 'Coins',
        quantity: 2,
        weight: 10,
        containerId: pouch.id,
      );
      final rock = _item(id: 'rock', name: 'Rock', weight: 1);

      final snapshot = InventorySnapshot.fromEquipment([pouch, coins, rock]);

      expect(snapshot.totalWeight, 3);
    });

    test('keeps ammunition with zero quantity visible', () {
      final arrows = _item(
        id: 'arrows',
        name: 'Arrows',
        type: ItemType.ammunition,
        quantity: 0,
      );

      final snapshot = InventorySnapshot.fromEquipment([arrows]);

      expect(snapshot.ammunition.single.id, 'arrows');
    });

    test('treats equipped items inside containers as root equipped items', () {
      final backpack = _item(
        id: 'backpack',
        name: 'Backpack',
        type: ItemType.container,
      );
      final ring = _item(
        id: 'ring',
        name: 'Ring',
        type: ItemType.equippable,
        containerId: backpack.id,
        equipped: true,
      );

      final snapshot = InventorySnapshot.fromEquipment([backpack, ring]);

      expect(snapshot.equipped.single.id, 'ring');
      expect(snapshot.contentsByContainer[backpack.id], isEmpty);
    });

    test('sorts root and container contents independently by sortOrder', () {
      final backpack = _item(
        id: 'backpack',
        name: 'Backpack',
        type: ItemType.container,
        sortOrder: 1,
      );
      final sword = _item(id: 'sword', name: 'Sword', sortOrder: 0);
      final rope = _item(
        id: 'rope',
        name: 'Rope',
        containerId: backpack.id,
        sortOrder: 2,
      );
      final torch = _item(
        id: 'torch',
        name: 'Torch',
        containerId: backpack.id,
        sortOrder: 1,
      );

      final snapshot = InventorySnapshot.fromEquipment([
        backpack,
        rope,
        sword,
        torch,
      ]);

      expect(snapshot.rootItems.map((item) => item.id), ['sword', 'backpack']);
      expect(
        snapshot.contentsByContainer[backpack.id]!.map((item) => item.id),
        ['torch', 'rope'],
      );
    });
  });
}
