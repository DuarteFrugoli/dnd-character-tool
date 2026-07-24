part of '../character_detail_screen.dart';

// ── Notes Tab ─────────────────────────────────────────────────────────────────

const _noteTagPalette = <int>[
  0xFF5E81AC,
  0xFFA3BE8C,
  0xFFEBCB8B,
  0xFFD08770,
  0xFFB48EAD,
  0xFF88C0D0,
  0xFFBF616A,
  0xFF607D8B,
];

String _normalizeNoteTagLabel(String label) => label.trim().toLowerCase();

List<CharacterNoteTag> _defaultNoteTags(AppLocalizations l10n) => [
  CharacterNoteTag(label: l10n.notesDefaultTagSession, colorValue: 0xFF5E81AC),
  CharacterNoteTag(label: l10n.notesDefaultTagNpc, colorValue: 0xFFB48EAD),
  CharacterNoteTag(label: l10n.notesDefaultTagQuest, colorValue: 0xFFA3BE8C),
  CharacterNoteTag(label: l10n.notesDefaultTagPlace, colorValue: 0xFF88C0D0),
  CharacterNoteTag(label: l10n.notesDefaultTagLoot, colorValue: 0xFFEBCB8B),
  CharacterNoteTag(label: l10n.notesDefaultTagRule, colorValue: 0xFFD08770),
];

Color _noteTagColor(CharacterNoteTag tag) => Color(tag.colorValue);

Color _noteTagForeground(Color color) =>
    color.computeLuminance() > 0.45 ? Colors.black87 : Colors.white;

enum _NoteViewAction { edit, togglePinned }

enum _NoteCardAction { edit, togglePinned, delete }

class _NotesTab extends ConsumerStatefulWidget {
  const _NotesTab({required this.character, required this.characterId});
  final Character character;
  final String characterId;

  @override
  ConsumerState<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends ConsumerState<_NotesTab> {
  late final TextEditingController _searchCtrl;
  String? _selectedTagKey;
  String? _selectedNoteId;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _showNoteView(BuildContext context, CharacterNote note) async {
    final action = await showModalBottomSheet<_NoteViewAction>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _NoteViewSheet(note: note),
    );
    if (!context.mounted || action == null) return;

    if (action == _NoteViewAction.edit) {
      _openNoteSheet(context, existing: note);
      return;
    }

    if (action == _NoteViewAction.togglePinned) {
      await ref
          .read(characterDetailProvider(widget.characterId).notifier)
          .toggleNotePinned(note.id);
    }
  }

  void _openNoteSheet(BuildContext context, {CharacterNote? existing}) {
    FocusScope.of(context).unfocus();
    final notifier = ref.read(
      characterDetailProvider(widget.characterId).notifier,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _NoteEditorSheet(
        existing: existing,
        notifier: notifier,
        availableTags: _allTags(widget.character.notes),
      ),
    );
  }

  Future<void> _deleteNote(BuildContext context, CharacterNote note) async {
    final notifier = ref.read(
      characterDetailProvider(widget.characterId).notifier,
    );
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.notesDeleteTitle),
        content: note.title.isNotEmpty
            ? Text(
                AppLocalizations.of(
                  context,
                )!.notesDeleteContentNamed(note.title),
              )
            : Text(AppLocalizations.of(context)!.notesDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(AppLocalizations.of(context)!.dialogRemove),
          ),
        ],
      ),
    );

    if (!mounted || confirm != true) return;
    await notifier.deleteNote(note.id);
    if (_selectedNoteId == note.id) {
      setState(() => _selectedNoteId = null);
    }
  }

  CharacterNote? _selectedNote(List<CharacterNote> notes) {
    if (notes.isEmpty) return null;
    final selectedId = _selectedNoteId;
    if (selectedId == null) return notes.first;
    return notes.firstWhereOrNull((note) => note.id == selectedId) ??
        notes.first;
  }

  List<CharacterNoteTag> _allTags(List<CharacterNote> notes) {
    final byKey = <String, CharacterNoteTag>{};
    for (final note in notes) {
      for (final tag in note.tags) {
        final label = tag.label.trim();
        if (label.isEmpty) continue;
        byKey.putIfAbsent(_normalizeNoteTagLabel(label), () => tag);
      }
    }
    final tags = byKey.values.toList()
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    return tags;
  }

  List<CharacterNote> _filteredNotes(
    List<CharacterNote> notes,
    String? selectedTagKey,
  ) {
    final query = _searchCtrl.text.trim().toLowerCase();
    return _notesInDisplayOrder(notes.where((note) {
      final matchesQuery =
          query.isEmpty ||
          note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query) ||
          note.tags.any((tag) => tag.label.toLowerCase().contains(query));
      final matchesTag =
          selectedTagKey == null ||
          note.tags.any(
            (tag) => _normalizeNoteTagLabel(tag.label) == selectedTagKey,
          );
      return matchesQuery && matchesTag;
    }));
  }

  List<CharacterNote> _notesInDisplayOrder(Iterable<CharacterNote> notes) {
    final indexed = notes
        .mapIndexed((index, note) => MapEntry(index, note))
        .toList()
      ..sort((a, b) {
        final noteA = a.value;
        final noteB = b.value;
        if (noteA.isPinned != noteB.isPinned) {
          return noteA.isPinned ? -1 : 1;
        }
        final byOrder = noteA.sortOrder.compareTo(noteB.sortOrder);
        if (byOrder != 0) return byOrder;
        return a.key.compareTo(b.key);
      });
    return indexed.map((entry) => entry.value).toList();
  }

  Widget _emptyState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_outlined, size: 64, color: scheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            l10n.notesEmptyTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.notesEmptyHint,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _notesList(
    BuildContext context,
    List<CharacterNote> notes, {
    required List<CharacterNoteTag> allTags,
    required String? selectedTagKey,
    required bool desktop,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final canReorder =
        _searchCtrl.text.trim().isEmpty && selectedTagKey == null;
    final pinned = notes.where((note) => note.isPinned).toList();
    final unpinned = notes.where((note) => !note.isPinned).toList();
    final notifier = ref.read(
      characterDetailProvider(widget.characterId).notifier,
    );

    _NoteCard noteCard(CharacterNote note, {int? reorderIndex}) {
      return _NoteCard(
        key: ValueKey(note.id),
        note: note,
        reorderIndex: reorderIndex,
        selected: desktop && note.id == _selectedNote(notes)?.id,
        onView: () {
          FocusScope.of(context).unfocus();
          if (desktop) {
            setState(() => _selectedNoteId = note.id);
          } else {
            _showNoteView(context, note);
          }
        },
        onTogglePinned: () => notifier.toggleNotePinned(note.id),
        onEdit: () {
          FocusScope.of(context).unfocus();
          _openNoteSheet(context, existing: note);
        },
        onDelete: () => _deleteNote(context, note),
      );
    }

    Widget noteGroup(List<CharacterNote> group, {required bool pinned}) {
      if (!canReorder || group.length < 2) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => noteCard(group[index]),
            childCount: group.length,
          ),
        );
      }

      return SliverReorderableList(
        itemCount: group.length,
        onReorder: (oldIndex, newIndex) => notifier.reorderNotes(
          pinned: pinned,
          oldIndex: oldIndex,
          newIndex: newIndex,
        ),
        itemBuilder: (context, index) =>
            noteCard(group[index], reorderIndex: index),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: _NotesSearchAndFilters(
              searchController: _searchCtrl,
              tags: allTags,
              selectedTagKey: selectedTagKey,
              onTagSelected: (key) => setState(() => _selectedTagKey = key),
            ),
          ),
        ),
        if (notes.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 192),
            sliver: SliverToBoxAdapter(child: _NotesNoResults(l10n: l10n)),
          ),
        if (pinned.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _NoteListSectionHeader(label: l10n.notesPinnedSection),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: noteGroup(pinned, pinned: true),
          ),
        ],
        if (unpinned.isNotEmpty) ...[
          if (pinned.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              sliver: SliverToBoxAdapter(
                child: _NoteListSectionHeader(label: l10n.notesOtherSection),
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16,
              pinned.isEmpty ? 12 : 0,
              16,
              0,
            ),
            sliver: noteGroup(unpinned, pinned: false),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 192)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = widget.character.notes;
    final allTags = _allTags(notes);
    final selectedTagKey =
        _selectedTagKey != null &&
            allTags.any(
              (tag) => _normalizeNoteTagLabel(tag.label) == _selectedTagKey,
            )
        ? _selectedTagKey
        : null;
    final filteredNotes = _filteredNotes(notes, selectedTagKey);
    final isDesktop = ResponsiveBreakpoints.of(context).isExpanded;
    final selectedNote = _selectedNote(filteredNotes);

    return Scaffold(
      body: notes.isEmpty
          ? _emptyState(context)
          : isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 380,
                  child: _notesList(
                    context,
                    filteredNotes,
                    allTags: allTags,
                    selectedTagKey: selectedTagKey,
                    desktop: true,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: selectedNote == null
                      ? _emptyState(context)
                      : _NoteDetailPane(
                          note: selectedNote,
                          onTogglePinned: () => ref
                              .read(
                                characterDetailProvider(
                                  widget.characterId,
                                ).notifier,
                              )
                              .toggleNotePinned(selectedNote.id),
                          onEdit: () =>
                              _openNoteSheet(context, existing: selectedNote),
                          onDelete: () => _deleteNote(context, selectedNote),
                        ),
                ),
              ],
            )
          : _notesList(
              context,
              filteredNotes,
              allTags: allTags,
              selectedTagKey: selectedTagKey,
              desktop: false,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteSheet(context),
        tooltip: AppLocalizations.of(context)!.notesTooltipAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _NotesSearchAndFilters extends StatelessWidget {
  const _NotesSearchAndFilters({
    required this.searchController,
    required this.tags,
    required this.selectedTagKey,
    required this.onTagSelected,
  });

  final TextEditingController searchController;
  final List<CharacterNoteTag> tags;
  final String? selectedTagKey;
  final ValueChanged<String?> onTagSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: searchController,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          decoration: InputDecoration(
            hintText: l10n.notesSearchHint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchController.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: searchController.clear,
                  ),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(l10n.notesAllTags),
                    selected: selectedTagKey == null,
                    onSelected: (_) {
                      FocusScope.of(context).unfocus();
                      onTagSelected(null);
                    },
                  ),
                ),
                ...tags.map((tag) {
                  final key = _normalizeNoteTagLabel(tag.label);
                  final color = _noteTagColor(tag);
                  final selected = selectedTagKey == key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: _NoteColorDot(color: color, size: 12),
                      label: Text(tag.label),
                      selected: selected,
                      selectedColor: color.withValues(alpha: 0.28),
                      checkmarkColor: scheme.onSurface,
                      onSelected: (_) {
                        FocusScope.of(context).unfocus();
                        onTagSelected(selected ? null : key);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _NotesNoResults extends StatelessWidget {
  const _NotesNoResults({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.search_off_outlined, size: 48, color: scheme.outline),
          const SizedBox(height: 12),
          Text(
            l10n.notesNoResultsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.notesNoResultsHint,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.outline),
          ),
        ],
      ),
    );
  }
}

class _NoteListSectionHeader extends StatelessWidget {
  const _NoteListSectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NoteColorDot extends StatelessWidget {
  const _NoteColorDot({required this.color, this.size = 14});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

class _NoteTagWrap extends StatelessWidget {
  const _NoteTagWrap({required this.tags, this.dense = false});

  final List<CharacterNoteTag> tags;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: dense ? 4 : 6,
      runSpacing: dense ? 4 : 6,
      children: tags.map((tag) {
        final color = _noteTagColor(tag);
        final foreground = _noteTagForeground(color);
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 7 : 9,
            vertical: dense ? 3 : 5,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            tag.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EditableNoteTagsWrap extends StatelessWidget {
  const _EditableNoteTagsWrap({
    required this.tags,
    required this.onPressed,
    required this.onDeleted,
  });

  final List<CharacterNoteTag> tags;
  final ValueChanged<CharacterNoteTag> onPressed;
  final ValueChanged<CharacterNoteTag> onDeleted;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        final color = _noteTagColor(tag);
        return InputChip(
          avatar: _NoteColorDot(color: color, size: 12),
          label: Text(tag.label),
          onPressed: () => onPressed(tag),
          onDeleted: () => onDeleted(tag),
        );
      }).toList(),
    );
  }
}

class _NoteColorChoice extends StatelessWidget {
  const _NoteColorChoice({
    required this.colorValue,
    required this.selected,
    required this.onTap,
  });

  final int colorValue;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    final scheme = Theme.of(context).colorScheme;
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? scheme.onSurface : scheme.outlineVariant,
            width: selected ? 3 : 1,
          ),
        ),
        child: selected
            ? Icon(Icons.check, size: 16, color: _noteTagForeground(color))
            : null,
      ),
    );
  }
}

class _TagColorDialog extends StatelessWidget {
  const _TagColorDialog({required this.selectedColorValue});

  final int selectedColorValue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.notesChooseTagColor),
      content: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _noteTagPalette
            .map(
              (colorValue) => _NoteColorChoice(
                colorValue: colorValue,
                selected: colorValue == selectedColorValue,
                onTap: () => Navigator.pop(context, colorValue),
              ),
            )
            .toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.dialogCancel),
        ),
      ],
    );
  }
}

class _NoteDetailPane extends StatelessWidget {
  const _NoteDetailPane({
    required this.note,
    required this.onTogglePinned,
    required this.onEdit,
    required this.onDelete,
  });

  final CharacterNote note;
  final VoidCallback onTogglePinned;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final dateStr =
        '${note.createdAt.day.toString().padLeft(2, '0')}/'
        '${note.createdAt.month.toString().padLeft(2, '0')}/'
        '${note.createdAt.year}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 192),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                note.title.isNotEmpty ? note.title : l10n.notesUntitled,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              ),
              tooltip: note.isPinned
                  ? l10n.notesTooltipUnpin
                  : l10n.notesTooltipPin,
              onPressed: onTogglePinned,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.notesTooltipEdit,
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: scheme.error,
              tooltip: l10n.notesTooltipDelete,
              onPressed: onDelete,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          dateStr,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: scheme.outline),
        ),
        if (note.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          _NoteTagWrap(tags: note.tags),
        ],
        const SizedBox(height: 24),
        if (note.content.isNotEmpty)
          Text(note.content, style: Theme.of(context).textTheme.bodyLarge)
        else
          Text(
            l10n.detailNone,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.outline),
          ),
      ],
    );
  }
}

// ── Note Editor Sheet ─────────────────────────────────────────────────────────

class _NoteEditorSheet extends StatefulWidget {
  const _NoteEditorSheet({
    required this.notifier,
    required this.availableTags,
    this.existing,
  });

  final CharacterDetailNotifier notifier;
  final List<CharacterNoteTag> availableTags;
  final CharacterNote? existing;

  @override
  State<_NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<_NoteEditorSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late final TextEditingController _tagCtrl;
  late List<CharacterNoteTag> _tags;
  int _selectedTagColorValue = _noteTagPalette.first;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.existing?.content ?? '');
    _tagCtrl = TextEditingController();
    _tags = [...?widget.existing?.tags];
    if (_tags.isNotEmpty) {
      _selectedTagColorValue = _tags.last.colorValue;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  void _upsertTag(String label, int colorValue) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;
    final key = _normalizeNoteTagLabel(trimmed);
    setState(() {
      _tags = [
        ..._tags.where((tag) => _normalizeNoteTagLabel(tag.label) != key),
        CharacterNoteTag(label: trimmed, colorValue: colorValue),
      ];
    });
  }

  void _toggleDefaultTag(CharacterNoteTag tag) {
    final key = _normalizeNoteTagLabel(tag.label);
    final exists = _tags.any(
      (selected) => _normalizeNoteTagLabel(selected.label) == key,
    );
    setState(() {
      _tags = exists
          ? _tags
                .where((selected) => _normalizeNoteTagLabel(selected.label) != key)
                .toList()
          : [..._tags, tag];
    });
  }

  void _addCustomTag() {
    _upsertTag(_tagCtrl.text, _selectedTagColorValue);
    _tagCtrl.clear();
  }

  Future<void> _chooseColorForTag(CharacterNoteTag tag) async {
    final selected = await showDialog<int>(
      context: context,
      builder: (ctx) => _TagColorDialog(selectedColorValue: tag.colorValue),
    );
    if (selected == null) return;
    final key = _normalizeNoteTagLabel(tag.label);
    setState(() {
      _tags = _tags
          .map(
            (current) => _normalizeNoteTagLabel(current.label) == key
                ? current.copyWith(colorValue: selected)
                : current,
          )
          .toList();
    });
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    final l10n = AppLocalizations.of(context)!;
    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }
    final effectiveTitle = title.isEmpty ? l10n.notesUntitled : title;
    if (widget.existing == null) {
      widget.notifier.addNote(
        CharacterNote(title: effectiveTitle, content: content, tags: _tags),
      );
    } else {
      widget.notifier.updateNote(
        widget.existing!.copyWith(
          title: effectiveTitle,
          content: content,
          tags: _tags,
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tagShortcuts = <String, CharacterNoteTag>{};
    for (final tag in [..._defaultNoteTags(l10n), ...widget.availableTags]) {
      final label = tag.label.trim();
      if (label.isEmpty) continue;
      tagShortcuts.putIfAbsent(_normalizeNoteTagLabel(label), () => tag);
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    widget.existing == null
                        ? AppLocalizations.of(context)!.notesTooltipAdd
                        : AppLocalizations.of(context)!.notesTooltipEdit,
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
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  32 + MediaQuery.of(context).viewPadding.bottom,
                ),
                children: [
                  TextField(
                    controller: _titleCtrl,
                    autofocus: widget.existing == null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l10n.notesLabelTitle,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _contentCtrl,
                    autofocus: false,
                    maxLines: 10,
                    minLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l10n.notesLabelContent,
                      alignLabelWithHint: true,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.notesTags,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tagShortcuts.values.map((tag) {
                      final key = _normalizeNoteTagLabel(tag.label);
                      final selected = _tags.any(
                        (current) =>
                            _normalizeNoteTagLabel(current.label) == key,
                      );
                      return FilterChip(
                        avatar: _NoteColorDot(
                          color: _noteTagColor(tag),
                          size: 12,
                        ),
                        label: Text(tag.label),
                        selected: selected,
                        onSelected: (_) => _toggleDefaultTag(tag),
                      );
                    }).toList(),
                  ),
                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _EditableNoteTagsWrap(
                      tags: _tags,
                      onPressed: _chooseColorForTag,
                      onDeleted: (tag) {
                        final key = _normalizeNoteTagLabel(tag.label);
                        setState(() {
                          _tags = _tags
                              .where(
                                (current) =>
                                    _normalizeNoteTagLabel(current.label) !=
                                    key,
                              )
                              .toList();
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    l10n.notesTagColor,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _noteTagPalette
                        .map(
                          (colorValue) => _NoteColorChoice(
                            colorValue: colorValue,
                            selected: colorValue == _selectedTagColorValue,
                            onTap: () => setState(
                              () => _selectedTagColorValue = colorValue,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: l10n.notesCustomTag,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _addCustomTag(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        tooltip: l10n.notesAddTag,
                        onPressed: _addCustomTag,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _save,
                    child: Text(
                      widget.existing == null
                          ? AppLocalizations.of(context)!.dialogAdd
                          : AppLocalizations.of(context)!.dialogConfirm,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Note View Sheet ───────────────────────────────────────────────────────────

class _NoteViewSheet extends StatelessWidget {
  const _NoteViewSheet({required this.note});
  final CharacterNote note;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final dateStr =
        '${note.createdAt.day.toString().padLeft(2, '0')}/'
        '${note.createdAt.month.toString().padLeft(2, '0')}/'
        '${note.createdAt.year}';

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: note.title.isNotEmpty
                      ? Text(
                          note.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        )
                      : const SizedBox.shrink(),
                ),
                IconButton(
                  icon: Icon(
                    note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  ),
                  tooltip: note.isPinned
                      ? l10n.notesTooltipUnpin
                      : l10n.notesTooltipPin,
                  onPressed: () =>
                      Navigator.pop(context, _NoteViewAction.togglePinned),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: AppLocalizations.of(context)!.notesTooltipEdit,
                  onPressed: () => Navigator.pop(context, _NoteViewAction.edit),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                32 + MediaQuery.of(context).viewPadding.bottom,
              ),
              children: [
                if (note.tags.isNotEmpty) ...[
                  _NoteTagWrap(tags: note.tags),
                  const SizedBox(height: 12),
                ],
                if (note.content.isNotEmpty)
                  Text(
                    note.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  Text(
                    l10n.detailNone,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: scheme.outline),
                  ),
                const SizedBox(height: 12),
                Text(
                  dateStr,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: scheme.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Note Card ─────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    super.key,
    required this.note,
    this.reorderIndex,
    required this.onView,
    required this.onTogglePinned,
    required this.onEdit,
    required this.onDelete,
    this.selected = false,
  });

  final CharacterNote note;
  final int? reorderIndex;
  final VoidCallback onView;
  final VoidCallback onTogglePinned;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final contentStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);
    final dateStr =
        '${note.createdAt.day.toString().padLeft(2, '0')}/'
        '${note.createdAt.month.toString().padLeft(2, '0')}/'
        '${note.createdAt.year}';
    final widgetsL10n = WidgetsLocalizations.of(context);
    final reorderTooltip =
        '${widgetsL10n.reorderItemUp} / ${widgetsL10n.reorderItemDown}';

    return Card(
      color: selected ? scheme.secondaryContainer : null,
      margin: const EdgeInsets.only(bottom: 8),
      shape: selected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: scheme.secondary),
            )
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          FocusScope.of(context).unfocus();
          onView();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.title.isNotEmpty || note.isPinned)
                      Row(
                        children: [
                          if (note.isPinned) ...[
                            Icon(
                              Icons.push_pin,
                              size: 15,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 4),
                          ],
                          if (note.title.isNotEmpty)
                            Expanded(
                              child: Text(
                                note.title,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ),
                    if (note.content.isNotEmpty) ...[
                      if (note.title.isNotEmpty || note.isPinned)
                        const SizedBox(height: 4),
                      LayoutBuilder(
                        builder: (ctx, constraints) {
                          const maxLines = 3;
                          final tp = TextPainter(
                            text: TextSpan(
                              text: note.content,
                              style: contentStyle,
                            ),
                            maxLines: maxLines,
                            textDirection: TextDirection.ltr,
                          )..layout(maxWidth: constraints.maxWidth);
                          final isOverflow = tp.didExceedMaxLines;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.content,
                                maxLines: maxLines,
                                overflow: TextOverflow.ellipsis,
                                style: contentStyle,
                              ),
                              if (isOverflow) ...[
                                const SizedBox(height: 2),
                                Text(
                                  AppLocalizations.of(context)!.notesReadMore,
                                  style: Theme.of(ctx).textTheme.labelSmall
                                      ?.copyWith(
                                        color: scheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                    if (note.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _NoteTagWrap(tags: note.tags, dense: true),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      dateStr,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: scheme.outline),
                    ),
                  ],
                ),
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
              PopupMenuButton<_NoteCardAction>(
                tooltip: AppLocalizations.of(context)!.notesMoreActions,
                onOpened: () => FocusScope.of(context).unfocus(),
                onSelected: (action) {
                  switch (action) {
                    case _NoteCardAction.edit:
                      onEdit();
                      break;
                    case _NoteCardAction.togglePinned:
                      onTogglePinned();
                      break;
                    case _NoteCardAction.delete:
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (ctx) {
                  final l10n = AppLocalizations.of(ctx)!;
                  return [
                    PopupMenuItem(
                      value: _NoteCardAction.edit,
                      child: _NoteMenuItem(
                        icon: Icons.edit_outlined,
                        label: l10n.notesTooltipEdit,
                      ),
                    ),
                    PopupMenuItem(
                      value: _NoteCardAction.togglePinned,
                      child: _NoteMenuItem(
                        icon: note.isPinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                        label: note.isPinned
                            ? l10n.notesTooltipUnpin
                            : l10n.notesTooltipPin,
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: _NoteCardAction.delete,
                      child: _NoteMenuItem(
                        icon: Icons.delete_outline,
                        label: l10n.notesTooltipDelete,
                        destructive: true,
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteMenuItem extends StatelessWidget {
  const _NoteMenuItem({
    required this.icon,
    required this.label,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = destructive ? scheme.error : null;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}
