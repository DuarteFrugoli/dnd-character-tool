part of '../character_detail_screen.dart';

// ── Stats Tab ─────────────────────────────────────────────────────────────────

class _StatsTab extends ConsumerStatefulWidget {
  const _StatsTab({
    required this.character,
    required this.characterId,
  });
  final Character character;
  final String characterId;

  @override
  ConsumerState<_StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends ConsumerState<_StatsTab> {
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

  CharacterDetailNotifier get _notifier =>
      ref.read(characterDetailProvider(widget.characterId).notifier);

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _snapshot = widget.character;
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
    FocusScope.of(context).unfocus();
    final snap = _snapshot;
    if (snap != null) {
      await _notifier.revertTo(snap);
    }
    if (!mounted) return;
    setState(() {
      _isEditing = false;
      _snapshot = null;
    });
  }

  void _saveEditing() {
    FocusScope.of(context).unfocus();
    final hpMax = int.tryParse(_hpMaxCtrl.text);
    if (hpMax != null) _notifier.updateHpMax(hpMax);
    final speed = int.tryParse(_speedCtrl.text);
    if (speed != null) _notifier.updateSpeed(speed);
    final xp = int.tryParse(_xpCtrl.text);
    if (xp != null) _notifier.updateExperiencePoints(xp);
    setState(() {
      _isEditing = false;
      _snapshot = null;
    });
  }

  @override
  void initState() {
    super.initState();
    final c = widget.character;
    _hpMaxCtrl = TextEditingController(text: '${c.hitPoints.maximum}');
    _speedCtrl = TextEditingController(text: '${c.speed}');
    _xpCtrl = TextEditingController(text: '${c.experiencePoints}');

    _hpMaxFocus.addListener(() {
      if (!_hpMaxFocus.hasFocus && _isEditing) {
        final v = int.tryParse(_hpMaxCtrl.text);
        if (v != null) _notifier.updateHpMax(v);
      }
    });
    _speedFocus.addListener(() {
      if (!_speedFocus.hasFocus && _isEditing) {
        final v = int.tryParse(_speedCtrl.text);
        if (v != null) _notifier.updateSpeed(v);
      }
    });
    _xpFocus.addListener(() {
      if (!_xpFocus.hasFocus && _isEditing) {
        final v = int.tryParse(_xpCtrl.text);
        if (v != null) _notifier.updateExperiencePoints(v);
      }
    });
  }

  @override
  void didUpdateWidget(_StatsTab old) {
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
    _hpMaxFocus.dispose();
    _speedFocus.dispose();
    _xpFocus.dispose();
    super.dispose();
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 192),
          children: [
          // ── HP Tracker ────────────────────────────────────────────────────
          _Section(
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
                        label: Text('+${hp.temporary} temp'),
                        backgroundColor: scheme.tertiaryContainer,
                        labelStyle: TextStyle(
                          color: scheme.onTertiaryContainer,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      const SizedBox(width: 4),
                    ],
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton.filledTonal(
                        icon: const Icon(Icons.shield_outlined, size: 16),
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
                    Expanded(
                      flex: 2,
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
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.errorContainer,
                          foregroundColor: scheme.onErrorContainer,
                        ),
                        onPressed: () {
                          final n = int.tryParse(_amountCtrl.text) ?? 0;
                          if (n > 0) {
                            ref
                                .read(
                                  characterDetailProvider(
                                    widget.characterId,
                                  ).notifier,
                                )
                                .adjustHp(-n);
                          }
                        },
                        child: Text(l10n.detailDamage),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.primaryContainer,
                          foregroundColor: scheme.onPrimaryContainer,
                        ),
                        onPressed: () {
                          final n = int.tryParse(_amountCtrl.text) ?? 0;
                          if (n > 0) {
                            ref
                                .read(
                                  characterDetailProvider(
                                    widget.characterId,
                                  ).notifier,
                                )
                                .adjustHp(n);
                          }
                        },
                        child: Text(l10n.detailHeal),
                      ),
                    ),
                  ],
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 12),
                  _InlineField(
                    label: l10n.labelMaxHP,
                    controller: _hpMaxCtrl,
                    focusNode: _hpMaxFocus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Inspiration ───────────────────────────────────────────────────
          _InspirationBanner(
            active: character.inspiration,
            onTap: () => notifier.toggleInspiration(),
            label: l10n.statInspiration,
            activeSubtitle: l10n.inspirationGranted,
            inactiveSubtitle: l10n.inspirationNotGranted,
          ),
          const SizedBox(height: 12),

          // ── Combat Stats ──────────────────────────────────────────────────
          _Section(
            title: l10n.sectionCombat,
            child: _isEditing
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InlineField(
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
                          _StatChip(l10n.statAC, '${character.armorClass}'),
                          _StatChip(l10n.statArmor, armorSummary),
                          _StatChip(
                            l10n.statInitiative,
                            _sign(character.initiative),
                          ),
                          _StatChip(
                            l10n.statProfBonus,
                            _sign(character.proficiencyBonus),
                          ),
                          _StatChip(
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
                      _StatChip(l10n.statAC, '${character.armorClass}'),
                      _StatChip(l10n.statArmor, armorSummary),
                      _StatChip(l10n.statSpeed, '${character.speed} ft'),
                      _StatChip(
                        l10n.statInitiative,
                        _sign(character.initiative),
                      ),
                      _StatChip(
                        l10n.statProfBonus,
                        _sign(character.proficiencyBonus),
                      ),
                      _StatChip(
                        l10n.statPassivePerc,
                        '${character.passivePerception}',
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),

          // ── Ability Scores ────────────────────────────────────────────────
          _Section(
            title: l10n.sectionAbilityScores,
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: _isEditing ? 0.75 : 1.2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _AbilityCardEdit(
                  l10n.abilityStr,
                  character.abilityScores.strength,
                  'strength',
                  notifier: notifier,
                  isEditing: _isEditing,
                ),
                _AbilityCardEdit(
                  l10n.abilityDex,
                  character.abilityScores.dexterity,
                  'dexterity',
                  notifier: notifier,
                  isEditing: _isEditing,
                ),
                _AbilityCardEdit(
                  l10n.abilityCon,
                  character.abilityScores.constitution,
                  'constitution',
                  notifier: notifier,
                  isEditing: _isEditing,
                ),
                _AbilityCardEdit(
                  l10n.abilityInt,
                  character.abilityScores.intelligence,
                  'intelligence',
                  notifier: notifier,
                  isEditing: _isEditing,
                ),
                _AbilityCardEdit(
                  l10n.abilityWis,
                  character.abilityScores.wisdom,
                  'wisdom',
                  notifier: notifier,
                  isEditing: _isEditing,
                ),
                _AbilityCardEdit(
                  l10n.abilityCha,
                  character.abilityScores.charisma,
                  'charisma',
                  notifier: notifier,
                  isEditing: _isEditing,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Saving Throws ─────────────────────────────────────────────────
          _Section(
            title: l10n.sectionSavingThrows,
            child: _isEditing
                ? _SavingThrowsEditor(
                    current: character.savingThrowProficiencies,
                    notifier: notifier,
                  )
                : character.savingThrowProficiencies.isEmpty
                ? Text(l10n.detailNone)
                : Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: character.savingThrowProficiencies.map((s) {
                      final label =
                          {
                            'strength': l10n.abilityStr,
                            'dexterity': l10n.abilityDex,
                            'constitution': l10n.abilityCon,
                            'intelligence': l10n.abilityInt,
                            'wisdom': l10n.abilityWis,
                            'charisma': l10n.abilityCha,
                          }[s.toLowerCase()] ??
                          s;
                      return Chip(label: Text(label));
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 12),

          // ── Progression ───────────────────────────────────────────────────
          _Section(
            title: l10n.sectionProgression,
            child: _isEditing
                ? _InlineField(
                    label: l10n.statXP,
                    controller: _xpCtrl,
                    focusNode: _xpFocus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${character.experiencePoints}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.statXP,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
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
                                ? scheme.onTertiaryContainer
                                    .withValues(alpha: 0.8)
                                : scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  active
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
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
