import '../../character_detail_dependencies.dart';
import '../../../../data/json_helpers.dart';
import 'inventory_display_helpers.dart';
import 'item_detail_sheet.dart';

Future<int?> showRemoveQuantityDialog(
  BuildContext context,
  EquipmentItem item, {
  String? displayName,
}) async {
  final itemDisplayName = displayName ?? item.name;
  if (item.quantity <= 1) {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.inventoryRemoveTitle),
        content: Text(
          AppLocalizations.of(context)!.inventoryRemoveContent(itemDisplayName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context)!.dialogRemove),
          ),
        ],
      ),
    );

    return confirm == true ? 1 : null;
  }

  int selected = 1;
  final qtyCtrl = TextEditingController(text: '1');

  final result = await showDialog<int>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.inventoryRemoveTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(itemDisplayName),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(
                context,
              )!.inventoryRemovePartial(selected, item.quantity),
            ),
            const SizedBox(height: 12),
            Slider(
              value: selected.toDouble(),
              min: 1,
              max: item.quantity.toDouble(),
              divisions: item.quantity > 1 ? item.quantity - 1 : null,
              label: '$selected',
              onChanged: (v) {
                final next = v.round().clamp(1, item.quantity);
                setState(() {
                  selected = next;
                  qtyCtrl.text = '$selected';
                });
              },
            ),
            const SizedBox(height: 6),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(
                  context,
                )!.inventoryLabelQuantityToRemove,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
              onChanged: (text) {
                final parsed = int.tryParse(text);
                if (parsed == null) return;
                final clamped = parsed.clamp(1, item.quantity);
                if (clamped != selected) {
                  setState(() => selected = clamped);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, selected),
            child: Text(AppLocalizations.of(context)!.dialogRemove),
          ),
        ],
      ),
    ),
  );

  qtyCtrl.dispose();
  return result;
}

Future<ContainerRemovalMode?> showRemoveContainerDialog(
  BuildContext context,
  String containerName,
  int contentsCount,
) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<ContainerRemovalMode>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.inventoryRemoveContainerTitle),
      content: Text(
        l10n.inventoryRemoveContainerContent(containerName, contentsCount),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.dialogCancel),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(ctx, ContainerRemovalMode.moveContentsToInventory),
          child: Text(l10n.inventoryRemoveContainerMoveContents),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(ctx, ContainerRemovalMode.deleteContents),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: Text(l10n.inventoryRemoveContainerDeleteContents),
        ),
      ],
    ),
  );
}

Future<void> showMoveItemSheet(
  BuildContext context,
  WidgetRef ref, {
  required EquipmentItem item,
  required String characterId,
  required List<EquipmentItem> containers,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final i18n = ref.read(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
  final notifier = ref.read(characterDetailProvider(characterId).notifier);
  final displayName = itemDisplayName(item, i18n);

  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(
              l10n.inventoryMoveTitle(displayName),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.inventory_outlined),
              title: Text(l10n.inventoryMoveToInventory),
              selected: item.containerId == null,
              onTap: () {
                Navigator.pop(ctx);
                notifier.moveItemToContainer(item.id, null);
              },
            ),
            for (final container in containers)
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(itemDisplayName(container, i18n)),
                selected: item.containerId == container.id,
                enabled: item.containerId != container.id,
                onTap: item.containerId == container.id
                    ? null
                    : () {
                        Navigator.pop(ctx);
                        notifier.moveItemToContainer(item.id, container.id);
                      },
              ),
          ],
        ),
      );
    },
  );
}

// ── Ammunition Section ────────────────────────────────────────────────────────

String containerSubtitleText(
  BuildContext context,
  EquipmentItem container,
  List<EquipmentItem> contents,
  UnitSystem unitSystem,
) {
  final l10n = AppLocalizations.of(context)!;
  final usedWeight = inventoryItemsTotalWeight(contents);
  final capacityWeight = inventoryContainerCapacityWeight(container);
  final contentsText = containerContentsLabel(l10n, contents);
  final weightText = capacityWeight == null || capacityWeight <= 0
      ? formatWeight(usedWeight, unitSystem)
      : '${formatWeight(usedWeight, unitSystem)} / ${formatWeight(capacityWeight, unitSystem)}';
  return '$contentsText - $weightText';
}

bool containerHasCountedContents(Iterable<EquipmentItem> contents) =>
    inventoryItemsTotalQuantity(contents) > 0;

String containerContentsLabel(
  AppLocalizations l10n,
  Iterable<EquipmentItem> contents,
) {
  final totalQuantity = inventoryItemsTotalQuantity(contents);
  if (totalQuantity <= 0) return l10n.inventoryContainerEmpty;
  return l10n.inventoryContainerContents(totalQuantity);
}

enum InventoryItemAction { move, remove }

class InventoryMenuItem extends StatelessWidget {
  const InventoryMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isDestructive ? scheme.error : scheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}

class InventorySliverReorderableItemList extends ConsumerWidget {
  const InventorySliverReorderableItemList({
    super.key,
    required this.items,
    required this.characterId,
    required this.itemBuilder,
  });

  final List<EquipmentItem> items;
  final String characterId;
  final Widget Function(
    BuildContext context,
    EquipmentItem item,
    int? reorderIndex,
  )
  itemBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget buildItem(int index, {required bool reorderable}) {
      final item = items[index];
      return KeyedSubtree(
        key: ValueKey('inventory-item-${item.id}'),
        child: Material(
          type: MaterialType.transparency,
          child: itemBuilder(context, item, reorderable ? index : null),
        ),
      );
    }

    if (items.length < 2) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => buildItem(index, reorderable: false),
          childCount: items.length,
        ),
      );
    }

    return SliverReorderableList(
      itemCount: items.length,
      findChildIndexCallback: (key) {
        if (key is! ValueKey<String>) return null;
        const prefix = 'inventory-item-';
        final value = key.value;
        if (!value.startsWith(prefix)) return null;
        final id = value.substring(prefix.length);
        final index = items.indexWhere((item) => item.id == id);
        return index == -1 ? null : index;
      },
      onReorder: (oldIndex, newIndex) => ref
          .read(characterDetailProvider(characterId).notifier)
          .reorderEquipmentItems(
            itemIds: items.map((item) => item.id).toList(),
            oldIndex: oldIndex,
            newIndex: newIndex,
          ),
      itemBuilder: (context, index) => buildItem(index, reorderable: true),
    );
  }
}

class ItemTile extends ConsumerWidget {
  const ItemTile({
    super.key,
    required this.item,
    required this.containers,
    required this.i18n,
    required this.characterId,
    this.reorderIndex,
  });

  final EquipmentItem item;
  final List<EquipmentItem> containers;
  final SrdI18nService i18n;
  final String characterId;
  final int? reorderIndex;

  Future<void> _confirmRemoveItem(
    BuildContext context,
    WidgetRef ref,
    CharacterDetailNotifier notifier,
  ) async {
    final character = ref
        .read(characterDetailProvider(characterId))
        .valueOrNull;
    final contents =
        character?.equipment
            .where(
              (e) =>
                  e.containerId == item.id && e.itemType != ItemType.container,
            )
            .toList() ??
        const <EquipmentItem>[];
    if (item.itemType == ItemType.container && contents.isNotEmpty) {
      final mode = await showRemoveContainerDialog(
        context,
        itemDisplayName(item, i18n),
        inventoryItemsTotalQuantity(contents),
      );
      if (mode != null) {
        await notifier.removeEquipmentQuantity(
          item.id,
          item.quantity,
          containerRemovalMode: mode,
        );
      }
      return;
    }

    final amount = await showRemoveQuantityDialog(
      context,
      item,
      displayName: itemDisplayName(item, i18n),
    );
    if (amount != null) {
      await notifier.removeEquipmentQuantity(item.id, amount);
    }
  }

  static String? itemMeta(
    EquipmentItem item, [
    SrdI18nService? i18n,
    AppLocalizations? l10n,
  ]) => inventoryItemMeta(item, i18n, l10n);

  static IconData _leadingIcon(ItemType type, bool equipped) {
    switch (type) {
      case ItemType.weapon:
        return equipped ? Icons.sports_kabaddi : Icons.sports_kabaddi_outlined;
      case ItemType.armor:
        return equipped ? Icons.shield : Icons.shield_outlined;
      case ItemType.consumable:
        return Icons.local_drink_outlined;
      case ItemType.ammunition:
        return Icons.arrow_upward;
      case ItemType.equippable:
        return equipped ? Icons.checkroom : Icons.checkroom_outlined;
      case ItemType.container:
        return Icons.inventory_2_outlined;
      case ItemType.gear:
        return Icons.backpack_outlined;
    }
  }

  static bool _isBodyArmor(EquipmentItem item) {
    if (item.itemType != ItemType.armor) return false;
    final props = item.properties;
    if (props == null) return false;
    if (readBool(props['isShield'])) return false;
    return props.containsKey('baseAC');
  }

  Future<void> _onEquipTap(
    BuildContext context,
    WidgetRef ref,
    CharacterDetailNotifier notifier,
  ) async {
    final character = ref
        .read(characterDetailProvider(characterId))
        .valueOrNull;

    // Troca de armadura corporal exige confirmação, mostrando CA atual e prevista.
    if (character != null && _isBodyArmor(item) && !item.isEquipped) {
      final equippedBodyArmors = character.equipment
          .where((e) => e.id != item.id && e.isEquipped && _isBodyArmor(e))
          .toList();

      if (equippedBodyArmors.isNotEmpty) {
        final equippedBodyArmor = equippedBodyArmors.first;
        final simulated = character.equipment.map((e) {
          if (e.id == equippedBodyArmor.id) {
            return e.copyWith(isEquipped: false);
          }
          if (e.id == item.id) return e.copyWith(isEquipped: true);
          return e;
        }).toList();
        final nextAc = calcArmorClass(character, equipment: simulated);

        final l10n = AppLocalizations.of(context)!;
        final armorDisplayName = i18n.equipmentName(equippedBodyArmor.name);
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.inventoryReplaceArmorTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.armorSwapCurrent(armorDisplayName)),
                const SizedBox(height: 8),
                Text(l10n.armorSwapAcNow(character.armorClass)),
                Text(l10n.armorSwapAcAfter(nextAc)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.dialogCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.armorSwapButton),
              ),
            ],
          ),
        );

        if (confirm != true) return;
        await notifier.toggleEquipped(item.id, forceArmorSwap: true);
        return;
      }
    }

    await notifier.toggleEquipped(item.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(characterDetailProvider(characterId).notifier);
    final canEquip =
        item.itemType == ItemType.weapon ||
        item.itemType == ItemType.armor ||
        item.itemType == ItemType.equippable;
    final canMove =
        item.itemType != ItemType.container &&
        !item.isEquipped &&
        (item.containerId != null || containers.isNotEmpty);
    final meta = itemMeta(item, i18n, l10n);
    final displayName = itemDisplayName(item, i18n);
    final widgetsL10n = WidgetsLocalizations.of(context);
    final reorderTooltip =
        '${widgetsL10n.reorderItemUp} / ${widgetsL10n.reorderItemDown}';

    // Stealth disadvantage: stored in properties (new items) or description (old items)
    final stealthDisadv =
        item.itemType == ItemType.armor &&
        (readBool(item.properties?['stealthDisadvantage']) ||
            (item.description?.toLowerCase().contains('stealth') == true));

    String? subtitleText;
    if (meta != null &&
        item.description != null &&
        item.description!.isNotEmpty &&
        !stealthDisadv) {
      subtitleText = '$meta  ·  ${item.description!}';
    } else {
      subtitleText = meta ?? (stealthDisadv ? null : item.description);
    }
    if (stealthDisadv) {
      subtitleText = subtitleText != null
          ? '$subtitleText  ·  ${l10n.armorStealthDisadvantage}'
          : l10n.armorStealthDisadvantage;
    }

    final accentColor = item.isEquipped ? scheme.primary : scheme.outline;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        tileColor: item.isEquipped
            ? scheme.primary.withValues(alpha: 0.10)
            : scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: item.isEquipped
                ? scheme.primary.withValues(alpha: 0.36)
                : scheme.outlineVariant.withValues(alpha: 0.68),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        onTap: () => showItemDetailsSheet(context, ref, item, displayName, meta),
        leading: canEquip
            ? MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _onEquipTap(context, ref, notifier),
                  child: Tooltip(
                    message: item.isEquipped
                        ? l10n.inventoryTooltipUnequip
                        : l10n.inventoryTooltipEquip,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: item.isEquipped
                          ? scheme.primary
                          : accentColor.withValues(alpha: 0.10),
                      child: Icon(
                        _leadingIcon(item.itemType, item.isEquipped),
                        size: 16,
                        color: item.isEquipped
                            ? scheme.onPrimary
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              )
            : null,
        title: Text(
          itemQuantityTitle(displayName, item.quantity),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: subtitleText != null
            ? Text(
                subtitleText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reorderIndex != null)
              ReorderableDragStartListener(
                index: reorderIndex!,
                child: Tooltip(
                  message: reorderTooltip,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.drag_handle,
                      size: 20,
                      color: scheme.outline,
                    ),
                  ),
                ),
              ),
            PopupMenuButton<InventoryItemAction>(
              onSelected: (action) {
                switch (action) {
                  case InventoryItemAction.move:
                    showMoveItemSheet(
                      context,
                      ref,
                      item: item,
                      characterId: characterId,
                      containers: containers,
                    );
                    break;
                  case InventoryItemAction.remove:
                    _confirmRemoveItem(context, ref, notifier);
                    break;
                }
              },
              itemBuilder: (ctx) => [
                if (canMove)
                  PopupMenuItem(
                    value: InventoryItemAction.move,
                    child: InventoryMenuItem(
                      icon: Icons.drive_file_move_outlined,
                      label: l10n.inventoryTooltipMove,
                    ),
                  ),
                PopupMenuItem(
                  value: InventoryItemAction.remove,
                  child: InventoryMenuItem(
                    icon: Icons.delete_outline,
                    label: l10n.inventoryTooltipRemove,
                    isDestructive: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
