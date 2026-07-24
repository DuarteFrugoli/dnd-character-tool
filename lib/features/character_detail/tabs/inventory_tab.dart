part of '../character_detail_screen.dart';

// ── Inventory Tab ─────────────────────────────────────────────────────────────

final _numberedPackSuffixPattern = RegExp(r'\s*\((\d+)\)$');

String _stripAmmunitionPackSuffix(String name, ItemType itemType) {
  if (itemType != ItemType.ammunition) return name;
  return name.replaceFirst(_numberedPackSuffixPattern, '').trim();
}

int? _ammunitionPackQuantity(String name, ItemType itemType) {
  if (itemType != ItemType.ammunition) return null;
  final match = _numberedPackSuffixPattern.firstMatch(name);
  if (match == null) return null;
  return int.tryParse(match.group(1)!);
}

double _inventoryUnitWeight(
  String name,
  ItemType itemType,
  double packWeight,
) {
  final packQuantity = _ammunitionPackQuantity(name, itemType);
  if (packQuantity == null || packQuantity <= 1 || packWeight <= 0) {
    return packWeight;
  }
  return packWeight / packQuantity;
}

String _itemQuantityTitle(String displayName, int quantity) {
  return quantity != 1 ? '$displayName ×$quantity' : displayName;
}

class _InventoryTab extends ConsumerStatefulWidget {
  const _InventoryTab({required this.character, required this.characterId});
  final Character character;
  final String characterId;

  @override
  ConsumerState<_InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends ConsumerState<_InventoryTab> {
  // Moedas — controladores locais sincronizados com o modelo
  late final Map<String, TextEditingController> _currencyCtrl;

  static const _coins = ['cp', 'sp', 'ep', 'gp', 'pp'];

  @override
  void initState() {
    super.initState();
    final currency = widget.character.currency;
    _currencyCtrl = {
      for (final c in _coins)
        c: TextEditingController(text: '${currency[c] ?? 0}'),
    };
  }

  @override
  void didUpdateWidget(_InventoryTab old) {
    super.didUpdateWidget(old);
    // Atualiza controladores se os valores mudaram externamente
    final currency = widget.character.currency;
    for (final c in _coins) {
      final val = '${currency[c] ?? 0}';
      if (_currencyCtrl[c]!.text != val) {
        _currencyCtrl[c]!.text = val;
      }
    }
  }

  @override
  void dispose() {
    for (final ctrl in _currencyCtrl.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _saveCurrency() {
    final map = <String, int>{
      for (final c in _coins) c: int.tryParse(_currencyCtrl[c]!.text) ?? 0,
    };
    ref
        .read(characterDetailProvider(widget.characterId).notifier)
        .updateCurrency(map);
  }

  void _showAddItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddItemSheet(characterId: widget.characterId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final character = widget.character;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final inventory = InventorySnapshot.fromEquipment(character.equipment);
    final coinLabels = {
      'cp': l10n.coinCopper,
      'sp': l10n.coinSilver,
      'ep': l10n.coinElectrum,
      'gp': l10n.coinGold,
      'pp': l10n.coinPlatinum,
    };

    // Weight tracking
    final strScore = character.abilityScores.strength;
    final totalWeight = inventory.totalWeight;
    final maxCarry = strScore * 15.0;
    final encumberedThreshold = strScore * 5.0;
    final heavilyEncThreshold = strScore * 10.0;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 192),
        children: [
          ResponsiveTwoColumn(
            leadingFlex: 2,
            trailingFlex: 3,
            leading: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Currency ───────────────────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.inventoryCurrency,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: scheme.primary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: _coins.map((c) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                child: TextField(
                                  controller: _currencyCtrl[c],
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    labelText: coinLabels[c],
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 8,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    _saveCurrency();
                                    FocusScope.of(context).unfocus();
                                  },
                                  onTapOutside: (_) {
                                    _saveCurrency();
                                    FocusScope.of(context).unfocus();
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Weight Tracking ───────────────────────────────────────
                if (character.weightTrackingEnabled)
                  _WeightBar(
                    totalWeight: totalWeight,
                    maxCarry: maxCarry,
                    encumberedAt: encumberedThreshold,
                    heavilyEncAt: heavilyEncThreshold,
                    onDisable: () => ref
                        .read(
                          characterDetailProvider(widget.characterId).notifier,
                        )
                        .toggleWeightTracking(),
                  )
                else
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => ref
                          .read(
                            characterDetailProvider(
                              widget.characterId,
                            ).notifier,
                          )
                          .toggleWeightTracking(),
                      icon: const Icon(Icons.monitor_weight_outlined, size: 16),
                      label: Text(l10n.weightEnableTooltip),
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.onSurfaceVariant,
                        textStyle: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),

                // ── Ammunition ─────────────────────────────────────────────
                if (inventory.ammunition.isNotEmpty)
                  _AmmunitionSection(
                    items: inventory.ammunition,
                    characterId: widget.characterId,
                  ),
              ],
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Equipped ───────────────────────────────────────────────
                if (inventory.equipped.isNotEmpty) ...[
                  _Section(
                    title: l10n.inventoryEquippedSection(
                      inventory.equipped.length,
                      character.armorClass,
                    ),
                    child: _InventoryReorderableItemList(
                      items: inventory.equipped,
                      characterId: widget.characterId,
                      itemBuilder: (context, item, reorderIndex) => _ItemTile(
                        item: item,
                        characterId: widget.characterId,
                        reorderIndex: reorderIndex,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Containers ─────────────────────────────────────────────
                if (inventory.containers.isNotEmpty) ...[
                  _ContainersSection(
                    containers: inventory.containers,
                    contentsByContainer: inventory.contentsByContainer,
                    characterId: widget.characterId,
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Equippable ─────────────────────────────────────────────
                if (inventory.equippable.isNotEmpty) ...[
                  _Section(
                    title: l10n.inventoryEquippableSection(
                      inventory.equippable.length,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
                          child: Row(
                            children: [
                              Icon(
                                Icons.touch_app_outlined,
                                size: 13,
                                color: scheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  l10n.inventoryEquipHint,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _InventoryReorderableItemList(
                          items: inventory.equippable,
                          characterId: widget.characterId,
                          itemBuilder: (context, item, reorderIndex) =>
                              _ItemTile(
                            item: item,
                            characterId: widget.characterId,
                            reorderIndex: reorderIndex,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Carried ────────────────────────────────────────────────
                if (inventory.carried.isNotEmpty || inventory.isEmpty)
                  _Section(
                    title: inventory.carried.isEmpty
                        ? l10n.inventoryInventory
                        : l10n.inventoryCarriedSection(
                            inventory.carried.length,
                          ),
                    child: inventory.carried.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              l10n.inventoryEmpty,
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          )
                        : Column(
                            children: [
                              _InventoryReorderableItemList(
                                items: inventory.carried,
                                characterId: widget.characterId,
                                itemBuilder: (context, item, reorderIndex) =>
                                    _ItemTile(
                                    item: item,
                                    characterId: widget.characterId,
                                    reorderIndex: reorderIndex,
                                  ),
                              ),
                            ],
                          ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemSheet,
        tooltip: AppLocalizations.of(context)!.inventoryTooltipAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<int?> _showRemoveQuantityDialog(
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

Future<ContainerRemovalMode?> _showRemoveContainerDialog(
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

Future<void> _showMoveItemSheet(
  BuildContext context,
  WidgetRef ref, {
  required EquipmentItem item,
  required String characterId,
  required List<EquipmentItem> containers,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final i18n = ref.read(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
  final notifier = ref.read(characterDetailProvider(characterId).notifier);
  final displayName = _itemDisplayName(item, i18n);

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
                title: Text(_itemDisplayName(container, i18n)),
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

enum _InventoryItemAction { move, remove }

class _InventoryMenuItem extends StatelessWidget {
  const _InventoryMenuItem({
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

class _InventoryReorderableItemList extends ConsumerWidget {
  const _InventoryReorderableItemList({
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
  ) itemBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget buildItem(int index, {required bool reorderable}) {
      final item = items[index];
      return KeyedSubtree(
        key: ValueKey('inventory-item-${item.id}'),
        child: itemBuilder(context, item, reorderable ? index : null),
      );
    }

    if (items.length < 2) {
      return Column(
        children: [
          for (var i = 0; i < items.length; i++)
            buildItem(i, reorderable: false),
        ],
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      padding: EdgeInsets.zero,
      itemCount: items.length,
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

class _AmmunitionSection extends ConsumerWidget {
  const _AmmunitionSection({required this.items, required this.characterId});
  final List<EquipmentItem> items;
  final String characterId;

  Future<void> _confirmRemoveAmmo(
    BuildContext context,
    WidgetRef ref,
    CharacterDetailNotifier notifier,
    EquipmentItem item,
  ) async {
    final i18n =
        ref.read(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final amount = await _showRemoveQuantityDialog(
      context,
      item,
      displayName: _itemDisplayName(item, i18n),
    );
    if (amount != null) {
      await notifier.removeEquipmentQuantity(item.id, amount);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final scheme = Theme.of(context).colorScheme;
    final notifier = ref.read(characterDetailProvider(characterId).notifier);
    final character = ref
        .watch(characterDetailProvider(characterId))
        .valueOrNull;
    final containers = character == null
        ? const <EquipmentItem>[]
        : InventorySnapshot.fromEquipment(character.equipment).containers;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.inventoryAmmunition,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: scheme.primary),
            ),
            const SizedBox(height: 8),
            _InventoryReorderableItemList(
              items: items,
              characterId: characterId,
              itemBuilder: (context, item, reorderIndex) {
                final displayName = _itemDisplayName(item, i18n);
                final meta = _ItemTile._itemMeta(item, i18n, l10n);
                final widgetsL10n = WidgetsLocalizations.of(context);
                final reorderTooltip =
                    '${widgetsL10n.reorderItemUp} / ${widgetsL10n.reorderItemDown}';
                final canMove =
                    item.containerId != null || containers.isNotEmpty;

                return InkWell(
                  onTap: () => _showItemDetailsSheet(
                    context,
                    ref,
                    item,
                    displayName,
                    meta,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_upward, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            displayName,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          onPressed: item.quantity <= 0
                              ? null
                              : () => notifier.adjustItemQuantity(item.id, -1),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '${item.quantity}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          onPressed: () =>
                              notifier.adjustItemQuantity(item.id, 1),
                        ),
                        if (reorderIndex != null)
                          ReorderableDragStartListener(
                            index: reorderIndex,
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
                        PopupMenuButton<_InventoryItemAction>(
                          onSelected: (action) {
                            switch (action) {
                              case _InventoryItemAction.move:
                                _showMoveItemSheet(
                                  context,
                                  ref,
                                  item: item,
                                  characterId: characterId,
                                  containers: containers,
                                );
                                break;
                              case _InventoryItemAction.remove:
                                _confirmRemoveAmmo(
                                  context,
                                  ref,
                                  notifier,
                                  item,
                                );
                                break;
                            }
                          },
                          itemBuilder: (ctx) => [
                            if (canMove)
                              PopupMenuItem(
                                value: _InventoryItemAction.move,
                                child: _InventoryMenuItem(
                                  icon: Icons.drive_file_move_outlined,
                                  label: l10n.inventoryTooltipMove,
                                ),
                              ),
                            PopupMenuItem(
                              value: _InventoryItemAction.remove,
                              child: _InventoryMenuItem(
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
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Containers Section ───────────────────────────────────────────────────────

class _ContainersSection extends ConsumerWidget {
  const _ContainersSection({
    required this.containers,
    required this.contentsByContainer,
    required this.characterId,
  });

  final List<EquipmentItem> containers;
  final Map<String, List<EquipmentItem>> contentsByContainer;
  final String characterId;

  Future<void> _removeContainer(
    BuildContext context,
    WidgetRef ref,
    EquipmentItem container,
    String displayName,
    List<EquipmentItem> contents,
  ) async {
    final notifier = ref.read(characterDetailProvider(characterId).notifier);
    if (contents.isNotEmpty) {
      final mode = await _showRemoveContainerDialog(
        context,
        displayName,
        inventoryItemsTotalQuantity(contents),
      );
      if (mode != null) {
        await notifier.removeEquipmentQuantity(
          container.id,
          container.quantity,
          containerRemovalMode: mode,
        );
      }
      return;
    }

    final amount = await _showRemoveQuantityDialog(
      context,
      container,
      displayName: displayName,
    );
    if (amount != null) {
      await notifier.removeEquipmentQuantity(container.id, amount);
    }
  }

  String _containerSubtitle(
    BuildContext context,
    EquipmentItem container,
    List<EquipmentItem> contents,
    UnitSystem unitSystem,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final totalQuantity = inventoryItemsTotalQuantity(contents);
    final usedWeight = inventoryItemsTotalWeight(contents);
    final capacityWeight = inventoryContainerCapacityWeight(container);
    final contentsText = l10n.inventoryContainerContents(totalQuantity);
    final weightText = capacityWeight == null || capacityWeight <= 0
        ? formatWeight(usedWeight, unitSystem)
        : '${formatWeight(usedWeight, unitSystem)} / ${formatWeight(capacityWeight, unitSystem)}';
    return '$contentsText · $weightText';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final unitSystem = ref.watch(unitSystemProvider);
    final scheme = Theme.of(context).colorScheme;

    return _Section(
      title: l10n.inventoryContainersSection(containers.length),
      child: _InventoryReorderableItemList(
        items: containers,
        characterId: characterId,
        itemBuilder: (context, container, reorderIndex) {
          final contents = contentsByContainer[container.id] ?? const [];
          final displayName = _itemDisplayName(container, i18n);
          final meta = _ItemTile._itemMeta(container, i18n, l10n);
          final widgetsL10n = WidgetsLocalizations.of(context);
          final reorderTooltip =
              '${widgetsL10n.reorderItemUp} / ${widgetsL10n.reorderItemDown}';
          final capacityWeight = inventoryContainerCapacityWeight(container);
          final usedWeight = inventoryItemsTotalWeight(contents);
          final overCapacity =
              capacityWeight != null &&
              capacityWeight > 0 &&
              usedWeight > capacityWeight;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: overCapacity ? scheme.errorContainer : null,
            child: ExpansionTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(
                _itemQuantityTitle(displayName, container.quantity),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _containerSubtitle(context, container, contents, unitSystem),
                style: TextStyle(
                  color: overCapacity
                      ? scheme.onErrorContainer
                      : scheme.onSurfaceVariant,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (reorderIndex != null)
                    ReorderableDragStartListener(
                      index: reorderIndex,
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
                  PopupMenuButton<_InventoryItemAction>(
                    onSelected: (action) {
                      switch (action) {
                        case _InventoryItemAction.move:
                          break;
                        case _InventoryItemAction.remove:
                          _removeContainer(
                            context,
                            ref,
                            container,
                            displayName,
                            contents,
                          );
                          break;
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: _InventoryItemAction.remove,
                        child: _InventoryMenuItem(
                          icon: Icons.delete_outline,
                          label: l10n.inventoryTooltipRemove,
                          isDestructive: true,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.expand_more),
                ],
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              children: [
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: Text(l10n.inventoryDetailSummary),
                      onPressed: () => _showItemDetailsSheet(
                        context,
                        ref,
                        container,
                        displayName,
                        meta,
                      ),
                    ),
                  ],
                ),
                if (contents.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.inventoryContainerEmpty,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  )
                else
                  _InventoryReorderableItemList(
                    items: contents,
                    characterId: characterId,
                    itemBuilder: (context, item, reorderIndex) => _ItemTile(
                      item: item,
                      characterId: characterId,
                      reorderIndex: reorderIndex,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Weight Bar ────────────────────────────────────────────────────────────────

class _WeightBar extends ConsumerWidget {
  const _WeightBar({
    required this.totalWeight,
    required this.maxCarry,
    required this.encumberedAt,
    required this.heavilyEncAt,
    required this.onDisable,
  });

  final double totalWeight;
  final double maxCarry;
  final double encumberedAt;
  final double heavilyEncAt;
  final VoidCallback onDisable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final unitSystem = ref.watch(unitSystemProvider);
    final fraction = maxCarry > 0
        ? (totalWeight / maxCarry).clamp(0.0, 1.0)
        : 0.0;

    final Color barColor;
    String? statusLabel;
    if (totalWeight > heavilyEncAt) {
      barColor = scheme.error;
      statusLabel = l10n.weightHeavilyEncumbered;
    } else if (totalWeight > encumberedAt) {
      barColor = Colors.orange;
      statusLabel = l10n.weightEncumbered;
    } else {
      barColor = scheme.primary;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.monitor_weight_outlined,
                  size: 16,
                  color: scheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '${formatWeight(totalWeight, unitSystem)} / ${formatWeight(maxCarry, unitSystem)}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (statusLabel != null) ...[
                          const TextSpan(text: '  '),
                          TextSpan(
                            text: statusLabel,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: barColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  tooltip: l10n.weightDisableTooltip,
                  onPressed: onDisable,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 8,
                    backgroundColor: scheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
                // Tick marks at ×5 and ×10 STR thresholds
                if (maxCarry > 0) ...[
                  _WeightTick(fraction: encumberedAt / maxCarry),
                  _WeightTick(fraction: heavilyEncAt / maxCarry),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightTick extends StatelessWidget {
  const _WeightTick({required this.fraction});
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: fraction.clamp(0.0, 1.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(width: 2, height: 8, color: scheme.surface),
      ),
    );
  }
}

// ── Add Item Bottom Sheet ─────────────────────────────────────────────────────

class _AddItemSheet extends ConsumerStatefulWidget {
  const _AddItemSheet({required this.characterId});
  final String characterId;

  @override
  ConsumerState<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<_AddItemSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _search = TextEditingController();
  final _customNameCtrl = TextEditingController();
  final _customQtyCtrl = TextEditingController(text: '1');
  final _customWeightCtrl = TextEditingController(text: '0');
  final _customDescCtrl = TextEditingController();
  final _customWeaponDamageCtrl = TextEditingController();
  final _customWeaponDamageTypeCtrl = TextEditingController();
  final _customWeaponPropertiesCtrl = TextEditingController();
  final _customWeaponRangeNormalCtrl = TextEditingController();
  final _customWeaponRangeLongCtrl = TextEditingController();
  final _customArmorBaseAcCtrl = TextEditingController(text: '10');
  final _customArmorAcBonusCtrl = TextEditingController(text: '2');
  final _customArmorMaxDexCtrl = TextEditingController();
  final _customArmorStrengthCtrl = TextEditingController();
  final _customEquipSlotCtrl = TextEditingController();
  final _customContainerCapacityWeightCtrl = TextEditingController();
  final _customContainerCapacityVolumeCtrl = TextEditingController();
  final _customContainerVolumeUnitCtrl = TextEditingController();
  final _customConsumableEffectCtrl = TextEditingController();
  final _customConsumableUsesCtrl = TextEditingController(text: '1');
  final _customConsumableActionCtrl = TextEditingController();
  final _customAmmoTypeCtrl = TextEditingController();
  final _customAmmoCompatibleCtrl = TextEditingController();
  final _customAmmoBonusCtrl = TextEditingController();
  final _customAmmoExtraDamageCtrl = TextEditingController();
  final _customAmmoExtraDamageTypeCtrl = TextEditingController();
  final _customGearSubtypeCtrl = TextEditingController();
  ItemType _customSelectedType = ItemType.gear;
  bool _customArmorIsShield = false;
  bool _customArmorAddDex = true;
  bool _customArmorStealthDisadvantage = false;
  bool _customRequiresAttunement = false;
  bool _customContainerIgnoresContentWeight = false;

  List<SrdWeapon>? _weapons;
  List<SrdArmor>? _armors;
  List<SrdGearItem>? _gear;
  List<SrdMagicItem>? _magic;
  List<SrdTool>? _tools;
  SrdInventorySearchCatalog? _searchCatalog;
  String? _searchCatalogKey;
  String? _loadError;

  List<String> _getTabLabels(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.inventoryTabWeapons,
      l10n.inventoryTabArmor,
      l10n.inventoryTabGear,
      l10n.inventoryTabMagic,
      l10n.inventoryTabTools,
      l10n.inventoryTabCustom,
    ];
  }

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 6, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) {
        _search.clear();
        setState(() {});
      }
    });
    _search.addListener(() => setState(() {}));
    _loadData();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _search.dispose();
    _customNameCtrl.dispose();
    _customQtyCtrl.dispose();
    _customWeightCtrl.dispose();
    _customDescCtrl.dispose();
    _customWeaponDamageCtrl.dispose();
    _customWeaponDamageTypeCtrl.dispose();
    _customWeaponPropertiesCtrl.dispose();
    _customWeaponRangeNormalCtrl.dispose();
    _customWeaponRangeLongCtrl.dispose();
    _customArmorBaseAcCtrl.dispose();
    _customArmorAcBonusCtrl.dispose();
    _customArmorMaxDexCtrl.dispose();
    _customArmorStrengthCtrl.dispose();
    _customEquipSlotCtrl.dispose();
    _customContainerCapacityWeightCtrl.dispose();
    _customContainerCapacityVolumeCtrl.dispose();
    _customContainerVolumeUnitCtrl.dispose();
    _customConsumableEffectCtrl.dispose();
    _customConsumableUsesCtrl.dispose();
    _customConsumableActionCtrl.dispose();
    _customAmmoTypeCtrl.dispose();
    _customAmmoCompatibleCtrl.dispose();
    _customAmmoBonusCtrl.dispose();
    _customAmmoExtraDamageCtrl.dispose();
    _customAmmoExtraDamageTypeCtrl.dispose();
    _customGearSubtypeCtrl.dispose();
    super.dispose();
  }

  String _categoryForCustomType(ItemType type) {
    switch (type) {
      case ItemType.weapon:
        return 'weapon';
      case ItemType.armor:
        return 'armor';
      case ItemType.consumable:
        return 'consumable';
      case ItemType.ammunition:
        return 'ammunition';
      case ItemType.equippable:
        return 'equippable';
      case ItemType.container:
        return 'container';
      case ItemType.gear:
        return 'adventuring gear';
    }
  }

  double? _parseCustomDouble(TextEditingController ctrl) {
    final text = ctrl.text.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  int? _parseCustomInt(TextEditingController ctrl) {
    final text = ctrl.text.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  List<String> _parseCustomList(TextEditingController ctrl) {
    return ctrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Map<String, dynamic>? _customProperties(UnitSystem unitSystem) {
    final props = <String, dynamic>{};
    switch (_customSelectedType) {
      case ItemType.weapon:
        final damage = _customWeaponDamageCtrl.text.trim();
        final damageType = _customWeaponDamageTypeCtrl.text.trim();
        final weaponProperties = _parseCustomList(_customWeaponPropertiesCtrl);
        final rangeNormal = _parseCustomInt(_customWeaponRangeNormalCtrl);
        final rangeLong = _parseCustomInt(_customWeaponRangeLongCtrl);
        final range = <String, int>{};
        if (damage.isNotEmpty) props['damageDice'] = damage;
        if (damageType.isNotEmpty) props['damageType'] = damageType;
        if (weaponProperties.isNotEmpty) {
          props['weaponProperties'] = weaponProperties;
        }
        if (rangeNormal != null) range['normal'] = rangeNormal;
        if (rangeLong != null) range['long'] = rangeLong;
        if (range.isNotEmpty) props['range'] = range;
        break;
      case ItemType.armor:
        if (_customArmorIsShield) {
          props['isShield'] = true;
          props['acBonus'] = _parseCustomInt(_customArmorAcBonusCtrl) ?? 2;
        } else {
          props['baseAC'] = _parseCustomInt(_customArmorBaseAcCtrl) ?? 10;
          props['addDexModifier'] = _customArmorAddDex;
          final maxDex = _parseCustomInt(_customArmorMaxDexCtrl);
          final strength = _parseCustomInt(_customArmorStrengthCtrl);
          if (maxDex != null) props['maxDexBonus'] = maxDex;
          if (strength != null) props['strengthRequirement'] = strength;
          if (_customArmorStealthDisadvantage) {
            props['stealthDisadvantage'] = true;
          }
        }
        break;
      case ItemType.equippable:
        final slot = _customEquipSlotCtrl.text.trim();
        if (slot.isNotEmpty) props['equipSlot'] = slot;
        if (_customRequiresAttunement) props['requiresAttunement'] = true;
        break;
      case ItemType.container:
        final capacityWeight = _parseCustomDouble(
          _customContainerCapacityWeightCtrl,
        );
        final capacityVolume = _parseCustomDouble(
          _customContainerCapacityVolumeCtrl,
        );
        final volumeUnit = _customContainerVolumeUnitCtrl.text.trim();
        if (capacityWeight != null) {
          props['capacityWeight'] = weightToLb(capacityWeight, unitSystem);
        }
        if (capacityVolume != null) props['capacityVolume'] = capacityVolume;
        if (volumeUnit.isNotEmpty) props['capacityVolumeUnit'] = volumeUnit;
        if (_customContainerIgnoresContentWeight) {
          props['contentsWeightIgnored'] = true;
        }
        break;
      case ItemType.consumable:
        final effect = _customConsumableEffectCtrl.text.trim();
        final action = _customConsumableActionCtrl.text.trim();
        final uses = _parseCustomInt(_customConsumableUsesCtrl);
        if (effect.isNotEmpty) props['effect'] = effect;
        if (uses != null) props['uses'] = {'amount': uses};
        if (action.isNotEmpty) props['actionType'] = action;
        break;
      case ItemType.ammunition:
        final ammoType = _customAmmoTypeCtrl.text.trim();
        final compatibleWith = _parseCustomList(_customAmmoCompatibleCtrl);
        final bonus = _parseCustomInt(_customAmmoBonusCtrl);
        final extraDamage = _customAmmoExtraDamageCtrl.text.trim();
        final extraDamageType = _customAmmoExtraDamageTypeCtrl.text.trim();
        if (ammoType.isNotEmpty) props['ammoType'] = ammoType;
        if (compatibleWith.isNotEmpty) props['compatibleWith'] = compatibleWith;
        if (bonus != null) props['bonus'] = bonus;
        if (extraDamage.isNotEmpty) props['extraDamage'] = extraDamage;
        if (extraDamageType.isNotEmpty) {
          props['extraDamageType'] = extraDamageType;
        }
        break;
      case ItemType.gear:
        final subtype = _customGearSubtypeCtrl.text.trim();
        if (subtype.isNotEmpty) props['subtype'] = subtype;
        break;
    }
    return props.isEmpty ? null : props;
  }

  Widget _customTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? suffixText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffixText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _customCheck(String label, bool value, ValueChanged<bool> onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      title: Text(label),
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildCustomTypeFields(UnitSystem unitSystem) {
    final l10n = AppLocalizations.of(context)!;
    const numberKeyboard = TextInputType.numberWithOptions(decimal: true);
    final decimalFormatter = FilteringTextInputFormatter.allow(
      RegExp(r'[0-9.,]'),
    );

    switch (_customSelectedType) {
      case ItemType.weapon:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _customTextField(
                    _customWeaponDamageCtrl,
                    l10n.inventoryCustomDamageDice,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _customTextField(
                    _customWeaponDamageTypeCtrl,
                    l10n.inventoryCustomDamageType,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _customTextField(
              _customWeaponPropertiesCtrl,
              l10n.inventoryCustomWeaponProperties,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _customTextField(
                    _customWeaponRangeNormalCtrl,
                    l10n.inventoryCustomRangeNormal,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _customTextField(
                    _customWeaponRangeLongCtrl,
                    l10n.inventoryCustomRangeLong,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
          ],
        );
      case ItemType.armor:
        return Column(
          children: [
            _customCheck(
              l10n.inventoryDetailShield,
              _customArmorIsShield,
              (v) => setState(() => _customArmorIsShield = v),
            ),
            if (_customArmorIsShield)
              _customTextField(
                _customArmorAcBonusCtrl,
                l10n.inventoryDetailAcBonus,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _customTextField(
                      _customArmorBaseAcCtrl,
                      l10n.inventoryDetailBaseAc,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _customTextField(
                      _customArmorMaxDexCtrl,
                      l10n.inventoryDetailMaxDex,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _customTextField(
                _customArmorStrengthCtrl,
                l10n.inventoryDetailStrengthMinimum,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              _customCheck(
                l10n.inventoryCustomAddDexToAc,
                _customArmorAddDex,
                (v) => setState(() => _customArmorAddDex = v),
              ),
              _customCheck(
                l10n.armorStealthDisadvantage,
                _customArmorStealthDisadvantage,
                (v) => setState(() => _customArmorStealthDisadvantage = v),
              ),
            ],
          ],
        );
      case ItemType.equippable:
        return Column(
          children: [
            _customTextField(
              _customEquipSlotCtrl,
              l10n.inventoryCustomEquipSlot,
            ),
            _customCheck(
              l10n.inventoryDetailRequiresAttunement,
              _customRequiresAttunement,
              (v) => setState(() => _customRequiresAttunement = v),
            ),
          ],
        );
      case ItemType.container:
        return Column(
          children: [
            _customTextField(
              _customContainerCapacityWeightCtrl,
              l10n.inventoryDetailCapacityWeight,
              keyboardType: numberKeyboard,
              inputFormatters: [decimalFormatter],
              suffixText: weightSuffix(unitSystem),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _customTextField(
                    _customContainerCapacityVolumeCtrl,
                    l10n.inventoryDetailCapacityVolume,
                    keyboardType: numberKeyboard,
                    inputFormatters: [decimalFormatter],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _customTextField(
                    _customContainerVolumeUnitCtrl,
                    l10n.inventoryDetailCapacityVolumeUnit,
                  ),
                ),
              ],
            ),
            _customCheck(
              l10n.inventoryDetailIgnoreContentWeight,
              _customContainerIgnoresContentWeight,
              (v) => setState(() => _customContainerIgnoresContentWeight = v),
            ),
          ],
        );
      case ItemType.consumable:
        return Column(
          children: [
            _customTextField(
              _customConsumableEffectCtrl,
              l10n.inventoryDetailEffect,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _customTextField(
                    _customConsumableUsesCtrl,
                    l10n.inventoryDetailUses,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _customTextField(
                    _customConsumableActionCtrl,
                    l10n.inventoryDetailAction,
                  ),
                ),
              ],
            ),
          ],
        );
      case ItemType.ammunition:
        return Column(
          children: [
            _customTextField(_customAmmoTypeCtrl, l10n.inventoryDetailAmmoType),
            const SizedBox(height: 12),
            _customTextField(
              _customAmmoCompatibleCtrl,
              l10n.inventoryCustomCompatibleWith,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _customTextField(
                    _customAmmoBonusCtrl,
                    l10n.inventoryDetailBonus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[-0-9]')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _customTextField(
                    _customAmmoExtraDamageCtrl,
                    l10n.inventoryDetailExtraDamage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _customTextField(
              _customAmmoExtraDamageTypeCtrl,
              l10n.inventoryDetailExtraDamageType,
            ),
          ],
        );
      case ItemType.gear:
        return _customTextField(
          _customGearSubtypeCtrl,
          l10n.inventoryDetailSubtype,
        );
    }
  }

  Future<void> _loadData() async {
    try {
      final srd = ref.read(srdDataSourceProvider);
      final results = await Future.wait([
        srd.getWeapons(),
        srd.getArmors(),
        srd.getGear(),
        srd.getMagicItems(),
        srd.getTools(),
      ]);
      if (mounted) {
        setState(() {
          _weapons = results[0] as List<SrdWeapon>;
          _armors = results[1] as List<SrdArmor>;
          _gear = results[2] as List<SrdGearItem>;
          _magic = results[3] as List<SrdMagicItem>;
          _tools = results[4] as List<SrdTool>;
          _searchCatalog = null;
          _searchCatalogKey = null;
        });
      }
    } catch (e, st) {
      debugPrint('_loadData error: $e\n$st');
      if (mounted) setState(() => _loadError = e.toString());
    }
  }

  Future<void> _addItem(EquipmentItem item) async {
    try {
      await ref
          .read(characterDetailProvider(widget.characterId).notifier)
          .addEquipmentItem(item);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e, st) {
      debugPrint('_addItem error: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.inventoryAddItemError),
        ),
      );
    }
  }

  // Mostra dialog de confirmação com quantidade antes de adicionar
  Future<void> _confirmAdd({
    required String name,
    String? displayName,
    required String category,
    required ItemType itemType,
    required String? description,
    Map<String, dynamic>? properties,
    double weight = 0.0,
  }) async {
    final itemName = _stripAmmunitionPackSuffix(name, itemType);
    final itemDisplayName = displayName == null
        ? null
        : _stripAmmunitionPackSuffix(displayName, itemType);
    final unitWeight = _inventoryUnitWeight(name, itemType, weight);
    var quantityText = '1';
    final selectedQuantity = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(itemDisplayName ?? itemName),
        content: Row(
          children: [
            Text(AppLocalizations.of(context)!.inventoryLabelQuantity),
            const SizedBox(width: 12),
            SizedBox(
              width: 64,
              child: TextFormField(
                initialValue: quantityText,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                onChanged: (value) => quantityText = value,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              FocusScope.of(ctx).unfocus();
              Navigator.of(ctx).pop();
            },
            child: Text(AppLocalizations.of(context)!.dialogCancel),
          ),
          FilledButton(
            onPressed: () {
              FocusScope.of(ctx).unfocus();
              final quantity = int.tryParse(quantityText) ?? 1;
              Navigator.of(ctx).pop(quantity < 1 ? 1 : quantity);
            },
            child: Text(AppLocalizations.of(context)!.dialogAdd),
          ),
        ],
      ),
    );

    if (!mounted || selectedQuantity == null) return;
    await _addItem(
      EquipmentItem(
        name: itemName,
        category: category,
        itemType: itemType,
        quantity: selectedQuantity,
        description: description,
        weight: unitWeight,
        properties: properties,
      ),
    );
  }

  // Lista agrupada por categoria, com cabeçalhos. Ao pesquisar, exibe lista plana.
  Widget _buildSrdListTile({
    required String name,
    String? displayName,
    required String subtitle,
    required String category,
    required ItemType itemType,
    required String? description,
    Map<String, dynamic>? properties,
    double weight = 0.0,
  }) {
    final cleanDisplayName = _stripAmmunitionPackSuffix(
      displayName ?? name,
      itemType,
    );
    final subtitleFull = description != null && description.isNotEmpty
        ? '$subtitle  ·  $description'
        : subtitle;
    return ListTile(
      title: Text(cleanDisplayName, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        subtitleFull,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle_outline),
        color: Theme.of(context).colorScheme.primary,
        onPressed: () => _confirmAdd(
          name: name,
          displayName: displayName,
          category: category,
          itemType: itemType,
          description: description,
          properties: properties,
          weight: weight,
        ),
      ),
    );
  }

  SrdInventorySearchCatalog? _globalSrdSearchCatalog(
    SrdI18nService i18n,
    AppLocalizations l10n,
  ) {
    final weapons = _weapons;
    final armors = _armors;
    final gear = _gear;
    final magic = _magic;
    final tools = _tools;
    if (weapons == null ||
        armors == null ||
        gear == null ||
        magic == null ||
        tools == null) {
      return null;
    }

    final key = Object.hash(
      i18n.locale,
      l10n.localeName,
      identityHashCode(weapons),
      identityHashCode(armors),
      identityHashCode(gear),
      identityHashCode(magic),
      identityHashCode(tools),
    ).toString();
    if (_searchCatalogKey == key && _searchCatalog != null) {
      return _searchCatalog;
    }

    _searchCatalog = SrdInventorySearchCatalog.fromSrd(
      weapons: weapons,
      armors: armors,
      gear: gear,
      magic: magic,
      tools: tools,
      i18n: i18n,
      l10n: l10n,
      itemTypeLabel: (type) => _itemTypeLabel(type, l10n),
      categoryLabel: (category) => _categoryLabel(category, l10n, i18n),
    );
    _searchCatalogKey = key;
    return _searchCatalog;
  }

  Widget _buildGlobalSrdSearch(
    SrdI18nService i18n,
    AppLocalizations l10n,
  ) {
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.inventoryLoadItemsError(_loadError!),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final catalog = _globalSrdSearchCatalog(i18n, l10n);
    if (catalog == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final q = _search.text.trim().toLowerCase();
    final filtered = catalog.search(q);

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          l10n.inventoryNoResults(q),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewPadding.bottom,
      ),
      children: filtered
          .map(
            (entry) => _buildSrdListTile(
              name: entry.name,
              displayName: entry.displayName,
              subtitle:
                  '${_itemTypeLabel(entry.itemType, l10n)}  ·  ${entry.subtitle}',
              category: entry.category,
              itemType: entry.itemType,
              description: entry.description,
              properties: entry.properties,
              weight: entry.weight,
            ),
          )
          .toList(),
    );
  }

  Widget _buildGroupedSrdList<T>({
    required List<T>? items,
    required String Function(T) getName,
    String Function(T)? getDisplayName,
    required String Function(T) getSubtitle,
    required String Function(T) getCategory,
    required String Function(T) getGroup,
    required String? Function(T) getDescription,
    required ItemType Function(T) getItemType,
    Map<String, dynamic>? Function(T)? getProperties,
    double Function(T)? getWeight,
    required List<String> groupOrder,
    required Map<String, String> groupLabels,
  }) {
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            AppLocalizations.of(context)!.inventoryLoadItemsError(_loadError!),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (items == null) return const Center(child: CircularProgressIndicator());

    final q = _search.text.toLowerCase();
    final filtered = q.isEmpty
        ? items
        : items.where((e) {
            final itemType = getItemType(e);
            final display = _stripAmmunitionPackSuffix(
              (getDisplayName ?? getName)(e),
              itemType,
            ).toLowerCase();
            final english = _stripAmmunitionPackSuffix(
              getName(e),
              itemType,
            ).toLowerCase();
            return display.contains(q) || english.contains(q);
          }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.inventoryNoResults(q),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    Widget buildTile(T item) {
      return _buildSrdListTile(
        name: getName(item),
        displayName: getDisplayName?.call(item),
        subtitle: getSubtitle(item),
        category: getCategory(item),
        itemType: getItemType(item),
        description: getDescription(item),
        properties: getProperties?.call(item),
        weight: getWeight?.call(item) ?? 0.0,
      );
    }

    // Com busca activa: lista plana sem cabeçalhos.
    if (q.isNotEmpty) {
      return ListView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
        children: filtered.map(buildTile).toList(),
      );
    }

    // Sem busca: agrupa por categoria com cabeçalhos fixos (sticky).
    final grouped = <String, List<T>>{for (final key in groupOrder) key: []};
    for (final item in filtered) {
      final g = getGroup(item);
      (grouped[g] ??= []).add(item);
    }

    final slivers = <Widget>[];
    for (final key in groupOrder) {
      final group = grouped[key];
      if (group == null || group.isEmpty) continue;
      slivers.add(
        SliverStickyHeader(
          header: _GroupHeader(label: groupLabels[key] ?? key),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => buildTile(group[i]),
              childCount: group.length,
            ),
          ),
        ),
      );
    }
    slivers.add(
      SliverPadding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
      ),
    );
    return CustomScrollView(slivers: slivers);
  }

  Widget _buildCustomTab() {
    final scheme = Theme.of(context).colorScheme;
    final unitSystem = ref.read(unitSystemProvider);
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom > 0
        ? mediaQuery.viewInsets.bottom
        : mediaQuery.viewPadding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _customNameCtrl,
            autofocus: false,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.inventoryLabelItemName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ItemType>(
            initialValue: _customSelectedType,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.inventoryLabelType,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: ItemType.weapon,
                child: Text(AppLocalizations.of(context)!.inventoryTypeWeapon),
              ),
              DropdownMenuItem(
                value: ItemType.armor,
                child: Text(AppLocalizations.of(context)!.inventoryTypeArmor),
              ),
              DropdownMenuItem(
                value: ItemType.equippable,
                child: Text(
                  AppLocalizations.of(context)!.inventoryTypeEquippable,
                ),
              ),
              DropdownMenuItem(
                value: ItemType.container,
                child: Text(
                  AppLocalizations.of(context)!.inventoryTypeContainer,
                ),
              ),
              DropdownMenuItem(
                value: ItemType.consumable,
                child: Text(
                  AppLocalizations.of(context)!.inventoryTypeConsumable,
                ),
              ),
              DropdownMenuItem(
                value: ItemType.ammunition,
                child: Text(AppLocalizations.of(context)!.inventoryAmmunition),
              ),
              DropdownMenuItem(
                value: ItemType.gear,
                child: Text(AppLocalizations.of(context)!.inventoryTypeGear),
              ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _customSelectedType = v);
            },
          ),
          const SizedBox(height: 12),
          _buildCustomTypeFields(unitSystem),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customQtyCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    )!.inventoryLabelItemQuantity,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _customWeightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    )!.inventoryLabelWeight,
                    suffixText: weightSuffix(unitSystem),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customDescCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(
                context,
              )!.inventoryLabelDescription,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              final name = _customNameCtrl.text.trim();
              if (name.isEmpty) return;
              await _addItem(
                EquipmentItem(
                  name: name,
                  category: _categoryForCustomType(_customSelectedType),
                  itemType: _customSelectedType,
                  quantity: int.tryParse(_customQtyCtrl.text) ?? 1,
                  weight: weightToLb(
                    double.tryParse(
                          _customWeightCtrl.text.replaceAll(',', '.'),
                        ) ??
                        0.0,
                    unitSystem,
                  ),
                  description: _customDescCtrl.text.trim().isEmpty
                      ? null
                      : _customDescCtrl.text.trim(),
                  properties: _customProperties(unitSystem),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
            ),
            child: Text(AppLocalizations.of(context)!.inventoryAddCustomItem),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final isCustomTab = _tabs.index == 5;
    final isSearchingSrd = !isCustomTab && _search.text.trim().isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.87,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.inventoryAddItem,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Barra de busca (oculta na aba Custom)
          if (!isCustomTab)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: l10n.hintSearch,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _search.clear(),
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _getTabLabels(context).map((l) => Tab(text: l)).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: isSearchingSrd
                  ? [
                      for (var i = 0; i < 5; i++)
                        _buildGlobalSrdSearch(i18n, l10n),
                      _buildCustomTab(),
                    ]
                  : [
                // Weapons
                _buildGroupedSrdList<SrdWeapon>(
                  items: _weapons,
                  getName: (w) => w.name,
                  getDisplayName: (w) => i18n.equipmentName(w.name),
                  getSubtitle: (w) =>
                      '${w.damage} ${i18n.damageType(w.damageType)}  ·  ${w.cost}',
                  getCategory: (w) => w.category,
                  getGroup: (w) => w.category,
                  getDescription: (w) => w.properties.isNotEmpty
                      ? i18n.weaponProperties(w.properties)
                      : null,
                  getItemType: (_) => ItemType.weapon,
                  getProperties: (w) => {
                    'damageDice': w.damage,
                    'damageType': w.damageType,
                    if (w.properties.isNotEmpty)
                      'weaponProperties': w.properties,
                    if (w.versatileDamage != null)
                      'versatileDamage': w.versatileDamage,
                    if (w.range != null)
                      'range': {
                        'normal': w.range!.normal,
                        'long': w.range!.long,
                      },
                    if (w.cost.isNotEmpty) 'cost': w.cost,
                  },
                  getWeight: (w) => w.weight,
                  groupOrder: const [
                    'simple melee',
                    'simple ranged',
                    'martial melee',
                    'martial ranged',
                  ],
                  groupLabels: {
                    'simple melee': l10n.inventoryGroupSimpleMelee,
                    'simple ranged': l10n.inventoryGroupSimpleRanged,
                    'martial melee': l10n.inventoryGroupMartialMelee,
                    'martial ranged': l10n.inventoryGroupMartialRanged,
                  },
                ),
                // Armor
                _buildGroupedSrdList<SrdArmor>(
                  items: _armors,
                  getName: (a) => a.name,
                  getDisplayName: (a) => i18n.equipmentName(a.name),
                  getSubtitle: (a) => a.isShield
                      ? '+${a.acBonus} ${i18n.term("AC")}  ·  ${a.cost}'
                      : '${i18n.term("AC")} ${a.baseAC}${a.addDexModifier ? " + ${i18n.term("DEX")}" : ""}${a.maxDexBonus != null ? " (${l10n.inventoryDetailMaxShort} +${a.maxDexBonus})" : ""}  ·  ${a.cost}',
                  getCategory: (_) => 'armor',
                  getGroup: (a) => a.type,
                  getDescription: (a) => a.stealthDisadvantage
                      ? l10n.armorStealthDisadvantage
                      : null,
                  getItemType: (_) => ItemType.armor,
                  getProperties: (a) => {
                    'armorType': a.type,
                    'baseAC': a.baseAC,
                    'addDexModifier': a.addDexModifier,
                    'maxDexBonus': a.maxDexBonus,
                    'isShield': a.isShield,
                    'acBonus': a.acBonus,
                    if (a.strengthRequired != null)
                      'strengthRequirement': a.strengthRequired,
                    if (a.stealthDisadvantage) 'stealthDisadvantage': true,
                    if (a.cost.isNotEmpty) 'cost': a.cost,
                  },
                  getWeight: (a) => a.weight,
                  groupOrder: const ['light', 'medium', 'heavy', 'shield'],
                  groupLabels: {
                    'light': l10n.inventoryGroupLightArmor,
                    'medium': l10n.inventoryGroupMediumArmor,
                    'heavy': l10n.inventoryGroupHeavyArmor,
                    'shield': l10n.inventoryGroupShields,
                  },
                ),
                // Gear
                _buildGroupedSrdList<SrdGearItem>(
                  items: _gear,
                  getName: (g) => g.name,
                  getDisplayName: (g) => i18n.equipmentName(g.name),
                  getSubtitle: (g) => g.cost,
                  getCategory: (g) => g.category,
                  getGroup: (g) => g.category,
                  getDescription: (g) =>
                      i18n.equipmentDescription(g.name) ??
                      (g.description.isNotEmpty ? g.description : null),
                  getItemType: (g) => g.category == 'ammunition'
                      ? ItemType.ammunition
                      : g.category == 'container'
                      ? ItemType.container
                      : ItemType.gear,
                  getProperties: (g) => {if (g.cost.isNotEmpty) 'cost': g.cost},
                  getWeight: (g) => g.weight,
                  groupOrder: const [
                    'adventuring gear',
                    'ammunition',
                    'arcane focus',
                    'clothing',
                    'container',
                    'poison',
                  ],
                  groupLabels: {
                    'adventuring gear': l10n.inventoryGroupAdventuringGear,
                    'ammunition': l10n.inventoryGroupAmmunition,
                    'arcane focus': l10n.inventoryGroupArcaneFocus,
                    'clothing': l10n.inventoryGroupClothing,
                    'container': l10n.inventoryGroupContainer,
                    'poison': l10n.inventoryGroupPoison,
                  },
                ),
                // Magic Items
                _buildGroupedSrdList<SrdMagicItem>(
                  items: _magic,
                  getName: (m) => m.name,
                  getDisplayName: (m) => i18n.magicItemName(m.name),
                  getSubtitle: (m) =>
                      '${i18n.term(m.rarity)}${m.requiresAttunement ? "  ·  ${i18n.term("attunement")}" : ""}',
                  getCategory: (m) => m.type,
                  getGroup: (m) => m.type,
                  getDescription: (m) =>
                      i18n.magicItemDescription(m.name) ?? m.description,
                  getItemType: (m) => m.itemType,
                  getProperties: (m) => m.properties,
                  getWeight: (m) => m.weight,
                  groupOrder: const [
                    'potion',
                    'ring',
                    'wand',
                    'weapon',
                    'armor',
                    'wondrous item',
                  ],
                  groupLabels: {
                    'potion': l10n.inventoryGroupPotions,
                    'ring': l10n.inventoryGroupRings,
                    'wand': l10n.inventoryGroupWands,
                    'weapon': l10n.inventoryGroupWeapons,
                    'armor': l10n.inventoryGroupArmor,
                    'wondrous item': l10n.inventoryGroupWondrousItems,
                  },
                ),
                // Tools
                _buildGroupedSrdList<SrdTool>(
                  items: _tools,
                  getName: (t) => t.name,
                  getDisplayName: (t) => i18n.toolName(t.name),
                  getSubtitle: (t) {
                    switch (t.category) {
                      case 'artisans_tools':
                        return l10n.inventoryGroupArtisansTools;
                      case 'gaming_sets':
                        return l10n.inventoryGroupGamingSets;
                      case 'musical_instruments':
                        return l10n.inventoryGroupMusicalInstruments;
                      default:
                        return l10n.inventoryGroupOtherTools;
                    }
                  },
                  getCategory: (t) => t.category,
                  getGroup: (t) => t.category,
                  getDescription: (_) => null,
                  getItemType: (_) => ItemType.gear,
                  getWeight: (t) => t.weight,
                  groupOrder: const [
                    'artisans_tools',
                    'gaming_sets',
                    'musical_instruments',
                    'other_tools',
                  ],
                  groupLabels: {
                    'artisans_tools': l10n.inventoryGroupArtisansTools,
                    'gaming_sets': l10n.inventoryGroupGamingSets,
                    'musical_instruments':
                        l10n.inventoryGroupMusicalInstruments,
                    'other_tools': l10n.inventoryGroupOtherTools,
                  },
                ),
                // Custom
                _buildCustomTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Item Tile ─────────────────────────────────────────────────────────────────

/// Returns a localised display name for [item].
/// Tries equipment overlay, then magic_items overlay, then background
/// equipment strings, then falls back to the original name.
String _itemDisplayName(EquipmentItem item, SrdI18nService i18n) {
  final fromEquip = i18n.equipmentName(item.name);
  if (fromEquip != item.name) {
    return _stripAmmunitionPackSuffix(fromEquip, item.itemType);
  }
  final fromMagic = i18n.magicItemName(item.name);
  if (fromMagic != item.name) {
    return _stripAmmunitionPackSuffix(fromMagic, item.itemType);
  }
  return _stripAmmunitionPackSuffix(
    i18n.backgroundEquipmentName(item.name),
    item.itemType,
  );
}

class _ItemDetailRow {
  const _ItemDetailRow(this.label, this.value);

  final String label;
  final String value;
}

String _itemTypeLabel(ItemType type, AppLocalizations l10n) {
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

String _itemCategoryLabel(
  EquipmentItem item,
  AppLocalizations l10n,
  SrdI18nService i18n,
) {
  return _categoryLabel(item.category, l10n, i18n);
}

String _categoryLabel(
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
      return text == null ? null : _categoryLabel(text, l10n, i18n);
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

List<_ItemDetailRow> _itemBaseDetailRows(
  EquipmentItem item,
  UnitSystem unitSystem,
  AppLocalizations l10n,
  SrdI18nService i18n,
) {
  final rows = <_ItemDetailRow>[
    _ItemDetailRow(
      l10n.inventoryLabelType,
      _itemTypeLabel(item.itemType, l10n),
    ),
    if (item.category.trim().isNotEmpty)
      _ItemDetailRow(
        l10n.inventoryLabelCategory,
        _itemCategoryLabel(item, l10n, i18n),
      ),
    _ItemDetailRow(l10n.inventoryLabelItemQuantity, item.quantity.toString()),
    _ItemDetailRow(
      l10n.inventoryDetailWeightEach,
      formatWeight(item.weight, unitSystem),
    ),
  ];

  if (item.quantity > 1) {
    rows.add(
      _ItemDetailRow(
        l10n.inventoryDetailWeightTotal,
        formatWeight(item.weight * item.quantity, unitSystem),
      ),
    );
  }

  if (item.itemType == ItemType.weapon ||
      item.itemType == ItemType.armor ||
      item.itemType == ItemType.equippable) {
    rows.add(
      _ItemDetailRow(
        l10n.inventoryDetailState,
        item.isEquipped
            ? l10n.inventoryDetailEquipped
            : l10n.inventoryDetailNotEquipped,
      ),
    );
  }

  return rows;
}

List<_ItemDetailRow> _itemPropertyDetailRows(
  EquipmentItem item,
  UnitSystem unitSystem,
  SrdI18nService i18n,
  AppLocalizations l10n,
) {
  final props = item.properties;
  if (props == null || props.isEmpty) return const [];

  final rows = <_ItemDetailRow>[];
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
      rows.add(_ItemDetailRow(label, text));
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
      rows.add(_ItemDetailRow(_propertyDetailLabel(entry.key, l10n), text));
    }
  }

  return rows;
}

class _ItemDetailRows extends StatelessWidget {
  const _ItemDetailRows({required this.rows});

  final List<_ItemDetailRow> rows;

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

void _showItemDetailsSheet(
  BuildContext context,
  WidgetRef ref,
  EquipmentItem item,
  String displayName,
  String? meta,
) {
  final scheme = Theme.of(context).colorScheme;
  final unitSystem = ref.read(unitSystemProvider);
  final i18n = ref.read(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
  final l10n = AppLocalizations.of(context)!;
  final baseRows = _itemBaseDetailRows(item, unitSystem, l10n, i18n);
  final propertyRows = _itemPropertyDetailRows(item, unitSystem, i18n, l10n);
  final description = item.description?.trim();

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
              _itemQuantityTitle(displayName, item.quantity),
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
                  child: _ItemDetailRows(rows: baseRows),
                ),
                if (description != null && description.isNotEmpty)
                  _ItemDetailSection(
                    title: l10n.inventoryDetailDescription,
                    child: Text(
                      description,
                      style: const TextStyle(height: 1.6),
                    ),
                  ),
                if (propertyRows.isNotEmpty)
                  _ItemDetailSection(
                    title: l10n.inventoryDetailAttributes,
                    child: _ItemDetailRows(rows: propertyRows),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ItemTile extends ConsumerWidget {
  const _ItemTile({
    required this.item,
    required this.characterId,
    this.reorderIndex,
  });

  final EquipmentItem item;
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
      final i18n =
          ref.read(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
      final mode = await _showRemoveContainerDialog(
        context,
        _itemDisplayName(item, i18n),
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

    final i18n =
        ref.read(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final amount = await _showRemoveQuantityDialog(
      context,
      item,
      displayName: _itemDisplayName(item, i18n),
    );
    if (amount != null) {
      await notifier.removeEquipmentQuantity(item.id, amount);
    }
  }

  static String? _itemMeta(
    EquipmentItem item, [
    SrdI18nService? i18n,
    AppLocalizations? l10n,
  ]) {
    final props = item.properties;

    if (item.itemType == ItemType.weapon && props != null) {
      final dice = (props['damageDice'] ?? props['damage'])?.toString();
      final type = props['damageType']?.toString();
      if (dice != null && dice.isNotEmpty && type != null && type.isNotEmpty) {
        return '$dice ${i18n?.damageType(type) ?? type}';
      }
      if (dice != null && dice.isNotEmpty) return dice;
    }

    if (item.itemType == ItemType.armor && props != null) {
      final isShield = props['isShield'] == true;
      if (isShield) {
        final bonus = (props['acBonus'] as num?)?.toInt() ?? 2;
        return '${i18n?.term('shield') ?? 'Shield'}  ·  +$bonus ${i18n?.term('AC') ?? 'AC'}';
      }

      final baseAc = (props['baseAC'] as num?)?.toInt();
      if (baseAc != null) {
        final addDex = props['addDexModifier'] as bool? ?? true;
        final maxDex = (props['maxDexBonus'] as num?)?.toInt();
        final ac = i18n?.term('AC') ?? 'AC';
        final dex = i18n?.term('DEX') ?? 'DEX';
        if (!addDex) return '$ac $baseAc';
        if (maxDex != null) {
          return '$ac $baseAc + $dex (${l10n?.inventoryDetailMaxShort ?? 'max'} +$maxDex)';
        }
        return '$ac $baseAc + $dex';
      }
    }

    return null;
  }

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
    if (props['isShield'] == true) return false;
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
        final i18n =
            ref.read(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
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
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final notifier = ref.read(characterDetailProvider(characterId).notifier);
    final character = ref
        .watch(characterDetailProvider(characterId))
        .valueOrNull;
    final containers = character == null
        ? const <EquipmentItem>[]
        : InventorySnapshot.fromEquipment(character.equipment).containers;
    final canEquip =
        item.itemType == ItemType.weapon ||
        item.itemType == ItemType.armor ||
        item.itemType == ItemType.equippable;
    final canMove =
        item.itemType != ItemType.container &&
        !item.isEquipped &&
        (item.containerId != null || containers.isNotEmpty);
    final meta = _itemMeta(item, i18n, l10n);
    final displayName = _itemDisplayName(item, i18n);
    final widgetsL10n = WidgetsLocalizations.of(context);
    final reorderTooltip =
        '${widgetsL10n.reorderItemUp} / ${widgetsL10n.reorderItemDown}';

    // Stealth disadvantage: stored in properties (new items) or description (old items)
    final stealthDisadv =
        item.itemType == ItemType.armor &&
        (item.properties?['stealthDisadvantage'] == true ||
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

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => _showItemDetailsSheet(context, ref, item, displayName, meta),
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
                        : scheme.surfaceContainerHighest,
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
        _itemQuantityTitle(displayName, item.quantity),
        style: const TextStyle(fontSize: 14),
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
          PopupMenuButton<_InventoryItemAction>(
            onSelected: (action) {
              switch (action) {
                case _InventoryItemAction.move:
                  _showMoveItemSheet(
                    context,
                    ref,
                    item: item,
                    characterId: characterId,
                    containers: containers,
                  );
                  break;
                case _InventoryItemAction.remove:
                  _confirmRemoveItem(context, ref, notifier);
                  break;
              }
            },
            itemBuilder: (ctx) => [
              if (canMove)
                PopupMenuItem(
                  value: _InventoryItemAction.move,
                  child: _InventoryMenuItem(
                    icon: Icons.drive_file_move_outlined,
                    label: l10n.inventoryTooltipMove,
                  ),
                ),
              PopupMenuItem(
                value: _InventoryItemAction.remove,
                child: _InventoryMenuItem(
                  icon: Icons.delete_outline,
                  label: l10n.inventoryTooltipRemove,
                  isDestructive: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
