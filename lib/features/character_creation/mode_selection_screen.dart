import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ModeSelectionScreen extends ConsumerWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Character')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'How do you want to create your character?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          _ModeCard(
            icon: Icons.menu_book,
            title: 'Guided',
            subtitle:
                'Step-by-step wizard. Choose class, race, background, skills and attributes one at a time. Recommended for new players.',
            onTap: () => context.push('/create/guided'),
          ),
          const SizedBox(height: 12),
          _ModeCard(
            icon: Icons.edit_note,
            title: 'Manual',
            subtitle:
                'Fill in everything yourself. All fields are free and no values are calculated for you. Best for experienced players.',
            onTap: () => context.push('/create/manual'),
            comingSoon: true,
          ),
          const SizedBox(height: 12),
          _ModeCard(
            icon: Icons.casino,
            title: 'Random',
            subtitle:
                'Everything is rolled for you — race, class, background and attributes. Great for a challenge or one-shots.',
            onTap: () {},
            comingSoon: true,
          ),
          const SizedBox(height: 12),
          _ModeCard(
            icon: Icons.tune,
            title: 'Semi-random',
            subtitle:
                'You pick the important choices; everything else is rolled. Good for when you have a concept but want surprises.',
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
                          Text(title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium),
                          if (comingSoon) ...[
                            const SizedBox(width: 8),
                            Chip(
                              label: const Text('Soon'),
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .labelSmall,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: scheme.onSurfaceVariant)),
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
