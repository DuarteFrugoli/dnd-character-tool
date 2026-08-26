import '../character_detail_dependencies.dart';
import '../widgets/inventory/add_item_sheet.dart';
import '../widgets/inventory/container_contents_sheet.dart';
import '../widgets/inventory/inventory_display_helpers.dart';
import '../widgets/inventory/inventory_item_tile.dart';
import '../widgets/inventory/item_detail_sheet.dart';

// ── Inventory Tab ─────────────────────────────────────────────────────────────

class InventoryTab extends ConsumerStatefulWidget {
  const InventoryTab({
    super.key,
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
  ConsumerState<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends ConsumerState<InventoryTab>
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
  void didUpdateWidget(InventoryTab old) {
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
      builder: (_) => AddItemSheet(characterId: widget.characterId),
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
        elevation: 0,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: scheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.72)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.paid_outlined,
                    size: 18,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.inventoryCurrency,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
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
        key: PageStorageKey('inventory-${widget.characterId}'),
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
                icon: Icons.arrow_upward,
                accentColor: scheme.tertiary,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: InventorySliverReorderableItemList(
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
                icon: Icons.check_circle_outline,
                accentColor: scheme.primary,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: InventorySliverReorderableItemList(
                items: inventory.equipped,
                characterId: widget.characterId,
                itemBuilder: (context, item, reorderIndex) => ItemTile(
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
                icon: Icons.inventory_2_outlined,
                accentColor: scheme.secondary,
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
                icon: Icons.checkroom_outlined,
                accentColor: scheme.tertiary,
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
              sliver: InventorySliverReorderableItemList(
                items: inventory.equippable,
                characterId: widget.characterId,
                itemBuilder: (context, item, reorderIndex) => ItemTile(
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
                icon: Icons.backpack_outlined,
                accentColor: scheme.primary,
              ),
            ),
            if (inventory.carried.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: DetailEmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: l10n.inventoryEmpty,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: InventorySliverReorderableItemList(
                  items: inventory.carried,
                  characterId: widget.characterId,
                  itemBuilder: (context, item, reorderIndex) => ItemTile(
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

class _InventorySliverSectionHeader extends StatelessWidget {
  const _InventorySliverSectionHeader({
    required this.title,
    this.subtitle,
    this.icon,
    this.accentColor,
  });

  final String title;
  final Widget? subtitle;
  final IconData? icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return DetailSectionHeader(
      title: title,
      subtitle: subtitle,
      icon: icon,
      accentColor: accentColor,
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
    final amount = await showRemoveQuantityDialog(
      context,
      item,
      displayName: itemDisplayName(item, i18n),
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
    final displayName = itemDisplayName(item, i18n);
    final meta = ItemTile.itemMeta(item, i18n, l10n);
    final widgetsL10n = WidgetsLocalizations.of(context);
    final reorderTooltip =
        '${widgetsL10n.reorderItemUp} / ${widgetsL10n.reorderItemDown}';
    final canMove = item.containerId != null || containers.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => showItemDetailsSheet(
            context,
            ref,
            item,
            displayName,
            meta,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: scheme.tertiary.withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.arrow_upward, size: 16, color: scheme.tertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
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
                        _confirmRemoveAmmo(context, ref, notifier);
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
    if (containerHasCountedContents(contents)) {
      final mode = await showRemoveContainerDialog(
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

    final amount = await showRemoveQuantityDialog(
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
      builder: (_) => ContainerContentsSheet(
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

    return InventorySliverReorderableItemList(
      items: containers,
      characterId: characterId,
      itemBuilder: (context, container, reorderIndex) {
        final contents = contentsByContainer[container.id] ?? const [];
        final hasStoredItems = contents.isNotEmpty;
        final displayName = itemDisplayName(container, i18n);
        final meta = ItemTile.itemMeta(container, i18n, l10n);
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
          elevation: 0,
          color: overCapacity
              ? scheme.errorContainer
              : scheme.surfaceContainerLow,
          surfaceTintColor: overCapacity ? scheme.error : scheme.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: overCapacity
                  ? scheme.error
                  : scheme.secondary.withValues(alpha: 0.22),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            key: PageStorageKey<String>(
              'inventory-container-expansion-$characterId-${container.id}',
            ),
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text(
              itemQuantityTitle(displayName, container.quantity),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              containerSubtitleText(context, container, contents, unitSystem),
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
                PopupMenuButton<InventoryItemAction>(
                  onSelected: (action) {
                    switch (action) {
                      case InventoryItemAction.move:
                        break;
                      case InventoryItemAction.remove:
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
                      value: InventoryItemAction.remove,
                      child: InventoryMenuItem(
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
                    onPressed: () => showItemDetailsSheet(
                      context,
                      ref,
                      container,
                      displayName,
                      meta,
                    ),
                  ),
                  if (hasStoredItems)
                    TextButton.icon(
                      icon: const Icon(Icons.inventory_2_outlined, size: 18),
                      label: Text(containerContentsLabel(l10n, contents)),
                      onPressed: () =>
                          _showContainerContentsSheet(context, container.id),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      child: Text(
                        l10n.inventoryContainerEmpty,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                ],
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
      elevation: 0,
      color: scheme.surfaceContainerLow,
      surfaceTintColor: barColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: barColor.withValues(alpha: 0.24)),
      ),
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
