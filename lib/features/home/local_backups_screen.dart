import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/file_exporter.dart';
import '../../data/models/local_backup.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/providers/providers.dart';
import '../character_list/character_list_provider.dart';

class LocalBackupsTile extends StatelessWidget {
  const LocalBackupsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.history_outlined),
      title: Text(l10n.settingsLocalBackupsTitle),
      subtitle: Text(l10n.settingsLocalBackupsSubtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const LocalBackupsScreen()),
      ),
    );
  }
}

class LocalBackupsScreen extends ConsumerStatefulWidget {
  const LocalBackupsScreen({super.key});

  @override
  ConsumerState<LocalBackupsScreen> createState() => _LocalBackupsScreenState();
}

class _LocalBackupsScreenState extends ConsumerState<LocalBackupsScreen> {
  List<LocalBackupInfo> _backups = [];
  bool _loading = true;
  bool _busy = false;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    if (mounted) setState(() => _loading = true);
    try {
      final backups = await ref
          .read(characterRepositoryProvider)
          .listLocalBackups();
      if (mounted) {
        setState(() {
          _backups = backups;
          _loadFailed = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _create() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await ref.read(characterRepositoryProvider).createLocalBackup();
      await _reload();
      _message(l10n.settingsLocalBackupsSaved);
    } catch (_) {
      _message(l10n.settingsLocalBackupSaveError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export(LocalBackupInfo backup) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final fileJson = await ref
          .read(characterRepositoryProvider)
          .readLocalBackup(backup.id);
      if (!mounted) return;
      await exportDndBackupFile(
        fileJson,
        sharePositionOrigin: fileShareOrigin(context),
      );
    } on FileExportCancelled {
      // The saved local copy is still available.
    } catch (_) {
      _message(l10n.settingsBackupExportError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore(LocalBackupInfo backup) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsLocalBackupRestoreTitle),
        content: Text(l10n.settingsLocalBackupRestoreBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.settingsLocalBackupRestoreAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final container = ProviderScope.containerOf(context, listen: false);
    setState(() => _busy = true);
    try {
      final restored = await ref
          .read(characterRepositoryProvider)
          .restoreLocalBackup(backup.id);
      container.invalidate(characterListProvider);
      _message(l10n.settingsBackupImportSuccess(restored.length));
    } catch (_) {
      _message(l10n.settingsBackupImportError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final material = MaterialLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsLocalBackupsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.settingsLocalBackupsSubtitle),
          const SizedBox(height: 8),
          Text(l10n.settingsLocalBackupsDeviceNotice),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy || _loading ? null : _create,
            icon: const Icon(Icons.save_outlined),
            label: Text(l10n.settingsLocalBackupsCreate),
          ),
          if (_loading || _busy)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: LinearProgressIndicator(),
            ),
          if (_loadFailed) ...[
            Text(l10n.settingsLocalBackupsError),
            IconButton(
              onPressed: _busy ? null : _reload,
              icon: const Icon(Icons.refresh),
            ),
          ] else if (!_loading && _backups.isEmpty) ...[
            const SizedBox(height: 20),
            Text(l10n.settingsLocalBackupsEmpty),
          ],
          for (final backup in _backups)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${material.formatMediumDate(backup.createdAt.toLocal())} · ${material.formatTimeOfDay(TimeOfDay.fromDateTime(backup.createdAt.toLocal()))}',
                    ),
                    Text(
                      l10n.settingsLocalBackupCharacters(backup.characterCount),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _busy ? null : () => _export(backup),
                          icon: const Icon(Icons.ios_share),
                          label: Text(l10n.settingsBackupExportTitle),
                        ),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : () => _restore(backup),
                          icon: const Icon(Icons.restore),
                          label: Text(l10n.settingsLocalBackupRestoreAction),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
