import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dnd_character_tool/l10n/app_localizations.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_themes.dart';
import '../../core/theme/theme_provider.dart';

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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final currentScheme = current.toThemeData().colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsTitle)),
      body: ListView(
        padding: EdgeInsets.only(top: 8, bottom: bottomPadding + 16),
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
        ],
      ),
    );
  }
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
                  l10n.settingsChooseLanguage,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
            ),
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
