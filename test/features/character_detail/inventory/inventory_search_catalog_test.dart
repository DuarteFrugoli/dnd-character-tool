import 'package:dnd_character_tool/data/datasources/srd/srd_i18n_service.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_models.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/features/character_detail/inventory/inventory_search_catalog.dart';
import 'package:dnd_character_tool/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

SrdInventorySearchCatalog _catalog() {
  return SrdInventorySearchCatalog.fromSrd(
    weapons: const [
      SrdWeapon(
        name: 'Longsword',
        category: 'martial melee weapons',
        damage: '1d8',
        damageType: 'slashing',
        weight: 3,
        cost: '15 gp',
        properties: ['versatile'],
      ),
    ],
    armors: const [
      SrdArmor(
        name: 'Shield',
        type: 'shield',
        acBonus: 2,
        addDexModifier: false,
        stealthDisadvantage: false,
        weight: 6,
        cost: '10 gp',
      ),
    ],
    gear: const [
      SrdGearItem(
        name: 'Arrows (20)',
        category: 'ammunition',
        weight: 1,
        cost: '1 gp',
        description: '',
      ),
      SrdGearItem(
        name: 'Backpack',
        category: 'container',
        weight: 5,
        cost: '2 gp',
        description: 'A pack that holds gear.',
      ),
    ],
    magic: const [
      SrdMagicItem(
        name: 'Ring of Protection',
        type: 'ring',
        rarity: 'rare',
        requiresAttunement: true,
        weight: 0,
        cost: '',
        description: 'A protective ring.',
        itemType: ItemType.equippable,
      ),
    ],
    tools: const [
      SrdTool(name: 'Lute', category: 'musical_instruments', weight: 2),
    ],
    i18n: SrdI18nService.english,
    l10n: AppLocalizationsEn(),
    itemTypeLabel: (type) => type.name,
    categoryLabel: (category) => category,
  );
}

void main() {
  group('SrdInventorySearchCatalog', () {
    test('searches globally across item types', () {
      final catalog = _catalog();

      expect(catalog.search('longsword').single.itemType, ItemType.weapon);
      expect(catalog.search('shield').single.itemType, ItemType.armor);
      expect(catalog.search('ring').single.itemType, ItemType.equippable);
      expect(catalog.search('lute').single.name, 'Lute');
    });

    test('strips ammunition pack suffix from display and search names', () {
      final catalog = _catalog();

      final arrows = catalog.search('arrows').single;

      expect(arrows.name, 'Arrows (20)');
      expect(arrows.displayName, 'Arrows');
      expect(arrows.itemType, ItemType.ammunition);
    });

    test('searches by type, category and description text', () {
      final catalog = _catalog();

      expect(catalog.search('container').map((entry) => entry.name), [
        'Backpack',
      ]);
      expect(catalog.search('protective').map((entry) => entry.name), [
        'Ring of Protection',
      ]);
      expect(catalog.search('ammunition').map((entry) => entry.name), [
        'Arrows (20)',
      ]);
    });

    test('empty search returns all entries', () {
      final catalog = _catalog();

      expect(catalog.search(''), hasLength(6));
    });
  });
}
