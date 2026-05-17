import 'package:flutter/material.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:dnd_character_tool/l10n/ability_l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/srd/srd_i18n_service.dart';
import '../../../data/datasources/srd/srd_models.dart';
import '../../../shared/providers/providers.dart';
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
    _classesFuture = ref.read(srdDataSourceProvider).getClasses();
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(characterDraftProvider).selectedClass;
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;

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
                  i18n: i18n,
                  isSelected: isSelected,
                  onTap: () {
                    if (isSelected) {
                      ref.read(characterDraftProvider.notifier).clearClass();
                    } else {
                      ref.read(characterDraftProvider.notifier).setClass(cls);
                    }
                  },
                ),
                if (isSelected && cls.subclasses.isNotEmpty)
                  _SubclassSelector(
                    cls: cls,
                    i18n: i18n,
                    selectedSubclass: ref
                        .watch(characterDraftProvider)
                        .selectedSubclass,
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
    required this.i18n,
    required this.isSelected,
    required this.onTap,
  });

  final SrdClass cls;
  final SrdI18nService i18n;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final clsName = i18n.className(cls.name);
    final subclassFeature =
        i18n.classSubclassFeatureName(cls.name) ?? cls.subclassFeatureName;
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
                    Text(
                      clsName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isSelected ? scheme.onPrimaryContainer : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.stepHitDieLabel}: d${cls.hitDie}  ·  ${l10n.stepSavesLabel}: ${cls.savingThrows.map((s) => abilityName(l10n, s)).join(', ')}',
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
                          '${l10n.stepSpellcastingLabel}: ${abilityName(l10n, cls.spellcastingAbility ?? '')}',
                          style: Theme.of(context).textTheme.bodySmall
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
                          '${cls.subclasses.length} $subclassFeature ${l10n.stepOptionsLabel}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isSelected
                                    ? scheme.onPrimaryContainer
                                    : scheme.secondary,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: scheme.primary),
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
    required this.i18n,
    required this.selectedSubclass,
    required this.onSelect,
  });

  final SrdClass cls;
  final SrdI18nService i18n;
  final SrdSubclass? selectedSubclass;
  final ValueChanged<SrdSubclass?> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final subclassFeature =
        i18n.classSubclassFeatureName(cls.name) ?? cls.subclassFeatureName;
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.stepChooseSubclassPrompt(subclassFeature, cls.subclassLevel),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          ...cls.subclasses.map((sub) {
            final isSelected = selectedSubclass?.name == sub.name;
            final subName = i18n.subclassName(cls.name, sub.name);
            final subDesc =
                i18n.subclassDescription(cls.name, sub.name) ?? sub.description;
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              color: isSelected ? scheme.secondaryContainer : scheme.surface,
              child: InkWell(
                onTap: () => onSelect(isSelected ? null : sub),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subName,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subDesc,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: scheme.secondary,
                          size: 20,
                        ),
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
