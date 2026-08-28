import '../../character_detail_dependencies.dart';
import 'inventory_display_helpers.dart';

class _ItemDetailSection extends StatelessWidget {
  const _ItemDetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

List<SrdPackContent> _itemDetailContents(
  WidgetRef ref,
  EquipmentItem item,
  List<SrdPackContent> explicitContents,
) {
  if (explicitContents.isNotEmpty) return explicitContents;
  final itemsByName = ref.read(srdItemsProvider).valueOrNull;
  if (itemsByName == null) return const [];
  return itemsByName[item.name.trim().toLowerCase()]?.contents ?? const [];
}

void showItemDetailsSheet(
  BuildContext context,
  WidgetRef ref,
  EquipmentItem item,
  String displayName,
  String? meta, {
  List<SrdPackContent> contents = const [],
}) {
  final scheme = Theme.of(context).colorScheme;
  final unitSystem = ref.read(unitSystemProvider);
  final i18n = ref.read(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
  final l10n = AppLocalizations.of(context)!;
  final baseRows = itemBaseDetailRows(item, unitSystem, l10n, i18n);
  final propertyRows = itemPropertyDetailRows(item, unitSystem, i18n, l10n);
  final description = item.description?.trim();
  final detailContents = _itemDetailContents(ref, item, contents);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.28,
      maxChildSize: 0.9,
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              itemQuantityTitle(displayName, item.quantity),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (meta != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                meta,
                style: TextStyle(color: scheme.primary, fontSize: 13),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(16),
              children: [
                _ItemDetailSection(
                  title: l10n.inventoryDetailSummary,
                  child: ItemDetailRows(rows: baseRows),
                ),
                if (description != null && description.isNotEmpty)
                  _ItemDetailSection(
                    title: l10n.inventoryDetailDescription,
                    child: Text(
                      description,
                      style: const TextStyle(height: 1.6),
                    ),
                  ),
                if (detailContents.isNotEmpty)
                  _ItemDetailSection(
                    title: l10n.reviewEquipmentIncluded,
                    child: _PackContentsList(
                      contents: detailContents,
                      i18n: i18n,
                    ),
                  ),
                if (propertyRows.isNotEmpty)
                  _ItemDetailSection(
                    title: l10n.inventoryDetailAttributes,
                    child: ItemDetailRows(rows: propertyRows),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _PackContentsList extends StatelessWidget {
  const _PackContentsList({required this.contents, required this.i18n});

  final List<SrdPackContent> contents;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (final content in contents)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.circle,
                  size: 6,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.72),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    itemQuantityTitle(
                      i18n.backgroundEquipmentName(content.name),
                      content.quantity,
                    ),
                    style: const TextStyle(fontSize: 13, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
