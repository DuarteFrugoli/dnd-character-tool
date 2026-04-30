import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/srd/srd_data_source.dart';
import '../../../data/datasources/srd/srd_models.dart';
import '../character_draft_provider.dart';

class StepClass extends ConsumerWidget {
  const StepClass({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(characterDraftProvider).selectedClass;

    return FutureBuilder<List<SrdClass>>(
      future: SrdDataSource.instance.getClasses(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final classes = snap.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: classes.length,
          itemBuilder: (context, i) {
            final cls = classes[i];
            final isSelected = selected?.name == cls.name;
            return _ClassCard(
              cls: cls,
              isSelected: isSelected,
              onTap: () =>
                  ref.read(characterDraftProvider.notifier).setClass(cls),
            );
          },
        );
      },
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({
    required this.cls,
    required this.isSelected,
    required this.onTap,
  });

  final SrdClass cls;
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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cls.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: isSelected
                                  ? scheme.onPrimaryContainer
                                  : null,
                            )),
                    const SizedBox(height: 4),
                    Text(
                      'Hit die: d${cls.hitDie}  ·  Saves: ${cls.savingThrows.join(', ')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? scheme.onPrimaryContainer
                                : scheme.onSurfaceVariant,
                          ),
                    ),
                    if (cls.isSpellcaster)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Spellcasting: ${cls.spellcastingAbility}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: isSelected
                                    ? scheme.onPrimaryContainer
                                    : scheme.primary,
                              ),
                        ),
                      ),
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
