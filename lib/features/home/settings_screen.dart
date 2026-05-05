import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_themes.dart';
import '../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeProvider);
    final cs = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: EdgeInsets.only(top: 8, bottom: bottomPadding + 16),
        children: [
          // ── Tema Visual ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Tema Visual',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: cs.primary),
            ),
          ),
          ...appThemes.map((theme) => _ThemeTile(
                theme: theme,
                isSelected: theme.id == current.id,
                onTap: () => ref.read(themeProvider.notifier).setTheme(theme),
              )),

          const Divider(height: 32),

          // ── Idioma ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              'Idioma',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: cs.primary),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('Idioma do app'),
            subtitle: const Text('Em breve — Português e English'),
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
    );

    return ListTile(
      onTap: onTap,
      leading: _ColorSwatch(scheme: previewScheme),
      title: Text(theme.name),
      subtitle: Text(
        theme.brightness == Brightness.dark ? 'Escuro' : 'Claro',
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
      child: SizedBox(
        width: 44,
        height: 44,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: ColoredBox(color: scheme.primary)),
                  Expanded(child: ColoredBox(color: scheme.secondary)),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: ColoredBox(color: scheme.tertiary)),
                  Expanded(child: ColoredBox(color: scheme.surface)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
