import 'package:dnd_character_tool/l10n/app_localizations.dart';

import '../../../data/datasources/srd/srd_i18n_service.dart';
import '../../../data/datasources/srd/srd_models.dart';
import '../../../data/models/models.dart';

final _numberedPackSuffixPattern = RegExp(r'\s*\((\d+)\)$');

class SrdInventorySearchEntry {
  const SrdInventorySearchEntry({
    required this.name,
    required this.displayName,
    required this.subtitle,
    required this.category,
    required this.itemType,
    required this.weight,
    required this.searchText,
    this.description,
    this.properties,
  });

  final String name;
  final String displayName;
  final String subtitle;
  final String category;
  final ItemType itemType;
  final double weight;
  final String searchText;
  final String? description;
  final Map<String, dynamic>? properties;

  bool matches(String query) => searchText.contains(query.toLowerCase());
}

class SrdInventorySearchCatalog {
  SrdInventorySearchCatalog._(this.entries);

  factory SrdInventorySearchCatalog.fromSrd({
    required List<SrdWeapon> weapons,
    required List<SrdArmor> armors,
    required List<SrdGearItem> gear,
    required List<SrdMagicItem> magic,
    required List<SrdTool> tools,
    required SrdI18nService i18n,
    required AppLocalizations l10n,
    required String Function(ItemType type) itemTypeLabel,
    required String Function(String category) categoryLabel,
  }) {
    final entries = <SrdInventorySearchEntry>[];

    void addEntry({
      required String name,
      required String displayName,
      required String subtitle,
      required String category,
      required ItemType itemType,
      required double weight,
      String? description,
      Map<String, dynamic>? properties,
    }) {
      entries.add(
        SrdInventorySearchEntry(
          name: name,
          displayName: _stripAmmunitionPackSuffix(displayName, itemType),
          subtitle: subtitle,
          category: category,
          itemType: itemType,
          weight: weight,
          description: description,
          properties: properties,
          searchText: _buildSearchText([
            _stripAmmunitionPackSuffix(displayName, itemType),
            _stripAmmunitionPackSuffix(name, itemType),
            itemTypeLabel(itemType),
            categoryLabel(category),
            description,
          ]),
        ),
      );
    }

    for (final weapon in weapons) {
      addEntry(
        name: weapon.name,
        displayName: i18n.equipmentName(weapon.name),
        subtitle:
            '${weapon.damage} ${i18n.damageType(weapon.damageType)}  -  ${weapon.cost}',
        category: weapon.category,
        itemType: ItemType.weapon,
        weight: weapon.weight,
        description: weapon.properties.isNotEmpty
            ? i18n.weaponProperties(weapon.properties)
            : null,
        properties: {
          'damageDice': weapon.damage,
          'damageType': weapon.damageType,
          if (weapon.properties.isNotEmpty)
            'weaponProperties': weapon.properties,
          if (weapon.versatileDamage != null)
            'versatileDamage': weapon.versatileDamage,
          if (weapon.range != null)
            'range': {
              'normal': weapon.range!.normal,
              'long': weapon.range!.long,
            },
          if (weapon.cost.isNotEmpty) 'cost': weapon.cost,
        },
      );
    }

    for (final armor in armors) {
      final armorSubtitle = armor.isShield
          ? '+${armor.acBonus} ${i18n.term("AC")}  -  ${armor.cost}'
          : '${i18n.term("AC")} ${armor.baseAC}'
                '${armor.addDexModifier ? " + ${i18n.term("DEX")}" : ""}'
                '${armor.maxDexBonus != null ? " (${l10n.inventoryDetailMaxShort} +${armor.maxDexBonus})" : ""}'
                '  -  ${armor.cost}';
      addEntry(
        name: armor.name,
        displayName: i18n.equipmentName(armor.name),
        subtitle: armorSubtitle,
        category: 'armor',
        itemType: ItemType.armor,
        weight: armor.weight,
        description:
            armor.stealthDisadvantage ? l10n.armorStealthDisadvantage : null,
        properties: {
          'armorType': armor.type,
          'baseAC': armor.baseAC,
          'addDexModifier': armor.addDexModifier,
          'maxDexBonus': armor.maxDexBonus,
          'isShield': armor.isShield,
          'acBonus': armor.acBonus,
          if (armor.strengthRequired != null)
            'strengthRequirement': armor.strengthRequired,
          if (armor.stealthDisadvantage) 'stealthDisadvantage': true,
          if (armor.cost.isNotEmpty) 'cost': armor.cost,
        },
      );
    }

    for (final item in gear) {
      final itemType = item.category == 'ammunition'
          ? ItemType.ammunition
          : item.category == 'container'
          ? ItemType.container
          : ItemType.gear;
      addEntry(
        name: item.name,
        displayName: i18n.equipmentName(item.name),
        subtitle: item.cost,
        category: item.category,
        itemType: itemType,
        weight: item.weight,
        description:
            i18n.equipmentDescription(item.name) ??
            (item.description.isNotEmpty ? item.description : null),
        properties: {if (item.cost.isNotEmpty) 'cost': item.cost},
      );
    }

    for (final item in magic) {
      addEntry(
        name: item.name,
        displayName: i18n.magicItemName(item.name),
        subtitle:
            '${i18n.term(item.rarity)}${item.requiresAttunement ? "  -  ${i18n.term("attunement")}" : ""}',
        category: item.type,
        itemType: item.itemType,
        weight: item.weight,
        description: i18n.magicItemDescription(item.name) ?? item.description,
        properties: item.properties,
      );
    }

    for (final tool in tools) {
      addEntry(
        name: tool.name,
        displayName: i18n.toolName(tool.name),
        subtitle: switch (tool.category) {
          'artisans_tools' => l10n.inventoryGroupArtisansTools,
          'gaming_sets' => l10n.inventoryGroupGamingSets,
          'musical_instruments' => l10n.inventoryGroupMusicalInstruments,
          _ => l10n.inventoryGroupOtherTools,
        },
        category: tool.category,
        itemType: ItemType.gear,
        weight: tool.weight,
      );
    }

    return SrdInventorySearchCatalog._(List.unmodifiable(entries));
  }

  final List<SrdInventorySearchEntry> entries;

  List<SrdInventorySearchEntry> search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return entries;
    return entries.where((entry) => entry.matches(normalized)).toList();
  }
}

String _stripAmmunitionPackSuffix(String name, ItemType itemType) {
  if (itemType != ItemType.ammunition) return name;
  return name.replaceFirst(_numberedPackSuffixPattern, '').trim();
}

String _buildSearchText(Iterable<String?> parts) {
  return parts
      .whereType<String>()
      .map((part) => part.trim().toLowerCase())
      .where((part) => part.isNotEmpty)
      .join(' ');
}
