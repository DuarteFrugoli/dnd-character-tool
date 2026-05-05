import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_themes.dart';
import '../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _openThemePicker(BuildContext context, WidgetRef ref, AppTheme current) {
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
                  'Choose a Theme',
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

    final currentScheme = ColorScheme.fromSeed(
      seedColor: current.seedColor,
      brightness: current.brightness,
      contrastLevel: current.contrastLevel,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: EdgeInsets.only(top: 8, bottom: bottomPadding + 16),
        children: [
          // ── Visual Theme ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Visual Theme',
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
              current.brightness == Brightness.dark ? 'Dark' : 'Light',
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
              'Language',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: cs.primary),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('App language'),
            subtitle: const Text('Coming soon — Portuguese and English'),
            enabled: false,
          ),
        ],
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

    // Preview swatch using a small ColorScheme
    final previewScheme = ColorScheme.fromSeed(
      seedColor: theme.seedColor,
      brightness: theme.brightness,
      contrastLevel: theme.contrastLevel,
    );

    return ListTile(
      onTap: onTap,
      leading: _ColorSwatch(scheme: previewScheme),
      title: Text(theme.name),
      subtitle: Text(
        theme.brightness == Brightness.dark ? 'Dark' : 'Light',
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
