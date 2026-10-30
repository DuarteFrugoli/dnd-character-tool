import '../character_detail_dependencies.dart';
import '../widgets/features/add_feature_sheet.dart';
import '../widgets/features/feature_sections.dart';
import '../widgets/features/feature_support.dart';
import '../../../data/custom_background.dart';
import '../../../data/rulesets/ruleset_ids.dart';
import '../../../data/rulesets/srd_content_pack.dart';

final _featuresDataProvider = Provider.family<AsyncValue<FeaturesData>, String>(
  (ref, characterId) {
    final vmState = ref.watch(featuresTabVmProvider(characterId));
    return vmState.when(
      loading: () => const AsyncLoading(),
      error: (error, stackTrace) => AsyncError(error, stackTrace),
      data: (vm) {
        final character = vm.character;
        final packId = character.contentPackId;
        final is2024 = character.rulesetId == RulesetId.dnd2024;
        final classEntries = character.classEntries;
        final classFeatureStates = {
          for (final entry in classEntries)
            entry.id: ref.watch(srdClassFeaturesForPackProvider((packId, entry.className))),
        };
        final allSubclassFeaturesState = ref.watch(
          srdAllSubclassFeaturesForPackProvider(packId),
        );
        final racesState = is2024 ? null : ref.watch(srdRacesProvider);
        final speciesState = is2024 ? ref.watch(srd2024SpeciesProvider) : null;
        final backgroundsState = is2024 ? null : ref.watch(srdBackgroundsProvider);
        final traitDescriptionsState = ref.watch(srdRaceTraitsForPackProvider(packId));
        final featureChoiceCatalogState = ref.watch(
          srdFeatureChoicesForPackProvider(packId),
        );
        final featureUsageCatalogState = ref.watch(
          srdFeatureUsagesForPackProvider(packId),
        );
        final skillsState = ref.watch(srdSkillsForPackProvider(packId));
        final toolsState = ref.watch(srdToolsForPackProvider(packId));
        final spellsState = ref.watch(srdSpellsForPackProvider(packId));
        final languagesState = ref.watch(srdLanguagesForPackProvider(packId));
        final weaponsState = ref.watch(srdWeaponsForPackProvider(packId));
        final featsState = ref.watch(srdFeatsForPackProvider(packId));

        final pendingState = _featuresDataPendingState([
          ...classFeatureStates.values,
          allSubclassFeaturesState,
          ?racesState,
          ?speciesState,
          ?backgroundsState,
          traitDescriptionsState,
          featureChoiceCatalogState,
          featureUsageCatalogState,
          skillsState,
          toolsState,
          spellsState,
          languagesState,
          weaponsState,
          featsState,
        ]);
        if (pendingState != null) return pendingState;

        final allSubclassFeatures = allSubclassFeaturesState.valueOrNull!;
        final races = racesState?.valueOrNull;
        final species = speciesState?.valueOrNull;
        final backgrounds = backgroundsState?.valueOrNull;
        final traitDescriptions = traitDescriptionsState.valueOrNull!;
        final featureChoiceCatalog = featureChoiceCatalogState.valueOrNull!;
        final featureUsageCatalog = featureUsageCatalogState.valueOrNull!;
        final skills = skillsState.valueOrNull!;
        final tools = toolsState.valueOrNull!;
        final spells = spellsState.valueOrNull!;
        final languages = languagesState.valueOrNull!;
        final weapons = weaponsState.valueOrNull!;
        final srdFeats = featsState.valueOrNull!;

        final race = races?.where((r) => r.name == character.race).firstOrNull;
        final speciesEntry = species?.where((r) => r.name == character.race).firstOrNull;
        final subrace = race?.subraces
            .where((s) => s.name == character.subrace)
            .firstOrNull;
        final featureSource = CustomBackground.featureSourceFor(character);
        final bg = backgrounds?.where((b) => b.name == featureSource).firstOrNull;

        List<SrdClassFeature> subclassFeaturesFor(CharacterClassEntry entry) {
          final subclassName = entry.subclassName;
          if (subclassName == null || subclassName.isEmpty) {
            return const <SrdClassFeature>[];
          }
          return (allSubclassFeatures[entry.className]?[subclassName] ??
                  const <SrdClassFeature>[])
              .where((f) => f.level <= entry.level)
              .toList();
        }

        return AsyncData(
          FeaturesData(
            classSections: [
              for (final entry in classEntries)
                FeaturesClassSectionData(
                  classEntry: entry,
                  classFeatures: classFeatureStates[entry.id]!.valueOrNull!
                      .where((f) => f.level <= entry.level)
                      .toList(),
                  subclassFeatures: subclassFeaturesFor(entry),
                ),
            ],
            raceTraits: speciesEntry?.traits ?? race?.traits ?? [],
            subraceTraits: subrace?.traits ?? [],
            traitDescriptions: traitDescriptions,
            backgroundFeatureName: bg?.feature.name,
            backgroundFeatureDescription: bg?.feature.description,
            featureChoiceCatalog: featureChoiceCatalog,
            featureUsageCatalog: featureUsageCatalog,
            skills: skills,
            tools: tools,
            spells: spells,
            languages: languages,
            weapons: weapons,
            srdFeats: srdFeats,
          ),
        );
      },
    );
  },
);

AsyncValue<FeaturesData>? _featuresDataPendingState(
  List<AsyncValue<dynamic>> values,
) {
  for (final value in values) {
    if (value.hasError) {
      return AsyncError(value.error!, value.stackTrace ?? StackTrace.current);
    }
  }
  if (values.any((value) => value.valueOrNull == null)) {
    return const AsyncLoading();
  }
  return null;
}

class FeaturesTab extends ConsumerStatefulWidget {
  const FeaturesTab({
    super.key,
    required this.character,
    required this.characterId,
  });
  final Character character;
  final String characterId;

  @override
  ConsumerState<FeaturesTab> createState() => _FeaturesTabState();
}

class _FeaturesTabState extends ConsumerState<FeaturesTab>
    with AutomaticKeepAliveClientMixin {
  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddFeatureSheet(
        characterId: widget.characterId,
        customOnly: widget.character.rulesetId == RulesetId.dnd2024,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final extraFeatures = widget.character.extraFeatures;
    final featItems = extraFeatures
        .where((f) => f.sourceClass == 'Feat')
        .toList();
    final classExtras = extraFeatures
        .where((f) => f.sourceClass != 'Feat')
        .toList();
    final packId = widget.character.contentPackId;
    final i18n = ref.watch(srdI18nForPackProvider(packId)).valueOrNull ??
        SrdI18nService.englishForPack(SrdContentPackRegistry.forId(packId));
    final dataState = ref.watch(_featuresDataProvider(widget.characterId));

    return dataState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text(AppLocalizations.of(context)!.featuresLoadError)),
      data: (data) {
        final disabledSet = widget.character.disabledFeatures.toSet();
        void toggle(String key, {String? legacyName}) {
          final list = List<String>.from(widget.character.disabledFeatures);
          final isDisabled =
              list.contains(key) ||
              (legacyName != null && list.contains(legacyName));
          if (isDisabled) {
            list.remove(key);
            if (legacyName != null) list.remove(legacyName);
          } else {
            list.add(key);
          }
          ref
              .read(characterDetailProvider(widget.characterId).notifier)
              .updateDisabledFeatures(list);
        }

        return Scaffold(
          body: CustomScrollView(
            key: PageStorageKey('features-${widget.characterId}'),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverMainAxisGroup(
                  slivers: [
                    if (featItems.isNotEmpty) ...[
                      FeatsSection(
                        feats: featItems,
                        character: widget.character,
                        characterId: widget.characterId,
                        data: data,
                        i18n: i18n,
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                    RacialTraitsSection(
                      raceName: widget.character.race,
                      subraceName: widget.character.subrace,
                      raceTraits: data.raceTraits,
                      subraceTraits: data.subraceTraits,
                      traitDescriptions: data.traitDescriptions,
                      disabledFeatures: disabledSet,
                      onToggle: toggle,
                      character: widget.character,
                      characterId: widget.characterId,
                      data: data,
                      i18n: i18n,
                    ),
                    if (data.backgroundFeatureName != null) ...[
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      BackgroundFeatureSection(
                        backgroundName: CustomBackground.featureSourceFor(widget.character),
                        featureName: data.backgroundFeatureName!,
                        featureDescription:
                            data.backgroundFeatureDescription ?? '',
                        disabledFeatures: disabledSet,
                        onToggle: toggle,
                        i18n: i18n,
                      ),
                    ],
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    for (var i = 0; i < data.classSections.length; i++) ...[
                      if (i > 0)
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ClassFeaturesSection(
                        classEntry: data.classSections[i].classEntry,
                        features: data.classSections[i].classFeatures,
                        disabledFeatures: disabledSet,
                        onToggle: toggle,
                        character: widget.character,
                        characterId: widget.characterId,
                        data: data,
                        i18n: i18n,
                      ),
                      if (data
                          .classSections[i]
                          .subclassFeatures
                          .isNotEmpty) ...[
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                        SubclassFeaturesSection(
                          classEntry: data.classSections[i].classEntry,
                          features: data.classSections[i].subclassFeatures,
                          disabledFeatures: disabledSet,
                          onToggle: toggle,
                          character: widget.character,
                          characterId: widget.characterId,
                          data: data,
                          i18n: i18n,
                        ),
                      ],
                    ],
                    if (widget.character.features.isNotEmpty) ...[
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ToolProficienciesSection(
                        features: widget.character.features,
                        characterId: widget.characterId,
                        i18n: i18n,
                      ),
                    ],
                    if (classExtras.isNotEmpty) ...[
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ExtraFeaturesSection(
                        features: classExtras,
                        characterId: widget.characterId,
                        character: widget.character,
                        data: data,
                        i18n: i18n,
                      ),
                    ],
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 192)),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openAddSheet,
            tooltip: AppLocalizations.of(context)!.featuresTooltipAdd,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
