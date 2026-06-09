part of '../character_detail_screen.dart';

// ── Inventory Tab ─────────────────────────────────────────────────────────────

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
        c: TextEditingController(text: '${currency[c] ?? 0}')
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
      for (final c in _coins)
        c: int.tryParse(_currencyCtrl[c]!.text) ?? 0,
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
    final coinLabels = {
      'cp': l10n.coinCopper,
      'sp': l10n.coinSilver,
      'ep': l10n.coinElectrum,
      'gp': l10n.coinGold,
      'pp': l10n.coinPlatinum,
    };
    final ammo = character.equipment
        .where((e) => e.itemType == ItemType.ammunition)
        .toList();
    final nonAmmo =
        character.equipment.where((e) => e.itemType != ItemType.ammunition);
    final equipped = nonAmmo.where((e) => e.isEquipped).toList();
    const equippableTypes = {ItemType.weapon, ItemType.armor};
    final equippable = nonAmmo
        .where((e) => !e.isEquipped && equippableTypes.contains(e.itemType))
        .toList();
    final carried = nonAmmo
        .where((e) => !e.isEquipped && !equippableTypes.contains(e.itemType))
        .toList();

    // Weight tracking
    final strScore = character.abilityScores.strength;
    final totalWeight = character.equipment.fold<double>(
      0.0,
      (sum, item) => sum + item.weight * item.quantity,
    );
    final maxCarry = strScore * 15.0;
    final encumberedThreshold = strScore * 5.0;
    final heavilyEncThreshold = strScore * 10.0;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 192),
        children: [
          // ── Currency ────────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.inventoryCurrency,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.primary,
                        ),
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
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: coinLabels[c],
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 8),
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

          // ── Weight Tracking ─────────────────────────────────────────────
          if (character.weightTrackingEnabled)
            _WeightBar(
              totalWeight: totalWeight,
              maxCarry: maxCarry,
              encumberedAt: encumberedThreshold,
              heavilyEncAt: heavilyEncThreshold,
              onDisable: () => ref
                  .read(characterDetailProvider(widget.characterId).notifier)
                  .toggleWeightTracking(),
            )
          else
            Align(
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
            ),
          const SizedBox(height: 4),

          // ── Ammunition ──────────────────────────────────────────────────
          if (ammo.isNotEmpty) ...[
            _AmmunitionSection(
              items: ammo,
              characterId: widget.characterId,
            ),
            const SizedBox(height: 12),
          ],

          // ── Equipped ────────────────────────────────────────────────────
          if (equipped.isNotEmpty) ...[
            _Section(
              title: l10n.inventoryEquippedSection(equipped.length, character.armorClass),
              child: Column(
                children: equipped
                    .map((item) => _ItemTile(
                          item: item,
                          characterId: widget.characterId,
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Equippable ──────────────────────────────────────────────────
          if (equippable.isNotEmpty) ...[
            _Section(
              title: l10n.inventoryEquippableSection(equippable.length),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
                    child: Row(
                      children: [
                        Icon(Icons.touch_app_outlined,
                            size: 13, color: scheme.onSurfaceVariant),
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
                  ...equippable.map((item) => _ItemTile(
                        item: item,
                        characterId: widget.characterId,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Carried ─────────────────────────────────────────────────────
          if (carried.isNotEmpty ||
              (equipped.isEmpty && equippable.isEmpty && ammo.isEmpty))
            _Section(
              title: carried.isEmpty
                  ? l10n.inventoryInventory
                  : l10n.inventoryCarriedSection(carried.length),
              child: carried.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        l10n.inventoryEmpty,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    )
                  : Column(
                      children: carried
                          .map((item) => _ItemTile(
                                item: item,
                                characterId: widget.characterId,
                              ))
                          .toList(),
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
  EquipmentItem item,
) async {
  if (item.quantity <= 1) {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.inventoryRemoveTitle),
        content: Text(AppLocalizations.of(context)!.inventoryRemoveContent(item.name)),
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
            Text(item.name),
            const SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.inventoryRemovePartial(selected, item.quantity)),
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
                labelText: AppLocalizations.of(context)!.inventoryLabelQuantityToRemove,
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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

// ── Ammunition Section ────────────────────────────────────────────────────────

class _AmmunitionSection extends ConsumerWidget {
  const _AmmunitionSection(
      {required this.items, required this.characterId});
  final List<EquipmentItem> items;
  final String characterId;

  Future<void> _confirmRemoveAmmo(
    BuildContext context,
    CharacterDetailNotifier notifier,
    EquipmentItem item,
  ) async {
    final amount = await _showRemoveQuantityDialog(context, item);
    if (amount != null) {
      await notifier.removeEquipmentQuantity(item.id, amount);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final i18n = ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final scheme = Theme.of(context).colorScheme;
    final notifier =
        ref.read(characterDetailProvider(characterId).notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.inventoryAmmunition,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: scheme.primary),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_upward, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(_itemDisplayName(item, i18n),
                            style: const TextStyle(fontSize: 14)),
                      ),
                      // Diminuir
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 32, minHeight: 32),
                        onPressed: () =>
                            notifier.adjustItemQuantity(item.id, -1),
                      ),
                      // Quantidade
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Aumentar
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 32, minHeight: 32),
                        onPressed: () =>
                            notifier.adjustItemQuantity(item.id, 1),
                      ),
                      // Remover
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: scheme.error,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 32, minHeight: 32),
                        onPressed: () =>
                          _confirmRemoveAmmo(context, notifier, item),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ── Weight Bar ────────────────────────────────────────────────────────────────

class _WeightBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final fraction = maxCarry > 0 ? (totalWeight / maxCarry).clamp(0.0, 1.0) : 0.0;

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
                Icon(Icons.monitor_weight_outlined, size: 16, color: scheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: '${totalWeight % 1 == 0 ? totalWeight.toInt() : totalWeight.toStringAsFixed(2)} / ${maxCarry.toInt()} lb',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (statusLabel != null) ...[
                        const TextSpan(text: '  '),
                        TextSpan(
                          text: statusLabel,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: barColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ]),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  tooltip: l10n.weightDisableTooltip,
                  onPressed: onDisable,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
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
        child: Container(
          width: 2,
          height: 8,
          color: scheme.surface,
        ),
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

  List<SrdWeapon>? _weapons;
  List<SrdArmor>? _armors;
  List<SrdGearItem>? _gear;
  List<SrdMagicItem>? _magic;
  List<SrdTool>? _tools;
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
    super.dispose();
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
        });
      }
    } catch (e, st) {
      debugPrint('_loadData error: $e\n$st');
      if (mounted) setState(() => _loadError = e.toString());
    }
  }

  void _addItem(EquipmentItem item) {
    ref
        .read(characterDetailProvider(widget.characterId).notifier)
        .addEquipmentItem(item);
    Navigator.pop(context);
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
    final qtyCtrl = TextEditingController(text: '1');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(displayName ?? name),
        content: Row(
          children: [
            Text(AppLocalizations.of(context)!.inventoryLabelQuantity),
            const SizedBox(width: 12),
            SizedBox(
              width: 64,
              child: TextField(
                controller: qtyCtrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context)!.dialogAdd),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _addItem(EquipmentItem(
        name: name,
        category: category,
        itemType: itemType,
        quantity: int.tryParse(qtyCtrl.text) ?? 1,
        description: description,
        weight: weight,
        properties: properties,
      ));
    }
    // qtyCtrl é variável local — não precisa de dispose manual
  }

  // Lista agrupada por categoria, com cabeçalhos. Ao pesquisar, exibe lista plana.
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
            'Error loading items:\n$_loadError',
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
            final display = (getDisplayName ?? getName)(e).toLowerCase();
            final english = getName(e).toLowerCase();
            return display.contains(q) || english.contains(q);
          }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No results for "$q"',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    Widget buildTile(T item) {
      final desc = getDescription(item);
      final subtitleFull = (desc != null && desc.isNotEmpty)
          ? '${getSubtitle(item)}  ·  $desc'
          : getSubtitle(item);
      return ListTile(
          title: Text((getDisplayName ?? getName)(item), style: const TextStyle(fontSize: 14)),
          subtitle: Text(
            subtitleFull,
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () => _confirmAdd(
              name: getName(item),
              displayName: getDisplayName?.call(item),
              category: getCategory(item),
              itemType: getItemType(item),
              description: getDescription(item),
              properties: getProperties?.call(item),
              weight: getWeight?.call(item) ?? 0.0,
            ),
          ),
        );
    }

    // Com busca activa: lista plana sem cabeçalhos.
    if (q.isNotEmpty) {
      return ListView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
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
      slivers.add(SliverStickyHeader(
        header: _GroupHeader(label: groupLabels[key] ?? key),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => buildTile(group[i]),
            childCount: group.length,
          ),
        ),
      ));
    }
    slivers.add(SliverPadding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom)));
    return CustomScrollView(slivers: slivers);
  }

  Widget _buildCustomTab() {
    final nameCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'adventuring gear');
    final qtyCtrl = TextEditingController(text: '1');
    final weightCtrl = TextEditingController(text: '0');
    final descCtrl = TextEditingController();
    final scheme = Theme.of(context).colorScheme;

    return StatefulBuilder(
      builder: (ctx, setInner) {
        var selectedType = ItemType.gear;

        return StatefulBuilder(
          builder: (ctx2, setType) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: false,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.inventoryLabelItemName, border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ItemType>(
                  initialValue: selectedType,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.inventoryLabelType, border: const OutlineInputBorder()),
                  items: [
                    DropdownMenuItem(
                        value: ItemType.weapon, child: Text(AppLocalizations.of(context)!.inventoryTypeWeapon)),
                    DropdownMenuItem(
                        value: ItemType.armor, child: Text(AppLocalizations.of(context)!.inventoryTypeArmor)),
                    DropdownMenuItem(
                        value: ItemType.consumable, child: Text(AppLocalizations.of(context)!.inventoryTypeConsumable)),
                    DropdownMenuItem(
                        value: ItemType.gear, child: Text(AppLocalizations.of(context)!.inventoryTypeGear)),
                  ],
                  onChanged: (v) {
                    if (v != null) setType(() => selectedType = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryCtrl,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.inventoryLabelCategory, border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: qtyCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.inventoryLabelItemQuantity, border: const OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                        decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.inventoryLabelWeight,
                            suffixText: 'lb',
                            border: const OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.inventoryLabelDescription,
                      border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    _addItem(EquipmentItem(
                      name: name,
                      category: categoryCtrl.text.trim().isEmpty
                          ? 'adventuring gear'
                          : categoryCtrl.text.trim(),
                      itemType: selectedType,
                      quantity: int.tryParse(qtyCtrl.text) ?? 1,
                      weight: double.tryParse(weightCtrl.text.replaceAll(',', '.')) ?? 0.0,
                      description: descCtrl.text.trim().isEmpty
                          ? null
                          : descCtrl.text.trim(),
                    ));
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                  ),
                  child: Text(AppLocalizations.of(context)!.inventoryAddCustomItem),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final i18n = ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final isCustomTab = _tabs.index == 5;

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
                Text(AppLocalizations.of(context)!.inventoryAddItem,
                    style: Theme.of(context).textTheme.titleMedium),
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
                  hintText: AppLocalizations.of(context)!.hintSearchCategory(_getTabLabels(context)[_tabs.index]),
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
              children: [
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
                      : '${i18n.term("AC")} ${a.baseAC}${a.addDexModifier ? " + ${i18n.term("DEX")}" : ""}${a.maxDexBonus != null ? " (max +${a.maxDexBonus})" : ""}  ·  ${a.cost}',
                  getCategory: (_) => 'armor',
                  getGroup: (a) => a.type,
                  getDescription: (a) => a.stealthDisadvantage
                      ? l10n.armorStealthDisadvantage
                      : null,
                  getItemType: (_) => ItemType.armor,
                  getProperties: (a) => {
                    'baseAC': a.baseAC,
                    'addDexModifier': a.addDexModifier,
                    'maxDexBonus': a.maxDexBonus,
                    'isShield': a.isShield,
                    'acBonus': a.acBonus,
                    if (a.stealthDisadvantage) 'stealthDisadvantage': true,
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
                      : ItemType.gear,
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
                      case 'artisans_tools':  return l10n.inventoryGroupArtisansTools;
                      case 'gaming_sets':     return l10n.inventoryGroupGamingSets;
                      case 'musical_instruments': return l10n.inventoryGroupMusicalInstruments;
                      default:                return l10n.inventoryGroupOtherTools;
                    }
                  },
                  getCategory: (t) => t.category,
                  getGroup: (t) => t.category,
                  getDescription: (_) => null,
                  getItemType: (_) => ItemType.gear,
                  groupOrder: const [
                    'artisans_tools',
                    'gaming_sets',
                    'musical_instruments',
                    'other_tools',
                  ],
                  groupLabels: {
                    'artisans_tools':       l10n.inventoryGroupArtisansTools,
                    'gaming_sets':          l10n.inventoryGroupGamingSets,
                    'musical_instruments':  l10n.inventoryGroupMusicalInstruments,
                    'other_tools':          l10n.inventoryGroupOtherTools,
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
  if (fromEquip != item.name) return fromEquip;
  final fromMagic = i18n.magicItemName(item.name);
  if (fromMagic != item.name) return fromMagic;
  return i18n.backgroundEquipmentName(item.name);
}

class _ItemTile extends ConsumerWidget {
  const _ItemTile({required this.item, required this.characterId});
  final EquipmentItem item;
  final String characterId;

  Future<void> _confirmRemoveItem(
    BuildContext context,
    CharacterDetailNotifier notifier,
  ) async {
    final amount = await _showRemoveQuantityDialog(context, item);
    if (amount != null) {
      await notifier.removeEquipmentQuantity(item.id, amount);
    }
  }

  static String? _itemMeta(EquipmentItem item, [SrdI18nService? i18n]) {
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
        return '${i18n?.term('shield') ?? 'Shield'}  ·  +$bonus AC';
      }

      final baseAc = (props['baseAC'] as num?)?.toInt();
      if (baseAc != null) {
        final addDex = props['addDexModifier'] as bool? ?? true;
        final maxDex = (props['maxDexBonus'] as num?)?.toInt();
        final ac = i18n?.term('AC') ?? 'AC';
        final dex = i18n?.term('DEX') ?? 'DEX';
        if (!addDex) return '$ac $baseAc';
        if (maxDex != null) return '$ac $baseAc + $dex (max +$maxDex)';
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

  static int _calcArmorClass(Character c, List<EquipmentItem> equipment) {
    final dexMod = c.abilityScores.dexterityModifier;
    int base = 10 + dexMod;
    int shieldBonus = 0;

    for (final it in equipment) {
      if (!it.isEquipped || it.itemType != ItemType.armor) continue;
      final props = it.properties;
      if (props == null) continue;

      if (props['isShield'] == true) {
        shieldBonus = (props['acBonus'] as num?)?.toInt() ?? 2;
      } else {
        final baseAC = (props['baseAC'] as num?)?.toInt() ?? 10;
        final addDex = props['addDexModifier'] as bool? ?? true;
        final maxDex = (props['maxDexBonus'] as num?)?.toInt();
        int armorAC = baseAC;
        if (addDex) {
          armorAC += maxDex != null ? dexMod.clamp(-99, maxDex) : dexMod;
        }
        base = armorAC;
      }
    }

    return base + shieldBonus;
  }

  void _showDescriptionSheet(
    BuildContext context,
    String displayName,
    String? meta,
  ) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.25,
        maxChildSize: 0.85,
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
                item.quantity > 1
                    ? '$displayName ×${item.quantity}'
                    : displayName,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
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
                  Text(
                    item.description!,
                    style: const TextStyle(height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onEquipTap(
    BuildContext context,
    WidgetRef ref,
    CharacterDetailNotifier notifier,
  ) async {
    final character = ref.read(characterDetailProvider(characterId)).valueOrNull;

    // Troca de armadura corporal exige confirmação, mostrando CA atual e prevista.
    if (character != null && _isBodyArmor(item) && !item.isEquipped) {
      final equippedBodyArmors = character.equipment
          .where((e) => e.id != item.id && e.isEquipped && _isBodyArmor(e))
          .toList();

      if (equippedBodyArmors.isNotEmpty) {
        final equippedBodyArmor = equippedBodyArmors.first;
        final simulated = character.equipment.map((e) {
          if (e.id == equippedBodyArmor.id) return e.copyWith(isEquipped: false);
          if (e.id == item.id) return e.copyWith(isEquipped: true);
          return e;
        }).toList();
        final nextAc = _calcArmorClass(character, simulated);

        final l10n = AppLocalizations.of(context)!;
        final i18n = ref.read(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
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
    final i18n = ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final notifier = ref.read(characterDetailProvider(characterId).notifier);
    final canEquip =
        item.itemType == ItemType.weapon || item.itemType == ItemType.armor;
    final meta = _itemMeta(item, i18n);
    final displayName = _itemDisplayName(item, i18n);

    // Stealth disadvantage: stored in properties (new items) or description (old items)
    final stealthDisadv = item.itemType == ItemType.armor &&
        (item.properties?['stealthDisadvantage'] == true ||
         (item.description?.toLowerCase().contains('stealth') == true));

    String? subtitleText;
    if (meta != null && item.description != null && item.description!.isNotEmpty &&
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

    final hasDescription =
        item.description != null && item.description!.trim().isNotEmpty;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: hasDescription
          ? () => _showDescriptionSheet(context, displayName, meta)
          : null,
      leading: canEquip
          ? GestureDetector(
              onTap: () => _onEquipTap(context, ref, notifier),
              child: Tooltip(
                message: item.isEquipped ? 'Unequip' : 'Equip',
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
            )
          : null,
      title: Text(
        item.quantity > 1 ? '$displayName ×${item.quantity}' : displayName,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: subtitleText != null
          ? Text(
              subtitleText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12, color: scheme.onSurfaceVariant),
            )
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 18),
        color: scheme.error,
        tooltip: l10n.inventoryTooltipRemove,
        onPressed: () => _confirmRemoveItem(context, notifier),
      ),
    );
  }
}
