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
  const _InventoryTab({
    required this.character,
    required this.inventory,
    required this.strengthScore,
    required this.characterId,
  });

  final Character character;
  final InventorySnapshot inventory;
  final int strengthScore;
  final String characterId;

  @override
  ConsumerState<_InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends ConsumerState<_InventoryTab>
    with AutomaticKeepAliveClientMixin {
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

  @override
  bool get wantKeepAlive => true;

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
    super.build(context);
    final character = widget.character;
    final inventory = widget.inventory;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final coinLabels = {
      'cp': l10n.coinCopper,
      'sp': l10n.coinSilver,
      'ep': l10n.coinElectrum,
      'gp': l10n.coinGold,
      'pp': l10n.coinPlatinum,
    };

    // Weight tracking
    final strScore = widget.strengthScore;
    final totalWeight = inventory.totalWeight;
    final maxCarry = strScore * 15.0;
    final encumberedThreshold = strScore * 5.0;
    final heavilyEncThreshold = strScore * 10.0;
    Widget buildCurrencyCard() {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.inventoryCurrency,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: scheme.primary),
              ),
              const SizedBox(height: 12),
              Row(
                children: _coins.map((c) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
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
      );
    }

    Widget buildWeightControl() {
      if (character.weightTrackingEnabled) {
        return _WeightBar(
          totalWeight: totalWeight,
          maxCarry: maxCarry,
          encumberedAt: encumberedThreshold,
          heavilyEncAt: heavilyEncThreshold,
          onDisable: () => ref
              .read(characterDetailProvider(widget.characterId).notifier)
              .toggleWeightTracking(),
        );
      }

      return Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => ref
              .read(characterDetailProvider(widget.characterId).notifier)
              .toggleWeightTracking(),
          icon: const Icon(Icons.monitor_weight_outlined, size: 16),
          label: Text(l10n.weightEnableTooltip),
          style: TextButton.styleFrom(
            foregroundColor: scheme.onSurfaceVariant,
            textStyle: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                buildCurrencyCard(),
                const SizedBox(height: 12),
                buildWeightControl(),
                const SizedBox(height: 12),
              ]),
            ),
          ),
          if (inventory.ammunition.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _InventorySliverSectionHeader(
                title: l10n.inventoryAmmunition,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _InventorySliverReorderableItemList(
                items: inventory.ammunition,
                characterId: widget.characterId,
                itemBuilder: (context, item, reorderIndex) =>
                    _AmmunitionItemTile(
                  item: item,
                  containers: inventory.containers,
                  i18n: i18n,
                  characterId: widget.characterId,
                  reorderIndex: reorderIndex,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          ],
          if (inventory.equipped.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _InventorySliverSectionHeader(
                title: l10n.inventoryEquippedSection(
                  inventory.equipped.length,
                  character.armorClass,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _InventorySliverReorderableItemList(
                items: inventory.equipped,
                characterId: widget.characterId,
                itemBuilder: (context, item, reorderIndex) => _ItemTile(
                  item: item,
                  containers: inventory.containers,
                  i18n: i18n,
                  characterId: widget.characterId,
                  reorderIndex: reorderIndex,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          ],
          if (inventory.containers.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _InventorySliverSectionHeader(
                title: l10n.inventoryContainersSection(
                  inventory.containers.length,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _ContainersSection(
                containers: inventory.containers,
                contentsByContainer: inventory.contentsByContainer,
                i18n: i18n,
                characterId: widget.characterId,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          ],
          if (inventory.equippable.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _InventorySliverSectionHeader(
                title: l10n.inventoryEquippableSection(
                  inventory.equippable.length,
                ),
                subtitle: Row(
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
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _InventorySliverReorderableItemList(
                items: inventory.equippable,
                characterId: widget.characterId,
                itemBuilder: (context, item, reorderIndex) => _ItemTile(
                  item: item,
                  containers: inventory.containers,
                  i18n: i18n,
                  characterId: widget.characterId,
                  reorderIndex: reorderIndex,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          ],
          if (inventory.carried.isNotEmpty || inventory.isEmpty) ...[
            SliverToBoxAdapter(
              child: _InventorySliverSectionHeader(
                title: inventory.carried.isEmpty
                    ? l10n.inventoryInventory
                    : l10n.inventoryCarriedSection(inventory.carried.length),
              ),
            ),
            if (inventory.carried.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    l10n.inventoryEmpty,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: _InventorySliverReorderableItemList(
                  items: inventory.carried,
                  characterId: widget.characterId,
                  itemBuilder: (context, item, reorderIndex) => _ItemTile(
                    item: item,
                    containers: inventory.containers,
                    i18n: i18n,
                    characterId: widget.characterId,
                    reorderIndex: reorderIndex,
                  ),
                ),
              ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 192)),
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

String _containerSubtitleText(
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
  return '$contentsText - $weightText';
}

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

class _InventorySliverReorderableItemList extends ConsumerWidget {
  const _InventorySliverReorderableItemList({
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

class _InventorySliverSectionHeader extends StatelessWidget {
  const _InventorySliverSectionHeader({
    required this.title,
    this.subtitle,
  });

  final String title;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: scheme.primary),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            subtitle!,
          ],
        ],
      ),
    );
  }
}

class _AmmunitionItemTile extends ConsumerWidget {
  const _AmmunitionItemTile({
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

  Future<void> _confirmRemoveAmmo(
    BuildContext context,
    WidgetRef ref,
    CharacterDetailNotifier notifier,
  ) async {
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
    final scheme = Theme.of(context).colorScheme;
    final notifier = ref.read(characterDetailProvider(characterId).notifier);
    final displayName = _itemDisplayName(item, i18n);
    final meta = _ItemTile._itemMeta(item, i18n, l10n);
    final widgetsL10n = WidgetsLocalizations.of(context);
    final reorderTooltip =
        '${widgetsL10n.reorderItemUp} / ${widgetsL10n.reorderItemDown}';
    final canMove = item.containerId != null || containers.isNotEmpty;

    return InkWell(
      onTap: () => _showItemDetailsSheet(context, ref, item, displayName, meta),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.arrow_upward, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(displayName, style: const TextStyle(fontSize: 14)),
            ),
            IconButton(
              icon: const Icon(Icons.remove, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: item.quantity <= 0
                  ? null
                  : () => notifier.adjustItemQuantity(item.id, -1),
            ),
            SizedBox(
              width: 40,
              child: Text(
                '${item.quantity}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: () => notifier.adjustItemQuantity(item.id, 1),
            ),
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
                    _confirmRemoveAmmo(context, ref, notifier);
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
  }
}

class _ContainersSection extends ConsumerWidget {
  const _ContainersSection({
    required this.containers,
    required this.contentsByContainer,
    required this.i18n,
    required this.characterId,
  });

  final List<EquipmentItem> containers;
  final Map<String, List<EquipmentItem>> contentsByContainer;
  final SrdI18nService i18n;
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

  void _showContainerContentsSheet(BuildContext context, String containerId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _ContainerContentsSheet(
        characterId: characterId,
        containerId: containerId,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final unitSystem = ref.watch(unitSystemProvider);
    final scheme = Theme.of(context).colorScheme;

    return _InventorySliverReorderableItemList(
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
              _containerSubtitleText(
                context,
                container,
                contents,
                unitSystem,
              ),
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
              Wrap(
                spacing: 8,
                runSpacing: 4,
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
                  TextButton.icon(
                    icon: const Icon(Icons.inventory_2_outlined, size: 18),
                    label: Text(
                      l10n.inventoryContainerContents(
                        inventoryItemsTotalQuantity(contents),
                      ),
                    ),
                    onPressed: () => _showContainerContentsSheet(
                      context,
                      container.id,
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
                ),
            ],
          ),
        );
      },
    );
  }
}

// Container contents sheet

// Weight Bar

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

class _ItemTile extends ConsumerWidget {
  const _ItemTile({
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
