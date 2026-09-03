import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/character_file_payload.dart';
import '../../core/services/incoming_file_service.dart';
import '../../core/platform/picked_file_reader.dart';
import '../../core/utils/file_exporter.dart';

import 'character_list_provider.dart';
import '../../data/datasources/srd/srd_i18n_service.dart';
import '../../data/models/models.dart';
import '../../shared/providers/providers.dart';
import '../../shared/utils/character_display.dart';
import '../../shared/widgets/character_avatar.dart';
import '../../shared/widgets/responsive_layout.dart';

String _duplicateCharacterName(
  AppLocalizations l10n,
  String sourceName,
  Iterable<String> existingNames,
) {
  final names = existingNames.map((name) => name.trim()).toSet();
  for (var copyNumber = 1; copyNumber < 10000; copyNumber++) {
    final candidate = copyNumber == 1
        ? l10n.charDuplicateName(sourceName)
        : l10n.charDuplicateNameNumbered(sourceName, copyNumber);
    if (!names.contains(candidate.trim())) return candidate;
  }
  return l10n.charDuplicateNameNumbered(sourceName, 10000);
}

class CharacterListScreen extends ConsumerStatefulWidget {
  const CharacterListScreen({super.key});

  @override
  ConsumerState<CharacterListScreen> createState() =>
      _CharacterListScreenState();
}

class _CharacterListScreenState extends ConsumerState<CharacterListScreen> {
  StreamSubscription<String>? _fileSub;

  @override
  void initState() {
    super.initState();
    _fileSub = IncomingFileService.instance.fileStream.listen(
      _handleIncomingFile,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      IncomingFileService.instance.checkPendingFile();
    });
  }

  @override
  void dispose() {
    _fileSub?.cancel();
    super.dispose();
  }

  Future<void> _handleIncomingFile(String fileJson) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final isBackup = looksLikeDndBackupFileJson(fileJson);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isBackup ? l10n.incomingBackupPrompt : l10n.importFileIncoming,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.dialogImport),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _importFromFileJson(fileJson);
  }

  Future<void> _importFromFileJson(String fileJson) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    try {
      if (looksLikeDndBackupFileJson(fileJson)) {
        final imported = await ref
            .read(characterRepositoryProvider)
            .importBackupFromFileJson(fileJson);
        ref.invalidate(characterListProvider);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.incomingBackupSuccess(imported.length)),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        return;
      }

      final character = await ref
          .read(characterListProvider.notifier)
          .importCharacterFromFile(fileJson);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.charListImportedSuccess(character.name)),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } on FormatException catch (e) {
      if (!mounted) return;
      final msg = switch (e.message) {
        'invalid_json' => l10n.importErrorInvalidJson,
        'not_object' => l10n.importErrorNotObject,
        'missing_character' => l10n.importErrorMissingCharacter,
        'corrupted_character' => l10n.importErrorCorruptedCharacter,
        _ => l10n.charListImportError,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.charListImportError),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _refreshCharacters() {
    return ref.read(characterListProvider.notifier).refresh();
  }

  Future<void> _importFile() async {
    final fileJson = await showDialog<String>(
      context: context,
      builder: (ctx) => const _ImportDialog(),
    );
    if (fileJson == null || !mounted) return;
    await _importFromFileJson(fileJson);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(characterListProvider);
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.alphaBlend(
          cs.primary.withValues(alpha: 0.08),
          cs.surface,
        ),
        surfaceTintColor: cs.primary,
        title: Text(l10n.charListTitle),
        actions: [
          IconButton(
            tooltip: l10n.charListImportTooltip,
            onPressed: _importFile,
            icon: const Icon(Icons.upload_file),
          ),
          IconButton(
            tooltip: l10n.charListSettingsTooltip,
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.alphaBlend(cs.primary.withValues(alpha: 0.08), cs.surface),
              cs.surface,
              cs.surface,
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshCharacters,
          child: state.when(
            loading: () => const CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
            error: (e, _) => CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('Error: $e')),
                ),
              ],
            ),
            data: (characters) => characters.isEmpty
                ? const CustomScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(),
                      ),
                    ],
                  )
                : ResponsiveListConstraints(
                    maxWidth: 960,
                    child: _CharacterList(characters: characters),
                  ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create'),
        icon: const Icon(Icons.add),
        label: Text(l10n.charListNewCharacter),
      ),
    );
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.currentName});
  final String currentName;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.renameDialogTitle),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: l10n.renameDialogLabel,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.dialogCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _ctrl.text),
          child: Text(l10n.dialogSave),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cs.primaryContainer, cs.secondaryContainer],
                ),
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.40),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.16),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(
                Icons.shield_outlined,
                size: 58,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              l10n.charListEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.charListEmptyHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.push('/create'),
              icon: const Icon(Icons.add),
              label: Text(l10n.charListNewCharacter),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterList extends ConsumerWidget {
  const _CharacterList({required this.characters});

  final List<Character> characters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 192),
          sliver: SliverReorderableList(
            itemCount: characters.length,
            onReorder: (oldIndex, newIndex) => ref
                .read(characterListProvider.notifier)
                .reorder(oldIndex, newIndex),
            itemBuilder: (context, index) {
              final character = characters[index];
              return Padding(
                key: ValueKey(character.id),
                padding: const EdgeInsets.only(bottom: 8),
                child: _CharacterCard(
                  character: character,
                  reorderIndex: index,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CharacterCard extends ConsumerWidget {
  const _CharacterCard({required this.character, required this.reorderIndex});

  final Character character;
  final int reorderIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    void openCharacter() {
      if (character.needsDataUpdate) {
        context.push('/settings?section=maintenance');
        return;
      }
      context.push('/character/${character.id}');
    }

    Future<void> exportCharacter() async {
      final fileJson = await ref
          .read(characterListProvider.notifier)
          .exportCharacterToFile(character);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) =>
            _ExportDialog(characterName: character.name, fileJson: fileJson),
      );
    }

    Future<void> duplicateCharacter() async {
      final characters =
          ref.read(characterListProvider).valueOrNull ?? const <Character>[];
      final duplicateName = _duplicateCharacterName(
        l10n,
        character.name,
        characters.map((character) => character.name),
      );

      try {
        final duplicate = await ref
            .read(characterListProvider.notifier)
            .duplicate(character.id, name: duplicateName);
        if (!context.mounted || duplicate == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.charListDuplicatedSuccess(duplicate.name)),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.charListDuplicateError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    final cs = Theme.of(context).colorScheme;
    final widgetsL10n = WidgetsLocalizations.of(context);
    final reorderTooltip =
        '${widgetsL10n.reorderItemUp} / ${widgetsL10n.reorderItemDown}';
    final cardColor = cs.surfaceContainerLow;
    final borderColor = character.isPinned
        ? cs.primary.withValues(alpha: 0.62)
        : cs.outlineVariant.withValues(alpha: 0.82);
    return Card(
      elevation: 0,
      color: cardColor,
      surfaceTintColor: cs.primary,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cs.primary, cs.tertiary.withValues(alpha: 0.85)],
                ),
              ),
              child: CharacterAvatar(
                name: character.name,
                imagePath: character.imagePath,
                radius: 22,
                heroTag: 'character_avatar_${character.id}',
                onImageChanged: (path) => ref
                    .read(characterListProvider.notifier)
                    .updateImage(character.id, path),
              ),
            ),
            if (character.isPinned)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: cardColor, width: 1.5),
                  ),
                  child: Icon(Icons.push_pin, size: 10, color: cs.onPrimary),
                ),
              ),
          ],
        ),
        title: Text(
          character.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${localizedRaceSummary(character, i18n)} · '
          '${localizedClassLevelSummary(character, i18n)} · '
          '${l10n.charCardLevel(character.totalLevel)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReorderableDragStartListener(
              index: reorderIndex,
              child: Tooltip(
                message: reorderTooltip,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.drag_handle,
                    size: 20,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'pin') {
                  await ref
                      .read(characterListProvider.notifier)
                      .togglePin(character.id);
                }
                if (value == 'photo') {
                  if (!context.mounted) return;
                  await showCharacterPhotoPicker(
                    context,
                    currentImagePath: character.imagePath,
                    onImageChanged: (path) => ref
                        .read(characterListProvider.notifier)
                        .updateImage(character.id, path),
                  );
                }
                if (value == 'export') {
                  await exportCharacter();
                }
                if (value == 'duplicate') {
                  await duplicateCharacter();
                }
                if (value == 'rename') {
                  if (!context.mounted) return;
                  final newName = await showDialog<String>(
                    context: context,
                    builder: (ctx) =>
                        _RenameDialog(currentName: character.name),
                  );
                  if (newName != null &&
                      newName.trim().isNotEmpty &&
                      context.mounted) {
                    await ref
                        .read(characterListProvider.notifier)
                        .rename(character.id, newName);
                  }
                }
                if (value == 'delete') {
                  if (!context.mounted) return;
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.deleteDialogTitle),
                      content: Text(l10n.deleteDialogContent(character.name)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l10n.dialogCancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(l10n.charCardDelete),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref
                        .read(characterListProvider.notifier)
                        .delete(character.id);
                  }
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'pin',
                  child: Text(
                    character.isPinned ? l10n.charCardUnpin : l10n.charCardPin,
                  ),
                ),
                PopupMenuItem(
                  value: 'photo',
                  child: Text(l10n.charCardChangePhoto),
                ),
                PopupMenuItem(
                  value: 'rename',
                  child: Text(l10n.charCardRename),
                ),
                PopupMenuItem(
                  value: 'duplicate',
                  child: Text(l10n.charCardDuplicate),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: Text(l10n.charCardExport),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(l10n.charCardDelete),
                ),
              ],
            ),
          ],
        ),
        onTap: openCharacter,
      ),
    );
  }
}

// Export dialog.

class _ExportDialog extends StatefulWidget {
  const _ExportDialog({required this.characterName, required this.fileJson});

  final String characterName;
  final String fileJson;

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  bool _sharingFile = false;

  Future<void> _shareFile() async {
    setState(() => _sharingFile = true);
    try {
      await exportDndCharFile(widget.characterName, widget.fileJson);
    } finally {
      if (mounted) setState(() => _sharingFile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(l10n.exportDialogTitle(widget.characterName)),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Complete .dndchar file.
              Text(
                l10n.exportSectionFile,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 2),
              Text(
                l10n.exportSectionFileCaption,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                icon: _sharingFile
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.ios_share, size: 16),
                label: Text(l10n.exportShareFile),
                onPressed: _sharingFile ? null : _shareFile,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.dialogClose),
        ),
      ],
    );
  }
}

// Import dialog.

class _ImportDialog extends StatefulWidget {
  const _ImportDialog();

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  bool _pickingFile = false;

  Future<void> _pickFile(BuildContext ctx) async {
    setState(() => _pickingFile = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        // On web, path is always null — we need bytes instead.
        withData: shouldLoadPickedFileData,
      );
      if (result == null || result.files.isEmpty) return;

      final picked = result.files.single;

      // Validate filename (name is always available on all platforms).
      final fileName = picked.name.toLowerCase();
      final isSupportedFile =
          fileName.endsWith('.dndchar') || fileName.endsWith('.dndbackup');
      if (!isSupportedFile) {
        if (!ctx.mounted) return;
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(ctx)!.importFileError),
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
        );
        return;
      }

      final fileJson = await readPickedFileAsString(picked);
      if (fileJson == null) return;

      if (!ctx.mounted) return;
      Navigator.pop(ctx, fileJson);
    } on FormatException {
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(ctx)!.importFileError),
          backgroundColor: Theme.of(ctx).colorScheme.error,
        ),
      );
    } catch (_) {
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(ctx)!.importFileError),
          backgroundColor: Theme.of(ctx).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _pickingFile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.importDialogTitle),
      content: SizedBox(
        width: 520,
        child: Align(
          alignment: Alignment.centerLeft,
          heightFactor: 1,
          widthFactor: 1,
          child: OutlinedButton.icon(
            onPressed: _pickingFile ? null : () => _pickFile(context),
            icon: _pickingFile
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.folder_open, size: 18),
            label: Text(l10n.importPickFile),
          ),
        ),
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
