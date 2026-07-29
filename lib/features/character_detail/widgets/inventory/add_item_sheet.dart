part of '../../character_detail_screen.dart';

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

  Widget _buildGlobalSrdSearch(SrdI18nService i18n, AppLocalizations l10n) {
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
          header: DetailGroupHeader(label: groupLabels[key] ?? key),
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
                          if (a.stealthDisadvantage)
                            'stealthDisadvantage': true,
                          if (a.cost.isNotEmpty) 'cost': a.cost,
                        },
                        getWeight: (a) => a.weight,
                        groupOrder: const [
                          'light',
                          'medium',
                          'heavy',
                          'shield',
                        ],
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
                        getProperties: (g) => {
                          if (g.cost.isNotEmpty) 'cost': g.cost,
                        },
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
                          'adventuring gear':
                              l10n.inventoryGroupAdventuringGear,
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
