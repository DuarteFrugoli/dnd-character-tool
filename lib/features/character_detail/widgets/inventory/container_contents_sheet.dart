import '../../character_detail_dependencies.dart';
import 'inventory_display_helpers.dart';
import 'inventory_item_tile.dart';
import 'item_detail_sheet.dart';

class ContainerContentsSheet extends ConsumerWidget {
  const ContainerContentsSheet({
    super.key,
    required this.characterId,
    required this.containerId,
  });

  final String characterId;
  final String containerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inventoryTabVmProvider(characterId));
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final unitSystem = ref.watch(unitSystemProvider);
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.35,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.detailErrorLoading(error.toString()),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (vm) {
            final inventory = vm.snapshot;
            final container = inventory.containers.firstWhereOrNull(
              (item) => item.id == containerId,
            );

            if (container == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.inventoryContainerEmpty),
                ),
              );
            }

            final contents =
                inventory.contentsByContainer[containerId] ??
                const <EquipmentItem>[];
            final displayName = itemDisplayName(container, i18n);
            final meta = ItemTile.itemMeta(container, i18n, l10n);

            return CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        containerSubtitleText(
                          context,
                          container,
                          contents,
                          unitSystem,
                        ),
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: Text(l10n.inventoryDetailSummary),
                          onPressed: () => showItemDetailsSheet(
                            context,
                            ref,
                            container,
                            displayName,
                            meta,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ]),
                  ),
                ),
                if (contents.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        l10n.inventoryContainerEmpty,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: InventorySliverReorderableItemList(
                      items: contents,
                      characterId: characterId,
                      itemBuilder: (context, item, reorderIndex) => ItemTile(
                        item: item,
                        containers: inventory.containers,
                        i18n: i18n,
                        characterId: characterId,
                        reorderIndex: reorderIndex,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        );
      },
    );
  }
}
