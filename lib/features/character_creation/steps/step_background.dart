import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/srd/srd_data_source.dart';
import '../../../data/datasources/srd/srd_models.dart';
import '../character_draft_provider.dart';

class StepBackground extends ConsumerWidget {
  const StepBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(characterDraftProvider).selectedBackground;

    return FutureBuilder<List<SrdBackground>>(
      future: SrdDataSource.instance.getBackgrounds(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final backgrounds = snap.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: backgrounds.length,
          itemBuilder: (context, i) {
            final bg = backgrounds[i];
            final isSelected = selected?.name == bg.name;
            return _BackgroundCard(
              bg: bg,
              isSelected: isSelected,
              onTap: () => ref
                  .read(characterDraftProvider.notifier)
                  .setBackground(bg),
            );
          },
        );
      },
    );
  }
}

class _BackgroundCard extends StatelessWidget {
  const _BackgroundCard({
    required this.bg,
    required this.isSelected,
    required this.onTap,
  });

  final SrdBackground bg;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? scheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bg.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isSelected
                                      ? scheme.onPrimaryContainer
                                      : null,
                                )),
                    const SizedBox(height: 4),
                    Text(
                      'Skills: ${bg.skillProficiencies.join(', ')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? scheme.onPrimaryContainer
                                : scheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Feature: ${bg.feature.name}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? scheme.onPrimaryContainer
                                : scheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 8),
                      Text(
                        bg.feature.description,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
