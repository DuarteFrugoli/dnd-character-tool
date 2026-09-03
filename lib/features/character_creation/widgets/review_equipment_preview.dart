import 'package:flutter/widgets.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';

import '../../../data/datasources/srd/srd_i18n_service.dart';
import '../../../data/datasources/srd/srd_models.dart';
import '../../../data/models/equipment_item.dart';
import '../../character_detail/widgets/inventory/inventory_display_helpers.dart';

class ReviewEquipmentPreview {
  const ReviewEquipmentPreview({
    required this.item,
    required this.displayName,
    required this.meta,
    required this.contents,
  });

  final EquipmentItem item;
  final String displayName;
  final String? meta;
  final List<SrdPackContent> contents;

  bool get hasDetails {
    return meta != null ||
        item.description?.trim().isNotEmpty == true ||
        contents.isNotEmpty ||
        item.properties?.isNotEmpty == true;
  }
}

class _ParsedEquipmentName {
  const _ParsedEquipmentName({required this.name, required this.quantity});

  final String name;
  final int quantity;
}

bool isGoldEquipmentEntry(String rawName) {
  return RegExp(r'^\d+\s*gp$', caseSensitive: false).hasMatch(rawName.trim());
}

ReviewEquipmentPreview? equipmentPreviewFor({
  required String rawName,
  required Map<String, SrdItemData> itemsByName,
  required SrdI18nService i18n,
  required AppLocalizations l10n,
}) {
  final parsed = _parseEquipmentName(rawName);
  if (parsed == null) return null;

  final data =
      _lookupEquipmentData(itemsByName, parsed.name) ??
      _lookupEquipmentData(itemsByName, rawName);
  final dataName = data?.name.trim();
  final canonicalName = dataName == null || dataName.isEmpty ? null : dataName;
  final name = parsed.name;
  final description =
      _nonEmpty(i18n.equipmentDescription(name)) ??
      _nonEmpty(
        canonicalName == null ? null : i18n.equipmentDescription(canonicalName),
      ) ??
      _nonEmpty(data?.description);

  final item = EquipmentItem(
    name: name,
    category: data?.category ?? '',
    itemType: data?.asItemType ?? ItemType.gear,
    quantity: parsed.quantity,
    description: description,
    weight: data?.weight ?? 0,
    properties: data?.properties,
  );
  return ReviewEquipmentPreview(
    item: item,
    displayName: itemDisplayName(item, i18n),
    meta: inventoryItemMeta(item, i18n, l10n),
    contents: data?.contents ?? const [],
  );
}

String equipmentPreviewTitle(ReviewEquipmentPreview preview) {
  return itemQuantityTitle(preview.displayName, preview.item.quantity);
}

String equipmentPreviewLabel({
  required String rawName,
  required Map<String, SrdItemData> itemsByName,
  required SrdI18nService i18n,
  required AppLocalizations l10n,
}) {
  final preview = equipmentPreviewFor(
    rawName: rawName,
    itemsByName: itemsByName,
    i18n: i18n,
    l10n: l10n,
  );
  return preview == null
      ? i18n.backgroundEquipmentName(rawName)
      : equipmentPreviewTitle(preview);
}

String? equipmentPreviewSubtitle(
  BuildContext context,
  ReviewEquipmentPreview preview,
  SrdI18nService i18n,
) {
  final l10n = AppLocalizations.of(context)!;
  return preview.meta ??
      _nonEmpty(preview.item.description) ??
      (preview.item.category.trim().isEmpty
          ? null
          : itemCategoryLabel(preview.item, l10n, i18n));
}

_ParsedEquipmentName? _parseEquipmentName(String rawName) {
  final trimmed = rawName.trim();
  if (trimmed.isEmpty || isGoldEquipmentEntry(trimmed)) return null;
  final quantityMatch = RegExp(r'^(\d+)\s+(.+)$').firstMatch(trimmed);
  if (quantityMatch == null) {
    return _ParsedEquipmentName(name: trimmed, quantity: 1);
  }
  return _ParsedEquipmentName(
    name: quantityMatch.group(2)!.trim(),
    quantity: int.parse(quantityMatch.group(1)!),
  );
}

SrdItemData? _lookupEquipmentData(
  Map<String, SrdItemData> itemsByName,
  String name,
) {
  final lower = name.trim().toLowerCase();
  if (lower.isEmpty) return null;
  return itemsByName[lower] ??
      (lower.endsWith('s')
          ? itemsByName[lower.substring(0, lower.length - 1)]
          : null);
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
