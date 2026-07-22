part of '../character_detail_screen.dart';

// ── Notes Tab ─────────────────────────────────────────────────────────────────

class _NotesTab extends ConsumerStatefulWidget {
  const _NotesTab({required this.character, required this.characterId});
  final Character character;
  final String characterId;

  @override
  ConsumerState<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends ConsumerState<_NotesTab> {
  Future<void> _showNoteView(BuildContext context, CharacterNote note) async {
    final shouldEdit = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _NoteViewSheet(note: note),
    );
    if (shouldEdit == true && context.mounted) {
      _openNoteSheet(context, existing: note);
    }
  }

  void _openNoteSheet(BuildContext context, {CharacterNote? existing}) {
    final notifier = ref.read(
      characterDetailProvider(widget.characterId).notifier,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) =>
          _NoteEditorSheet(existing: existing, notifier: notifier),
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
    notifier.deleteNote(note.id);
    if (_selectedNoteId == note.id) {
      setState(() => _selectedNoteId = null);
    }
  }

  String? _selectedNoteId;

  CharacterNote? _selectedNote(List<CharacterNote> notes) {
    if (notes.isEmpty) return null;
    final selectedId = _selectedNoteId;
    if (selectedId == null) return notes.first;
    return notes.firstWhereOrNull((note) => note.id == selectedId) ??
        notes.first;
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
    required bool desktop,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 192),
      children: [
        ...notes.map(
          (note) => _NoteCard(
            note: note,
            selected: desktop && note.id == _selectedNote(notes)?.id,
            onView: () {
              if (desktop) {
                setState(() => _selectedNoteId = note.id);
              } else {
                _showNoteView(context, note);
              }
            },
            onDelete: () => _deleteNote(context, note),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = widget.character.notes;
    final isDesktop = ResponsiveBreakpoints.of(context).isExpanded;
    final selectedNote = _selectedNote(notes);

    return Scaffold(
      body: notes.isEmpty
          ? _emptyState(context)
          : isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 380,
                  child: _notesList(context, notes, desktop: true),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: selectedNote == null
                      ? _emptyState(context)
                      : _NoteDetailPane(
                          note: selectedNote,
                          onEdit: () =>
                              _openNoteSheet(context, existing: selectedNote),
                          onDelete: () => _deleteNote(context, selectedNote),
                        ),
                ),
              ],
            )
          : _notesList(context, notes, desktop: false),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteSheet(context),
        tooltip: AppLocalizations.of(context)!.notesTooltipAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _NoteDetailPane extends StatelessWidget {
  const _NoteDetailPane({
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  final CharacterNote note;
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
  const _NoteEditorSheet({required this.notifier, this.existing});
  final CharacterDetailNotifier notifier;
  final CharacterNote? existing;

  @override
  State<_NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<_NoteEditorSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.existing?.content ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
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
        CharacterNote(title: effectiveTitle, content: content),
      );
    } else {
      widget.notifier.updateNote(
        widget.existing!.copyWith(title: effectiveTitle, content: content),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
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
                      labelText: AppLocalizations.of(context)!.notesLabelTitle,
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
                      labelText: AppLocalizations.of(
                        context,
                      )!.notesLabelContent,
                      alignLabelWithHint: true,
                      border: const OutlineInputBorder(),
                    ),
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
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: AppLocalizations.of(context)!.notesTooltipEdit,
                  onPressed: () => Navigator.pop(context, true),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context, false),
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
                if (note.content.isNotEmpty)
                  Text(
                    note.content,
                    style: Theme.of(context).textTheme.bodyMedium,
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
    required this.note,
    required this.onView,
    required this.onDelete,
    this.selected = false,
  });

  final CharacterNote note;
  final VoidCallback onView;
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
        onTap: onView,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.title.isNotEmpty)
                      Text(
                        note.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (note.content.isNotEmpty) ...[
                      if (note.title.isNotEmpty) const SizedBox(height: 4),
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
                                  'Read more',
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
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: scheme.error,
                tooltip: AppLocalizations.of(context)!.notesTooltipDelete,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
