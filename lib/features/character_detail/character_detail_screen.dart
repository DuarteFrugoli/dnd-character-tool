import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/display/keep_screen_on_provider.dart';
import '../../core/platform/keep_screen_on.dart';
import '../../data/datasources/srd/srd_i18n_service.dart';
import '../../data/constants/level_up_rules.dart';
import '../../data/models/models.dart';
import '../../shared/providers/providers.dart';
import '../../shared/utils/character_display.dart';
import '../../shared/widgets/responsive_layout.dart';
import 'application/character_tab_view_models.dart';
import 'character_detail_provider.dart';
import 'level_reset_sheet.dart';
import 'level_up_wizard_sheet.dart';
import 'tabs/features_tab.dart';
import 'tabs/identity_tab.dart';
import 'tabs/inventory_tab.dart';
import 'tabs/notes_tab.dart';
import 'tabs/skills_tab.dart';
import 'tabs/spells_tab.dart';
import 'tabs/stats_tab.dart';
import 'widgets/character_detail_shell.dart';
import 'widgets/dice/dice_roller_sheet.dart';
import 'widgets/detail_edit_guard.dart';
import 'widgets/detail_tab_host.dart';

class CharacterDetailScreen extends ConsumerStatefulWidget {
  const CharacterDetailScreen({super.key, required this.characterId});
  final String characterId;

  @override
  ConsumerState<CharacterDetailScreen> createState() =>
      _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends ConsumerState<CharacterDetailScreen>
    with SingleTickerProviderStateMixin {
  static const _detailTabCount = 7;

  late final TabController _tabs;
  final _editGuard = EditGuard();
  bool? _keepScreenOnApplied;
  bool _tabWarmupScheduled = false;
  int? _lastWarmedTabIndex;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _detailTabCount, vsync: this);
    _tabs.addListener(_onTabChanging);
    _tabs.addListener(_onTabWarmupRequested);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scheduleTabWarmup(_tabs.index);
    });
  }

  @override
  void dispose() {
    if (_keepScreenOnApplied == true) {
      unawaited(KeepScreenOn.setEnabled(false));
    }
    _tabs.removeListener(_onTabChanging);
    _tabs.removeListener(_onTabWarmupRequested);
    _tabs.dispose();
    super.dispose();
  }

  int _lastTabIndex = 0;
  bool _isIntercepting = false;

  void _onTabWarmupRequested() {
    _scheduleTabWarmup(_tabs.index);
  }

  void _scheduleTabWarmup(int centerIndex) {
    if (_tabWarmupScheduled) return;
    _tabWarmupScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabWarmupScheduled = false;
      if (!mounted) return;
      _warmTabsAround(centerIndex);
    });
  }

  void _warmTabsAround(int centerIndex) {
    if (_lastWarmedTabIndex == centerIndex) return;
    _lastWarmedTabIndex = centerIndex;
    for (final tabIndex in <int>{
      centerIndex - 1,
      centerIndex,
      centerIndex + 1,
    }) {
      if (tabIndex < 0 || tabIndex >= _detailTabCount) continue;
      _warmTabData(tabIndex);
    }
  }

  void _warmTabData(int tabIndex) {
    switch (tabIndex) {
      case 0:
        ref.read(identityTabVmProvider(widget.characterId));
        ref.read(srdI18nProvider);
        return;
      case 1:
        ref.read(statsTabVmProvider(widget.characterId));
        ref.read(srdI18nProvider);
        ref.read(srdConditionsProvider);
        return;
      case 2:
        ref.read(skillsTabVmProvider(widget.characterId));
        ref.read(srdI18nProvider);
        return;
      case 3:
        ref.read(featuresTabVmProvider(widget.characterId));
        ref.read(srdI18nProvider);
        ref.read(srdAllSubclassFeaturesProvider);
        ref.read(srdRacesProvider);
        ref.read(srdBackgroundsProvider);
        ref.read(srdRaceTraitsProvider);
        ref.read(srdFeatureChoiceCatalogProvider);
        ref.read(srdFeatureUsageCatalogProvider);
        ref.read(srdSkillsProvider);
        ref.read(srdToolsProvider);
        ref.read(srdSpellsProvider);
        ref.read(srdLanguagesProvider);
        ref.read(srdWeaponsProvider);
        ref.read(srdFeatsProvider);
        final character = _currentCharacter();
        if (character != null) {
          for (final entry in character.classEntries) {
            ref.read(srdClassFeaturesProvider(entry.className));
          }
        }
        return;
      case 4:
        ref.read(spellsTabVmProvider(widget.characterId));
        ref.read(srdI18nProvider);
        ref.read(srdSpellsProvider);
        return;
      case 5:
        ref.read(inventoryTabVmProvider(widget.characterId));
        ref.read(srdI18nProvider);
        ref.read(srdItemsProvider);
        ref.read(srdWeaponsProvider);
        ref.read(srdToolsProvider);
        return;
      case 6:
        ref.read(notesTabVmProvider(widget.characterId));
        return;
    }
  }

  void _onTabChanging() {
    // Only act when the tab index actually changes (not animation updates).
    if (!_tabs.indexIsChanging) return;
    // Prevent re-entry: animateTo(_lastTabIndex) below re-triggers this listener.
    if (_isIntercepting) return;
    if (!_editGuard.isEditing) {
      _lastTabIndex = _tabs.index;
      return;
    }
    // A tab is in edit mode — intercept the change.
    final targetIndex = _tabs.index;
    _isIntercepting = true;
    // Jump back to the editing tab immediately (before the animation settles).
    _tabs.animateTo(_lastTabIndex);
    // Then ask the tab to confirm discard asynchronously.
    final l10n = AppLocalizations.of(context)!;
    _editGuard.requestCancel(context, l10n).then((discarded) {
      _isIntercepting = false;
      if (discarded && mounted) {
        _lastTabIndex = targetIndex;
        _tabs.animateTo(targetIndex);
      }
    });
  }

  void _goBack() => context.canPop() ? context.pop() : context.go('/');

  Future<void> _handleBack() async {
    _goBack();
  }

  Character? _currentCharacter() {
    return ref.read(characterDetailProvider(widget.characterId)).valueOrNull;
  }

  void _openLevelUpForCurrentCharacter() {
    final character = _currentCharacter();
    if (character == null) return;
    openLevelUpWizardSheet(context, character, widget.characterId);
  }

  void _openLevelResetForCurrentCharacter() {
    final character = _currentCharacter();
    if (character == null) return;
    openLevelResetSheet(context, character, widget.characterId);
  }

  void _showRestPickerForCurrentCharacter() {
    final character = _currentCharacter();
    if (character == null) return;
    _showRestPicker(character);
  }

  @override
  Widget build(BuildContext context) {
    _syncKeepScreenOn(ref.watch(keepScreenOnCharacterSheetProvider));
    final state = ref.watch(characterHeaderVmProvider(widget.characterId));
    return state.when(
      loading: () => Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: _handleBack)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: _handleBack),
          title: const Text('Character'),
        ),
        body: Center(
          child: Text(
            AppLocalizations.of(context)!.detailErrorLoading(e.toString()),
          ),
        ),
      ),
      data: _buildLoaded,
    );
  }

  void _syncKeepScreenOn(bool enabled) {
    if (_keepScreenOnApplied == enabled) return;
    _keepScreenOnApplied = enabled;
    unawaited(KeepScreenOn.setEnabled(enabled));
  }

  Widget _buildLoaded(CharacterHeaderVm header) {
    if (header.dataVersion < currentCharacterDataVersion) {
      return _buildMaintenanceRequired(header);
    }

    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final l10n = AppLocalizations.of(context)!;
    final classSummary = localizedClassEntriesSummary(
      header.classes,
      i18n,
      includeSubclasses: true,
    );
    final raceSummary = localizedRaceSummaryFromParts(
      race: header.race,
      subrace: header.subrace,
      i18n: i18n,
    );
    final levelLabel = l10n.charCardLevel(header.level);
    final compactHeader = MediaQuery.sizeOf(context).width < 420;
    final subtitle = compactHeader
        ? '$levelLabel  ·  $classSummary  ·  $raceSummary'
        : '$classSummary  ·  $raceSummary  ·  $levelLabel';
    return CharacterDetailShell(
      header: header,
      subtitle: subtitle,
      tabs: _tabs,
      onBack: _handleBack,
      onRollDice: () =>
          openDiceRollerSheet(context, characterId: widget.characterId),
      onLevelUp: _openLevelUpForCurrentCharacter,
      onResetLevels: _openLevelResetForCurrentCharacter,
      onRest: _showRestPickerForCurrentCharacter,
      onImageChanged: (path) {
        ref
            .read(characterDetailProvider(widget.characterId).notifier)
            .updateImage(path);
      },
      children: [
        CharacterTabHost<IdentityTabVm>(
          provider: identityTabVmProvider(widget.characterId),
          builder: (context, vm) => IdentityTab(
            character: vm.character,
            characterId: widget.characterId,
            editGuard: _editGuard,
          ),
        ),
        CharacterTabHost<StatsTabVm>(
          provider: statsTabVmProvider(widget.characterId),
          builder: (context, vm) => StatsTab(
            character: vm.character,
            characterId: widget.characterId,
            editGuard: _editGuard,
          ),
        ),
        CharacterTabHost<SkillsTabVm>(
          provider: skillsTabVmProvider(widget.characterId),
          builder: (context, vm) => SkillsTab(
            skillRows: vm.rows,
            preferences: vm.preferences,
            characterId: widget.characterId,
          ),
        ),
        CharacterTabHost<FeaturesTabVm>(
          provider: featuresTabVmProvider(widget.characterId),
          builder: (context, vm) => FeaturesTab(
            character: vm.character,
            characterId: widget.characterId,
          ),
        ),
        CharacterTabHost<SpellsTabVm>(
          provider: spellsTabVmProvider(widget.characterId),
          builder: (context, vm) => SpellsTab(
            character: vm.character,
            spellcastingSummary: vm.spellcastingSummary,
            characterId: widget.characterId,
          ),
        ),
        CharacterTabHost<InventoryTabVm>(
          provider: inventoryTabVmProvider(widget.characterId),
          builder: (context, vm) => InventoryTab(
            character: vm.character,
            inventory: vm.snapshot,
            strengthScore: vm.strengthScore,
            characterId: widget.characterId,
          ),
        ),
        CharacterTabHost<NotesTabVm>(
          provider: notesTabVmProvider(widget.characterId),
          builder: (context, vm) =>
              NotesTab(notes: vm.notes, characterId: widget.characterId),
        ),
      ],
    );
  }

  Widget _buildMaintenanceRequired(CharacterHeaderVm character) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: _handleBack),
        title: Text(
          character.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ResponsiveScaffoldBody(
        maxWidth: 720,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.system_update_alt_outlined,
                  size: 48,
                  color: scheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.characterUpdateRequiredTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.characterUpdateRequiredBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.go('/settings?section=maintenance'),
                  icon: const Icon(Icons.settings_outlined),
                  label: Text(l10n.characterUpdateRequiredAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRestPicker(Character character) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                l10n.restPickerTitle,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.bedtime_outlined),
              title: Text(l10n.restPickerShort),
              subtitle: Text(l10n.restPickerShortCaption),
              onTap: () {
                Navigator.pop(ctx);
                _showShortRestDialog(character);
              },
            ),
            ListTile(
              leading: const Icon(Icons.hotel_outlined),
              title: Text(l10n.restPickerLong),
              subtitle: Text(l10n.restPickerLongCaption),
              onTap: () {
                Navigator.pop(ctx);
                _confirmLongRest();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _showShortRestDialog(Character character) async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(
      characterDetailProvider(widget.characterId).notifier,
    );

    final hitDicePools = character.hitDicePools.isNotEmpty
        ? character.hitDicePools
        : [
            CharacterHitDiePool(
              dieSize: levelUpHitDie(character.primaryClassName),
              total: character.totalLevel,
              used: character.hitPoints.hitDiceUsed,
              sourceClass: character.primaryClassName,
              sourceClassEntryId: character.primaryClass.id,
            ),
          ];
    final i18n =
        ref.read(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final poolRows = [
      for (var i = 0; i < hitDicePools.length; i++)
        _ShortRestHitDiePool(
          index: i,
          label: hitDicePools[i].sourceClass == null
              ? 'd${hitDicePools[i].dieSize}'
              : i18n.className(hitDicePools[i].sourceClass!),
          dieSize: hitDicePools[i].dieSize,
          remaining: hitDicePools[i].remaining,
        ),
    ];
    final conMod = (character.abilityScores.constitution - 10) ~/ 2;

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => _ShortRestDialog(
        l10n: l10n,
        pools: poolRows,
        conMod: conMod,
        maxHp: character.hitPoints.maximum,
        currentHp: character.hitPoints.current,
        onConfirm: (hitDiceSpentByPool, hpGained) async {
          await notifier.shortRest(
            hitDiceSpentByPool: hitDiceSpentByPool,
            hpGained: hpGained,
          );
        },
      ),
    );
  }

  Future<void> _confirmLongRest() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.longRestTitle),
        content: Text(l10n.longRestContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.longRestButton),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref
          .read(characterDetailProvider(widget.characterId).notifier)
          .longRest();
    }
  }
}

// ── Short Rest Dialog ─────────────────────────────────────────────────────────

class _ShortRestDialog extends StatefulWidget {
  final AppLocalizations l10n;
  final List<_ShortRestHitDiePool> pools;
  final int conMod;
  final int maxHp;
  final int currentHp;
  final Future<void> Function(List<int> hitDiceSpentByPool, int hpGained)
  onConfirm;

  const _ShortRestDialog({
    required this.l10n,
    required this.pools,
    required this.conMod,
    required this.maxHp,
    required this.currentHp,
    required this.onConfirm,
  });

  @override
  State<_ShortRestDialog> createState() => _ShortRestDialogState();
}

class _ShortRestDialogState extends State<_ShortRestDialog> {
  late final List<int> _diceToSpend;
  int _rolledHp = 0;
  bool _hasRolled = false;

  int get _totalAvailable =>
      widget.pools.fold<int>(0, (sum, pool) => sum + pool.remaining);

  int get _totalToSpend =>
      _diceToSpend.fold<int>(0, (sum, count) => sum + count);

  @override
  void initState() {
    super.initState();
    _diceToSpend = List.filled(widget.pools.length, 0);
    final firstAvailable = widget.pools.indexWhere(
      (pool) => pool.remaining > 0,
    );
    if (firstAvailable >= 0) _diceToSpend[firstAvailable] = 1;
  }

  void _setPoolSpend(int index, int value) {
    final pool = widget.pools[index];
    setState(() {
      _diceToSpend[index] = value.clamp(0, pool.remaining).toInt();
      _hasRolled = false;
    });
  }

  void _roll() {
    final rng = math.Random();
    int total = 0;
    for (var poolIndex = 0; poolIndex < widget.pools.length; poolIndex++) {
      final pool = widget.pools[poolIndex];
      final dice = _diceToSpend[poolIndex];
      for (var die = 0; die < dice; die++) {
        total += rng.nextInt(pool.dieSize) + 1;
      }
    }
    total += widget.conMod * _totalToSpend;
    setState(() {
      _rolledHp = total.clamp(0, widget.maxHp - widget.currentHp);
      _hasRolled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final scheme = Theme.of(context).colorScheme;
    final noDice = _totalAvailable <= 0;

    return AlertDialog(
      title: Text(l10n.shortRestTitle),
      content: noDice
          ? Text(l10n.shortRestNoDice)
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.shortRestAvailableDice}'
                    '${widget.conMod >= 0 ? ' (+${widget.conMod} CON)' : ' (${widget.conMod} CON)'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  for (final pool in widget.pools)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${pool.label}: ${pool.remaining} d${pool.dieSize}',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _diceToSpend[pool.index] > 0
                                ? () => _setPoolSpend(
                                    pool.index,
                                    _diceToSpend[pool.index] - 1,
                                  )
                                : null,
                          ),
                          Text(
                            '${_diceToSpend[pool.index]}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _diceToSpend[pool.index] < pool.remaining
                                ? () => _setPoolSpend(
                                    pool.index,
                                    _diceToSpend[pool.index] + 1,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  if (_hasRolled) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.shortRestRolled}: +$_rolledHp HP',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: scheme.primary),
                    ),
                  ],
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.dialogCancel),
        ),
        if (!noDice && !_hasRolled)
          FilledButton(
            onPressed: _totalToSpend > 0 ? _roll : null,
            child: Text(l10n.shortRestRollButton),
          ),
        if (!noDice && _hasRolled)
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await widget.onConfirm(_diceToSpend, _rolledHp);
            },
            child: Text(l10n.shortRestButton),
          ),
      ],
    );
  }
}

class _ShortRestHitDiePool {
  const _ShortRestHitDiePool({
    required this.index,
    required this.label,
    required this.dieSize,
    required this.remaining,
  });

  final int index;
  final String label;
  final int dieSize;
  final int remaining;
}
