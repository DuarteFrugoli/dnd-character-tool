import '../character_detail_dependencies.dart';
import '../../../shared/utils/character_display.dart';

// ── Stats Tab ─────────────────────────────────────────────────────────────────

class StatsTab extends ConsumerStatefulWidget {
  const StatsTab({
    super.key,
    required this.character,
    required this.characterId,
    required this.editGuard,
  });
  final Character character;
  final String characterId;
  final EditGuard editGuard;

  @override
  ConsumerState<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends ConsumerState<StatsTab> {
  // HP tracker
  final _amountCtrl = TextEditingController(text: '1');

  // Local edit mode for stats fields
  bool _isEditing = false;
  Character? _snapshot;

  // Stats edit controllers
  late final TextEditingController _hpMaxCtrl;
  late final TextEditingController _speedCtrl;
  late final TextEditingController _xpCtrl;

  // Focus nodes
  final _hpMaxFocus = FocusNode();
  final _speedFocus = FocusNode();
  final _xpFocus = FocusNode();

  // XP progression panel
  final _xpAddCtrl = TextEditingController(text: '0');
  bool _levelTableExpanded = false;
  bool _xpAddInProgress = false;

  CharacterDetailNotifier get _notifier =>
      ref.read(characterDetailProvider(widget.characterId).notifier);

  bool _isPendingLevelUp(Character c) {
    if (!c.xpTrackingEnabled || c.totalLevel >= 20) return false;
    return c.experiencePoints >= kXpThresholds[c.totalLevel];
  }

  Future<void> _addXp(int amount) async {
    if (_xpAddInProgress) return;
    final character = widget.character;
    if (!character.xpTrackingEnabled) return;
    setState(() => _xpAddInProgress = true);
    try {
      final newXp = (character.experiencePoints + amount).clamp(0, 999999);
      if (character.totalLevel < 20) {
        final nextThreshold = kXpThresholds[character.totalLevel];
        if (newXp >= nextThreshold &&
            character.experiencePoints < nextThreshold) {
          final l10n = AppLocalizations.of(context)!;
          // Save the full earned XP before showing dialog
          await _notifier.updateExperiencePoints(newXp);
          if (!mounted) return;
          final levelNow = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.xpLevelUpNowTitle),
              content: Text(
                l10n.xpLevelUpNowMessage(character.totalLevel + 1),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.xpLevelUpLater),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.tooltipLevelUp),
                ),
              ],
            ),
          );
          if (!mounted) return;
          if (levelNow == true) {
            // Wizard will set XP to min of new level via provider.levelUp()
            openLevelUpWizardSheet(
              context,
              widget.character,
              widget.characterId,
            );
          } else {
            // Cap at threshold so the pending state remains visible
            await _notifier.updateExperiencePoints(nextThreshold);
          }
          return;
        }
      }
      await _notifier.updateExperiencePoints(newXp);
    } finally {
      if (mounted) setState(() => _xpAddInProgress = false);
    }
  }

  void _startEditing() {
    widget.editGuard.register(_discardEditing);
    setState(() {
      _isEditing = true;
      _snapshot = widget.character;
    });
  }

  /// Called by the guard after the user confirms discard (no additional dialog).
  Future<void> _discardEditing() async {
    FocusScope.of(context).unfocus();
    final snap = _snapshot;
    if (snap != null) {
      await _notifier.revertTo(snap);
    }
    if (!mounted) return;
    widget.editGuard.unregister();
    setState(() {
      _isEditing = false;
      _snapshot = null;
    });
  }

  Future<void> _cancelEditing() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.detailCancelEditTitle),
        content: Text(l10n.detailCancelEditContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogKeepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.dialogDiscard),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await _discardEditing();
  }

  void _saveEditing() {
    // Set _isEditing = false BEFORE unfocus() so focus listeners don't fire
    // individual saves that would race against each other and corrupt the file.
    widget.editGuard.unregister();
    setState(() {
      _isEditing = false;
      _snapshot = null;
    });
    FocusScope.of(context).unfocus();
    _notifier.saveStatsEdit(
      hpMax: int.tryParse(_hpMaxCtrl.text),
      speed: int.tryParse(_speedCtrl.text),
      xp: int.tryParse(_xpCtrl.text),
    );
  }

  @override
  void initState() {
    super.initState();
    final c = widget.character;
    _hpMaxCtrl = TextEditingController(text: '${c.hitPoints.maximum}');
    _speedCtrl = TextEditingController(text: '${c.speed}');
    _xpCtrl = TextEditingController(text: '${c.experiencePoints}');

    // Use a single atomic save when any field loses focus to avoid
    // concurrent writes from multiple individual listeners.
    void onFocusLost() {
      if (_isEditing) {
        _notifier.saveStatsEdit(
          hpMax: int.tryParse(_hpMaxCtrl.text),
          speed: int.tryParse(_speedCtrl.text),
          xp: int.tryParse(_xpCtrl.text),
        );
      }
    }

    _hpMaxFocus.addListener(() {
      if (!_hpMaxFocus.hasFocus) onFocusLost();
    });
    _speedFocus.addListener(() {
      if (!_speedFocus.hasFocus) onFocusLost();
    });
    _xpFocus.addListener(() {
      if (!_xpFocus.hasFocus) onFocusLost();
    });
  }

  @override
  void didUpdateWidget(StatsTab old) {
    super.didUpdateWidget(old);
    final c = widget.character;
    if (!_hpMaxFocus.hasFocus) _hpMaxCtrl.text = '${c.hitPoints.maximum}';
    if (!_speedFocus.hasFocus) _speedCtrl.text = '${c.speed}';
    if (!_xpFocus.hasFocus) _xpCtrl.text = '${c.experiencePoints}';
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _hpMaxCtrl.dispose();
    _speedCtrl.dispose();
    _xpCtrl.dispose();
    _xpAddCtrl.dispose();
    _hpMaxFocus.dispose();
    _speedFocus.dispose();
    _xpFocus.dispose();
    super.dispose();
  }

  void _incrementAmount(int delta) {
    final v = int.tryParse(_amountCtrl.text) ?? 1;
    _amountCtrl.text = '${(v + delta).clamp(1, 9999)}';
  }

  Future<void> _showSetTempHpDialog(BuildContext context) async {
    final currentTemp = widget.character.hitPoints.temporary;
    final ctrl = TextEditingController(
      text: currentTemp > 0 ? '$currentTemp' : '',
    );
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final parsed = int.tryParse(ctrl.text);
          final isValid =
              parsed != null &&
              parsed > 0 &&
              (currentTemp == 0 || parsed > currentTemp);
          return AlertDialog(
            title: Text(
              currentTemp > 0
                  ? AppLocalizations.of(context)!.tempHpDialogTitleReplace
                  : AppLocalizations.of(context)!.tempHpDialogTitle,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentTemp > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      AppLocalizations.of(ctx)!.tempHpCurrent(currentTemp),
                      style: TextStyle(
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(ctx)!.labelTempHP,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setLocal(() {}),
                  onSubmitted: (_) {
                    final n = int.tryParse(ctrl.text);
                    if (n != null &&
                        n > 0 &&
                        (currentTemp == 0 || n > currentTemp)) {
                      Navigator.pop(ctx, n);
                    }
                  },
                ),
                if (currentTemp > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      AppLocalizations.of(ctx)!.tempHpNoStack,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              if (currentTemp > 0)
                TextButton(
                  onPressed: () => Navigator.pop(ctx, 0),
                  child: Text(AppLocalizations.of(ctx)!.dialogRemove),
                ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppLocalizations.of(ctx)!.dialogCancel),
              ),
              FilledButton(
                onPressed: isValid ? () => Navigator.pop(ctx, parsed) : null,
                child: Text(
                  currentTemp > 0
                      ? AppLocalizations.of(ctx)!.tempHpReplace
                      : AppLocalizations.of(ctx)!.dialogAdd,
                ),
              ),
            ],
          );
        },
      ),
    );
    // ctrl é variável local — não precisa de dispose manual
    if (result != null && context.mounted) {
      ref
          .read(characterDetailProvider(widget.characterId).notifier)
          .setTemporaryHp(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final character = widget.character;
    final hp = character.hitPoints;
    final isDead = hp.isDead;
    final isFull = hp.current >= hp.maximum;
    final scheme = Theme.of(context).colorScheme;
    final notifier = _notifier;
    final equippedArmor = character.equipment
        .where((e) => e.itemType == ItemType.armor && e.isEquipped)
        .toList();
    final bodyArmor = equippedArmor
        .where((e) => e.properties?['isShield'] != true)
        .toList();
    final usingShield = equippedArmor.any(
      (e) => e.properties?['isShield'] == true,
    );
    final armorSummary = bodyArmor.isEmpty
        ? (usingShield ? l10n.statNoArmorShield : l10n.statNoArmor)
        : '${i18n.equipmentName(bodyArmor.first.name)}${usingShield ? l10n.statShieldSuffix : ''}';

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          key: PageStorageKey('stats-${widget.characterId}'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 192),
          children: [
            ResponsiveTwoColumn(
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── HP Tracker ───────────────────────────────────────────
                  DetailSection(
                    title: l10n.sectionHitPoints,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${hp.current}',
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDead
                                        ? scheme.error
                                        : isFull
                                        ? scheme.primary
                                        : null,
                                  ),
                            ),
                            Text(
                              ' / ${hp.maximum}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(width: 8),
                            if (hp.temporary > 0) ...[
                              Chip(
                                label: Text(l10n.statsTempHpChip(hp.temporary)),
                                backgroundColor: scheme.tertiaryContainer,
                                labelStyle: TextStyle(
                                  color: scheme.onTertiaryContainer,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: IconButton.filledTonal(
                                icon: const Icon(
                                  Icons.shield_outlined,
                                  size: 16,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: scheme.tertiaryContainer,
                                  foregroundColor: scheme.onTertiaryContainer,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(32, 32),
                                  fixedSize: const Size(32, 32),
                                ),
                                tooltip: hp.temporary > 0
                                    ? l10n.tooltipChangeTempHp
                                    : l10n.tooltipAddTempHp,
                                onPressed: () => _showSetTempHpDialog(context),
                              ),
                            ),
                          ],
                        ),
                        if (isDead)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              l10n.statUnconsciousDying,
                              style: TextStyle(color: scheme.error),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            IconButton.outlined(
                              icon: const Icon(Icons.remove, size: 16),
                              style: IconButton.styleFrom(
                                minimumSize: const Size(36, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => _incrementAmount(-1),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _amountCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  labelText: l10n.labelAmount,
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                            IconButton.outlined(
                              icon: const Icon(Icons.add, size: 16),
                              style: IconButton.styleFrom(
                                minimumSize: const Size(36, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => _incrementAmount(1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.tonal(
                                style: FilledButton.styleFrom(
                                  backgroundColor: scheme.errorContainer,
                                  foregroundColor: scheme.onErrorContainer,
                                ),
                                onPressed: () {
                                  final n = int.tryParse(_amountCtrl.text) ?? 0;
                                  if (n > 0) notifier.adjustHp(-n);
                                },
                                child: Text(l10n.detailDamage),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.tonal(
                                style: FilledButton.styleFrom(
                                  backgroundColor: scheme.primaryContainer,
                                  foregroundColor: scheme.onPrimaryContainer,
                                ),
                                onPressed: () {
                                  final n = int.tryParse(_amountCtrl.text) ?? 0;
                                  if (n > 0) notifier.adjustHp(n);
                                },
                                child: Text(l10n.detailHeal),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.stepHitDieLabel}: '
                          '${hitDicePoolSummary(character)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        if (_isEditing) ...[
                          const SizedBox(height: 12),
                          InlineEditField(
                            label: l10n.labelMaxHP,
                            controller: _hpMaxCtrl,
                            focusNode: _hpMaxFocus,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ],
                        if (isDead) ...[
                          const SizedBox(height: 8),
                          _DeathSavesRow(
                            successes: hp.deathSaveSuccesses,
                            failures: hp.deathSaveFailures,
                            onChanged: (s, f) => notifier.updateDeathSaves(
                              successes: s,
                              failures: f,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Active Conditions ────────────────────────────────────
                  _ConditionsSection(
                    activeConditions: character.activeConditions,
                    i18n: i18n,
                    onToggle: notifier.toggleCondition,
                    allConditions:
                        ref.watch(srdConditionsProvider).valueOrNull ??
                        const [],
                  ),
                  const SizedBox(height: 12),

                  // ── Inspiration ──────────────────────────────────────────
                  _InspirationBanner(
                    active: character.inspiration,
                    onTap: () => notifier.toggleInspiration(),
                    label: l10n.statInspiration,
                    activeSubtitle: l10n.inspirationGranted,
                    inactiveSubtitle: l10n.inspirationNotGranted,
                  ),
                  const SizedBox(height: 12),

                  // ── Combat Stats ─────────────────────────────────────────
                  DetailSection(
                    title: l10n.sectionCombat,
                    child: _isEditing
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InlineEditField(
                                label: l10n.labelSpeed,
                                controller: _speedCtrl,
                                focusNode: _speedFocus,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  DetailStatChip(
                                    l10n.statAC,
                                    '${character.armorClass}',
                                  ),
                                  DetailStatChip(l10n.statArmor, armorSummary),
                                  DetailStatChip(
                                    l10n.statInitiative,
                                    sign(character.initiative),
                                  ),
                                  DetailStatChip(
                                    l10n.statProfBonus,
                                    sign(character.proficiencyBonus),
                                  ),
                                  DetailStatChip(
                                    l10n.statPassivePerc,
                                    '${character.passivePerception}',
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              DetailStatChip(
                                l10n.statAC,
                                '${character.armorClass}',
                              ),
                              DetailStatChip(l10n.statArmor, armorSummary),
                              DetailStatChip(
                                l10n.statSpeed,
                                formatDistance(
                                  character.speed,
                                  ref.watch(unitSystemProvider),
                                ),
                              ),
                              DetailStatChip(
                                l10n.statInitiative,
                                sign(character.initiative),
                              ),
                              DetailStatChip(
                                l10n.statProfBonus,
                                sign(character.proficiencyBonus),
                              ),
                              DetailStatChip(
                                l10n.statPassivePerc,
                                '${character.passivePerception}',
                              ),
                            ],
                          ),
                  ),
                ],
              ),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Ability Scores ───────────────────────────────────────
                  DetailSection(
                    title: l10n.sectionAbilityScores,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: _isEditing ? 0.75 : 1.2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          children: [
                            AbilityCardEdit(
                              l10n.abilityStr,
                              character.abilityScores.strength,
                              'strength',
                              notifier: notifier,
                              isEditing: _isEditing,
                            ),
                            AbilityCardEdit(
                              l10n.abilityDex,
                              character.abilityScores.dexterity,
                              'dexterity',
                              notifier: notifier,
                              isEditing: _isEditing,
                            ),
                            AbilityCardEdit(
                              l10n.abilityCon,
                              character.abilityScores.constitution,
                              'constitution',
                              notifier: notifier,
                              isEditing: _isEditing,
                            ),
                            AbilityCardEdit(
                              l10n.abilityInt,
                              character.abilityScores.intelligence,
                              'intelligence',
                              notifier: notifier,
                              isEditing: _isEditing,
                            ),
                            AbilityCardEdit(
                              l10n.abilityWis,
                              character.abilityScores.wisdom,
                              'wisdom',
                              notifier: notifier,
                              isEditing: _isEditing,
                            ),
                            AbilityCardEdit(
                              l10n.abilityCha,
                              character.abilityScores.charisma,
                              'charisma',
                              notifier: notifier,
                              isEditing: _isEditing,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Saving Throws ────────────────────────────────────────
                  DetailSection(
                    title: l10n.sectionSavingThrows,
                    child: _SavingThrowsList(
                      character: character,
                      l10n: l10n,
                      notifier: _isEditing ? notifier : null,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Progression ──────────────────────────────────────────
                  DetailSection(
                    title: l10n.sectionProgression,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.xpTrackingLabel,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            Switch(
                              value: character.xpTrackingEnabled,
                              onChanged: (v) => notifier.updateXpTracking(v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Opacity(
                          opacity: character.xpTrackingEnabled ? 1.0 : 0.4,
                          child: AbsorbPointer(
                            absorbing: !character.xpTrackingEnabled,
                            child: _isEditing
                                ? InlineEditField(
                                    label: l10n.statXP,
                                    controller: _xpCtrl,
                                    focusNode: _xpFocus,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  )
                                : _XpProgressionPanel(
                                    xp: character.experiencePoints,
                                    characterLevel: character.totalLevel,
                                    xpAddCtrl: _xpAddCtrl,
                                    expanded: _levelTableExpanded,
                                    onToggle: () => setState(
                                      () => _levelTableExpanded =
                                          !_levelTableExpanded,
                                    ),
                                    onAdd: _addXp,
                                    xpTrackingEnabled:
                                        character.xpTrackingEnabled,
                                    isPendingLevelUp: _isPendingLevelUp(
                                      character,
                                    ),
                                    onLevelUpTap: () => openLevelUpWizardSheet(
                                      context,
                                      character,
                                      widget.characterId,
                                    ),
                                    l10n: l10n,
                                    scheme: scheme,
                                  ),
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
      ),
      floatingActionButton: _isEditing
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'stats_cancel',
                  onPressed: _cancelEditing,
                  backgroundColor: scheme.errorContainer,
                  foregroundColor: scheme.onErrorContainer,
                  tooltip: l10n.dialogCancel,
                  child: const Icon(Icons.close),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'stats_save',
                  onPressed: _saveEditing,
                  tooltip: l10n.dialogSave,
                  child: const Icon(Icons.check),
                ),
              ],
            )
          : FloatingActionButton(
              heroTag: 'stats_edit',
              onPressed: _startEditing,
              tooltip: l10n.detailEditButton,
              child: const Icon(Icons.edit_outlined),
            ),
    );
  }
}

// ── XP / Progression ─────────────────────────────────────────────────────────

// ── XP / Progression ──────────────────────────────────────────────────────────

class _XpProgressionPanel extends StatelessWidget {
  const _XpProgressionPanel({
    required this.xp,
    required this.characterLevel,
    required this.xpAddCtrl,
    required this.expanded,
    required this.onToggle,
    required this.onAdd,
    required this.xpTrackingEnabled,
    required this.isPendingLevelUp,
    required this.onLevelUpTap,
    required this.l10n,
    required this.scheme,
  });

  final int xp;
  final int characterLevel;
  final TextEditingController xpAddCtrl;
  final bool expanded;
  final VoidCallback onToggle;
  final void Function(int) onAdd;
  final bool xpTrackingEnabled;
  final bool isPendingLevelUp;
  final VoidCallback onLevelUpTap;
  final AppLocalizations l10n;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    // Use characterLevel as source of truth — XP and level may diverge when
    // tracking is disabled.
    final level = characterLevel;
    final isMax = level >= 20;
    final prevXp = kXpThresholds[level - 1];
    final nextXp = isMax ? kXpThresholds.last : kXpThresholds[level];
    final progress = isMax
        ? 1.0
        : ((xp - prevXp) / (nextXp - prevXp).toDouble()).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Level + XP row
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              l10n.statLevel(level),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '$xp',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Text(
              l10n.statXP,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: scheme.surfaceContainerHigh,
            color: scheme.primary,
          ),
        ),
        if (!isMax) ...[
          const SizedBox(height: 4),
          Text(
            '${nextXp - xp} ${l10n.statXP} → ${l10n.statLevel(level + 1)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
        // Pending level-up CTA
        if (isPendingLevelUp) ...[
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onLevelUpTap,
            icon: const Icon(Icons.upgrade),
            label: Text(l10n.xpReadyToLevelUp),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
          ),
        ],
        // Quick-add XP row (hidden while pending)
        if (!isPendingLevelUp) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton.outlined(
                icon: const Icon(Icons.remove, size: 16),
                style: IconButton.styleFrom(
                  minimumSize: const Size(32, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  final v = int.tryParse(xpAddCtrl.text) ?? 0;
                  xpAddCtrl.text = '${(v - 1).clamp(0, 999999)}';
                },
              ),
              Expanded(
                child: TextField(
                  controller: xpAddCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              IconButton.outlined(
                icon: const Icon(Icons.add, size: 16),
                style: IconButton.styleFrom(
                  minimumSize: const Size(32, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  final v = int.tryParse(xpAddCtrl.text) ?? 0;
                  xpAddCtrl.text = '${v + 1}';
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () {
                    final amount = int.tryParse(xpAddCtrl.text) ?? 0;
                    if (amount > 0) {
                      onAdd(amount);
                    }
                  },
                  child: Text(l10n.tooltipAddXp),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        // Level table toggle
        TextButton.icon(
          icon: Icon(
            expanded ? Icons.expand_less : Icons.expand_more,
            size: 18,
          ),
          label: Text(l10n.labelLevelTable),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 32),
            foregroundColor: scheme.onSurfaceVariant,
          ),
          onPressed: onToggle,
        ),
        if (expanded) ...[
          const SizedBox(height: 8),
          ...List.generate(20, (i) {
            final lvl = i + 1;
            final threshold = kXpThresholds[i];
            final isCurrent = level == lvl;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      l10n.statLevel(lvl),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isCurrent ? scheme.primary : null,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '$threshold ${l10n.statXP}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isCurrent
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Icon(Icons.arrow_left, size: 16, color: scheme.primary),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}

// ── Active Conditions section ─────────────────────────────────────────────────

class _ConditionsSection extends StatelessWidget {
  const _ConditionsSection({
    required this.activeConditions,
    required this.i18n,
    required this.onToggle,
    required this.allConditions,
  });

  final List<String> activeConditions;
  final SrdI18nService i18n;
  final void Function(String name) onToggle;
  final List<({String name, String description})> allConditions;

  void _showPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ConditionPickerSheet(
        allConditions: allConditions,
        activeConditions: activeConditions,
        i18n: i18n,
        onToggle: onToggle,
        title: l10n.conditionsPickTitle,
      ),
    );
  }

  void _showDetail(BuildContext context, String name, String enDescription) {
    final l10n = AppLocalizations.of(context)!;
    final translated = i18n.conditionDescription(name);
    final description = translated ?? enDescription;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        i18n.conditionName(name),
                        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          color: scheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(description),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.remove_circle_outline, size: 16),
                    label: Text(l10n.conditionsRemove),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.error,
                    ),
                    onPressed: () {
                      onToggle(name);
                      Navigator.pop(ctx);
                    },
                  ),
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
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    // Build a lookup for English descriptions
    final descMap = {for (final c in allConditions) c.name: c.description};

    return DetailSection(
      title: l10n.sectionActiveConditions,
      action: IconButton(
        icon: const Icon(Icons.add, size: 20),
        tooltip: l10n.conditionsAdd,
        visualDensity: VisualDensity.compact,
        onPressed: () => _showPicker(context),
      ),
      child: activeConditions.isEmpty
          ? Text(
              l10n.conditionsNone,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 4,
              children: activeConditions.map((name) {
                return InputChip(
                  label: Text(i18n.conditionName(name)),
                  backgroundColor: scheme.errorContainer,
                  labelStyle: TextStyle(color: scheme.onErrorContainer),
                  deleteIconColor: scheme.onErrorContainer,
                  onPressed: () =>
                      _showDetail(context, name, descMap[name] ?? ''),
                  onDeleted: () => onToggle(name),
                );
              }).toList(),
            ),
    );
  }
}

class _ConditionPickerSheet extends StatefulWidget {
  const _ConditionPickerSheet({
    required this.allConditions,
    required this.activeConditions,
    required this.i18n,
    required this.onToggle,
    required this.title,
  });

  final List<({String name, String description})> allConditions;
  final List<String> activeConditions;
  final SrdI18nService i18n;
  final void Function(String name) onToggle;
  final String title;

  @override
  State<_ConditionPickerSheet> createState() => _ConditionPickerSheetState();
}

class _ConditionPickerSheetState extends State<_ConditionPickerSheet> {
  late final Set<String> _active;

  @override
  void initState() {
    super.initState();
    _active = Set.from(widget.activeConditions);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.allConditions.map((c) {
                final isActive = _active.contains(c.name);
                return FilterChip(
                  label: Text(widget.i18n.conditionName(c.name)),
                  selected: isActive,
                  selectedColor: scheme.errorContainer,
                  checkmarkColor: scheme.onErrorContainer,
                  labelStyle: TextStyle(
                    color: isActive
                        ? scheme.onErrorContainer
                        : scheme.onSurface,
                  ),
                  onSelected: (_) {
                    setState(() {
                      if (isActive) {
                        _active.remove(c.name);
                      } else {
                        _active.add(c.name);
                      }
                    });
                    widget.onToggle(c.name);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.dialogDone),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Saving Throws list (view mode) ────────────────────────────────────────────

class _SavingThrowsList extends StatelessWidget {
  const _SavingThrowsList({
    required this.character,
    required this.l10n,
    this.notifier,
  });
  final Character character;
  final AppLocalizations l10n;
  final CharacterDetailNotifier? notifier;

  void _toggle(BuildContext context, String key) {
    final current = List<String>.from(character.savingThrowProficiencies);
    final lower = key.toLowerCase();
    if (current.any((s) => s.toLowerCase() == lower)) {
      current.removeWhere((s) => s.toLowerCase() == lower);
    } else {
      current.add(key);
    }
    notifier!.updateSavingThrows(current);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isEditing = notifier != null;
    final profSet = character.savingThrowProficiencies
        .map((s) => s.toLowerCase())
        .toSet();
    final abilities = [
      ('strength', l10n.abilityStr, character.abilityScores.strengthModifier),
      ('dexterity', l10n.abilityDex, character.abilityScores.dexterityModifier),
      (
        'constitution',
        l10n.abilityCon,
        character.abilityScores.constitutionModifier,
      ),
      (
        'intelligence',
        l10n.abilityInt,
        character.abilityScores.intelligenceModifier,
      ),
      ('wisdom', l10n.abilityWis, character.abilityScores.wisdomModifier),
      ('charisma', l10n.abilityCha, character.abilityScores.charismaModifier),
    ];
    return Column(
      children: abilities.map((entry) {
        final (key, abbr, abilityMod) = entry;
        final isProf = profSet.contains(key);
        final bonus = abilityMod + (isProf ? character.proficiencyBonus : 0);
        final row = Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(
                isProf ? Icons.circle : Icons.circle_outlined,
                size: 10,
                color: isProf ? scheme.primary : scheme.outlineVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  abbr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isProf ? FontWeight.bold : FontWeight.normal,
                    color: isProf ? scheme.onSurface : scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                sign(bonus),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isProf ? FontWeight.bold : FontWeight.normal,
                  color: isProf ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
        if (!isEditing) return row;
        return InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => _toggle(context, key),
          child: row,
        );
      }).toList(),
    );
  }
}

// ── Death saves row ───────────────────────────────────────────────────────────

class _DeathSavesRow extends StatelessWidget {
  const _DeathSavesRow({
    required this.successes,
    required this.failures,
    required this.onChanged,
  });

  final int successes;
  final int failures;
  final void Function(int successes, int failures) onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isStabilized = successes >= 3;
    final characterDied = failures >= 3;
    const successColor = Color(0xFF43A047);

    Widget buildCircles({
      required int filled,
      required Color filledColor,
      required void Function(int index) onTap,
    }) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final isFilled = i < filled;
          return GestureDetector(
            onTap: () => onTap(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              child: Icon(
                isFilled ? Icons.circle : Icons.radio_button_unchecked,
                color: isFilled ? filledColor : scheme.outlineVariant,
                size: 26,
              ),
            ),
          );
        }),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 20),
        Text(
          l10n.deathSavesTitle,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        // Successes
        Row(
          children: [
            SizedBox(
              width: 84,
              child: Text(
                l10n.deathSavesSuccesses,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            buildCircles(
              filled: successes,
              filledColor: successColor,
              onTap: (i) {
                final newVal = (i + 1 == successes) ? i : i + 1;
                onChanged(newVal, failures);
              },
            ),
            if (isStabilized) ...[
              const SizedBox(width: 6),
              Text(
                l10n.deathSavesStabilized,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: successColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        // Failures
        Row(
          children: [
            SizedBox(
              width: 84,
              child: Text(
                l10n.deathSavesFailures,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            buildCircles(
              filled: failures,
              filledColor: scheme.error,
              onTap: (i) {
                final newVal = (i + 1 == failures) ? i : i + 1;
                onChanged(successes, newVal);
              },
            ),
            if (characterDied) ...[
              const SizedBox(width: 6),
              Text(
                l10n.deathSavesDead,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ── Inspiration banner ────────────────────────────────────────────────────────

class _InspirationBanner extends StatelessWidget {
  const _InspirationBanner({
    required this.active,
    required this.onTap,
    required this.label,
    required this.activeSubtitle,
    required this.inactiveSubtitle,
  });

  final bool active;
  final VoidCallback onTap;
  final String label;
  final String activeSubtitle;
  final String inactiveSubtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: active ? scheme.tertiaryContainer : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: active
                      ? scheme.tertiary.withValues(alpha: 0.2)
                      : scheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  active ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                  color: active ? scheme.tertiary : scheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: active
                            ? scheme.onTertiaryContainer
                            : scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      active ? activeSubtitle : inactiveSubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: active
                            ? scheme.onTertiaryContainer.withValues(alpha: 0.8)
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  active ? Icons.check_circle_rounded : Icons.circle_outlined,
                  key: ValueKey(active),
                  color: active ? scheme.tertiary : scheme.outlineVariant,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
