import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';

import '../../../data/datasources/srd/srd_i18n_service.dart';
import '../../character_detail/widgets/inventory/item_detail_sheet.dart';
import 'review_equipment_preview.dart';

void showEquipmentPreviewDetails(
  BuildContext context,
  WidgetRef ref,
  ReviewEquipmentPreview preview,
) {
  if (!preview.hasDetails) return;
  showItemDetailsSheet(
    context,
    ref,
    preview.item,
    preview.displayName,
    preview.meta,
    contents: preview.contents,
  );
}

void showEquipmentPackageDetails(
  BuildContext context,
  WidgetRef ref,
  List<ReviewEquipmentPreview> previews,
  String title,
  SrdI18nService i18n,
) {
  if (previews.length == 1) {
    showEquipmentPreviewDetails(context, ref, previews.single);
    return;
  }

  final scheme = Theme.of(context).colorScheme;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.58,
      minChildSize: 0.28,
      maxChildSize: 0.88,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(12),
              itemCount: previews.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final preview = previews[index];
                return EquipmentPreviewTile(
                  preview: preview,
                  i18n: i18n,
                  onTap: preview.hasDetails
                      ? () => showEquipmentPreviewDetails(
                          context,
                          ref,
                          preview,
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class EquipmentInfoButton extends StatelessWidget {
  const EquipmentInfoButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.of(context)!.detailSheetInfoTooltip,
      icon: const Icon(Icons.info_outline),
      iconSize: 18,
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
    );
  }
}

class EquipmentPreviewTile extends StatelessWidget {
  const EquipmentPreviewTile({
    super.key,
    required this.preview,
    required this.i18n,
    this.onTap,
  });

  final ReviewEquipmentPreview preview;
  final SrdI18nService i18n;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final subtitle = equipmentPreviewSubtitle(context, preview, i18n);
    return ListTile(
      dense: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      title: Text(equipmentPreviewTitle(preview)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: onTap == null ? null : const Icon(Icons.info_outline, size: 18),
      onTap: onTap,
    );
  }
}

class EquipmentDropdownOption extends StatelessWidget {
  const EquipmentDropdownOption({
    super.key,
    required this.preview,
    required this.label,
    required this.i18n,
  });

  final ReviewEquipmentPreview? preview;
  final String label;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context) {
    final itemPreview = preview;
    if (itemPreview == null) {
      return Text(label, overflow: TextOverflow.ellipsis);
    }
    final subtitle = equipmentPreviewSubtitle(context, itemPreview, i18n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          equipmentPreviewTitle(itemPreview),
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class ReviewEquipmentCheckboxTile extends StatelessWidget {
  const ReviewEquipmentCheckboxTile({
    super.key,
    required this.rawName,
    required this.preview,
    required this.i18n,
    required this.isSelected,
    required this.onChanged,
    required this.onDetails,
  });

  final String rawName;
  final ReviewEquipmentPreview? preview;
  final SrdI18nService i18n;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isGold = isGoldEquipmentEntry(rawName);
    final itemPreview = preview;
    final title = itemPreview == null
        ? i18n.backgroundEquipmentName(rawName)
        : equipmentPreviewTitle(itemPreview);
    final subtitle = itemPreview == null
        ? null
        : equipmentPreviewSubtitle(context, itemPreview, i18n);
    Widget? secondary;
    if (isGold) {
      secondary = Icon(
        Icons.monetization_on_outlined,
        size: 16,
        color: scheme.tertiary,
      );
    } else if (itemPreview?.hasDetails == true) {
      secondary = EquipmentInfoButton(onPressed: onDetails);
    }

    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      value: isSelected,
      onChanged: onChanged,
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      secondary: secondary,
    );
  }
}

class ReviewEquipmentChip extends StatelessWidget {
  const ReviewEquipmentChip({
    super.key,
    required this.rawName,
    required this.preview,
    required this.i18n,
    required this.onDetails,
  });

  final String rawName;
  final ReviewEquipmentPreview? preview;
  final SrdI18nService i18n;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    final itemPreview = preview;
    final label = itemPreview == null
        ? i18n.backgroundEquipmentName(rawName)
        : equipmentPreviewTitle(itemPreview);
    if (itemPreview?.hasDetails != true) {
      return Chip(
        label: Text(label, style: Theme.of(context).textTheme.bodySmall),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      );
    }
    return ActionChip(
      avatar: const Icon(Icons.info_outline, size: 16),
      label: Text(label, style: Theme.of(context).textTheme.bodySmall),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      onPressed: onDetails,
    );
  }
}

class ClassEquipmentOptionTile extends StatelessWidget {
  const ClassEquipmentOptionTile({
    super.key,
    required this.label,
    required this.previews,
    required this.i18n,
    required this.selected,
    required this.onSelected,
    required this.onDetails,
  });

  final String label;
  final List<ReviewEquipmentPreview> previews;
  final SrdI18nService i18n;
  final bool selected;
  final VoidCallback onSelected;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final subtitles = previews
        .map((preview) => equipmentPreviewSubtitle(context, preview, i18n))
        .whereType<String>()
        .toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onSelected,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? scheme.secondaryContainer.withValues(alpha: 0.72)
                : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? scheme.secondary : scheme.outlineVariant,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 18,
                  color: selected ? scheme.secondary : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected ? scheme.onSecondaryContainer : null,
                      ),
                    ),
                    if (subtitles.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitles.join('  \u00b7  '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: selected
                              ? scheme.onSecondaryContainer.withValues(
                                  alpha: 0.82,
                                )
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onDetails != null) EquipmentInfoButton(onPressed: onDetails),
            ],
          ),
        ),
      ),
    );
  }
}
