import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/file_exporter.dart';
import '../../data/migrations/character_migration_runner.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';
import 'character_maintenance_report.dart';
import 'confirmation_dialog_styles.dart';

Future<bool> showCharacterUpdateDialog(
  BuildContext context, {
  Future<void> Function(String)? exportBackup,
}) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => CharacterUpdateDialog(
          exportBackup: exportBackup ?? exportDndBackupFile,
        ),
      ) ??
      false;
}

class CharacterUpdateDialog extends ConsumerStatefulWidget {
  const CharacterUpdateDialog({super.key, required this.exportBackup});

  final Future<void> Function(String) exportBackup;

  @override
  ConsumerState<CharacterUpdateDialog> createState() =>
      _CharacterUpdateDialogState();
}

enum _UpdateTask { checking, backingUp, updating }

class _CharacterUpdateDialogState extends ConsumerState<CharacterUpdateDialog> {
  _UpdateTask? _task = _UpdateTask.checking;
  CharacterMigrationBatchReport? _preview;
  CharacterMigrationBatchReport? _result;
  String? _message;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadPreview());
  }

  Future<void> _loadPreview() async {
    try {
      final report = await ref
          .read(characterRepositoryProvider)
          .previewMigrations();
      if (!mounted) return;
      setState(() {
        _preview = report;
        _task = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = AppLocalizations.of(context)!.settingsMaintenanceError;
        _hasError = true;
        _task = null;
      });
    }
  }

  Future<void> _backup() async {
    if (_task != null || _preview == null || _preview!.hasReadIssues) return;
    setState(() {
      _task = _UpdateTask.backingUp;
      _message = null;
      _hasError = false;
    });
    try {
      final fileJson = await ref
          .read(characterRepositoryProvider)
          .exportBackupToFileJson();
      await widget.exportBackup(fileJson);
      if (!mounted) return;
      setState(
        () => _message = AppLocalizations.of(context)!.settingsBackupExportSuccess,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = AppLocalizations.of(context)!.settingsBackupExportError;
        _hasError = true;
      });
    } finally {
      if (mounted) setState(() => _task = null);
    }
  }

  Future<void> _updateAll() async {
    if (_task != null ||
        _preview?.hasUpdates != true ||
        _preview!.hasReadIssues) {
      return;
    }
    setState(() {
      _task = _UpdateTask.backingUp;
      _message = null;
      _hasError = false;
    });
    try {
      final repository = ref.read(characterRepositoryProvider);
      final fileJson = await repository.exportBackupToFileJson();
      await widget.exportBackup(fileJson);
      if (!mounted) return;
      setState(() => _task = _UpdateTask.updating);

      final report = await repository.applyMigrations();
      if (!mounted) return;
      setState(() => _result = report);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = _task == _UpdateTask.backingUp
            ? AppLocalizations.of(context)!.settingsBackupExportError
            : AppLocalizations.of(context)!.settingsMaintenanceError;
        _hasError = true;
      });
    } finally {
      if (mounted) setState(() => _task = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final preview = _preview;
    final result = _result;
    final busy = _task != null;
    final blocking = _task == _UpdateTask.backingUp ||
        _task == _UpdateTask.updating;

    return PopScope(
      canPop: !blocking && result == null,
      child: AlertDialog(
        scrollable: true,
        title: Text(
          result == null
              ? l10n.characterUpdateRequiredTitle
              : l10n.settingsMaintenanceCompleteTitle,
        ),
        content: result != null
            ? Text(formatCharacterMaintenanceReport(context, result))
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.characterUpdateRequiredBody),
                  if (preview != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      preview.hasReadIssues
                          ? l10n.settingsMaintenanceError
                          : preview.hasUpdates
                          ? l10n.settingsMaintenanceUpdatesFound(
                              preview.outdatedCount,
                            )
                          : l10n.settingsMaintenanceNoUpdates,
                      style: TextStyle(
                        color: preview.hasReadIssues
                            ? scheme.error
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (busy) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(
                      _task == _UpdateTask.backingUp
                          ? l10n.settingsBackupExporting
                          : _task == _UpdateTask.updating
                          ? l10n.characterUpdateApplying
                          : l10n.settingsMaintenanceWorking,
                    ),
                  ],
                  if (_message != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _message!,
                      style: TextStyle(
                        color: _hasError
                            ? scheme.error
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: busy || preview == null || preview.hasReadIssues
                          ? null
                          : _backup,
                      icon: const Icon(Icons.backup_outlined),
                      label: Text(l10n.characterUpdateBackupAction),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: busy ||
                              _preview?.hasUpdates != true ||
                              _preview?.hasReadIssues == true
                          ? null
                          : _updateAll,
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.tertiary,
                        foregroundColor: scheme.onTertiary,
                      ),
                      icon: const Icon(Icons.system_update_alt_outlined),
                      label: Text(l10n.characterUpdateAllAction),
                    ),
                  ),
                ],
              ),
        actions: [
          TextButton(
            onPressed: blocking
                ? null
                : () => Navigator.pop(context, result != null),
            style: neutralDialogTextButtonStyle(context),
            child: Text(result == null ? l10n.dialogCancel : l10n.dialogClose),
          ),
        ],
      ),
    );
  }
}
