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
    final carried = nonAmmo.where((e) => !e.isEquipped).toList();

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

          // ── Carried ─────────────────────────────────────────────────────
          _Section(
            title: carried.isEmpty && equipped.isEmpty && ammo.isEmpty
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
                        child: Text(item.name,
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
  String? _loadError;

  List<String> _getTabLabels(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.inventoryTabWeapons,
      l10n.inventoryTabArmor,
      l10n.inventoryTabGear,
      l10n.inventoryTabMagic,
      l10n.inventoryTabCustom,
    ];
  }

  /// Remove notação de pacote do nome: "Arrows (20)" → "Arrows"
  static String _stripPackNotation(String name) =>
      name.replaceAll(RegExp(r'\s*\(\d+\)\s*$'), '').trim();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
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
      ]);
      if (mounted) {
        setState(() {
          _weapons = results[0] as List<SrdWeapon>;
          _armors = results[1] as List<SrdArmor>;
          _gear = results[2] as List<SrdGearItem>;
          _magic = results[3] as List<SrdMagicItem>;
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
    required String category,
    required ItemType itemType,
    required String? description,
    Map<String, dynamic>? properties,
  }) async {
    final qtyCtrl = TextEditingController(text: '1');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(name),
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
        properties: properties,
      ));
    }
    // qtyCtrl é variável local — não precisa de dispose manual
  }

  // Lista agrupada por categoria, com cabeçalhos. Ao pesquisar, exibe lista plana.
  Widget _buildGroupedSrdList<T>({
    required List<T>? items,
    required String Function(T) getName,
    required String Function(T) getSubtitle,
    required String Function(T) getCategory,
    required String Function(T) getGroup,
    required String? Function(T) getDescription,
    required ItemType Function(T) getItemType,
    Map<String, dynamic>? Function(T)? getProperties,
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
        : items.where((e) => getName(e).toLowerCase().contains(q)).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No results for "$q"',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    Widget buildTile(T item) => ListTile(
          title: Text(getName(item), style: const TextStyle(fontSize: 14)),
          subtitle: Text(
            getSubtitle(item),
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () => _confirmAdd(
              name: getName(item),
              category: getCategory(item),
              itemType: getItemType(item),
              description: getDescription(item),
              properties: getProperties?.call(item),
            ),
          ),
        );

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
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.inventoryLabelItemQuantity, border: const OutlineInputBorder()),
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
    final isCustomTab = _tabs.index == 4;

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
                  getSubtitle: (w) =>
                      '${w.damage} ${w.damageType}  ·  ${w.cost}',
                  getCategory: (w) => w.category,
                  getGroup: (w) => w.category,
                  getDescription: (w) => w.properties.isNotEmpty
                      ? w.properties.join(', ')
                      : null,
                  getItemType: (_) => ItemType.weapon,
                  getProperties: (w) => {
                    'damageDice': w.damage,
                    'damageType': w.damageType,
                  },
                  groupOrder: const [
                    'simple melee',
                    'simple ranged',
                    'martial melee',
                    'martial ranged',
                  ],
                  groupLabels: const {
                    'simple melee': 'Simple Melee',
                    'simple ranged': 'Simple Ranged',
                    'martial melee': 'Martial Melee',
                    'martial ranged': 'Martial Ranged',
                  },
                ),
                // Armor
                _buildGroupedSrdList<SrdArmor>(
                  items: _armors,
                  getName: (a) => a.isShield ? a.name : '${a.name} Armor',
                  getSubtitle: (a) => a.isShield
                      ? '+${a.acBonus} AC  ·  ${a.cost}'
                      : 'AC ${a.baseAC}${a.addDexModifier ? " + DEX" : ""}${a.maxDexBonus != null ? " (max +${a.maxDexBonus})" : ""}  ·  ${a.cost}',
                  getCategory: (_) => 'armor',
                  getGroup: (a) => a.type,
                  getDescription: (a) => a.stealthDisadvantage
                      ? 'Stealth disadvantage'
                      : null,
                  getItemType: (_) => ItemType.armor,
                  getProperties: (a) => {
                    'baseAC': a.baseAC,
                    'addDexModifier': a.addDexModifier,
                    'maxDexBonus': a.maxDexBonus,
                    'isShield': a.isShield,
                    'acBonus': a.acBonus,
                  },
                  groupOrder: const ['light', 'medium', 'heavy', 'shield'],
                  groupLabels: const {
                    'light': 'Light Armor',
                    'medium': 'Medium Armor',
                    'heavy': 'Heavy Armor',
                    'shield': 'Shields',
                  },
                ),
                // Gear
                _buildGroupedSrdList<SrdGearItem>(
                  items: _gear,
                  getName: (g) => _stripPackNotation(g.name),
                  getSubtitle: (g) => g.cost,
                  getCategory: (g) => g.category,
                  getGroup: (g) => g.category,
                  getDescription: (g) =>
                      g.description.isNotEmpty ? g.description : null,
                  getItemType: (g) => g.category == 'ammunition'
                      ? ItemType.ammunition
                      : ItemType.gear,
                  groupOrder: const [
                    'adventuring gear',
                    'ammunition',
                    'arcane focus',
                    'clothing',
                    'container',
                    'poison',
                  ],
                  groupLabels: const {
                    'adventuring gear': 'Adventuring Gear',
                    'ammunition': 'Ammunition',
                    'arcane focus': 'Arcane Focus',
                    'clothing': 'Clothing',
                    'container': 'Container',
                    'poison': 'Poison',
                  },
                ),
                // Magic Items
                _buildGroupedSrdList<SrdMagicItem>(
                  items: _magic,
                  getName: (m) => m.name,
                  getSubtitle: (m) =>
                      '${m.rarity}${m.requiresAttunement ? "  ·  attunement" : ""}',
                  getCategory: (m) => m.type,
                  getGroup: (m) => m.type,
                  getDescription: (m) => m.description,
                  getItemType: (m) => m.itemType,
                  groupOrder: const [
                    'potion',
                    'ring',
                    'wand',
                    'weapon',
                    'armor',
                    'wondrous item',
                  ],
                  groupLabels: const {
                    'potion': 'Potions',
                    'ring': 'Rings',
                    'wand': 'Wands',
                    'weapon': 'Weapons',
                    'armor': 'Armor',
                    'wondrous item': 'Wondrous Items',
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

  static String? _itemMeta(EquipmentItem item) {
    final props = item.properties;

    if (item.itemType == ItemType.weapon && props != null) {
      final dice = props['damageDice']?.toString();
      final type = props['damageType']?.toString();
      if (dice != null && dice.isNotEmpty && type != null && type.isNotEmpty) {
        return '$dice $type';
      }
      if (dice != null && dice.isNotEmpty) return dice;
    }

    if (item.itemType == ItemType.armor && props != null) {
      final isShield = props['isShield'] == true;
      if (isShield) {
        final bonus = (props['acBonus'] as num?)?.toInt() ?? 2;
        return 'Shield  ·  +$bonus AC';
      }

      final baseAc = (props['baseAC'] as num?)?.toInt();
      if (baseAc != null) {
        final addDex = props['addDexModifier'] as bool? ?? true;
        final maxDex = (props['maxDexBonus'] as num?)?.toInt();
        if (!addDex) return 'AC $baseAc';
        if (maxDex != null) return 'AC $baseAc + DEX (max +$maxDex)';
        return 'AC $baseAc + DEX';
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

        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.inventoryReplaceArmorTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current: ${equippedBodyArmor.name}'),
                const SizedBox(height: 8),
                Text('AC now: ${character.armorClass}'),
                Text('AC after: $nextAc'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(AppLocalizations.of(context)!.dialogCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Swap armor'),
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
    final notifier = ref.read(characterDetailProvider(characterId).notifier);
    final canEquip =
        item.itemType == ItemType.weapon || item.itemType == ItemType.armor;
    final meta = _itemMeta(item);

    String? subtitleText;
    if (meta != null && item.description != null && item.description!.isNotEmpty) {
      subtitleText = '$meta  ·  ${item.description!}';
    } else {
      subtitleText = meta ?? item.description;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
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
          : CircleAvatar(
              radius: 16,
              backgroundColor: scheme.surfaceContainerHighest,
              child: Icon(
                _leadingIcon(item.itemType, false),
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
            ),
      title: Text(
        item.quantity > 1 ? '${item.name} ×${item.quantity}' : item.name,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: subtitleText != null
          ? Text(
              subtitleText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12, color: scheme.onSurfaceVariant),
            )
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 18),
        color: scheme.error,
        tooltip: 'Remove',
        onPressed: () => _confirmRemoveItem(context, notifier),
      ),
    );
  }
}
