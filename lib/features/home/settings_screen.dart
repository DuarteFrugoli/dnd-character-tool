import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dnd_character_tool/l10n/app_localizations.dart';

import '../../core/locale/locale_provider.dart';
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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsTitle)),
      body: ResponsiveScaffoldBody(
        maxWidth: 720,
        child: ListView(
          padding: EdgeInsets.only(top: 8, bottom: bottomPadding + 32),
          children: [
            // ── Visual Theme ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                AppLocalizations.of(context)!.settingsSectionTheme,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: cs.primary),
              ),
            ),
            ListTile(
              leading: _ColorSwatch(scheme: currentScheme),
              title: Text(current.name),
              subtitle: Text(
                current.brightness == Brightness.dark
                    ? AppLocalizations.of(context)!.settingsDark
                    : AppLocalizations.of(context)!.settingsLight,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openThemePicker(context, ref, current),
            ),

            const Divider(height: 32),

            // ── Language ──────────────────────────────────────────────────────
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

            // ── Units ─────────────────────────────────────────────────────────
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
                AppLocalizations.of(context)!.settingsBackupSection,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: cs.primary),
              ),
            ),
            const _BackupTile(),
            const _ImportBackupTile(),

            const Divider(height: 32),

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
      final backupJson = await ref
          .read(characterRepositoryProvider)
          .exportBackupToFileJson();
      await exportDndBackupFile(backupJson);

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsBackupExportSuccess)));
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
    final cs = Theme.of(context).colorScheme;

    // Preview swatch — use the real generated scheme so overrides (e.g. surfaceColor) are reflected
    final previewScheme = theme.toThemeData().colorScheme;

    return ListTile(
      onTap: onTap,
      leading: _ColorSwatch(scheme: previewScheme),
      title: Text(theme.name),
      subtitle: Text(
        theme.brightness == Brightness.dark
            ? AppLocalizations.of(context)!.settingsDark
            : AppLocalizations.of(context)!.settingsLight,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: cs.primary)
          : const SizedBox.shrink(),
      selected: isSelected,
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.scheme});
  final ColorScheme scheme;

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
              Container(width: 22, height: 22, color: scheme.primary),
              Container(width: 22, height: 22, color: scheme.secondary),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 22, height: 22, color: scheme.tertiary),
              Container(width: 22, height: 22, color: scheme.surface),
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
