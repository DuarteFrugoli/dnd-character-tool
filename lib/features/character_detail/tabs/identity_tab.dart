import '../character_detail_dependencies.dart';
import '../../../shared/utils/character_display.dart';

// ── Identity Tab ──────────────────────────────────────────────────────────────

class IdentityTab extends ConsumerStatefulWidget {
  const IdentityTab({
    super.key,
    required this.character,
    required this.characterId,
    required this.editGuard,
  });
  final Character character;
  final String characterId;
  final EditGuard editGuard;

  @override
  ConsumerState<IdentityTab> createState() => _IdentityTabState();
}

class _IdentityTabState extends ConsumerState<IdentityTab> {
  bool _isEditing = false;
  Character? _snapshot;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _alignCtrl;
  late final TextEditingController _playerCtrl;
  final TextEditingController _langCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _alignFocus = FocusNode();
  final _playerFocus = FocusNode();
  final _langFocus = FocusNode();

  late final TextEditingController _ageCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _eyesCtrl;
  late final TextEditingController _skinCtrl;
  late final TextEditingController _hairCtrl;
  final _ageFocus = FocusNode();
  final _heightFocus = FocusNode();
  final _weightFocus = FocusNode();
  final _eyesFocus = FocusNode();
  final _skinFocus = FocusNode();
  final _hairFocus = FocusNode();

  late final TextEditingController _traitsCtrl;
  late final TextEditingController _idealsCtrl;
  late final TextEditingController _bondsCtrl;
  late final TextEditingController _flawsCtrl;
  late final TextEditingController _backstoryCtrl;
  final _traitsFocus = FocusNode();
  final _idealsFocus = FocusNode();
  final _bondsFocus = FocusNode();
  final _flawsFocus = FocusNode();
  final _backstoryFocus = FocusNode();

  CharacterDetailNotifier get _notifier =>
      ref.read(characterDetailProvider(widget.characterId).notifier);

  @override
  void initState() {
    super.initState();
    final c = widget.character;
    _nameCtrl = TextEditingController(text: c.name);
    _alignCtrl = TextEditingController(text: c.alignment);
    _playerCtrl = TextEditingController(text: c.playerName);
    final app = c.appearance;
    _ageCtrl = TextEditingController(text: app.age ?? '');
    _heightCtrl = TextEditingController(text: app.height);
    _weightCtrl = TextEditingController(text: app.weight);
    _eyesCtrl = TextEditingController(text: app.eyes);
    _skinCtrl = TextEditingController(text: app.skin);
    _hairCtrl = TextEditingController(text: app.hair);

    final p = c.personality;
    _traitsCtrl = TextEditingController(text: p.traits);
    _idealsCtrl = TextEditingController(text: p.ideals);
    _bondsCtrl = TextEditingController(text: p.bonds);
    _flawsCtrl = TextEditingController(text: p.flaws);
    _backstoryCtrl = TextEditingController(text: c.backstory);

    _ageFocus.addListener(() {
      if (!_ageFocus.hasFocus && _isEditing) {
        _notifier.updateAppearance(_buildCurrentAppearance());
      }
    });
    _heightFocus.addListener(() {
      if (!_heightFocus.hasFocus && _isEditing) {
        _notifier.updateAppearance(_buildCurrentAppearance());
      }
    });
    _weightFocus.addListener(() {
      if (!_weightFocus.hasFocus && _isEditing) {
        _notifier.updateAppearance(_buildCurrentAppearance());
      }
    });
    _eyesFocus.addListener(() {
      if (!_eyesFocus.hasFocus && _isEditing) {
        _notifier.updateAppearance(_buildCurrentAppearance());
      }
    });
    _skinFocus.addListener(() {
      if (!_skinFocus.hasFocus && _isEditing) {
        _notifier.updateAppearance(_buildCurrentAppearance());
      }
    });
    _hairFocus.addListener(() {
      if (!_hairFocus.hasFocus && _isEditing) {
        _notifier.updateAppearance(_buildCurrentAppearance());
      }
    });

    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus && _isEditing) {
        final fallback = AppLocalizations.of(context)!.reviewUnnamedHero;
        _notifier.updateName(_nameCtrl.text, fallback: fallback);
      }
    });
    _alignFocus.addListener(() {
      if (!_alignFocus.hasFocus && _isEditing) {
        _notifier.updateAlignment(_alignCtrl.text);
      }
    });
    _playerFocus.addListener(() {
      if (!_playerFocus.hasFocus && _isEditing) {
        _notifier.updatePlayerName(_playerCtrl.text);
      }
    });
  }

  @override
  void didUpdateWidget(IdentityTab old) {
    super.didUpdateWidget(old);
    final c = widget.character;
    if (!_nameFocus.hasFocus) _nameCtrl.text = c.name;
    if (!_alignFocus.hasFocus) _alignCtrl.text = c.alignment;
    if (!_playerFocus.hasFocus) _playerCtrl.text = c.playerName;
    final app = c.appearance;
    if (!_ageFocus.hasFocus) _ageCtrl.text = app.age ?? '';
    if (!_heightFocus.hasFocus) _heightCtrl.text = app.height;
    if (!_weightFocus.hasFocus) _weightCtrl.text = app.weight;
    if (!_eyesFocus.hasFocus) _eyesCtrl.text = app.eyes;
    if (!_skinFocus.hasFocus) _skinCtrl.text = app.skin;
    if (!_hairFocus.hasFocus) _hairCtrl.text = app.hair;
    final p = c.personality;
    if (!_traitsFocus.hasFocus) _traitsCtrl.text = p.traits;
    if (!_idealsFocus.hasFocus) _idealsCtrl.text = p.ideals;
    if (!_bondsFocus.hasFocus) _bondsCtrl.text = p.bonds;
    if (!_flawsFocus.hasFocus) _flawsCtrl.text = p.flaws;
    if (!_backstoryFocus.hasFocus) _backstoryCtrl.text = c.backstory;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _alignCtrl.dispose();
    _playerCtrl.dispose();
    _langCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _eyesCtrl.dispose();
    _skinCtrl.dispose();
    _hairCtrl.dispose();
    _traitsCtrl.dispose();
    _idealsCtrl.dispose();
    _bondsCtrl.dispose();
    _flawsCtrl.dispose();
    _backstoryCtrl.dispose();
    _nameFocus.dispose();
    _alignFocus.dispose();
    _playerFocus.dispose();
    _langFocus.dispose();
    _ageFocus.dispose();
    _heightFocus.dispose();
    _weightFocus.dispose();
    _eyesFocus.dispose();
    _skinFocus.dispose();
    _hairFocus.dispose();
    _traitsFocus.dispose();
    _idealsFocus.dispose();
    _bondsFocus.dispose();
    _flawsFocus.dispose();
    _backstoryFocus.dispose();
    super.dispose();
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
    // individual saves that race against each other.
    widget.editGuard.unregister();
    setState(() {
      _isEditing = false;
      _snapshot = null;
    });
    FocusScope.of(context).unfocus();
    final fallback = AppLocalizations.of(context)!.reviewUnnamedHero;
    _notifier.updateIdentity(
      name: _nameCtrl.text,
      alignment: _alignCtrl.text,
      playerName: _playerCtrl.text,
      appearance: _buildCurrentAppearance(),
      personality: CharacterPersonality(
        traits: _traitsCtrl.text.trim(),
        ideals: _idealsCtrl.text.trim(),
        bonds: _bondsCtrl.text.trim(),
        flaws: _flawsCtrl.text.trim(),
      ),
      backstory: _backstoryCtrl.text,
      nameFallback: fallback,
    );
  }

  CharacterAppearance _buildCurrentAppearance() => CharacterAppearance(
    age: _ageCtrl.text.trim().isEmpty ? null : _ageCtrl.text.trim(),
    height: _heightCtrl.text.trim(),
    weight: _weightCtrl.text.trim(),
    eyes: _eyesCtrl.text.trim(),
    skin: _skinCtrl.text.trim(),
    hair: _hairCtrl.text.trim(),
  );

  Future<void> _onLevelUp(Character character) async {
    final primaryClass = character.primaryClass;
    final newLevel = primaryClass.level + 1;
    final srd = ref.read(srdDataSourceProvider);
    final classes = await srd.getClasses();
    final srdClass = classes
        .where((c) => c.name == primaryClass.className)
        .firstOrNull;

    if (srdClass == null ||
        srdClass.subclasses.isEmpty ||
        newLevel != srdClass.subclassLevel) {
      await _notifier.updateLevel(newLevel);
      return;
    }

    if (!mounted) return;

    final i18n =
        ref.read(srdI18nProvider).valueOrNull ?? SrdI18nService.english;

    if (primaryClass.subclassName != null &&
        primaryClass.subclassName!.isNotEmpty) {
      final picked = await _showSubclassDialog(
        context: context,
        srdClass: srdClass,
        current: primaryClass.subclassName,
        isConfirm: true,
        i18n: i18n,
      );
      if (!mounted) return;
      if (picked != null) await _notifier.updateSubclass(picked);
      await _notifier.updateLevel(newLevel);
      return;
    }

    final picked = await _showSubclassDialog(
      context: context,
      srdClass: srdClass,
      current: null,
      isConfirm: false,
      i18n: i18n,
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
    required SrdI18nService i18n,
  }) {
    final l10n = AppLocalizations.of(context)!;
    String? selected = current;
    return showDialog<String>(
      context: context,
      barrierDismissible: isConfirm,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(
              isConfirm
                  ? l10n.subclassConfirmTitle(srdClass.subclassFeatureName)
                  : l10n.subclassChooseTitle(srdClass.subclassFeatureName),
            ),
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
                        l10n.subclassConfirmBody(
                          srdClass.subclassLevel,
                          srdClass.subclassFeatureName,
                        ),
                        style: Theme.of(ctx).textTheme.bodySmall,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        l10n.subclassChooseBody(
                          srdClass.subclassLevel,
                          srdClass.subclassFeatureName,
                        ),
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
                          children: srdClass.subclasses.map((sub) {
                            final translatedName = i18n.subclassName(
                              srdClass.name,
                              sub.name,
                            );
                            final translatedDesc =
                                i18n.subclassDescription(
                                  srdClass.name,
                                  sub.name,
                                ) ??
                                (sub.description.isNotEmpty
                                    ? sub.description
                                    : null);
                            return RadioListTile<String>(
                              title: Text(translatedName),
                              subtitle: translatedDesc != null
                                  ? Text(
                                      translatedDesc,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(ctx).textTheme.bodySmall,
                                    )
                                  : null,
                              value: sub.name,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            );
                          }).toList(),
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
    final primaryClass = character.primaryClass;
    final srd = ref.read(srdDataSourceProvider);
    final classes = await srd.getClasses();
    final srdClass = classes
        .where((c) => c.name == primaryClass.className)
        .firstOrNull;
    if (srdClass == null || srdClass.subclasses.isEmpty || !mounted) return;

    if (primaryClass.subclassName != null &&
        primaryClass.subclassName!.isNotEmpty) {
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

    final i18n =
        ref.read(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final picked = await _showSubclassDialog(
      context: context,
      srdClass: srdClass,
      current: primaryClass.subclassName,
      isConfirm: primaryClass.subclassName != null,
      i18n: i18n,
    );
    if (picked != null && picked != primaryClass.subclassName) {
      await _notifier.updateSubclass(picked);
    }
  }

  Future<void> _showBackgroundDialog(Character character) async {
    final backgrounds = await ref.read(srdDataSourceProvider).getBackgrounds();
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
                    .map(
                      (bg) => RadioListTile<String>(
                        title: Text(bg.name),
                        value: bg.name,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final character = widget.character;
    final primaryClass = character.primaryClass;
    final scheme = Theme.of(context).colorScheme;
    final notifier = _notifier;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          key: PageStorageKey('identity-${widget.characterId}'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 192),
          children: [
            // ── Identity section ─────────────────────────────────────────────
            DetailSection(
              title: l10n.sectionIdentity,
              child: _isEditing
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InlineEditField(
                          label: l10n.labelName,
                          controller: _nameCtrl,
                          focusNode: _nameFocus,
                        ),
                        // Background picker
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 96,
                                child: Text(
                                  l10n.labelBackground,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  character.background.isNotEmpty
                                      ? i18n.backgroundName(
                                          character.background,
                                        )
                                      : '—',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.swap_horiz, size: 16),
                                label: Text(l10n.labelChange),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: () =>
                                    _showBackgroundDialog(character),
                              ),
                            ],
                          ),
                        ),
                        InlineEditField(
                          label: l10n.labelAlignment,
                          controller: _alignCtrl,
                          focusNode: _alignFocus,
                        ),
                        InlineEditField(
                          label: l10n.labelPlayer,
                          controller: _playerCtrl,
                          focusNode: _playerFocus,
                        ),
                        // Level row
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 96,
                                child: Text(
                                  l10n.labelLevel,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                              if (character.isMulticlass)
                                Expanded(
                                  child: Text(
                                    '${character.totalLevel} · '
                                    '${localizedClassLevelSummary(character, i18n)}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                )
                              else ...[
                                OutlinedButton(
                                  onPressed: character.totalLevel > 1
                                      ? () => notifier.updateLevel(
                                          character.totalLevel - 1,
                                        )
                                      : null,
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(36, 36),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  child: const Icon(Icons.remove, size: 16),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    '${character.totalLevel}',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                if (!character.xpTrackingEnabled)
                                  OutlinedButton(
                                    onPressed: character.totalLevel < 20
                                        ? () => _onLevelUp(character)
                                        : null,
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(36, 36),
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    child: const Icon(Icons.add, size: 16),
                                  ),
                              ],
                            ],
                          ),
                        ),
                        if (!character.isMulticlass)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 13,
                                  color: scheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    l10n.levelManualChangeWarning,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
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
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  primaryClass.subclassName?.isNotEmpty == true
                                      ? i18n.subclassName(
                                          primaryClass.className,
                                          primaryClass.subclassName!,
                                        )
                                      : '—',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.swap_horiz, size: 16),
                                label: Text(
                                  primaryClass.subclassName?.isNotEmpty == true
                                      ? l10n.labelChange
                                      : l10n.labelChoose,
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: () => _onChangeSubclass(character),
                              ),
                            ],
                          ),
                        ),
                        // Languages
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
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
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
                                            .map(
                                              (lang) => Chip(
                                                label: Text(
                                                  i18n.languageName(lang),
                                                ),
                                                labelStyle: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                    ),
                                                onDeleted: () {
                                                  final updated =
                                                      List<String>.from(
                                                        character.languages,
                                                      )..remove(lang);
                                                  notifier.updateLanguages(
                                                    updated,
                                                  );
                                                },
                                              ),
                                            )
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
                                              border:
                                                  const OutlineInputBorder(),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 8,
                                                  ),
                                            ),
                                            onSubmitted: (v) {
                                              final s = v.trim();
                                              if (s.isNotEmpty &&
                                                  !character.languages.contains(
                                                    s,
                                                  )) {
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
                                                !character.languages.contains(
                                                  s,
                                                )) {
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
                        DetailInfoRow(
                          l10n.labelName,
                          character.name.isNotEmpty ? character.name : '—',
                        ),
                        DetailInfoRow(
                          l10n.creationStepClass,
                          localizedClassLevelSummary(character, i18n),
                        ),
                        DetailInfoRow(
                          l10n.labelLevel,
                          '${character.totalLevel}',
                        ),
                        if (character.background.isNotEmpty)
                          DetailInfoRow(
                            l10n.labelBackground,
                            i18n.backgroundName(character.background),
                          ),
                        if (primaryClass.subclassName?.isNotEmpty == true)
                          DetailInfoRow(
                            l10n.labelSubclass,
                            i18n.subclassName(
                              primaryClass.className,
                              primaryClass.subclassName!,
                            ),
                          ),
                        if (character.alignment.isNotEmpty)
                          DetailInfoRow(
                            l10n.labelAlignment,
                            character.alignment,
                          ),
                        if (character.playerName.isNotEmpty)
                          DetailInfoRow(l10n.labelPlayer, character.playerName),
                        DetailInfoRow(
                          l10n.labelLanguages,
                          character.languages.isEmpty
                              ? '—'
                              : character.languages
                                    .map((l) => i18n.languageName(l))
                                    .join(', '),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 12),

            // ── Appearance section ───────────────────────────────────────────
            DetailSection(
              title: l10n.sectionAppearance,
              child: _isEditing
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CharacterAvatar(
                            name: character.name,
                            imagePath: character.imagePath,
                            radius: 44,
                            onImageChanged: (path) =>
                                _notifier.updateImage(path),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InlineEditField(
                          label: l10n.labelAge,
                          controller: _ageCtrl,
                          focusNode: _ageFocus,
                          keyboardType: TextInputType.text,
                        ),
                        InlineEditField(
                          label: l10n.labelHeight,
                          controller: _heightCtrl,
                          focusNode: _heightFocus,
                        ),
                        InlineEditField(
                          label: l10n.labelWeight,
                          controller: _weightCtrl,
                          focusNode: _weightFocus,
                        ),
                        InlineEditField(
                          label: l10n.labelEyes,
                          controller: _eyesCtrl,
                          focusNode: _eyesFocus,
                        ),
                        InlineEditField(
                          label: l10n.labelSkin,
                          controller: _skinCtrl,
                          focusNode: _skinFocus,
                        ),
                        InlineEditField(
                          label: l10n.labelHair,
                          controller: _hairCtrl,
                          focusNode: _hairFocus,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CharacterAvatar(
                          name: character.name,
                          imagePath: character.imagePath,
                          radius: 44,
                          onImageChanged: (path) => _notifier.updateImage(path),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Builder(
                            builder: (ctx) {
                              final app = character.appearance;
                              final hasAny =
                                  app.age != null ||
                                  app.height.isNotEmpty ||
                                  app.weight.isNotEmpty ||
                                  app.eyes.isNotEmpty ||
                                  app.skin.isNotEmpty ||
                                  app.hair.isNotEmpty;
                              if (!hasAny) {
                                return const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text('—'),
                                );
                              }
                              return Column(
                                children: [
                                  if (app.age != null)
                                    DetailInfoRow(l10n.labelAge, '${app.age}'),
                                  if (app.height.isNotEmpty)
                                    DetailInfoRow(l10n.labelHeight, app.height),
                                  if (app.weight.isNotEmpty)
                                    DetailInfoRow(l10n.labelWeight, app.weight),
                                  if (app.eyes.isNotEmpty)
                                    DetailInfoRow(l10n.labelEyes, app.eyes),
                                  if (app.skin.isNotEmpty)
                                    DetailInfoRow(l10n.labelSkin, app.skin),
                                  if (app.hair.isNotEmpty)
                                    DetailInfoRow(l10n.labelHair, app.hair),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 12),

            // ── Personality section ──────────────────────────────────────────
            DetailSection(
              title: l10n.sectionPersonality,
              child: _isEditing
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MultilineField(
                          label: l10n.sectionPersonalityTraits,
                          controller: _traitsCtrl,
                          focusNode: _traitsFocus,
                        ),
                        const SizedBox(height: 8),
                        _MultilineField(
                          label: l10n.sectionIdeals,
                          controller: _idealsCtrl,
                          focusNode: _idealsFocus,
                        ),
                        const SizedBox(height: 8),
                        _MultilineField(
                          label: l10n.sectionBonds,
                          controller: _bondsCtrl,
                          focusNode: _bondsFocus,
                        ),
                        const SizedBox(height: 8),
                        _MultilineField(
                          label: l10n.sectionFlaws,
                          controller: _flawsCtrl,
                          focusNode: _flawsFocus,
                        ),
                      ],
                    )
                  : _PersonalityView(
                      personality: character.personality,
                      traitsLabel: l10n.sectionPersonalityTraits,
                      idealsLabel: l10n.sectionIdeals,
                      bondsLabel: l10n.sectionBonds,
                      flawsLabel: l10n.sectionFlaws,
                    ),
            ),
            const SizedBox(height: 12),

            // ── Backstory section ────────────────────────────────────────────
            DetailSection(
              title: l10n.sectionBackstory,
              child: _isEditing
                  ? _MultilineField(
                      label: null,
                      controller: _backstoryCtrl,
                      focusNode: _backstoryFocus,
                      minLines: 5,
                    )
                  : character.backstory.isNotEmpty
                  ? Text(
                      character.backstory,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  : Text('—', style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
      floatingActionButton: _isEditing
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'identity_cancel',
                  onPressed: _cancelEditing,
                  backgroundColor: scheme.errorContainer,
                  foregroundColor: scheme.onErrorContainer,
                  tooltip: l10n.dialogCancel,
                  child: const Icon(Icons.close),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'identity_save',
                  onPressed: _saveEditing,
                  tooltip: l10n.dialogSave,
                  child: const Icon(Icons.check),
                ),
              ],
            )
          : FloatingActionButton(
              heroTag: 'identity_edit',
              onPressed: _startEditing,
              tooltip: l10n.detailTooltipEditCharacter,
              child: const Icon(Icons.edit_outlined),
            ),
    );
  }
}

// ── Multiline text field ──────────────────────────────────────────────────────

class _MultilineField extends StatelessWidget {
  const _MultilineField({
    required this.label,
    required this.controller,
    required this.focusNode,
    this.minLines = 3,
  });

  final String? label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
        ],
        TextField(
          controller: controller,
          focusNode: focusNode,
          maxLines: null,
          minLines: minLines,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
      ],
    );
  }
}

// ── Personality view (read-only) ──────────────────────────────────────────────

class _PersonalityView extends StatelessWidget {
  const _PersonalityView({
    required this.personality,
    required this.traitsLabel,
    required this.idealsLabel,
    required this.bondsLabel,
    required this.flawsLabel,
  });

  final CharacterPersonality personality;
  final String traitsLabel;
  final String idealsLabel;
  final String bondsLabel;
  final String flawsLabel;

  @override
  Widget build(BuildContext context) {
    final fields = [
      (traitsLabel, personality.traits),
      (idealsLabel, personality.ideals),
      (bondsLabel, personality.bonds),
      (flawsLabel, personality.flaws),
    ].where((e) => e.$2.isNotEmpty).toList();

    if (fields.isEmpty) {
      return Text('—', style: Theme.of(context).textTheme.bodyMedium);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < fields.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Text(
            fields[i].$1,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(fields[i].$2, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    );
  }
}
