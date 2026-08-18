import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dnd_character_tool/l10n/app_localizations.dart';

import '../../core/display/keep_screen_on_provider.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/review/app_review_service.dart';
import '../../core/theme/app_themes.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/units/unit_system_provider.dart';
import '../../core/utils/file_exporter.dart';
import '../../data/migrations/character_migration.dart';
import '../../data/migrations/character_migration_runner.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/responsive_layout.dart';
import '../character_list/character_list_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, this.focusMaintenance = false});

  final bool focusMaintenance;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _maintenanceKey = GlobalKey();
  bool _didFocusMaintenance = false;

  void _openThemePicker(BuildContext context, WidgetRef ref, AppTheme current) {
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.settingsChooseTheme,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: EdgeInsets.only(bottom: bottomPadding + 24),
                itemCount: appThemes.length,
                itemBuilder: (_, i) {
                  final theme = appThemes[i];
                  return _ThemeTile(
                    theme: theme,
                    isSelected: theme.id == current.id,
                    onTap: () {
                      ref.read(themeProvider.notifier).setTheme(theme);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.focusMaintenance && !_didFocusMaintenance) {
      _didFocusMaintenance = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final maintenanceContext = _maintenanceKey.currentContext;
        if (maintenanceContext == null) return;
        Scrollable.ensureVisible(
          maintenanceContext,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          alignment: 0.1,
        );
      });
    }

    final current = ref.watch(themeProvider);
    final cs = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    final currentScheme = current.toThemeData().colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.alphaBlend(
          cs.primary.withValues(alpha: 0.08),
          cs.surface,
        ),
        surfaceTintColor: cs.primary,
        title: Text(AppLocalizations.of(context)!.settingsTitle),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.alphaBlend(cs.primary.withValues(alpha: 0.07), cs.surface),
              cs.surface,
              cs.surface,
            ],
          ),
        ),
        child: ResponsiveScaffoldBody(
          maxWidth: 720,
          child: ListTileTheme.merge(
            iconColor: cs.primary,
            textColor: cs.onSurface,
            child: ListView(
              padding: EdgeInsets.only(top: 8, bottom: bottomPadding + 32),
              children: [
                // Visual theme
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    AppLocalizations.of(context)!.settingsSectionTheme,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: cs.primary),
                  ),
                ),
                _ThemePreferencePanel(
                  theme: current,
                  scheme: currentScheme,
                  onTap: () => _openThemePicker(context, ref, current),
                ),

                const Divider(height: 32),

                // Language
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Text(
                    AppLocalizations.of(context)!.settingsSectionLanguage,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: cs.primary),
                  ),
                ),
                _LanguageTile(),

                const Divider(height: 32),

                // Units
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Text(
                    AppLocalizations.of(context)!.settingsSectionUnits,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: cs.primary),
                  ),
                ),
                _UnitSystemTile(),

                const Divider(height: 32),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Text(
                    AppLocalizations.of(context)!.settingsSectionCharacterSheet,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: cs.primary),
                  ),
                ),
                const _KeepScreenOnTile(),

                const Divider(height: 32),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Text(
                    AppLocalizations.of(context)!.settingsBackupSection,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: cs.primary),
                  ),
                ),
                const _BackupTile(),
                const _ImportBackupTile(),

                const Divider(height: 32),

                if (AppReviewService.isPlayStoreReviewSupported) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                    child: Text(
                      AppLocalizations.of(context)!.settingsSectionApp,
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: cs.primary),
                    ),
                  ),
                  const _ReviewAppTile(),
                  const Divider(height: 32),
                ],

                Padding(
                  key: _maintenanceKey,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Text(
                    AppLocalizations.of(context)!.settingsMaintenanceSection,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: cs.primary),
                  ),
                ),
                _CharacterMaintenanceTile(autoCheck: widget.focusMaintenance),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackupTile extends ConsumerStatefulWidget {
  const _BackupTile();

  @override
  ConsumerState<_BackupTile> createState() => _BackupTileState();
}

class _BackupTileState extends ConsumerState<_BackupTile> {
  bool _exporting = false;

  Future<void> _exportBackup() async {
    if (_exporting) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() => _exporting = true);

    try {
      final repo = ref.read(characterRepositoryProvider);
      final cachedCharacterCount = ref
          .read(characterListProvider)
          .valueOrNull
          ?.length;
      final backupJson = await repo.exportBackupToFileJson();
      await exportDndBackupFile(backupJson);
      final characterCount =
          cachedCharacterCount ?? (await repo.getAll()).length;

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsBackupExportSuccess)));
      unawaited(
        ref
            .read(appReviewServiceProvider)
            .recordMilestoneAndMaybeRequest(
              milestone: ReviewMilestone.backupExported,
              characterCount: characterCount,
            ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsBackupExportError)));
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      enabled: !_exporting,
      leading: _exporting
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.backup_outlined),
      title: Text(l10n.settingsBackupExportTitle),
      subtitle: Text(
        _exporting
            ? l10n.settingsBackupExporting
            : l10n.settingsBackupExportSubtitle,
      ),
      trailing: _exporting ? null : const Icon(Icons.file_download_outlined),
      onTap: _exporting ? null : _exportBackup,
    );
  }
}

class _ImportBackupTile extends ConsumerStatefulWidget {
  const _ImportBackupTile();

  @override
  ConsumerState<_ImportBackupTile> createState() => _ImportBackupTileState();
}

class _ImportBackupTileState extends ConsumerState<_ImportBackupTile> {
  bool _importing = false;

  Future<void> _importBackup() async {
    if (_importing) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() => _importing = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final picked = result.files.single;
      if (!picked.name.toLowerCase().endsWith('.dndbackup')) {
        throw const FormatException('invalid_backup_file');
      }

      final bytes = picked.bytes;
      if (bytes == null) {
        throw const FormatException('invalid_backup_file');
      }

      final fileJson = utf8.decode(bytes);
      final imported = await ref
          .read(characterRepositoryProvider)
          .importBackupFromFileJson(fileJson);
      ref.invalidate(characterListProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsBackupImportSuccess(imported.length)),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsBackupImportError)));
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      enabled: !_importing,
      leading: _importing
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.restore_page_outlined),
      title: Text(l10n.settingsBackupImportTitle),
      subtitle: Text(
        _importing
            ? l10n.settingsBackupImporting
            : l10n.settingsBackupImportSubtitle,
      ),
      trailing: _importing ? null : const Icon(Icons.file_upload_outlined),
      onTap: _importing ? null : _importBackup,
    );
  }
}

class _ReviewAppTile extends ConsumerStatefulWidget {
  const _ReviewAppTile();

  @override
  ConsumerState<_ReviewAppTile> createState() => _ReviewAppTileState();
}

class _ReviewAppTileState extends ConsumerState<_ReviewAppTile> {
  bool _opening = false;

  Future<void> _openStoreListing() async {
    if (_opening) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _opening = true);
    try {
      final opened = await ref
          .read(appReviewServiceProvider)
          .openStoreListing();
      if (!mounted) return;
      if (!opened) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.settingsReviewOpenError)));
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      enabled: !_opening,
      leading: _opening
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.star_outline),
      title: Text(l10n.settingsReviewTitle),
      subtitle: Text(l10n.settingsReviewSubtitle),
      trailing: _opening ? null : const Icon(Icons.open_in_new_outlined),
      onTap: _opening ? null : _openStoreListing,
    );
  }
}

class _CharacterUpdateRequiredNotice extends StatelessWidget {
  const _CharacterUpdateRequiredNotice();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Card(
        margin: EdgeInsets.zero,
        color: scheme.errorContainer,
        child: ListTile(
          leading: Icon(
            Icons.system_update_alt_outlined,
            color: scheme.onErrorContainer,
          ),
          title: Text(
            l10n.characterUpdateRequiredTitle,
            style: TextStyle(
              color: scheme.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            l10n.characterUpdateRequiredBody,
            style: TextStyle(color: scheme.onErrorContainer),
          ),
        ),
      ),
    );
  }
}

class _CharacterMaintenanceTile extends ConsumerStatefulWidget {
  const _CharacterMaintenanceTile({this.autoCheck = false});

  final bool autoCheck;

  @override
  ConsumerState<_CharacterMaintenanceTile> createState() =>
      _CharacterMaintenanceTileState();
}

enum _MaintenanceBusyTask { checking, backingUp, updating }

class _CharacterMaintenanceTileState
    extends ConsumerState<_CharacterMaintenanceTile> {
  bool _busy = false;
  _MaintenanceBusyTask? _busyTask;
  CharacterMigrationBatchReport? _preview;
  bool _autoCheckScheduled = false;

  @override
  void initState() {
    super.initState();
    _scheduleAutoCheckIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _CharacterMaintenanceTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleAutoCheckIfNeeded();
  }

  void _scheduleAutoCheckIfNeeded() {
    if (!widget.autoCheck || _autoCheckScheduled) return;
    _autoCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _check(showSnackBar: false);
    });
  }

  Future<void> _check({bool showSnackBar = true}) async {
    if (_busy) return;

    setState(() {
      _busy = true;
      _busyTask = _MaintenanceBusyTask.checking;
    });
    try {
      final report = await ref
          .read(characterRepositoryProvider)
          .previewMigrations();
      if (!mounted) return;
      setState(() => _preview = report);

      if (showSnackBar) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              report.hasUpdates
                  ? l10n.settingsMaintenanceUpdatesFound(report.outdatedCount)
                  : report.hasReadIssues
                  ? l10n.importErrorCorruptedCharacter
                  : l10n.settingsMaintenanceNoUpdates,
            ),
          ),
        );
        if (report.hasReadIssues && mounted) {
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.settingsMaintenanceError),
              content: SingleChildScrollView(
                child: Text(_formatMaintenanceReport(ctx, report)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppLocalizations.of(ctx)!.dialogClose),
                ),
              ],
            ),
          );
        }
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.settingsMaintenanceError),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _busyTask = null;
        });
      }
    }
  }

  Future<void> _apply() async {
    if (_busy) return;

    var preview = _preview;
    if (preview == null) {
      setState(() {
        _busy = true;
        _busyTask = _MaintenanceBusyTask.checking;
      });
      try {
        preview = await ref
            .read(characterRepositoryProvider)
            .previewMigrations();
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.settingsMaintenanceError,
            ),
          ),
        );
        return;
      } finally {
        if (mounted) {
          setState(() {
            _busy = false;
            _busyTask = null;
          });
        }
      }
      if (!mounted) return;
      setState(() => _preview = preview);
    }

    if (!preview.hasUpdates) {
      await _check();
      return;
    }

    final outdatedCount = preview.outdatedCount;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsMaintenanceConfirmTitle),
        content: Text(l10n.settingsMaintenanceConfirmBody(outdatedCount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.dialogConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _busy = true;
      _busyTask = _MaintenanceBusyTask.backingUp;
    });
    try {
      final repo = ref.read(characterRepositoryProvider);
      final backupJson = await repo.exportBackupToFileJson();
      await exportDndBackupFile(backupJson);

      if (!mounted) return;
      setState(() => _busyTask = _MaintenanceBusyTask.updating);

      final report = await repo.applyMigrations();
      final freshPreview = await repo.previewMigrations();
      ref.invalidate(characterListProvider);
      if (!mounted) return;
      setState(() => _preview = freshPreview);
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.settingsMaintenanceCompleteTitle),
          content: SingleChildScrollView(
            child: Text(_formatMaintenanceReport(ctx, report)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(ctx)!.dialogClose),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!mounted) return;
      final errorMessage = _busyTask == _MaintenanceBusyTask.backingUp
          ? l10n.settingsBackupExportError
          : l10n.settingsMaintenanceError;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _busyTask = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final preview = _preview;
    final hasUpdates = preview?.hasUpdates == true;
    final hasReadIssues = preview?.hasReadIssues == true;
    final showRequiredNotice =
        widget.autoCheck && (preview == null || hasUpdates);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showRequiredNotice) const _CharacterUpdateRequiredNotice(),
        ListTile(
          enabled: !_busy,
          leading: _busy
              ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  hasUpdates
                      ? Icons.system_update_alt_outlined
                      : Icons.manage_history_outlined,
                ),
          title: Text(
            hasUpdates
                ? l10n.settingsMaintenanceUpdateTitle
                : l10n.settingsMaintenanceCheckTitle,
          ),
          subtitle: Text(
            _busy
                ? _busySubtitle(l10n)
                : preview == null
                ? l10n.settingsMaintenanceCheckSubtitle
                : preview.hasUpdates
                ? l10n.settingsMaintenanceUpdatesFound(preview.outdatedCount)
                : hasReadIssues
                ? l10n.importErrorCorruptedCharacter
                : l10n.settingsMaintenanceNoUpdates,
          ),
          trailing: _busy
              ? null
              : Icon(
                  hasUpdates
                      ? Icons.chevron_right
                      : Icons.manage_search_outlined,
                ),
          onTap: _busy ? null : (hasUpdates ? _apply : _check),
        ),
      ],
    );
  }

  String _busySubtitle(AppLocalizations l10n) {
    return switch (_busyTask) {
      _MaintenanceBusyTask.backingUp => l10n.settingsBackupExporting,
      _ => l10n.settingsMaintenanceWorking,
    };
  }
}

String _formatMaintenanceReport(
  BuildContext context,
  CharacterMigrationBatchReport report,
) {
  final l10n = AppLocalizations.of(context)!;
  final buffer = StringBuffer();

  buffer.writeln(l10n.settingsMaintenanceReportChecked(report.checkedCount));
  buffer.writeln(l10n.settingsMaintenanceReportUpdated(report.outdatedCount));
  buffer.writeln(
    l10n.settingsMaintenanceReportDataChanged(report.dataChangedCount),
  );
  if (report.hasReadIssues) {
    buffer.writeln();
    buffer.writeln(l10n.settingsMaintenanceError);
    for (final issue in report.readIssues) {
      final id = issue.id == null ? '' : ' (${issue.id})';
      buffer.writeln(
        '- ${issue.source}$id: ${_formatMaintenanceReadIssue(context, issue)}',
      );
    }
  }

  final updated = report.characters.where((entry) => entry.needsMigration);
  for (final entry in updated) {
    buffer.writeln();
    buffer.writeln(entry.original.name);
    if (entry.changes.isEmpty) {
      buffer.writeln('- ${l10n.settingsMaintenanceReportVersionUpdated}');
      continue;
    }

    for (final change in entry.changes) {
      buffer.writeln('- ${_formatMaintenanceChange(context, change)}');
    }
  }

  return buffer.toString().trimRight();
}

String _formatMaintenanceReadIssue(
  BuildContext context,
  CharacterMigrationReadIssue issue,
) {
  final l10n = AppLocalizations.of(context)!;
  return switch (issue.message) {
    'invalid_json' => l10n.importErrorInvalidJson,
    'not_object' => l10n.importErrorNotObject,
    _ => l10n.importErrorCorruptedCharacter,
  };
}

String _formatMaintenanceChange(
  BuildContext context,
  CharacterMigrationChange change,
) {
  final l10n = AppLocalizations.of(context)!;
  if (change.code == 'equipment_weights_backfilled') {
    return l10n.settingsMaintenanceChangeEquipmentWeights(change.count);
  }
  if (change.code == 'equipment_items_normalized') {
    return l10n.settingsMaintenanceChangeEquipmentNormalized(change.count);
  }
  if (change.code == 'equipment_packs_expanded') {
    return l10n.settingsMaintenanceChangeEquipmentPacksExpanded(change.count);
  }
  if (change.code == 'equipment_order_normalized') {
    return l10n.settingsMaintenanceChangeEquipmentOrder(change.count);
  }
  if (change.code == 'multiclass_structure_prepared') {
    return l10n.settingsMaintenanceChangeMulticlassStructure;
  }
  if (change.code == 'spell_slots_synced' ||
      change.code == 'standard_spell_slots_synced') {
    return l10n.settingsMaintenanceChangeSpellSlots;
  }
  if (change.code == 'pact_magic_slots_synced') {
    return l10n.settingsMaintenanceChangePactMagicSlots;
  }
  if (change.code == 'armor_class_recalculated') {
    return l10n.settingsMaintenanceChangeArmorClass;
  }

  return l10n.settingsMaintenanceChangeGeneric(change.count);
}

class _LanguageTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    final l10n = AppLocalizations.of(context)!;
    String label;
    if (locale == null) {
      label = l10n.settingsSystemDefault;
    } else if (locale.languageCode == 'en') {
      label = 'English';
    } else if (locale.languageCode == 'pt') {
      label = 'Português';
    } else if (locale.languageCode == 'es') {
      label = 'Espa\u00f1ol';
    } else if (locale.languageCode == 'fr') {
      label = 'Fran\u00e7ais';
    } else {
      label = locale.languageCode;
    }

    return ListTile(
      leading: const Icon(Icons.language_outlined),
      title: Text(l10n.settingsAppLanguage),
      subtitle: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _openLanguagePicker(context, ref, locale),
    );
  }

  void _openLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    Locale? current,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      (label: l10n.settingsSystemDefault, locale: null),
      (label: 'English', locale: const Locale('en')),
      (label: 'Português', locale: const Locale('pt')),
      (label: 'Español', locale: const Locale('es')),
      (label: 'Français', locale: const Locale('fr')),
      (label: 'Deutsch', locale: const Locale('de')),
      (label: 'Italiano', locale: const Locale('it')),
      (label: '日本語', locale: const Locale('ja')),
      (label: '한국어', locale: const Locale('ko')),
      (label: 'Русский', locale: const Locale('ru')),
      (label: '中文', locale: const Locale('zh')),
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollController) => Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.settingsChooseLanguage,
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    for (final opt in options)
                      ListTile(
                        title: Text(opt.label),
                        trailing:
                            opt.locale?.languageCode == current?.languageCode &&
                                !(opt.locale == null && current != null)
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(ctx).colorScheme.primary,
                              )
                            : const SizedBox.shrink(),
                        selected:
                            opt.locale?.languageCode == current?.languageCode &&
                            !(opt.locale == null && current != null),
                        onTap: () {
                          ref
                              .read(localeProvider.notifier)
                              .setLocale(opt.locale);
                          Navigator.pop(ctx);
                        },
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemePreferencePanel extends StatelessWidget {
  const _ThemePreferencePanel({
    required this.theme,
    required this.scheme,
    required this.onTap,
  });

  final AppTheme theme;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appScheme = Theme.of(context).colorScheme;
    final modeLabel = theme.brightness == Brightness.dark
        ? l10n.settingsDark
        : l10n.settingsLight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.surfaceContainerHighest,
                  scheme.surface,
                  Color.alphaBlend(
                    scheme.primary.withValues(alpha: 0.18),
                    scheme.surface,
                  ),
                ],
              ),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.42),
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _ThemeMiniPreview(scheme: scheme, size: 88),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          theme.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          modeLabel,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                        _ColorSwatch(scheme: scheme, size: 36),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: appScheme.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeMiniPreview extends StatelessWidget {
  const _ThemeMiniPreview({required this.scheme, required this.size});

  final ColorScheme scheme;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: size * 0.22,
                    height: size * 0.22,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Container(
                      height: size * 0.08,
                      decoration: BoxDecoration(
                        color: scheme.onSurface,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                height: size * 0.12,
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              SizedBox(height: size * 0.08),
              FractionallySizedBox(
                widthFactor: 0.72,
                child: Container(
                  height: size * 0.12,
                  decoration: BoxDecoration(
                    color: scheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  final AppTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Preview the same explicit ColorScheme used by the full app theme.
    final previewScheme = theme.toThemeData().colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: Color.alphaBlend(
          previewScheme.primary.withValues(alpha: 0.08),
          previewScheme.surfaceContainerLow,
        ),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          leading: _ThemeMiniPreview(scheme: previewScheme, size: 58),
          textColor: previewScheme.onSurface,
          iconColor: previewScheme.primary,
          selectedColor: previewScheme.primary,
          title: Text(theme.name),
          subtitle: Text(
            theme.brightness == Brightness.dark
                ? AppLocalizations.of(context)!.settingsDark
                : AppLocalizations.of(context)!.settingsLight,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: previewScheme.onSurfaceVariant,
            ),
          ),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: previewScheme.primary)
              : const SizedBox.shrink(),
          selected: isSelected,
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.scheme, this.size = 44});

  final ColorScheme scheme;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size / 2,
                height: size / 2,
                color: scheme.primary,
              ),
              Container(
                width: size / 2,
                height: size / 2,
                color: scheme.secondary,
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size / 2,
                height: size / 2,
                color: scheme.tertiary,
              ),
              Container(
                width: size / 2,
                height: size / 2,
                color: scheme.surface,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnitSystemTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(unitSystemProvider);
    final l10n = AppLocalizations.of(context)!;

    String label(UnitSystem v) => switch (v) {
      UnitSystem.imperial => l10n.settingsUnitImperial,
      UnitSystem.metric => l10n.settingsUnitMetric,
      UnitSystem.squares => l10n.settingsUnitSquares,
    };

    return ListTile(
      leading: const Icon(Icons.straighten_outlined),
      title: Text(l10n.settingsUnitSystem),
      subtitle: Text(label(current)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _openUnitPicker(context, ref, current, label, l10n),
    );
  }

  void _openUnitPicker(
    BuildContext context,
    WidgetRef ref,
    UnitSystem current,
    String Function(UnitSystem) label,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.settingsChooseUnitSystem,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
            ),
            for (final v in UnitSystem.values)
              ListTile(
                title: Text(label(v)),
                trailing: v == current
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(ctx).colorScheme.primary,
                      )
                    : const SizedBox.shrink(),
                selected: v == current,
                onTap: () {
                  ref.read(unitSystemProvider.notifier).setUnitSystem(v);
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _KeepScreenOnTile extends ConsumerWidget {
  const _KeepScreenOnTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(keepScreenOnCharacterSheetProvider);
    final l10n = AppLocalizations.of(context)!;

    return SwitchListTile.adaptive(
      secondary: const Icon(Icons.screen_lock_portrait_outlined),
      title: Text(l10n.settingsKeepScreenOnTitle),
      subtitle: Text(l10n.settingsKeepScreenOnSubtitle),
      value: enabled,
      onChanged: (value) {
        ref.read(keepScreenOnCharacterSheetProvider.notifier).setEnabled(value);
      },
    );
  }
}
