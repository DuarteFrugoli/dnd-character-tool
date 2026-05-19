part of '../character_detail_screen.dart';

// ── Identity Tab ──────────────────────────────────────────────────────────────

class _IdentityTab extends ConsumerStatefulWidget {
  const _IdentityTab({
    required this.character,
    required this.characterId,
  });
  final Character character;
  final String characterId;

  @override
  ConsumerState<_IdentityTab> createState() => _IdentityTabState();
}

class _IdentityTabState extends ConsumerState<_IdentityTab> {
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

  CharacterDetailNotifier get _notifier =>
      ref.read(characterDetailProvider(widget.characterId).notifier);

  @override
  void initState() {
    super.initState();
    final c = widget.character;
    _nameCtrl = TextEditingController(text: c.name);
    _alignCtrl = TextEditingController(text: c.alignment);
    _playerCtrl = TextEditingController(text: c.playerName);

    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus && _isEditing) {
        final fallback = AppLocalizations.of(context)!.reviewUnnamedHero;
        _notifier.updateName(_nameCtrl.text, fallback: fallback);
      }
    });
    _alignFocus.addListener(() {
      if (!_alignFocus.hasFocus && _isEditing)
        _notifier.updateAlignment(_alignCtrl.text);
    });
    _playerFocus.addListener(() {
      if (!_playerFocus.hasFocus && _isEditing)
        _notifier.updatePlayerName(_playerCtrl.text);
    });
  }

  @override
  void didUpdateWidget(_IdentityTab old) {
    super.didUpdateWidget(old);
    final c = widget.character;
    if (!_nameFocus.hasFocus) _nameCtrl.text = c.name;
    if (!_alignFocus.hasFocus) _alignCtrl.text = c.alignment;
    if (!_playerFocus.hasFocus) _playerCtrl.text = c.playerName;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _alignCtrl.dispose();
    _playerCtrl.dispose();
    _langCtrl.dispose();
    _nameFocus.dispose();
    _alignFocus.dispose();
    _playerFocus.dispose();
    _langFocus.dispose();
    super.dispose();
  }

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
    final fallback = AppLocalizations.of(context)!.reviewUnnamedHero;
    _notifier.updateName(_nameCtrl.text, fallback: fallback);
    _notifier.updateAlignment(_alignCtrl.text);
    _notifier.updatePlayerName(_playerCtrl.text);
    setState(() {
      _isEditing = false;
      _snapshot = null;
    });
  }

  Future<void> _onLevelUp(Character character) async {
    final newLevel = character.level + 1;
    final srd = ref.read(srdDataSourceProvider);
    final classes = await srd.getClasses();
    final srdClass = classes
        .where((c) => c.name == character.characterClass)
        .firstOrNull;

    if (srdClass == null ||
        srdClass.subclasses.isEmpty ||
        newLevel != srdClass.subclassLevel) {
      await _notifier.updateLevel(newLevel);
      return;
    }

    if (!mounted) return;

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
                          children: srdClass.subclasses
                              .map(
                                (sub) => RadioListTile<String>(
                                  title: Text(sub.name),
                                  subtitle: sub.description.isNotEmpty
                                      ? Text(
                                          sub.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            ctx,
                                          ).textTheme.bodySmall,
                                        )
                                      : null,
                                  value: sub.name,
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                ),
                              )
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
    final srdClass = classes
        .where((c) => c.name == character.characterClass)
        .firstOrNull;
    if (srdClass == null || srdClass.subclasses.isEmpty || !mounted) return;

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
    final scheme = Theme.of(context).colorScheme;
    final notifier = _notifier;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        children: [
          // ── Edit mode toggle ─────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: _isEditing
                ? [
                    OutlinedButton(
                      onPressed: _cancelEditing,
                      child: Text(l10n.dialogCancel),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _saveEditing,
                      child: Text(l10n.dialogConfirm),
                    ),
                  ]
                : [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text(l10n.detailTooltipEditCharacter),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: _startEditing,
                    ),
                  ],
          ),
          const SizedBox(height: 12),

          // ── Identity section ─────────────────────────────────────────────
          _Section(
            title: l10n.sectionIdentity,
            child: _isEditing
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InlineField(
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
                                    ? i18n.backgroundName(character.background)
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
                      _InlineField(
                        label: l10n.labelAlignment,
                        controller: _alignCtrl,
                        focusNode: _alignFocus,
                      ),
                      _InlineField(
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
                            OutlinedButton(
                              onPressed: character.level > 1
                                  ? () =>
                                      notifier.updateLevel(character.level - 1)
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
                                '${character.level}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: character.level < 20
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
                                character.subclass?.isNotEmpty == true
                                    ? i18n.subclassName(
                                        character.characterClass,
                                        character.subclass!,
                                      )
                                    : '—',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.swap_horiz, size: 16),
                              label: Text(
                                character.subclass?.isNotEmpty == true
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
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton.filled(
                                        icon: const Icon(
                                          Icons.add,
                                          size: 18,
                                        ),
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
                      _InfoRow(
                        l10n.labelName,
                        character.name.isNotEmpty ? character.name : '—',
                      ),
                      _InfoRow(
                        l10n.labelLevel,
                        '${character.level}',
                      ),
                      if (character.background.isNotEmpty)
                        _InfoRow(
                          l10n.labelBackground,
                          i18n.backgroundName(character.background),
                        ),
                      if (character.subclass?.isNotEmpty == true)
                        _InfoRow(
                          l10n.labelSubclass,
                          i18n.subclassName(
                            character.characterClass,
                            character.subclass!,
                          ),
                        ),
                      if (character.alignment.isNotEmpty)
                        _InfoRow(l10n.labelAlignment, character.alignment),
                      if (character.playerName.isNotEmpty)
                        _InfoRow(l10n.labelPlayer, character.playerName),
                      _InfoRow(
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
        ],
      ),
    );
  }
}
