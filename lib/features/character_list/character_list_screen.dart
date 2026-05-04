import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'character_list_provider.dart';
import '../../data/models/models.dart';

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
            content: Text('${character.name} importado com sucesso!'),
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
            content: const Text('Erro inesperado ao importar. Tente novamente.'),
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
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 192),
      itemCount: characters.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final character = characters[index];
        return _CharacterCard(character: character);
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
      // Generate token: base64url-encoded UTF-8 JSON
      final token = base64Url.encode(utf8.encode(json));
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

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(character.name.isNotEmpty ? character.name[0] : '?'),
        ),
        title: Text(character.name),
        subtitle: Text(
          '${character.race} · ${character.characterClass} · Level ${character.level}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'export') {
              await exportCharacter();
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
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'export', child: Text('Export')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
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

  Future<void> _copy(BuildContext ctx, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx)
        .showSnackBar(SnackBar(content: Text('$label copiado!')));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text('Exportar ${widget.characterName}'),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  widget.token,
                  style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copiar token'),
                    onPressed: () =>
                        _copy(context, widget.token, 'Token'),
                  ),
                  const SizedBox(width: 8),
                  // QR code placeholder
                  OutlinedButton.icon(
                    icon: const Icon(Icons.qr_code, size: 16),
                    label: const Text('QR Code'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('QR Code — em breve!')),
                      );
                    },
                  ),
                ],
              ),
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
                        'Ver JSON',
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
                TextButton.icon(
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copiar JSON'),
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
          child: const Text('Fechar'),
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
        return utf8.decode(base64Url.decode(base64Url.normalize(token)));
      } catch (_) {
        return null; // invalid token
      }
    }
    if (json.isNotEmpty) return json;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Importar Personagem'),
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
                  hintText: 'Cole o token aqui…',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 6),
              // QR code placeholder
              OutlinedButton.icon(
                icon: const Icon(Icons.qr_code_scanner, size: 16),
                label: const Text('Escanear QR Code'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('QR Code — em breve!')),
                  );
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
                        'Usar JSON diretamente',
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
                    hintText: 'Cole o JSON aqui…',
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
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _resolveInput() != null
              ? () => Navigator.pop(context, _resolveInput())
              : null,
          child: const Text('Importar'),
        ),
      ],
    );
  }
}
