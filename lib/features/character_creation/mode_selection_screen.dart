import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class ModeSelectionScreen extends ConsumerWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.modeSelectionTitle),
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l10n.modeSelectionQuestion,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          _ModeCard(
            icon: Icons.menu_book,
            title: l10n.modeGuidedTitle,
            subtitle: l10n.modeGuidedSubtitle,
            onTap: () => context.push('/create/guided'),
          ),
          const SizedBox(height: 12),
          _ModeCard(
            icon: Icons.edit_note,
            title: l10n.modeManualTitle,
            subtitle: l10n.modeManualSubtitle,
            onTap: () => context.push('/create/manual'),
            comingSoon: true,
          ),
          const SizedBox(height: 12),
          _ModeCard(
            icon: Icons.casino,
            title: l10n.modeRandomTitle,
            subtitle: l10n.modeRandomSubtitle,
            onTap: () {},
            comingSoon: true,
          ),
          const SizedBox(height: 12),
          _ModeCard(
            icon: Icons.tune,
            title: l10n.modeSemiRandomTitle,
            subtitle: l10n.modeSemiRandomSubtitle,
            onTap: () {},
            comingSoon: true,
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.comingSoon = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final disabled = comingSoon;

    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: Card(
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, size: 36, color: scheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (comingSoon) ...[
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                AppLocalizations.of(context)!.modeComingSoon,
                              ),
                              labelStyle: Theme.of(
                                context,
                              ).textTheme.labelSmall,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!disabled)
                  Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
