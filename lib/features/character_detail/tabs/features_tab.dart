part of '../character_detail_screen.dart';

// ── Features Tab ──────────────────────────────────────────────────────────────

String _featureTypeLabel(String type, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  switch (type) {
    case 'active':
      return l10n.labelActive;
    case 'passive':
      return l10n.labelPassive;
    case 'subclass':
      return l10n.labelSubclass;
    case 'asi':
      return l10n.stepRaceASILabel;
    default:
      return type;
  }
}

String _featureUsageRechargeLabel(BuildContext context, String recharge) {
  final l10n = AppLocalizations.of(context)!;
  switch (recharge) {
    case 'short_rest':
    case 'short_or_long_rest':
      return l10n.restPickerShort;
    case 'long_rest':
      return l10n.restPickerLong;
    default:
      return recharge;
  }
}

class _FeatureUsageControls extends ConsumerWidget {
  const _FeatureUsageControls({
    required this.view,
    required this.characterId,
    required this.i18n,
  });

  final FeatureUsageView view;
  final String characterId;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (view.isUnlimited) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final notifier = ref.read(characterDetailProvider(characterId).notifier);
    final current = view.current ?? 0;
    final max = view.max ?? 0;
    final resourceName = i18n.featureUsageResourceName(
      view.resource.id,
      view.resource.name,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '$resourceName: $current/$max',
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _featureUsageRechargeLabel(context, view.recharge),
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.outline,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            icon: Text('-${view.spend}'),
            tooltip: l10n.shortRestSpend,
            visualDensity: VisualDensity.compact,
            onPressed: view.canSpend
                ? () => notifier.adjustFeatureResource(
                      view.resource.id,
                      -view.spend,
                    )
                : null,
          ),
          const SizedBox(width: 6),
          IconButton.filledTonal(
            icon: const Icon(Icons.add),
            tooltip: l10n.dialogAdd,
            visualDensity: VisualDensity.compact,
            onPressed: view.canRecover
                ? () => notifier.adjustFeatureResource(view.resource.id, 1)
                : null,
          ),
        ],
      ),
    );
  }
}

List<Widget> _featureChoiceWidgets({
  required BuildContext context,
  required WidgetRef ref,
  required String characterId,
  required Character character,
  required List<FeatureChoiceRequest> requests,
  required _FeaturesData data,
  required SrdI18nService i18n,
}) {
  if (requests.isEmpty) return const [];
  final l10n = AppLocalizations.of(context)!;
  final scheme = Theme.of(context).colorScheme;
  final pending = FeatureChoiceEngine.pendingRequests(
    requests,
    character.featureChoices,
  );
  final chips = <Widget>[];
  for (final request in requests) {
    final choice = request.findIn(character.featureChoices);
    if (choice == null || choice.values.isEmpty) continue;
    final resolver = FeatureChoiceOptionResolver(
      request: request,
      catalog: data.featureChoiceCatalog,
      i18n: i18n,
      skills: data.skills,
      tools: data.tools,
      spells: data.spells,
      languages: data.languages,
      weapons: data.weapons,
      feats: data.srdFeats,
      character: character,
      relatedRequests: requests,
      choices: character.featureChoices,
    );
    chips.addAll(
      choice.values.map((value) {
        final label = resolver.labelFor(value) ?? value;
        final description = resolver.descriptionFor(value);
        if (description == null || description.trim().isEmpty) {
          return Chip(label: Text(label));
        }
        return ActionChip(
          avatar: const Icon(Icons.info_outline, size: 18),
          label: Text(label),
          onPressed: () => _showFeatureChoiceValueDetails(
            context,
            title: label,
            featureName: _featureChoiceRequestFeatureLabel(request, i18n),
            description: description,
          ),
        );
      }),
    );
  }

  return [
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.featureChoicesTitle,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              if (pending.isNotEmpty)
                Chip(
                  label: Text(l10n.featureChoicesPending),
                  backgroundColor: scheme.errorContainer,
                ),
            ],
          ),
          if (chips.isNotEmpty)
            Wrap(spacing: 6, runSpacing: 6, children: chips)
          else
            Text(
              l10n.featureChoicesPending,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.featureChoicesEdit),
              onPressed: () => _openFeatureChoiceEditorSheet(
                context: context,
                ref: ref,
                characterId: characterId,
                character: character,
                requests: requests,
                data: data,
                i18n: i18n,
              ),
            ),
          ),
        ],
      ),
    ),
  ];
}

String _featureChoiceRequestFeatureLabel(
  FeatureChoiceRequest request,
  SrdI18nService i18n,
) {
  return switch (request.sourceType) {
    FeatureChoiceSourceType.classFeature =>
      i18n.classFeatureName(request.sourceClass, request.featureName) ??
          request.featureName,
    FeatureChoiceSourceType.subclassFeature =>
      i18n.subclassFeatureName(
            request.sourceClass,
            request.sourceSubclass ?? '',
            request.featureName,
          ) ??
          request.featureName,
    FeatureChoiceSourceType.raceTrait =>
      i18n.raceTraitName(request.sourceName ?? request.featureName),
    FeatureChoiceSourceType.feat =>
      i18n.featName(request.sourceName ?? request.featureName) ??
          request.featureName,
    _ => request.featureName,
  };
}

void _showFeatureChoiceValueDetails(
  BuildContext context, {
  required String title,
  required String featureName,
  required String description,
}) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) {
      final theme = Theme.of(context);
      final scheme = theme.colorScheme;
      final l10n = AppLocalizations.of(context)!;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.75,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  featureName,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.dialogClose),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void _openFeatureChoiceEditorSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String characterId,
  required Character character,
  required List<FeatureChoiceRequest> requests,
  required _FeaturesData data,
  required SrdI18nService i18n,
}) {
  var editedChoices = <CharacterFeatureChoice>[
    for (final request in requests)
      request.findIn(character.featureChoices) ?? request.emptyChoice(),
  ];

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          final complete = FeatureChoiceEngine.allComplete(
            requests,
            editedChoices,
          );
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.45,
            maxChildSize: 1,
            builder: (_, controller) {
              return Column(
                children: [
                  Expanded(
                    child: PrimaryScrollController(
                      controller: controller,
                      child: FeatureChoiceEditor(
                        requests: requests,
                        initialChoices: editedChoices,
                        catalog: data.featureChoiceCatalog,
                        character: character,
                        i18n: i18n,
                        skills: data.skills,
                        tools: data.tools,
                        spells: data.spells,
                        languages: data.languages,
                        weapons: data.weapons,
                        feats: data.srdFeats,
                        featureLabelBuilder: (request) =>
                            _featureChoiceRequestFeatureLabel(request, i18n),
                        onChanged: (choices) {
                          setSheetState(() => editedChoices = choices);
                        },
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(sheetContext),
                              child: Text(
                                AppLocalizations.of(context)!.dialogCancel,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: complete
                                  ? () async {
                                      await ref
                                          .read(
                                            characterDetailProvider(
                                              characterId,
                                            ).notifier,
                                          )
                                          .upsertFeatureChoices(editedChoices);
                                      if (sheetContext.mounted) {
                                        Navigator.pop(sheetContext);
                                      }
                                    }
                                  : null,
                              child: Text(
                                AppLocalizations.of(context)!.dialogSave,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}

final _featuresDataProvider =
    Provider.family<AsyncValue<_FeaturesData>, String>((ref, characterId) {
  final vmState = ref.watch(featuresTabVmProvider(characterId));
  return vmState.when(
    loading: () => const AsyncLoading(),
    error: (error, stackTrace) => AsyncError(error, stackTrace),
    data: (vm) {
      final character = vm.character;
      final subclassName = character.subclass ?? '';
      final classFeaturesState = ref.watch(
        srdClassFeaturesProvider(character.characterClass),
      );
      final racesState = ref.watch(srdRacesProvider);
      final backgroundsState = ref.watch(srdBackgroundsProvider);
      final traitDescriptionsState = ref.watch(srdRaceTraitsProvider);
      final subclassFeaturesState = ref.watch(
        srdSubclassFeaturesProvider(
          SrdSubclassFeatureKey(
            className: character.characterClass,
            subclassName: subclassName,
          ),
        ),
      );
      final featureChoiceCatalogState =
          ref.watch(srdFeatureChoiceCatalogProvider);
      final featureUsageCatalogState = ref.watch(srdFeatureUsageCatalogProvider);
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
        _FeaturesData(
          classFeatures:
              classFeatures.where((f) => f.level <= character.level).toList(),
          raceTraits: race?.traits ?? [],
          subraceTraits: subrace?.traits ?? [],
          traitDescriptions: traitDescriptions,
          backgroundFeatureName: bg?.feature.name,
          backgroundFeatureDescription: bg?.feature.description,
          subclassName: subclassName,
          subclassFeatures: subclassFeatures
              .where((f) => f.level <= character.level)
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

AsyncValue<_FeaturesData>? _featuresDataPendingState(
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

class _FeaturesTab extends ConsumerStatefulWidget {
  const _FeaturesTab({
    required this.character,
    required this.characterId,
  });
  final Character character;
  final String characterId;

  @override
  ConsumerState<_FeaturesTab> createState() => _FeaturesTabState();
}

class _FeaturesTabState extends ConsumerState<_FeaturesTab>
    with AutomaticKeepAliveClientMixin {
  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddFeatureSheet(characterId: widget.characterId),
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
      error: (error, _) => Center(
        child: Text(AppLocalizations.of(context)!.featuresLoadError),
      ),
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
                      _FeatsSection(
                        feats: featItems,
                        character: widget.character,
                        characterId: widget.characterId,
                        data: data,
                        i18n: i18n,
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                    _RacialTraitsSection(
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
                      _BackgroundFeatureSection(
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
                    _ClassFeaturesSection(
                      className: widget.character.characterClass,
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
                      _SubclassFeaturesSection(
                        className: widget.character.characterClass,
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
                      _ToolProficienciesSection(
                        features: widget.character.features,
                        characterId: widget.characterId,
                        i18n: i18n,
                      ),
                    ],
                    if (classExtras.isNotEmpty) ...[
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      _ExtraFeaturesSection(
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

class _FeaturesData {
  final List<SrdClassFeature> classFeatures;
  final List<String> raceTraits;
  final List<String> subraceTraits;
  final Map<String, String> traitDescriptions;
  final String? backgroundFeatureName;
  final String? backgroundFeatureDescription;
  final String subclassName;
  final List<SrdClassFeature> subclassFeatures;
  final SrdFeatureChoiceCatalog featureChoiceCatalog;
  final FeatureUsageCatalog featureUsageCatalog;
  final List<SrdSkill> skills;
  final List<SrdTool> tools;
  final List<SrdSpell> spells;
  final List<SrdLanguage> languages;
  final List<SrdWeapon> weapons;
  final List<SrdFeat> srdFeats;

  const _FeaturesData({
    required this.classFeatures,
    required this.raceTraits,
    required this.subraceTraits,
    required this.traitDescriptions,
    this.backgroundFeatureName,
    this.backgroundFeatureDescription,
    required this.subclassName,
    required this.subclassFeatures,
    required this.featureChoiceCatalog,
    required this.featureUsageCatalog,
    required this.skills,
    required this.tools,
    required this.spells,
    required this.languages,
    required this.weapons,
    required this.srdFeats,
  });
}
