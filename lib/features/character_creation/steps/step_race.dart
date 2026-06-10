import 'package:flutter/material.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:dnd_character_tool/l10n/ability_l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/srd/srd_i18n_service.dart';
import '../../../data/datasources/srd/srd_models.dart';
import '../../../shared/providers/providers.dart';
import '../../../core/units/unit_system_provider.dart';
import '../../../core/units/unit_formatter.dart';
import '../../../shared/widgets/srd_detail_sheets.dart';
import '../character_draft_provider.dart';

class StepRace extends ConsumerStatefulWidget {
  const StepRace({super.key});

  @override
  ConsumerState<StepRace> createState() => _StepRaceState();
}

class _StepRaceState extends ConsumerState<StepRace> {
  late final Future<List<SrdRace>> _racesFuture;

  @override
  void initState() {
    super.initState();
    _racesFuture = ref.read(srdDataSourceProvider).getRaces();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(characterDraftProvider);
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;

    return FutureBuilder<List<SrdRace>>(
      future: _racesFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final races = snap.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: races.length,
          itemBuilder: (context, i) {
            final race = races[i];
            final isSelected = draft.selectedRace?.name == race.name;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RaceCard(
                  race: race,
                  i18n: i18n,
                  isSelected: isSelected,
                  onTap: () {
                    if (isSelected) {
                      ref.read(characterDraftProvider.notifier).clearRace();
                    } else {
                      ref.read(characterDraftProvider.notifier).setRace(race);
                    }
                  },
                ),
                if (isSelected && race.subraces.isNotEmpty)
                  _SubraceSelector(
                    race: race,
                    i18n: i18n,
                    selectedSubrace: draft.selectedSubrace,
                    onSelect: (s) =>
                        ref.read(characterDraftProvider.notifier).setSubrace(s),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _RaceCard extends ConsumerWidget {
  const _RaceCard({
    required this.race,
    required this.i18n,
    required this.isSelected,
    required this.onTap,
  });

  final SrdRace race;
  final SrdI18nService i18n;
  final bool isSelected;
  final VoidCallback onTap;

  String _asiText(AppLocalizations l10n) {
    return race.abilityScoreIncreases.entries
        .map((e) => '+${e.value} ${abilityName(l10n, e.key)}')
        .join(', ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final raceName = i18n.raceName(race.name);
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
                      raceName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isSelected ? scheme.onPrimaryContainer : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.stepRaceSpeedLabel}: ${formatDistance(race.speed, ref.watch(unitSystemProvider))}  ·  ${l10n.stepRaceASILabel}: ${_asiText(l10n)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? scheme.onPrimaryContainer
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                    if (race.subraces.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          l10n.stepRaceSubracesAvailable(race.subraces.length),
                          style: Theme.of(context).textTheme.bodySmall
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
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: isSelected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
                tooltip: AppLocalizations.of(context)!.detailSheetInfoTooltip,
                onPressed: () =>
                    showRaceDetailSheet(context, race, i18n),
              ),
              if (isSelected) Icon(Icons.check_circle, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubraceSelector extends StatelessWidget {
  const _SubraceSelector({
    required this.race,
    required this.i18n,
    required this.selectedSubrace,
    required this.onSelect,
  });

  final SrdRace race;
  final SrdI18nService i18n;
  final SrdSubrace? selectedSubrace;
  final ValueChanged<SrdSubrace?> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.stepChooseSubrace,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          ...race.subraces.map((sub) {
            final isSelected = selectedSubrace?.name == sub.name;
            final asiText = sub.abilityScoreIncreases.entries
                .map((e) => '+${e.value} ${abilityName(l10n, e.key)}')
                .join(', ');
            final subName = i18n.subraceName(sub.name);
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
                            if (asiText.isNotEmpty)
                              Text(
                                '${l10n.stepRaceASILabel}: $asiText',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.info_outline,
                          color: isSelected
                              ? scheme.onSecondaryContainer
                              : scheme.onSurfaceVariant,
                          size: 20,
                        ),
                        tooltip: AppLocalizations.of(context)!.detailSheetInfoTooltip,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () =>
                            showSubraceDetailSheet(context, race, sub, i18n),
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
