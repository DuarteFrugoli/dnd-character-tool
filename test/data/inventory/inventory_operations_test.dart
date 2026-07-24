import 'package:dnd_character_tool/data/inventory/inventory_operations.dart';
import 'package:dnd_character_tool/data/models/models.dart';
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

bool _isBodyArmor(EquipmentItem item) =>
    item.itemType == ItemType.armor &&
    item.properties?['isShield'] != true &&
    item.properties?.containsKey('baseAC') == true;

void main() {
  group('inventory operations', () {
    test('does not put a container inside another container', () {
      final backpack = _item(
        id: 'backpack',
        name: 'Backpack',
        type: ItemType.container,
      );
      final pouch = _item(id: 'pouch', name: 'Pouch', type: ItemType.container);

      final updated = moveItemToContainer(
        [backpack, pouch],
        pouch.id,
        backpack.id,
      );

      expect(
        updated.singleWhere((item) => item.id == pouch.id).containerId,
        isNull,
      );
    });

    test('keeps ammunition at zero quantity instead of removing it', () {
      final arrows = _item(
        id: 'arrows',
        name: 'Arrows',
        type: ItemType.ammunition,
        quantity: 1,
      );

      final updated = adjustItemQuantity([arrows], arrows.id, -1);

      expect(updated.single.quantity, 0);
    });

    test('reorder changes only the sort order of the visible group', () {
      final a = _item(id: 'a', name: 'A', sortOrder: 0);
      final b = _item(id: 'b', name: 'B', sortOrder: 1);
      final c = _item(id: 'c', name: 'C', sortOrder: 2);

      final updated = reorderEquipmentItems(
        equipment: [a, b, c],
        itemIds: [a.id, b.id, c.id],
        oldIndex: 2,
        newIndex: 0,
      );

      expect(updated.singleWhere((item) => item.id == c.id).sortOrder, 0);
      expect(updated.singleWhere((item) => item.id == a.id).sortOrder, 1);
      expect(updated.singleWhere((item) => item.id == b.id).sortOrder, 2);
    });

    test(
      'equipping one item from a stack splits it into an equipped entry',
      () {
        final sword = _item(
          id: 'sword',
          name: 'Sword',
          type: ItemType.weapon,
          quantity: 2,
        );

        final updated = toggleEquipped(
          [sword],
          sword.id,
          isBodyArmor: _isBodyArmor,
        );

        expect(updated.length, 2);
        expect(updated.where((item) => item.isEquipped), hasLength(1));
        expect(updated.where((item) => !item.isEquipped).single.quantity, 1);
      },
    );

    test('adds containers as separate entries instead of one stacked item', () {
      final backpack = _item(
        id: 'source',
        name: 'Backpack',
        type: ItemType.container,
        quantity: 2,
      );

      final updated = addEquipmentItem([], backpack);

      expect(updated, hasLength(2));
      expect(
        updated.every((item) => item.itemType == ItemType.container),
        isTrue,
      );
      expect(updated.every((item) => item.quantity == 1), isTrue);
      expect(updated.map((item) => item.sortOrder), [0, 1]);
    });

    test('stacks carried non-container items with the same name and type', () {
      final first = _item(id: 'first', name: 'Torch', quantity: 2);
      final second = _item(id: 'second', name: 'Torch', quantity: 3, weight: 1);

      final updated = addEquipmentItem([first], second);

      expect(updated, hasLength(1));
      expect(updated.single.quantity, 5);
      expect(updated.single.weight, 1);
    });

    test('removing a container can move its contents back to inventory', () {
      final backpack = _item(
        id: 'backpack',
        name: 'Backpack',
        type: ItemType.container,
      );
      final rope = _item(id: 'rope', name: 'Rope', containerId: backpack.id);

      final updated = removeEquipmentQuantity([backpack, rope], backpack.id, 1);

      expect(updated.map((item) => item.id), ['rope']);
      expect(updated.single.containerId, isNull);
    });

    test('removing a container can delete its contents', () {
      final backpack = _item(
        id: 'backpack',
        name: 'Backpack',
        type: ItemType.container,
      );
      final rope = _item(id: 'rope', name: 'Rope', containerId: backpack.id);

      final updated = removeEquipmentQuantity(
        [backpack, rope],
        backpack.id,
        1,
        containerRemovalMode: ContainerRemovalMode.deleteContents,
      );

      expect(updated, isEmpty);
    });

    test(
      'moving an item into a container merges with an equal stack there',
      () {
        final pouch = _item(
          id: 'pouch',
          name: 'Pouch',
          type: ItemType.container,
        );
        final coinA = _item(
          id: 'coin-a',
          name: 'Coin',
          quantity: 2,
          containerId: pouch.id,
        );
        final coinB = _item(id: 'coin-b', name: 'Coin', quantity: 3);

        final updated = moveItemToContainer(
          [pouch, coinA, coinB],
          coinB.id,
          pouch.id,
        );

        final coinStack = updated.singleWhere((item) => item.id == coinA.id);
        expect(coinStack.quantity, 5);
        expect(coinStack.containerId, pouch.id);
        expect(updated.any((item) => item.id == coinB.id), isFalse);
      },
    );

    test('equipping an item inside a container clears its container', () {
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
      );

      final updated = toggleEquipped(
        [backpack, ring],
        ring.id,
        isBodyArmor: _isBodyArmor,
      );

      final equippedRing = updated.singleWhere((item) => item.id == ring.id);
      expect(equippedRing.isEquipped, isTrue);
      expect(equippedRing.containerId, isNull);
    });

    test('forcing an armor swap unequips the previous body armor', () {
      final chainMail = _item(
        id: 'chain',
        name: 'Chain Mail',
        type: ItemType.armor,
        equipped: true,
        properties: const {'baseAC': 16, 'addDexModifier': false},
      );
      final leather = _item(
        id: 'leather',
        name: 'Leather',
        type: ItemType.armor,
        properties: const {'baseAC': 11, 'addDexModifier': true},
      );

      final updated = toggleEquipped(
        [chainMail, leather],
        leather.id,
        isBodyArmor: _isBodyArmor,
        forceArmorSwap: true,
      );

      expect(
        updated.singleWhere((item) => item.id == leather.id).isEquipped,
        isTrue,
      );
      expect(
        updated.singleWhere((item) => item.name == chainMail.name).isEquipped,
        isFalse,
      );
    });
  });
}
