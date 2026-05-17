import 'package:flutter/material.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/srd/srd_i18n_service.dart';
import '../../../data/datasources/srd/srd_models.dart';
import '../../../shared/providers/providers.dart';
import '../character_draft_provider.dart';

/// Translates a background tool proficiency string.
/// Choice descriptions ("one type of gaming set") use ARB keys;
/// specific tools (e.g. "Disguise kit") use the i18n tool map.
String _bgToolName(String en, SrdI18nService i18n, AppLocalizations l10n) {
  final lower = en.toLowerCase();
  if (lower.contains('gaming')) {
    return l10n.stepToolCategoryGamingSet;
  }
  if (lower.contains('musical instrument')) {
    return l10n.stepToolCategoryInstrument;
  }
  if (lower.contains('artisan') && lower.contains('musical')) {
    return l10n.stepToolCategoryArtisanOrInstrument;
  }
  if (lower.contains('artisan')) {
    return l10n.stepToolCategoryArtisanTool;
  }
  return i18n.toolName(en);
}

class StepBackground extends ConsumerStatefulWidget {
  const StepBackground({super.key});

  @override
  ConsumerState<StepBackground> createState() => _StepBackgroundState();
}

class _StepBackgroundState extends ConsumerState<StepBackground> {
  late final Future<List<SrdBackground>> _backgroundsFuture;

  @override
  void initState() {
    super.initState();
    _backgroundsFuture = ref.read(srdDataSourceProvider).getBackgrounds();
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(characterDraftProvider).selectedBackground;
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;

    return FutureBuilder<List<SrdBackground>>(
      future: _backgroundsFuture,
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
              i18n: i18n,
              isSelected: isSelected,
              onTap: () =>
                  ref.read(characterDraftProvider.notifier).setBackground(bg),
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
    required this.i18n,
    required this.isSelected,
    required this.onTap,
  });

  final SrdBackground bg;
  final SrdI18nService i18n;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final bgName = i18n.backgroundName(bg.name);
    final featureName = i18n.backgroundFeatureName(bg.name) ?? bg.feature.name;
    final featureDesc =
        i18n.backgroundFeatureDescription(bg.name) ?? bg.feature.description;
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
                    Text(
                      bgName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isSelected ? scheme.onPrimaryContainer : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.creationStepSkills}: ${bg.skillProficiencies.map(i18n.skillName).join(', ')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? scheme.onPrimaryContainer
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                    if (bg.toolProficiencies.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${l10n.inventoryTabTools}: ${bg.toolProficiencies.map((t) => _bgToolName(t, i18n, l10n)).join(', ')}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? scheme.onPrimaryContainer
                              : scheme.tertiary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.reviewRowFeature}: $featureName',
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
                        featureDesc,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ],
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
