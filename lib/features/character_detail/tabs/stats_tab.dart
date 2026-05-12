part of '../character_detail_screen.dart';

// ── Stats Tab ─────────────────────────────────────────────────────────────────

class _StatsTab extends ConsumerStatefulWidget {
  const _StatsTab({
    required this.character,
    required this.characterId,
    required this.isEditing,
  });
  final Character character;
  final String characterId;
  final bool isEditing;

  @override
  ConsumerState<_StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends ConsumerState<_StatsTab> {
  // HP tracker
  final _amountCtrl = TextEditingController(text: '1');

  // Edit mode controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _alignCtrl;
  late final TextEditingController _playerCtrl;
  late final TextEditingController _hpMaxCtrl;
  late final TextEditingController _speedCtrl;
  final TextEditingController _langCtrl = TextEditingController();

  // Focus nodes
  final _nameFocus = FocusNode();
  final _alignFocus = FocusNode();
  final _playerFocus = FocusNode();
  final _hpMaxFocus = FocusNode();
  final _speedFocus = FocusNode();
  final _langFocus = FocusNode();

  CharacterDetailNotifier get _notifier =>
      ref.read(characterDetailProvider(widget.characterId).notifier);

  Future<void> _onLevelUp(Character character) async {
    final newLevel = character.level + 1;

    // Load class data to check subclass threshold
    final srd = ref.read(srdDataSourceProvider);
    final classes = await srd.getClasses();
    final srdClass = classes.where((c) => c.name == character.characterClass).firstOrNull;

    // No subclasses or not crossing the threshold — just level up
    if (srdClass == null ||
        srdClass.subclasses.isEmpty ||
        newLevel != srdClass.subclassLevel) {
      await _notifier.updateLevel(newLevel);
      return;
    }

    if (!mounted) return;

    // Already has a subclass → confirm + option to change
    if (character.subclass != null && character.subclass!.isNotEmpty) {
      final picked = await _showSubclassDialog(
        context: context,
        srdClass: srdClass,
        current: character.subclass,
        isConfirm: true,
      );
      if (!mounted) return;
      if (picked != null) await _notifier.updateSubclass(picked);
      await _notifier.updateLevel(newLevel);
      return;
    }

    // No subclass yet → must pick one
    final picked = await _showSubclassDialog(
      context: context,
      srdClass: srdClass,
      current: null,
      isConfirm: false,
    );
    if (!mounted) return;
    if (picked != null) await _notifier.updateSubclass(picked);
    await _notifier.updateLevel(newLevel);
  }

  Future<String?> _showSubclassDialog({
    required BuildContext context,
    required SrdClass srdClass,
    required String? current,
    required bool isConfirm,
  }) {
    final l10n = AppLocalizations.of(context)!;
    String? selected = current;
    return showDialog<String>(
      context: context,
      barrierDismissible: isConfirm,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(isConfirm
                ? l10n.subclassConfirmTitle(srdClass.subclassFeatureName)
                : l10n.subclassChooseTitle(srdClass.subclassFeatureName)),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isConfirm)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        l10n.subclassConfirmBody(srdClass.subclassLevel, srdClass.subclassFeatureName),
                        style: Theme.of(ctx).textTheme.bodySmall,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        l10n.subclassChooseBody(srdClass.subclassLevel, srdClass.subclassFeatureName),
                        style: Theme.of(ctx).textTheme.bodySmall,
                      ),
                    ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: RadioGroup<String>(
                        groupValue: selected,
                        onChanged: (v) => setDialogState(() => selected = v),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: srdClass.subclasses
                              .map((sub) => RadioListTile<String>(
                                    title: Text(sub.name),
                                    subtitle: sub.description.isNotEmpty
                                        ? Text(sub.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(ctx).textTheme.bodySmall)
                                        : null,
                                    value: sub.name,
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (isConfirm)
                TextButton(
                  onPressed: () => Navigator.pop(ctx, current),
                  child: Text(AppLocalizations.of(ctx)!.subclassKeepCurrent),
                ),
              FilledButton(
                onPressed: selected != null
                    ? () => Navigator.pop(ctx, selected)
                    : null,
                child: Text(AppLocalizations.of(ctx)!.dialogConfirm),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _onChangeSubclass(Character character) async {
    final srd = ref.read(srdDataSourceProvider);
    final classes = await srd.getClasses();
    final srdClass =
        classes.where((c) => c.name == character.characterClass).firstOrNull;
    if (srdClass == null || srdClass.subclasses.isEmpty || !mounted) return;

    // Warn user if they already have a subclass
    if (character.subclass != null && character.subclass!.isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.subclassChangeTitle),
          content: Text(AppLocalizations.of(context)!.subclassChangeWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(ctx)!.dialogCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLocalizations.of(ctx)!.dialogContinue),
            ),
          ],
        ),
      );
      if (confirm != true || !mounted) return;
    }

    final picked = await _showSubclassDialog(
      context: context,
      srdClass: srdClass,
      current: character.subclass,
      isConfirm: character.subclass != null,
    );
    if (picked != null && picked != character.subclass) {
      await _notifier.updateSubclass(picked);
    }
  }

  @override
  void initState() {
    super.initState();
    final c = widget.character;
    _nameCtrl = TextEditingController(text: c.name);
    _alignCtrl = TextEditingController(text: c.alignment);
    _playerCtrl = TextEditingController(text: c.playerName);
    _hpMaxCtrl = TextEditingController(text: '${c.hitPoints.maximum}');
    _speedCtrl = TextEditingController(text: '${c.speed}');

    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus) _notifier.updateName(_nameCtrl.text);
    });
    _alignFocus.addListener(() {
      if (!_alignFocus.hasFocus) _notifier.updateAlignment(_alignCtrl.text);
    });
    _playerFocus.addListener(() {
      if (!_playerFocus.hasFocus) _notifier.updatePlayerName(_playerCtrl.text);
    });
    _hpMaxFocus.addListener(() {
      if (!_hpMaxFocus.hasFocus) {
        final v = int.tryParse(_hpMaxCtrl.text);
        if (v != null) _notifier.updateHpMax(v);
      }
    });
    _speedFocus.addListener(() {
      if (!_speedFocus.hasFocus) {
        final v = int.tryParse(_speedCtrl.text);
        if (v != null) _notifier.updateSpeed(v);
      }
    });
  }

  @override
  void didUpdateWidget(_StatsTab old) {
    super.didUpdateWidget(old);
    final c = widget.character;
    if (!_nameFocus.hasFocus) _nameCtrl.text = c.name;
    if (!_alignFocus.hasFocus) _alignCtrl.text = c.alignment;
    if (!_playerFocus.hasFocus) _playerCtrl.text = c.playerName;
    if (!_hpMaxFocus.hasFocus) _hpMaxCtrl.text = '${c.hitPoints.maximum}';
    if (!_speedFocus.hasFocus) _speedCtrl.text = '${c.speed}';
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    _alignCtrl.dispose();
    _playerCtrl.dispose();
    _hpMaxCtrl.dispose();
    _speedCtrl.dispose();
    _langCtrl.dispose();
    _nameFocus.dispose();
    _alignFocus.dispose();
    _playerFocus.dispose();
    _hpMaxFocus.dispose();
    _speedFocus.dispose();
    _langFocus.dispose();
    super.dispose();
  }

  Future<void> _showBackgroundDialog(Character character) async {
    final backgrounds = await SrdDataSource.instance.getBackgrounds();
    if (!mounted) return;
    String? selected = character.background;
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.backgroundChooseTitle),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: RadioGroup<String>(
              groupValue: selected,
              onChanged: (v) => setDialogState(() => selected = v),
              child: ListView(
                children: backgrounds
                    .map((bg) => RadioListTile<String>(
                          title: Text(bg.name),
                          value: bg.name,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ))
                    .toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(ctx)!.dialogCancel),
            ),
            FilledButton(
              onPressed: selected != null
                  ? () => Navigator.pop(ctx, selected)
                  : null,
              child: Text(AppLocalizations.of(ctx)!.dialogConfirm),
            ),
          ],
        ),
      ),
    );
    if (picked != null && picked != character.background) {
      _notifier.updateBackground(picked);
    }
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
          final isValid = parsed != null &&
              parsed > 0 &&
              (currentTemp == 0 || parsed > currentTemp);
          return AlertDialog(
            title: Text(currentTemp > 0
              ? AppLocalizations.of(context)!.tempHpDialogTitleReplace
              : AppLocalizations.of(context)!.tempHpDialogTitle),
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
                    if (n != null && n > 0 && (currentTemp == 0 || n > currentTemp)) {
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
                child: Text(currentTemp > 0
                    ? AppLocalizations.of(ctx)!.tempHpReplace
                    : AppLocalizations.of(ctx)!.dialogAdd),
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
    final i18n = ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final character = widget.character;
    final isEditing = widget.isEditing;
    final hp = character.hitPoints;
    final isDead = hp.isDead;
    final isFull = hp.current >= hp.maximum;
    final scheme = Theme.of(context).colorScheme;
    final notifier = _notifier;
    final equippedArmor = character.equipment
        .where((e) => e.itemType == ItemType.armor && e.isEquipped)
        .toList();
    final bodyArmor =
        equippedArmor.where((e) => e.properties?['isShield'] != true).toList();
    final usingShield =
        equippedArmor.any((e) => e.properties?['isShield'] == true);
    final armorSummary = bodyArmor.isEmpty
        ? (usingShield ? l10n.statNoArmorShield : l10n.statNoArmor)
        : '${i18n.equipmentName(bodyArmor.first.name)}${usingShield ? l10n.statShieldSuffix : ''}';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 192),
        children: [
          // ── Identity ──────────────────────────────────────────────────────
          _Section(
          title: l10n.sectionIdentity,
          child: isEditing
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InlineField(
                        label: l10n.labelName,
                        controller: _nameCtrl,
                        focusNode: _nameFocus),
                    // Background — picker, not free text
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 96,
                            child: Text(
                              l10n.labelBackground,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              character.background.isNotEmpty
                                  ? character.background
                                  : '—',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.swap_horiz, size: 16),
                            label: Text(l10n.labelChange),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () => _showBackgroundDialog(character),
                          ),
                        ],
                      ),
                    ),
                    _InlineField(
                        label: l10n.labelAlignment,
                        controller: _alignCtrl,
                        focusNode: _alignFocus),
                    _InlineField(
                        label: l10n.labelPlayer,
                        controller: _playerCtrl,
                        focusNode: _playerFocus),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 96,
                            child: Text(
                              l10n.labelLevel,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 32, minHeight: 32),
                            onPressed: character.level > 1
                                ? () => notifier
                                    .updateLevel(character.level - 1)
                                : null,
                          ),
                          SizedBox(
                            width: 40,
                            child: Text(
                              '${character.level}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 32, minHeight: 32),
                            onPressed: character.level < 20
                                ? () => _onLevelUp(character)
                                : null,
                          ),
                        ],
                      ),
                    ),
                    // Subclass row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 96,
                            child: Text(
                              l10n.labelSubclass,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              character.subclass?.isNotEmpty == true
                                  ? character.subclass!
                                  : '—',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.swap_horiz, size: 16),
                            label: Text(character.subclass?.isNotEmpty == true
                                ? l10n.labelChange
                                : l10n.labelChoose),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () => _onChangeSubclass(character),
                          ),
                        ],
                      ),
                    ),
                    // Languages chips
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 96,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                l10n.labelLanguages,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: scheme.onSurfaceVariant),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (character.languages.isNotEmpty)
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: character.languages
                                        .map((lang) => Chip(
                                              label: Text(i18n.languageName(lang)),
                                              labelStyle: const TextStyle(
                                                  fontSize: 12),
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4),
                                              onDeleted: () {
                                                final updated = List<
                                                    String>.from(
                                                  character.languages,
                                                )..remove(lang);
                                                notifier
                                                    .updateLanguages(updated);
                                              },
                                            ))
                                        .toList(),
                                  ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _langCtrl,
                                        focusNode: _langFocus,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintText: l10n.hintAddLanguage,
                                          border: const OutlineInputBorder(),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 8),
                                        ),
                                        onSubmitted: (v) {
                                          final s = v.trim();
                                          if (s.isNotEmpty &&
                                              !character.languages.contains(
                                                  s)) {
                                            notifier.updateLanguages([
                                              ...character.languages,
                                              s,
                                            ]);
                                          }
                                          _langCtrl.clear();
                                          _langFocus.requestFocus();
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton.filled(
                                      icon: const Icon(Icons.add, size: 18),
                                      tooltip: l10n.dialogAdd,
                                      onPressed: () {
                                        final s = _langCtrl.text.trim();
                                        if (s.isNotEmpty &&
                                            !character.languages
                                                .contains(s)) {
                                          notifier.updateLanguages([
                                            ...character.languages,
                                            s,
                                          ]);
                                        }
                                        _langCtrl.clear();
                                        _langFocus.requestFocus();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    if (character.background.isNotEmpty)
                      _InfoRow(l10n.labelBackground, i18n.backgroundName(character.background)),
                    if (character.alignment.isNotEmpty)
                      _InfoRow(l10n.labelAlignment, character.alignment),
                    if (character.playerName.isNotEmpty)
                      _InfoRow(l10n.labelPlayer, character.playerName),
                    _InfoRow(
                      l10n.labelLanguages,
                      character.languages.isEmpty
                          ? '—'
                          : character.languages.map((l) => i18n.languageName(l)).join(', '),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 12),

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
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
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
                      labelStyle: TextStyle(color: scheme.onTertiaryContainer),
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
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                              .read(characterDetailProvider(widget.characterId)
                                  .notifier)
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
                              .read(characterDetailProvider(widget.characterId)
                                  .notifier)
                              .adjustHp(n);
                        }
                      },
                      child: Text(l10n.detailHeal),
                    ),
                  ),
                ],
              ),
              if (isEditing) ...[
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

        // ── Combat Stats ──────────────────────────────────────────────────
        _Section(
          title: l10n.sectionCombat,
          child: isEditing
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InlineField(
                      label: l10n.labelSpeed,
                      controller: _speedCtrl,
                      focusNode: _speedFocus,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
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
                            l10n.statInitiative, _sign(character.initiative)),
                        _StatChip(l10n.statProfBonus,
                            _sign(character.proficiencyBonus)),
                        _StatChip(l10n.statPassivePerc,
                            '${character.passivePerception}'),
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
                    _StatChip(l10n.statInitiative, _sign(character.initiative)),
                    _StatChip(
                        l10n.statProfBonus, _sign(character.proficiencyBonus)),
                    _StatChip(
                        l10n.statPassivePerc, '${character.passivePerception}'),
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
            childAspectRatio: isEditing ? 0.75 : 1.2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _AbilityCardEdit(l10n.abilityStr, character.abilityScores.strength,
                  'strength', notifier: notifier, isEditing: isEditing),
              _AbilityCardEdit(l10n.abilityDex, character.abilityScores.dexterity,
                  'dexterity', notifier: notifier, isEditing: isEditing),
              _AbilityCardEdit(l10n.abilityCon, character.abilityScores.constitution,
                  'constitution', notifier: notifier, isEditing: isEditing),
              _AbilityCardEdit(l10n.abilityInt, character.abilityScores.intelligence,
                  'intelligence', notifier: notifier, isEditing: isEditing),
              _AbilityCardEdit(l10n.abilityWis, character.abilityScores.wisdom,
                  'wisdom', notifier: notifier, isEditing: isEditing),
              _AbilityCardEdit(l10n.abilityCha, character.abilityScores.charisma,
                  'charisma', notifier: notifier, isEditing: isEditing),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Saving Throws ─────────────────────────────────────────────────
        _Section(
          title: l10n.sectionSavingThrows,
          child: isEditing
              ? _SavingThrowsEditor(
                  current: character.savingThrowProficiencies,
                  notifier: notifier,
                )
              : character.savingThrowProficiencies.isEmpty
                  ? Text(l10n.detailNone)
                  : Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: character.savingThrowProficiencies
                          .map((s) => Chip(label: Text(s)))
                          .toList(),
                    ),
        ),
      ],
      ),
    );
  }
}
