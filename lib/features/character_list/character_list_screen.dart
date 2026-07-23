import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/incoming_file_service.dart';
import '../../core/platform/picked_file_reader.dart';
import '../../core/utils/file_exporter.dart';

import 'character_list_provider.dart';
import '../../data/datasources/srd/srd_i18n_service.dart';
import '../../data/models/models.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/character_avatar.dart';
import '../../shared/widgets/responsive_layout.dart';

bool _looksLikeBackupFile(String fileJson) {
  try {
    final decoded = jsonDecode(fileJson);
    return decoded is Map<String, dynamic> && decoded['characters'] is List;
  } catch (_) {
    return false;
  }
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
    final isBackup = _looksLikeBackupFile(fileJson);
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
      if (_looksLikeBackupFile(fileJson)) {
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

  Future<void> _importCharacter() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _ImportDialog(
        onFileImported: (character) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.charListImportedSuccess(character.name)),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );

    if (result == null || !mounted) return;
    try {
      final character = await ref
          .read(characterListProvider.notifier)
          .importCharacter(result);
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(characterListProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.charListTitle),
        actions: [
          IconButton(
            tooltip: l10n.charListImportTooltip,
            onPressed: _importCharacter,
            icon: const Icon(Icons.upload_file),
          ),
          IconButton(
            tooltip: l10n.charListSettingsTooltip,
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (characters) => characters.isEmpty
            ? const _EmptyState()
            : ResponsiveListConstraints(
                maxWidth: 960,
                child: _CharacterList(characters: characters),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.charListEmpty,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.charListEmptyHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
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
  const _CharacterCard({
    required this.character,
    required this.reorderIndex,
  });

  final Character character;
  final int reorderIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    Future<void> exportCharacter() async {
      final results = await Future.wait([
        ref.read(characterListProvider.notifier).exportCharacter(character),
        ref
            .read(characterListProvider.notifier)
            .exportCharacterToFile(character),
      ]);
      final json = results[0];
      final fileJson = results[1];
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => _ExportDialog(
          characterName: character.name,
          json: json,
          fileJson: fileJson,
        ),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final widgetsL10n = WidgetsLocalizations.of(context);
    final reorderTooltip =
        '${widgetsL10n.reorderItemUp} / ${widgetsL10n.reorderItemDown}';
    return Card(
      child: ListTile(
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CharacterAvatar(
              name: character.name,
              imagePath: character.imagePath,
              radius: 22,
              onImageChanged: (path) => ref
                  .read(characterListProvider.notifier)
                  .updateImage(character.id, path),
            ),
            if (character.isPinned)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.push_pin, size: 10, color: cs.onPrimary),
                ),
              ),
          ],
        ),
        title: Text(character.name),
        subtitle: Text(
          '${i18n.raceName(character.race)} · ${i18n.className(character.characterClass)} · ${l10n.charCardLevel(character.level)}',
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
                    color: cs.outline,
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
        onTap: () => context.push('/character/${character.id}'),
      ),
    );
  }
}

// Export dialog.

class _ExportDialog extends StatefulWidget {
  const _ExportDialog({
    required this.characterName,
    required this.json,
    required this.fileJson,
  });

  final String characterName;
  final String json;
  final String fileJson;

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  bool _jsonExpanded = false;
  bool _sharingFile = false;

  Future<void> _copy(BuildContext ctx, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(ctx)!.exportCopied(label))),
    );
  }

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
              const SizedBox(height: 16),
              // Advanced raw JSON fallback.
              InkWell(
                onTap: () => setState(() => _jsonExpanded = !_jsonExpanded),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        _jsonExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.exportShowJson,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
              if (_jsonExpanded) ...[
                const SizedBox(height: 6),
                Container(
                  height: 180,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.json,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                FilledButton.icon(
                  icon: const Icon(Icons.copy, size: 16),
                  label: Text(l10n.exportCopyJson),
                  onPressed: () => _copy(context, widget.json, 'JSON'),
                ),
              ],
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

class _ImportDialog extends ConsumerStatefulWidget {
  const _ImportDialog({required this.onFileImported});

  final void Function(Character character) onFileImported;

  @override
  ConsumerState<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends ConsumerState<_ImportDialog> {
  final _jsonCtrl = TextEditingController();
  bool _jsonExpanded = false;
  bool _pickingFile = false;

  @override
  void dispose() {
    _jsonCtrl.dispose();
    super.dispose();
  }

  String? _resolveInput() {
    final rawJson = _jsonCtrl.text.trim();
    if (rawJson.isNotEmpty) return rawJson;
    return null;
  }

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
      if (!picked.name.endsWith('.dndchar')) {
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
      final character = await ref
          .read(characterListProvider.notifier)
          .importCharacterFromFile(fileJson);
      if (!ctx.mounted) return;
      Navigator.pop(ctx);
      widget.onFileImported(character);
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
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.importDialogTitle),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Main .dndchar import path.
                    OutlinedButton.icon(
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
                    const SizedBox(height: 8),
                    // Advanced raw JSON fallback.
                    InkWell(
                      onTap: () =>
                          setState(() => _jsonExpanded = !_jsonExpanded),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              _jsonExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 18,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.importUseJson,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_jsonExpanded) ...[
                      const SizedBox(height: 6),
                      TextField(
                        controller: _jsonCtrl,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText: l10n.importJsonHint,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.dialogCancel),
        ),
        FilledButton(
          onPressed: _resolveInput() != null
              ? () => Navigator.pop(context, _resolveInput())
              : null,
          child: Text(l10n.dialogImport),
        ),
      ],
    );
  }
}
