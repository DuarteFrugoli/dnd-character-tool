import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'character_list_provider.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/character_avatar.dart';

class CharacterListScreen extends ConsumerWidget {
  const CharacterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(characterListProvider);

    Future<void> importCharacter() async {
      final result = await showDialog<String>(
        context: context,
        builder: (ctx) => const _ImportDialog(),
      );

      if (result == null || result.isEmpty || !context.mounted) return;
      try {
        final character =
            await ref.read(characterListProvider.notifier).importCharacter(result);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${character.name} imported successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } on FormatException catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unexpected error while importing. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('D&D Characters'),
        actions: [
          IconButton(
            tooltip: 'Import JSON',
            onPressed: importCharacter,
            icon: const Icon(Icons.file_download_outlined),
          ),
          IconButton(
            tooltip: 'Configurações',
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
            : _CharacterList(characters: characters),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Character'),
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
    return AlertDialog(
      title: const Text('Rename character'),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Name',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _ctrl.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
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
            'No characters yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first character',
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
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 192),
      itemCount: characters.length,
      onReorder: (oldIndex, newIndex) =>
          ref.read(characterListProvider.notifier).reorder(oldIndex, newIndex),
      itemBuilder: (context, index) {
        final character = characters[index];
        return Padding(
          key: ValueKey(character.id),
          padding: const EdgeInsets.only(bottom: 8),
          child: _CharacterCard(character: character),
        );
      },
    );
  }
}

class _CharacterCard extends ConsumerWidget {
  const _CharacterCard({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> exportCharacter() async {
      final json =
          await ref.read(characterListProvider.notifier).exportCharacter(character);
      // Token: base64url(gzip(json))
      final token = base64Url.encode(GZipCodec().encode(utf8.encode(json)));
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => _ExportDialog(
          characterName: character.name,
          token: token,
          json: json,
        ),
      );
    }

    final cs = Theme.of(context).colorScheme;
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
          '${character.race} · ${character.characterClass} · Level ${character.level}',
        ),
        trailing: PopupMenuButton<String>(
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
                builder: (ctx) => _RenameDialog(currentName: character.name),
              );
              if (newName != null && newName.trim().isNotEmpty && context.mounted) {
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
                  title: const Text('Delete character?'),
                  content: Text(
                    'Are you sure you want to delete ${character.name}? This cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
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
              child: Text(character.isPinned ? 'Unpin' : 'Pin to top'),
            ),
            const PopupMenuItem(value: 'photo', child: Text('Change photo')),
            const PopupMenuItem(value: 'rename', child: Text('Rename')),
            const PopupMenuItem(value: 'export', child: Text('Export')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () => context.push('/character/${character.id}'),
      ),
    );
  }
}

// ── Export Dialog ─────────────────────────────────────────────────────────────

class _ExportDialog extends StatefulWidget {
  const _ExportDialog({
    required this.characterName,
    required this.token,
    required this.json,
  });

  final String characterName;
  final String token;
  final String json;

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  bool _jsonExpanded = false;
  bool _qrExpanded = false;

  Future<void> _copy(BuildContext ctx, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx)
        .showSnackBar(SnackBar(content: Text('$label copied!')));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text('Export ${widget.characterName}'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Token (primary) ──────────────────────────────────────────
              Text('Token', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              // Fixed-height scrollable box, same pattern as JSON
              Container(
                height: 40,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText(
                    widget.token,
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy token'),
                onPressed: () => _copy(context, widget.token, 'Token'),
              ),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                icon: Icon(_qrExpanded ? Icons.qr_code_2 : Icons.qr_code, size: 16),
                label: Text(_qrExpanded ? 'Hide QR Code' : 'Show QR Code'),
                onPressed: () => setState(() => _qrExpanded = !_qrExpanded),
              ),
              if (_qrExpanded) ...
                [
                  const SizedBox(height: 12),
                  Builder(builder: (context) {
                    final validation = QrValidator.validate(
                      data: widget.token,
                      version: QrVersions.auto,
                      errorCorrectionLevel: QrErrorCorrectLevel.L,
                    );
                    if (validation.isValid) {
                      return LayoutBuilder(builder: (context, constraints) {
                        final size = constraints.maxWidth.isFinite
                            ? constraints.maxWidth
                            : 260.0;
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _QrFullscreenScreen(
                                  characterName: widget.characterName,
                                  token: widget.token),
                            ),
                          ),
                          child: ColoredBox(
                            color: Colors.white,
                            child: QrImageView(
                              data: widget.token,
                              version: QrVersions.auto,
                              size: size,
                              padding: const EdgeInsets.all(12),
                              errorCorrectionLevel: QrErrorCorrectLevel.L,
                            ),
                          ),
                        );
                      });
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Character too large for QR code.\nUse the token or JSON to share.',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),
                ],
              const SizedBox(height: 16),
              // ── JSON (secondary, expandable) ─────────────────────────────
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
                        'Show JSON',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
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
                    child: SelectableText(
                      widget.json,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                FilledButton.icon(
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy JSON'),
                  onPressed: () =>
                      _copy(context, widget.json, 'JSON'),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

// ── Import Dialog ─────────────────────────────────────────────────────────────

class _ImportDialog extends StatefulWidget {
  const _ImportDialog();

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  final _tokenCtrl = TextEditingController();
  final _jsonCtrl = TextEditingController();
  bool _jsonExpanded = false;

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _jsonCtrl.dispose();
    super.dispose();
  }

  String? _resolveInput() {
    final token = _tokenCtrl.text.trim();
    final json = _jsonCtrl.text.trim();
    if (token.isNotEmpty) {
      try {
        final bytes = base64Url.decode(base64Url.normalize(token));
        // Try gzip decompress (new format), fall back to raw UTF-8 (old format)
        try {
          return utf8.decode(GZipCodec().decode(bytes));
        } catch (_) {
          return utf8.decode(bytes);
        }
      } catch (_) {
        // Token inválido → tenta o JSON como fallback
        if (json.isNotEmpty) return json;
        return null;
      }
    }
    if (json.isNotEmpty) return json;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Import Character'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Token (primary) ──────────────────────────────────────────
              Text('Token', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: _tokenCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Paste token here…',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 6),
              // QR code scanner
              OutlinedButton.icon(
                icon: const Icon(Icons.qr_code_scanner, size: 16),
                label: const Text('Scan QR Code'),
                onPressed: () async {
                  final scanned = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const _QrScannerScreen()),
                  );
                  if (scanned != null) {
                    _tokenCtrl.text = scanned;
                    setState(() {});
                  }
                },
              ),
              const SizedBox(height: 16),
              // ── JSON (secondary, expandable) ─────────────────────────────
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
                        'Use JSON directly',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
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
                  decoration: const InputDecoration(
                    hintText: 'Paste JSON here…',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _resolveInput() != null
              ? () => Navigator.pop(context, _resolveInput())
              : null,
          child: const Text('Import'),
        ),
      ],
    );
  }
}

// ── QR Scanner Screen ─────────────────────────────────────────────────────────

class _QrScannerScreen extends StatefulWidget {
  const _QrScannerScreen();

  @override
  State<_QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<_QrScannerScreen> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_scanned) return;
          final barcode = capture.barcodes.firstOrNull;
          if (barcode == null) return;
          final value = barcode.rawValue;
          if (value != null && value.isNotEmpty) {
            _scanned = true;
            Navigator.pop(context, value);
          }
        },
      ),
    );
  }
}

// ── QR Fullscreen Screen ──────────────────────────────────────────────────────

class _QrFullscreenScreen extends StatelessWidget {
  const _QrFullscreenScreen({
    required this.characterName,
    required this.token,
  });

  final String characterName;
  final String token;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(characterName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: QrImageView(
            data: token,
            version: QrVersions.auto,
            size: double.infinity,
            errorCorrectionLevel: QrErrorCorrectLevel.L,
          ),
        ),
      ),
    );
  }
}
