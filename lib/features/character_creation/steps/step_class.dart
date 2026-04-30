import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/srd/srd_data_source.dart';
import '../../../data/datasources/srd/srd_models.dart';
import '../character_draft_provider.dart';

class StepClass extends ConsumerStatefulWidget {
  const StepClass({super.key});

  @override
  ConsumerState<StepClass> createState() => _StepClassState();
}

class _StepClassState extends ConsumerState<StepClass> {
  late final Future<List<SrdClass>> _classesFuture;

  @override
  void initState() {
    super.initState();
    _classesFuture = SrdDataSource.instance.getClasses();
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(characterDraftProvider).selectedClass;

    return FutureBuilder<List<SrdClass>>(
      future: _classesFuture,
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ClassCard(
                  cls: cls,
                  isSelected: isSelected,
                  onTap: () =>
                      ref.read(characterDraftProvider.notifier).setClass(cls),
                ),
                if (isSelected && cls.subclasses.isNotEmpty)
                  _SubclassSelector(
                    cls: cls,
                    selectedSubclass:
                        ref.watch(characterDraftProvider).selectedSubclass,
                    onSelect: (s) => ref
                        .read(characterDraftProvider.notifier)
                        .setSubclass(s),
                  ),
              ],
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
                    if (cls.subclasses.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${cls.subclasses.length} ${cls.subclassFeatureName} options',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isSelected
                                    ? scheme.onPrimaryContainer
                                    : scheme.secondary,
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

class _SubclassSelector extends StatelessWidget {
  const _SubclassSelector({
    required this.cls,
    required this.selectedSubclass,
    required this.onSelect,
  });

  final SrdClass cls;
  final SrdSubclass? selectedSubclass;
  final ValueChanged<SrdSubclass?> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Choose a ${cls.subclassFeatureName} (Lv ${cls.subclassLevel}):',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          ...cls.subclasses.map((sub) {
            final isSelected = selectedSubclass?.name == sub.name;
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              color: isSelected ? scheme.secondaryContainer : scheme.surface,
              child: InkWell(
                onTap: () => onSelect(isSelected ? null : sub),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sub.description,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle,
                            color: scheme.secondary, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
