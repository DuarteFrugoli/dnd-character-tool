import 'package:flutter/material.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:dnd_character_tool/l10n/ability_l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/srd/srd_i18n_service.dart';
import '../../../data/datasources/srd/srd_models.dart';
import '../../../shared/providers/providers.dart';
import '../../../shared/widgets/srd_detail_sheets.dart';
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
                  SubclassSelector(
                    cls: ClassDetail.from2014(cls),
                    i18n: i18n,
                    selected: ref
                        .watch(characterDraftProvider)
                        .selectedSubclass
                        ?.name,
                    onSelect: (name) => ref
                        .read(characterDraftProvider.notifier)
                        .setSubclass(
                          cls.subclasses
                              .where((sub) => sub.name == name)
                              .firstOrNull,
                        ),
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
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: isSelected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
                tooltip: AppLocalizations.of(context)!.detailSheetInfoTooltip,
                onPressed: () => showClassDetailSheet(context, ClassDetail.from2014(cls), i18n),
              ),
              if (isSelected) Icon(Icons.check_circle, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
