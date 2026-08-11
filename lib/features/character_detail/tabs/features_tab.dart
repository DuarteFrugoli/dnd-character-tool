import '../character_detail_dependencies.dart';
import '../widgets/features/add_feature_sheet.dart';
import '../widgets/features/feature_sections.dart';
import '../widgets/features/feature_support.dart';

final _featuresDataProvider =
    Provider.family<AsyncValue<FeaturesData>, String>((ref, characterId) {
      final vmState = ref.watch(featuresTabVmProvider(characterId));
      return vmState.when(
        loading: () => const AsyncLoading(),
        error: (error, stackTrace) => AsyncError(error, stackTrace),
        data: (vm) {
          final character = vm.character;
          final primaryClass = character.primaryClass;
          final className = primaryClass.className;
          final classLevel = primaryClass.level;
          final subclassName = primaryClass.subclassName ?? '';
          final classFeaturesState = ref.watch(
            srdClassFeaturesProvider(className),
          );
          final racesState = ref.watch(srdRacesProvider);
          final backgroundsState = ref.watch(srdBackgroundsProvider);
          final traitDescriptionsState = ref.watch(srdRaceTraitsProvider);
          final subclassFeaturesState = ref.watch(
            srdSubclassFeaturesProvider(
              SrdSubclassFeatureKey(
                className: className,
                subclassName: subclassName,
              ),
            ),
          );
          final featureChoiceCatalogState = ref.watch(
            srdFeatureChoiceCatalogProvider,
          );
          final featureUsageCatalogState = ref.watch(
            srdFeatureUsageCatalogProvider,
          );
          final skillsState = ref.watch(srdSkillsProvider);
          final toolsState = ref.watch(srdToolsProvider);
          final spellsState = ref.watch(srdSpellsProvider);
          final languagesState = ref.watch(srdLanguagesProvider);
          final weaponsState = ref.watch(srdWeaponsProvider);
          final featsState = ref.watch(srdFeatsProvider);

          final pendingState = _featuresDataPendingState([
            classFeaturesState,
            racesState,
            backgroundsState,
            traitDescriptionsState,
            subclassFeaturesState,
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

          final classFeatures = classFeaturesState.valueOrNull!;
          final races = racesState.valueOrNull!;
          final backgrounds = backgroundsState.valueOrNull!;
          final traitDescriptions = traitDescriptionsState.valueOrNull!;
          final subclassFeatures = subclassFeaturesState.valueOrNull!;
          final featureChoiceCatalog = featureChoiceCatalogState.valueOrNull!;
          final featureUsageCatalog = featureUsageCatalogState.valueOrNull!;
          final skills = skillsState.valueOrNull!;
          final tools = toolsState.valueOrNull!;
          final spells = spellsState.valueOrNull!;
          final languages = languagesState.valueOrNull!;
          final weapons = weaponsState.valueOrNull!;
          final srdFeats = featsState.valueOrNull!;

          final race = races.where((r) => r.name == character.race).firstOrNull;
          final subrace = race?.subraces
              .where((s) => s.name == character.subrace)
              .firstOrNull;
          final bg = backgrounds
              .where((b) => b.name == character.background)
              .firstOrNull;

          return AsyncData(
            FeaturesData(
              classFeatures: classFeatures
                  .where((f) => f.level <= classLevel)
                  .toList(),
              raceTraits: race?.traits ?? [],
              subraceTraits: subrace?.traits ?? [],
              traitDescriptions: traitDescriptions,
              backgroundFeatureName: bg?.feature.name,
              backgroundFeatureDescription: bg?.feature.description,
              subclassName: subclassName,
              subclassFeatures: subclassFeatures
                  .where((f) => f.level <= classLevel)
                  .toList(),
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
    });

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
      builder: (_) => AddFeatureSheet(characterId: widget.characterId),
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
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final dataState = ref.watch(_featuresDataProvider(widget.characterId));

    return dataState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text(AppLocalizations.of(context)!.featuresLoadError)),
      data: (data) {
        final disabledSet = widget.character.disabledFeatures.toSet();
        void toggle(String name) {
          final list = List<String>.from(widget.character.disabledFeatures);
          if (list.contains(name)) {
            list.remove(name);
          } else {
            list.add(name);
          }
          ref
              .read(characterDetailProvider(widget.characterId).notifier)
              .updateDisabledFeatures(list);
        }

        return Scaffold(
          body: CustomScrollView(
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
                        backgroundName: widget.character.background,
                        featureName: data.backgroundFeatureName!,
                        featureDescription:
                            data.backgroundFeatureDescription ?? '',
                        disabledFeatures: disabledSet,
                        onToggle: toggle,
                        i18n: i18n,
                      ),
                    ],
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ClassFeaturesSection(
                      className: widget.character.primaryClass.className,
                      features: data.classFeatures,
                      disabledFeatures: disabledSet,
                      onToggle: toggle,
                      character: widget.character,
                      characterId: widget.characterId,
                      data: data,
                      i18n: i18n,
                    ),
                    if (data.subclassFeatures.isNotEmpty) ...[
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      SubclassFeaturesSection(
                        className: widget.character.primaryClass.className,
                        subclassName: data.subclassName,
                        features: data.subclassFeatures,
                        disabledFeatures: disabledSet,
                        onToggle: toggle,
                        character: widget.character,
                        characterId: widget.characterId,
                        data: data,
                        i18n: i18n,
                      ),
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
