import '../../character_detail_dependencies.dart';

final _numberedPackSuffixPattern = RegExp(r'\s*\((\d+)\)$');

String stripAmmunitionPackSuffix(String name, ItemType itemType) {
  if (itemType != ItemType.ammunition) return name;
  return name.replaceFirst(_numberedPackSuffixPattern, '').trim();
}

int? ammunitionPackQuantity(String name, ItemType itemType) {
  if (itemType != ItemType.ammunition) return null;
  final match = _numberedPackSuffixPattern.firstMatch(name);
  if (match == null) return null;
  return int.tryParse(match.group(1)!);
}

double inventoryUnitWeight(String name, ItemType itemType, double packWeight) {
  final packQuantity = ammunitionPackQuantity(name, itemType);
  if (packQuantity == null || packQuantity <= 1 || packWeight <= 0) {
    return packWeight;
  }
  return packWeight / packQuantity;
}

String itemQuantityTitle(String displayName, int quantity) {
  return quantity != 1 ? '$displayName ×$quantity' : displayName;
}

// ── Item Tile ─────────────────────────────────────────────────────────────────

/// Returns a localised display name for [item].
/// Tries equipment overlay, then magic_items overlay, then background
/// equipment strings, then falls back to the original name.
String itemDisplayName(EquipmentItem item, SrdI18nService i18n) {
  final fromEquip = i18n.equipmentName(item.name);
  if (fromEquip != item.name) {
    return stripAmmunitionPackSuffix(fromEquip, item.itemType);
  }
  final fromMagic = i18n.magicItemName(item.name);
  if (fromMagic != item.name) {
    return stripAmmunitionPackSuffix(fromMagic, item.itemType);
  }
  return stripAmmunitionPackSuffix(
    i18n.backgroundEquipmentName(item.name),
    item.itemType,
  );
}

class ItemDetailRow {
  const ItemDetailRow(this.label, this.value);

  final String label;
  final String value;
}

String itemTypeLabel(ItemType type, AppLocalizations l10n) {
  switch (type) {
    case ItemType.weapon:
      return l10n.inventoryTypeWeapon;
    case ItemType.armor:
      return l10n.inventoryTypeArmor;
    case ItemType.consumable:
      return l10n.inventoryTypeConsumable;
    case ItemType.ammunition:
      return l10n.inventoryAmmunition;
    case ItemType.equippable:
      return l10n.inventoryTypeEquippable;
    case ItemType.container:
      return l10n.inventoryTypeContainer;
    case ItemType.gear:
      return l10n.inventoryTypeGear;
  }
}

String itemCategoryLabel(
  EquipmentItem item,
  AppLocalizations l10n,
  SrdI18nService i18n,
) {
  return categoryLabel(item.category, l10n, i18n);
}

String categoryLabel(
  String rawCategory,
  AppLocalizations l10n,
  SrdI18nService i18n,
) {
  final category = rawCategory.trim();
  switch (category) {
    case 'simple melee':
      return l10n.inventoryGroupSimpleMelee;
    case 'simple ranged':
      return l10n.inventoryGroupSimpleRanged;
    case 'martial melee':
      return l10n.inventoryGroupMartialMelee;
    case 'martial ranged':
      return l10n.inventoryGroupMartialRanged;
    case 'light':
      return l10n.inventoryGroupLightArmor;
    case 'medium':
      return l10n.inventoryGroupMediumArmor;
    case 'heavy':
      return l10n.inventoryGroupHeavyArmor;
    case 'shield':
      return l10n.inventoryGroupShields;
    case 'adventuring gear':
      return l10n.inventoryGroupAdventuringGear;
    case 'ammunition':
      return l10n.inventoryGroupAmmunition;
    case 'arcane focus':
      return l10n.inventoryGroupArcaneFocus;
    case 'clothing':
      return l10n.inventoryGroupClothing;
    case 'container':
      return l10n.inventoryGroupContainer;
    case 'poison':
      return l10n.inventoryGroupPoison;
    case 'potion':
      return l10n.inventoryGroupPotions;
    case 'ring':
      return l10n.inventoryGroupRings;
    case 'wand':
      return l10n.inventoryGroupWands;
    case 'wondrous item':
      return l10n.inventoryGroupWondrousItems;
    case 'artisans_tools':
      return l10n.inventoryGroupArtisansTools;
    case 'gaming_sets':
      return l10n.inventoryGroupGamingSets;
    case 'musical_instruments':
      return l10n.inventoryGroupMusicalInstruments;
    case 'other_tools':
      return l10n.inventoryGroupOtherTools;
    case 'weapon':
      return l10n.inventoryTypeWeapon;
    case 'armor':
      return l10n.inventoryTypeArmor;
    case 'consumable':
      return l10n.inventoryTypeConsumable;
    case 'equippable':
      return l10n.inventoryTypeEquippable;
    case 'gear':
      return l10n.inventoryTypeGear;
  }
  return i18n.term(category);
}

String _detailYesNo(bool value, AppLocalizations l10n) =>
    value ? l10n.inventoryDetailYes : l10n.inventoryDetailNo;

String _formatDetailNumber(num value) =>
    value % 1 == 0 ? value.toInt().toString() : value.toString();

String? _formatDetailValue(
  dynamic value,
  UnitSystem unitSystem,
  SrdI18nService i18n,
  AppLocalizations l10n,
) {
  if (value == null) return null;
  if (value is bool) return _detailYesNo(value, l10n);
  if (value is num) return _formatDetailNumber(value);
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  if (value is Iterable) {
    final parts = value
        .map((e) => _formatDetailValue(e, unitSystem, i18n, l10n))
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.isEmpty ? null : parts.join(', ');
  }
  if (value is Map) {
    final parts = value.entries
        .map((e) {
          final text = _formatDetailValue(e.value, unitSystem, i18n, l10n);
          return text == null ? null : '${e.key}: $text';
        })
        .whereType<String>()
        .toList();
    return parts.isEmpty ? null : parts.join(', ');
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

int? _detailInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? _formatRangeDetail(
  dynamic value,
  UnitSystem unitSystem,
  SrdI18nService i18n,
  AppLocalizations l10n,
) {
  if (value is! Map) return _formatDetailValue(value, unitSystem, i18n, l10n);
  final normal = _detailInt(value['normal']);
  final long = _detailInt(value['long']);
  final parts = <String>[];
  if (normal != null) {
    parts.add(
      '${l10n.inventoryDetailRangeNormal} ${formatDistance(normal, unitSystem)}',
    );
  }
  if (long != null) {
    parts.add(
      '${l10n.inventoryDetailRangeLong} ${formatDistance(long, unitSystem)}',
    );
  }
  return parts.isEmpty ? null : parts.join(' / ');
}

String? _formatUsesDetail(
  dynamic value,
  UnitSystem unitSystem,
  SrdI18nService i18n,
  AppLocalizations l10n,
) {
  if (value is Map && value['amount'] != null) {
    return _formatDetailValue(value['amount'], unitSystem, i18n, l10n);
  }
  return _formatDetailValue(value, unitSystem, i18n, l10n);
}

String? _formatFeaturesDetail(
  dynamic value,
  UnitSystem unitSystem,
  SrdI18nService i18n,
  AppLocalizations l10n,
) {
  if (value is! Iterable) {
    return _formatDetailValue(value, unitSystem, i18n, l10n);
  }
  final parts = value
      .map((feature) {
        if (feature is Map) {
          final name = _formatDetailValue(
            feature['name'],
            unitSystem,
            i18n,
            l10n,
          );
          final description = _formatDetailValue(
            feature['description'],
            unitSystem,
            i18n,
            l10n,
          );
          if (name != null && description != null) {
            return '$name: $description';
          }
          return name ?? description;
        }
        return _formatDetailValue(feature, unitSystem, i18n, l10n);
      })
      .whereType<String>()
      .where((e) => e.isNotEmpty)
      .toList();
  return parts.isEmpty ? null : parts.join('\n');
}

String? _formatPropertyDetail(
  String key,
  dynamic value,
  UnitSystem unitSystem,
  SrdI18nService i18n,
  AppLocalizations l10n,
) {
  switch (key) {
    case 'damageType':
    case 'extraDamageType':
      final text = _formatDetailValue(value, unitSystem, i18n, l10n);
      return text == null ? null : i18n.damageType(text);
    case 'weaponProperties':
      if (value is Iterable) {
        final props = value.map((e) => e.toString()).toList();
        return props.isEmpty ? null : i18n.weaponProperties(props);
      }
      return _formatDetailValue(value, unitSystem, i18n, l10n);
    case 'range':
      return _formatRangeDetail(value, unitSystem, i18n, l10n);
    case 'capacityWeight':
      if (value is num) return formatWeight(value.toDouble(), unitSystem);
      return _formatDetailValue(value, unitSystem, i18n, l10n);
    case 'uses':
      return _formatUsesDetail(value, unitSystem, i18n, l10n);
    case 'features':
      return _formatFeaturesDetail(value, unitSystem, i18n, l10n);
    case 'rarity':
      final text = _formatDetailValue(value, unitSystem, i18n, l10n);
      return text == null ? null : i18n.term(text);
    case 'armorType':
      final text = _formatDetailValue(value, unitSystem, i18n, l10n);
      return text == null ? null : categoryLabel(text, l10n, i18n);
    default:
      return _formatDetailValue(value, unitSystem, i18n, l10n);
  }
}

String _propertyDetailLabel(String key, AppLocalizations l10n) {
  switch (key) {
    case 'damageDice':
    case 'damage':
      return l10n.inventoryDetailDamage;
    case 'damageType':
      return l10n.inventoryDetailDamageType;
    case 'weaponProperties':
      return l10n.inventoryDetailWeaponProperties;
    case 'versatileDamage':
      return l10n.inventoryDetailVersatileDamage;
    case 'range':
      return l10n.inventoryDetailRange;
    case 'armorType':
      return l10n.inventoryDetailArmorType;
    case 'isShield':
      return l10n.inventoryDetailShield;
    case 'baseAC':
      return l10n.inventoryDetailBaseAc;
    case 'acBonus':
      return l10n.inventoryDetailAcBonus;
    case 'addDexModifier':
      return l10n.inventoryDetailAddDexToAc;
    case 'maxDexBonus':
      return l10n.inventoryDetailMaxDex;
    case 'strengthRequirement':
    case 'strengthRequired':
      return l10n.inventoryDetailStrengthMinimum;
    case 'stealthDisadvantage':
      return l10n.armorStealthDisadvantage;
    case 'equipSlot':
      return l10n.inventoryDetailEquipSlot;
    case 'requiresAttunement':
      return l10n.inventoryDetailRequiresAttunement;
    case 'capacityWeight':
      return l10n.inventoryDetailCapacityWeight;
    case 'capacityVolume':
      return l10n.inventoryDetailCapacityVolume;
    case 'capacityVolumeUnit':
      return l10n.inventoryDetailCapacityVolumeUnit;
    case 'contentsWeightIgnored':
      return l10n.inventoryDetailIgnoreContentWeight;
    case 'effect':
      return l10n.inventoryDetailEffect;
    case 'uses':
      return l10n.inventoryDetailUses;
    case 'actionType':
      return l10n.inventoryDetailAction;
    case 'ammoType':
      return l10n.inventoryDetailAmmoType;
    case 'compatibleWith':
      return l10n.inventoryDetailCompatibleWith;
    case 'bonus':
      return l10n.inventoryDetailBonus;
    case 'extraDamage':
      return l10n.inventoryDetailExtraDamage;
    case 'extraDamageType':
      return l10n.inventoryDetailExtraDamageType;
    case 'subtype':
      return l10n.inventoryDetailSubtype;
    case 'cost':
      return l10n.inventoryDetailCost;
    case 'rarity':
      return l10n.inventoryDetailRarity;
    case 'features':
      return l10n.inventoryDetailFeatures;
    default:
      return key;
  }
}

List<ItemDetailRow> itemBaseDetailRows(
  EquipmentItem item,
  UnitSystem unitSystem,
  AppLocalizations l10n,
  SrdI18nService i18n,
) {
  final rows = <ItemDetailRow>[
    ItemDetailRow(
      l10n.inventoryLabelType,
      itemTypeLabel(item.itemType, l10n),
    ),
    if (item.category.trim().isNotEmpty)
      ItemDetailRow(
        l10n.inventoryLabelCategory,
        itemCategoryLabel(item, l10n, i18n),
      ),
    ItemDetailRow(l10n.inventoryLabelItemQuantity, item.quantity.toString()),
    ItemDetailRow(
      l10n.inventoryDetailWeightEach,
      formatWeight(item.weight, unitSystem),
    ),
  ];

  if (item.quantity > 1) {
    rows.add(
      ItemDetailRow(
        l10n.inventoryDetailWeightTotal,
        formatWeight(item.weight * item.quantity, unitSystem),
      ),
    );
  }

  if (item.itemType == ItemType.weapon ||
      item.itemType == ItemType.armor ||
      item.itemType == ItemType.equippable) {
    rows.add(
      ItemDetailRow(
        l10n.inventoryDetailState,
        item.isEquipped
            ? l10n.inventoryDetailEquipped
            : l10n.inventoryDetailNotEquipped,
      ),
    );
  }

  return rows;
}

List<ItemDetailRow> itemPropertyDetailRows(
  EquipmentItem item,
  UnitSystem unitSystem,
  SrdI18nService i18n,
  AppLocalizations l10n,
) {
  final props = item.properties;
  if (props == null || props.isEmpty) return const [];

  final rows = <ItemDetailRow>[];
  final used = <String>{};

  void addValue(
    List<String> keys,
    String label,
    dynamic value, {
    String? propertyKey,
  }) {
    used.addAll(keys);
    final key = propertyKey ?? keys.first;
    final text = _formatPropertyDetail(key, value, unitSystem, i18n, l10n);
    if (text != null && text.isNotEmpty) {
      rows.add(ItemDetailRow(label, text));
    }
  }

  void addKey(String key) {
    addValue([key], _propertyDetailLabel(key, l10n), props[key]);
  }

  switch (item.itemType) {
    case ItemType.weapon:
      addValue(
        ['damageDice', 'damage'],
        _propertyDetailLabel('damageDice', l10n),
        props['damageDice'] ?? props['damage'],
        propertyKey: 'damageDice',
      );
      addKey('damageType');
      addKey('weaponProperties');
      addKey('versatileDamage');
      addKey('range');
      break;
    case ItemType.armor:
      addKey('armorType');
      addKey('isShield');
      addKey('baseAC');
      addKey('acBonus');
      addKey('addDexModifier');
      addKey('maxDexBonus');
      addValue(
        ['strengthRequirement', 'strengthRequired'],
        _propertyDetailLabel('strengthRequirement', l10n),
        props['strengthRequirement'] ?? props['strengthRequired'],
        propertyKey: 'strengthRequirement',
      );
      addKey('stealthDisadvantage');
      break;
    case ItemType.equippable:
      addKey('equipSlot');
      break;
    case ItemType.container:
      addKey('capacityWeight');
      addKey('capacityVolume');
      addKey('capacityVolumeUnit');
      addKey('contentsWeightIgnored');
      break;
    case ItemType.consumable:
      addKey('effect');
      addKey('uses');
      addKey('actionType');
      break;
    case ItemType.ammunition:
      addKey('ammoType');
      addKey('compatibleWith');
      addKey('bonus');
      addKey('extraDamage');
      addKey('extraDamageType');
      break;
    case ItemType.gear:
      addKey('subtype');
      break;
  }

  for (final key in ['rarity', 'requiresAttunement', 'cost', 'features']) {
    if (props.containsKey(key) && !used.contains(key)) addKey(key);
  }

  for (final entry in props.entries) {
    if (used.contains(entry.key)) continue;
    final text = _formatPropertyDetail(
      entry.key,
      entry.value,
      unitSystem,
      i18n,
      l10n,
    );
    if (text != null && text.isNotEmpty) {
      rows.add(ItemDetailRow(_propertyDetailLabel(entry.key, l10n), text));
    }
  }

  return rows;
}

class ItemDetailRows extends StatelessWidget {
  const ItemDetailRows({super.key, required this.rows});

  final List<ItemDetailRow> rows;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: rows
          .map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 124,
                    child: Text(
                      row.label,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      row.value,
                      style: const TextStyle(fontSize: 13, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
