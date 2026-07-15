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
import '../character_list/character_list_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeProvider);
    final cs = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    final currentScheme = current.toThemeData().colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsTitle)),
      body: ListView(
        padding: EdgeInsets.only(top: 8, bottom: bottomPadding + 32),
        children: [
          // ── Visual Theme ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              AppLocalizations.of(context)!.settingsSectionTheme,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: cs.primary),
            ),
          ),
          ListTile(
            leading: _ColorSwatch(scheme: currentScheme),
            title: Text(current.name),
            subtitle: Text(
              current.brightness == Brightness.dark
                  ? AppLocalizations.of(context)!.settingsDark
                  : AppLocalizations.of(context)!.settingsLight,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
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
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: cs.primary),
            ),
          ),
          _LanguageTile(),

          const Divider(height: 32),

          // ── Units ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              AppLocalizations.of(context)!.settingsSectionUnits,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: cs.primary),
            ),
          ),
          _UnitSystemTile(),

          const Divider(height: 32),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              _backupLabels(context).section,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: cs.primary),
            ),
          ),
          const _BackupTile(),
          const _ImportBackupTile(),

          const Divider(height: 32),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              _maintenanceLabels(context).section,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: cs.primary),
            ),
          ),
          const _CharacterMaintenanceTile(),
        ],
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

    final labels = _backupLabels(context);
    setState(() => _exporting = true);

    try {
      final backupJson =
          await ref.read(characterRepositoryProvider).exportBackupToFileJson();
      await exportDndBackupFile(backupJson);

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(labels.success)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(labels.error)),
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = _backupLabels(context);

    return ListTile(
      enabled: !_exporting,
      leading: _exporting
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.backup_outlined),
      title: Text(labels.title),
      subtitle: Text(_exporting ? labels.exporting : labels.subtitle),
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

    final labels = _backupLabels(context);
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
        SnackBar(content: Text(_backupImportSuccess(context, imported.length))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(labels.importError)),
      );
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = _backupLabels(context);

    return ListTile(
      enabled: !_importing,
      leading: _importing
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.restore_page_outlined),
      title: Text(labels.importTitle),
      subtitle: Text(_importing ? labels.importing : labels.importSubtitle),
      trailing: _importing ? null : const Icon(Icons.file_upload_outlined),
      onTap: _importing ? null : _importBackup,
    );
  }
}

class _CharacterMaintenanceTile extends ConsumerStatefulWidget {
  const _CharacterMaintenanceTile();

  @override
  ConsumerState<_CharacterMaintenanceTile> createState() =>
      _CharacterMaintenanceTileState();
}

class _CharacterMaintenanceTileState
    extends ConsumerState<_CharacterMaintenanceTile> {
  bool _busy = false;
  CharacterMigrationBatchReport? _preview;

  Future<void> _check() async {
    if (_busy) return;

    setState(() => _busy = true);
    try {
      final report =
          await ref.read(characterRepositoryProvider).previewMigrations();
      if (!mounted) return;
      setState(() => _preview = report);

      final labels = _maintenanceLabels(context);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            report.hasUpdates
                ? _maintenanceUpdatesFound(context, report.outdatedCount)
                : labels.noUpdates,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_maintenanceLabels(context).error)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _apply() async {
    if (_busy) return;

    var preview = _preview;
    if (preview == null) {
      setState(() => _busy = true);
      try {
        preview = await ref.read(characterRepositoryProvider).previewMigrations();
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_maintenanceLabels(context).error)),
        );
        return;
      } finally {
        if (mounted) setState(() => _busy = false);
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
    final labels = _maintenanceLabels(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(labels.confirmTitle),
        content: Text(_maintenanceConfirmBody(ctx, outdatedCount)),
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

    setState(() => _busy = true);
    try {
      final repo = ref.read(characterRepositoryProvider);
      final report = await repo.applyMigrations();
      final freshPreview = await repo.previewMigrations();
      ref.invalidate(characterListProvider);
      if (!mounted) return;
      setState(() => _preview = freshPreview);
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(labels.completeTitle),
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
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(labels.error)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = _maintenanceLabels(context);
    final preview = _preview;
    final hasUpdates = preview?.hasUpdates == true;

    return ListTile(
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
      title: Text(hasUpdates ? labels.updateTitle : labels.checkTitle),
      subtitle: Text(
        _busy
            ? labels.working
            : preview == null
                ? labels.checkSubtitle
                : preview.hasUpdates
                    ? _maintenanceUpdatesFound(
                        context,
                        preview.outdatedCount,
                      )
                    : labels.noUpdates,
      ),
      trailing: _busy
          ? null
          : Icon(
              hasUpdates
                  ? Icons.chevron_right
                  : Icons.manage_search_outlined,
            ),
      onTap: _busy ? null : (hasUpdates ? _apply : _check),
    );
  }
}

({
  String section,
  String title,
  String subtitle,
  String exporting,
  String success,
  String error,
  String importTitle,
  String importSubtitle,
  String importing,
  String importError,
}) _backupLabels(BuildContext context) {
  final language = Localizations.localeOf(context).languageCode;
  if (language == 'pt') {
    return (
      section: 'Backup',
      title: 'Exportar backup',
      subtitle: 'Salva todos os personagens em um arquivo de backup.',
      exporting: 'Criando backup...',
      success: 'Backup exportado.',
      error: 'Nao foi possivel exportar o backup.',
      importTitle: 'Importar backup',
      importSubtitle: 'Restaura personagens de um arquivo .dndbackup.',
      importing: 'Importando backup...',
      importError: 'Nao foi possivel importar o backup.',
    );
  }

  return (
    section: 'Backup',
    title: 'Export backup',
    subtitle: 'Save all characters in a backup file.',
    exporting: 'Creating backup...',
    success: 'Backup exported.',
    error: 'Could not export backup.',
    importTitle: 'Import backup',
    importSubtitle: 'Restore characters from a .dndbackup file.',
    importing: 'Importing backup...',
    importError: 'Could not import backup.',
  );
}

String _backupImportSuccess(BuildContext context, int count) {
  final language = Localizations.localeOf(context).languageCode;
  if (language == 'pt') {
    if (count == 1) return '1 personagem importado do backup.';
    return '$count personagens importados do backup.';
  }

  if (count == 1) return '1 character imported from backup.';
  return '$count characters imported from backup.';
}

({
  String section,
  String checkTitle,
  String checkSubtitle,
  String updateTitle,
  String working,
  String noUpdates,
  String error,
  String confirmTitle,
  String completeTitle,
}) _maintenanceLabels(BuildContext context) {
  final language = Localizations.localeOf(context).languageCode;
  if (language == 'pt') {
    return (
      section: 'Manutencao',
      checkTitle: 'Verificar atualizacoes de personagens',
      checkSubtitle: 'Procura correcoes de dados salvos.',
      updateTitle: 'Atualizar personagens',
      working: 'Verificando atualizacoes...',
      noUpdates: 'Todos os personagens ja estao atualizados.',
      error: 'Nao foi possivel atualizar os personagens.',
      confirmTitle: 'Atualizar personagens?',
      completeTitle: 'Atualizacao concluida',
    );
  }

  return (
    section: 'Maintenance',
    checkTitle: 'Check character updates',
    checkSubtitle: 'Look for saved data fixes.',
    updateTitle: 'Update characters',
    working: 'Checking updates...',
    noUpdates: 'All characters are already up to date.',
    error: 'Could not update characters.',
    confirmTitle: 'Update characters?',
    completeTitle: 'Update complete',
  );
}

String _maintenanceUpdatesFound(BuildContext context, int count) {
  final language = Localizations.localeOf(context).languageCode;
  if (language == 'pt') {
    if (count == 1) return '1 personagem precisa de atualizacao.';
    return '$count personagens precisam de atualizacao.';
  }

  if (count == 1) return '1 character needs an update.';
  return '$count characters need updates.';
}

String _maintenanceConfirmBody(BuildContext context, int count) {
  final language = Localizations.localeOf(context).languageCode;
  if (language == 'pt') {
    return '${_maintenanceUpdatesFound(context, count)} '
        'Recomendamos exportar um backup antes de continuar.';
  }

  return '${_maintenanceUpdatesFound(context, count)} '
      'We recommend exporting a backup before continuing.';
}

String _formatMaintenanceReport(
  BuildContext context,
  CharacterMigrationBatchReport report,
) {
  final language = Localizations.localeOf(context).languageCode;
  final buffer = StringBuffer();

  if (language == 'pt') {
    buffer.writeln('${report.checkedCount} personagens verificados.');
    buffer.writeln('${report.outdatedCount} personagens atualizados.');
    buffer.writeln('${report.dataChangedCount} personagens com dados corrigidos.');
  } else {
    buffer.writeln('${report.checkedCount} characters checked.');
    buffer.writeln('${report.outdatedCount} characters updated.');
    buffer.writeln('${report.dataChangedCount} characters had data fixes.');
  }

  final updated = report.characters.where((entry) => entry.needsMigration);
  for (final entry in updated) {
    buffer.writeln();
    buffer.writeln(entry.original.name);
    if (entry.changes.isEmpty) {
      buffer.writeln(
        language == 'pt'
            ? '- Versao de dados atualizada.'
            : '- Data version updated.',
      );
      continue;
    }

    for (final change in entry.changes) {
      buffer.writeln('- ${_formatMaintenanceChange(context, change)}');
    }
  }

  return buffer.toString().trimRight();
}

String _formatMaintenanceChange(
  BuildContext context,
  CharacterMigrationChange change,
) {
  final language = Localizations.localeOf(context).languageCode;
  if (change.code == 'equipment_weights_backfilled') {
    if (language == 'pt') {
      if (change.count == 1) return 'Peso de 1 item corrigido.';
      return 'Peso de ${change.count} itens corrigido.';
    }

    if (change.count == 1) return 'Fixed the weight of 1 item.';
    return 'Fixed the weight of ${change.count} items.';
  }

  if (language == 'pt') {
    return '${change.count} alteracoes aplicadas.';
  }
  return '${change.count} changes applied.';
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
      label = 'Português';    } else if (locale.languageCode == 'es') {
      label = 'Espa\u00f1ol';
    } else if (locale.languageCode == 'fr') {
      label = 'Fran\u00e7ais';    } else {
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

  void _openLanguagePicker(BuildContext context, WidgetRef ref, Locale? current) {
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
                        trailing: opt.locale?.languageCode == current?.languageCode &&
                                !(opt.locale == null && current != null)
                            ? Icon(Icons.check_circle,
                                color: Theme.of(ctx).colorScheme.primary)
                            : const SizedBox.shrink(),
                        selected: opt.locale?.languageCode == current?.languageCode &&
                            !(opt.locale == null && current != null),
                        onTap: () {
                          ref.read(localeProvider.notifier).setLocale(opt.locale);
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
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: cs.onSurfaceVariant),
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
      UnitSystem.metric   => l10n.settingsUnitMetric,
      UnitSystem.squares  => l10n.settingsUnitSquares,
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
                    ? Icon(Icons.check_circle,
                        color: Theme.of(ctx).colorScheme.primary)
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
