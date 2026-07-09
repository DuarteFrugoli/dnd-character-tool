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

List<Widget> _featureChoiceWidgets({
  required BuildContext context,
  required WidgetRef ref,
  required String characterId,
  required Character character,
  required List<FeatureChoiceRequest> requests,
  required _FeaturesData data,
}) {
  if (requests.isEmpty) return const [];
  final l10n = AppLocalizations.of(context)!;
  final i18n =
      ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
  final scheme = Theme.of(context).colorScheme;
  final pending = FeatureChoiceEngine.pendingRequests(
    requests,
    character.featureChoices,
  );
  final chips = <Widget>[];
  for (final request in requests) {
    final choice = request.findIn(character.featureChoices);
    if (choice == null || choice.values.isEmpty) continue;
    final resolver = _FeatureChoiceOptionResolver(
      request: request,
      catalog: data.featureChoiceCatalog,
      i18n: i18n,
      skills: data.skills,
      tools: data.tools,
      spells: data.spells,
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
        child: Padding(
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
                      child: _FeatureChoiceEditor(
                        requests: requests,
                        initialChoices: editedChoices,
                        catalog: data.featureChoiceCatalog,
                        character: character,
                        i18n: i18n,
                        skills: data.skills,
                        tools: data.tools,
                        spells: data.spells,
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

class _FeaturesTabState extends ConsumerState<_FeaturesTab> {
  late Future<_FeaturesData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(_FeaturesTab old) {
    super.didUpdateWidget(old);
    final current = widget.character;
    final previous = old.character;
    if (current.characterClass != previous.characterClass ||
        current.subclass != previous.subclass ||
        current.level != previous.level ||
        current.race != previous.race ||
        current.subrace != previous.subrace ||
        current.background != previous.background ||
        current.featureChoices != previous.featureChoices) {
      _future = _load();
    }
  }

  Future<_FeaturesData> _load() async {
    final srd = ref.read(srdDataSourceProvider);
    final subclassName = widget.character.subclass ?? '';
    final results = await Future.wait([
      srd.getClassFeatures(widget.character.characterClass),
      srd.getRaces(),
      srd.getBackgrounds(),
      srd.getRaceTraits(),
      srd.getSubclassFeatures(widget.character.characterClass, subclassName),
      srd.getFeatureChoiceCatalog(),
      srd.getSkills(),
      srd.getTools(),
      srd.getSpells(),
    ]);
    final classFeatures = results[0] as List<SrdClassFeature>;
    final races = results[1] as List<SrdRace>;
    final backgrounds = results[2] as List<SrdBackground>;
    final traitDescriptions = results[3] as Map<String, String>;
    final subclassFeatures = results[4] as List<SrdClassFeature>;
    final featureChoiceCatalog = results[5] as SrdFeatureChoiceCatalog;
    final skills = results[6] as List<SrdSkill>;
    final tools = results[7] as List<SrdTool>;
    final spells = results[8] as List<SrdSpell>;

    final race = races
        .where((r) => r.name == widget.character.race)
        .firstOrNull;
    final subrace = race?.subraces
        .where((s) => s.name == widget.character.subrace)
        .firstOrNull;
    final bg = backgrounds
        .where((b) => b.name == widget.character.background)
        .firstOrNull;

    return _FeaturesData(
      classFeatures: classFeatures
          .where((f) => f.level <= widget.character.level)
          .toList(),
      raceTraits: race?.traits ?? [],
      subraceTraits: subrace?.traits ?? [],
      traitDescriptions: traitDescriptions,
      backgroundFeatureName: bg?.feature.name,
      backgroundFeatureDescription: bg?.feature.description,
      subclassName: subclassName,
      subclassFeatures: subclassFeatures
          .where((f) => f.level <= widget.character.level)
          .toList(),
      featureChoiceCatalog: featureChoiceCatalog,
      skills: skills,
      tools: tools,
      spells: spells,
    );
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddFeatureSheet(characterId: widget.characterId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final extraFeatures = widget.character.extraFeatures;
    final featItems = extraFeatures.where((f) => f.sourceClass == 'Feat').toList();
    final classExtras = extraFeatures.where((f) => f.sourceClass != 'Feat').toList();
    return FutureBuilder<_FeaturesData>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || !snap.hasData) {
          return Center(
            child: Text(AppLocalizations.of(context)!.featuresLoadError),
          );
        }
        final data = snap.data!;
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
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 192),
            children: [
              if (featItems.isNotEmpty) ...[
                _FeatsSection(
                  feats: featItems,
                  character: widget.character,
                  characterId: widget.characterId,
                  data: data,
                ),
                const SizedBox(height: 24),
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
              ),
              if (data.backgroundFeatureName != null) ...[
                const SizedBox(height: 24),
                _BackgroundFeatureSection(
                  backgroundName: widget.character.background,
                  featureName: data.backgroundFeatureName!,
                  featureDescription: data.backgroundFeatureDescription ?? '',
                  disabledFeatures: disabledSet,
                  onToggle: toggle,
                ),
              ],
              const SizedBox(height: 24),
              _ClassFeaturesSection(
                className: widget.character.characterClass,
                features: data.classFeatures,
                disabledFeatures: disabledSet,
                onToggle: toggle,
                character: widget.character,
                characterId: widget.characterId,
                data: data,
              ),
              if (data.subclassFeatures.isNotEmpty) ...[
                const SizedBox(height: 24),
                _SubclassFeaturesSection(
                  className: widget.character.characterClass,
                  subclassName: data.subclassName,
                  features: data.subclassFeatures,
                  disabledFeatures: disabledSet,
                  onToggle: toggle,
                  character: widget.character,
                  characterId: widget.characterId,
                  data: data,
                ),
              ],
              if (widget.character.features.isNotEmpty) ...[
                const SizedBox(height: 24),
                _ToolProficienciesSection(
                  features: widget.character.features,
                  characterId: widget.characterId,
                ),
              ],
              if (classExtras.isNotEmpty) ...[
                const SizedBox(height: 24),
                _ExtraFeaturesSection(
                  features: classExtras,
                  characterId: widget.characterId,
                ),
              ],
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
  final List<SrdSkill> skills;
  final List<SrdTool> tools;
  final List<SrdSpell> spells;

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
    required this.skills,
    required this.tools,
    required this.spells,
  });
}

class _RacialTraitsSection extends ConsumerWidget {
  const _RacialTraitsSection({
    required this.raceName,
    required this.subraceName,
    required this.raceTraits,
    required this.subraceTraits,
    required this.traitDescriptions,
    required this.disabledFeatures,
    required this.onToggle,
    required this.character,
    required this.characterId,
    required this.data,
  });

  final String raceName;
  final String? subraceName;
  final List<String> raceTraits;
  final List<String> subraceTraits;
  final Map<String, String> traitDescriptions;
  final Set<String> disabledFeatures;
  final void Function(String) onToggle;
  final Character character;
  final String characterId;
  final _FeaturesData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final allTraits = [...raceTraits, ...subraceTraits];
    if (allTraits.isEmpty) return const SizedBox.shrink();

    final title = subraceName != null && subraceName!.isNotEmpty
        ? i18n.subraceName(subraceName!)
        : i18n.raceName(raceName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.featuresSectionRacialTraits(title),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...allTraits.map((trait) {
          final isDisabled = disabledFeatures.contains(trait);
          final desc = traitDescriptions[trait];
          final requests = FeatureChoiceEngine.requestsForRaceTrait(
            catalog: data.featureChoiceCatalog,
            traitName: trait,
            level: character.level,
          );
          Widget card;
          if (desc == null || desc.isEmpty) {
            card = Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: Column(
                children: [
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(
                      i18n.raceTraitName(trait),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  ..._featureChoiceWidgets(
                    context: context,
                    ref: ref,
                    characterId: characterId,
                    character: character,
                    requests: requests,
                    data: data,
                  ),
                ],
              ),
            );
          } else {
            card = Card(
              margin: const EdgeInsets.only(bottom: 6),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        i18n.raceTraitName(trait),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                children: [
                  ..._featureChoiceWidgets(
                    context: context,
                    ref: ref,
                    characterId: characterId,
                    character: character,
                    requests: requests,
                    data: data,
                  ),
                  Text(
                    i18n.raceTraitDescription(trait) ?? desc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }
          return GestureDetector(
            onLongPress: () => onToggle(trait),
            child: isDisabled ? Opacity(opacity: 0.35, child: card) : card,
          );
        }),
      ],
    );
  }
}

class _BackgroundFeatureSection extends ConsumerWidget {
  const _BackgroundFeatureSection({
    required this.backgroundName,
    required this.featureName,
    required this.featureDescription,
    required this.disabledFeatures,
    required this.onToggle,
  });

  final String backgroundName;
  final String featureName;
  final String featureDescription;
  final Set<String> disabledFeatures;
  final void Function(String) onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final isDisabled = disabledFeatures.contains(featureName);
    final card = Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                i18n.backgroundFeatureName(backgroundName) ?? featureName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              i18n.backgroundFeatureDescription(backgroundName) ??
                  featureDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.featuresSectionBackground(i18n.backgroundName(backgroundName)),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onLongPress: () => onToggle(featureName),
          child: isDisabled ? Opacity(opacity: 0.35, child: card) : card,
        ),
      ],
    );
  }
}

// ── Tool Proficiencies Section ────────────────────────────────────────────────

class _ToolProficienciesSection extends ConsumerWidget {
  const _ToolProficienciesSection({
    required this.features,
    required this.characterId,
  });
  final List<String> features;
  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final notifier =
        ref.read(characterDetailProvider(characterId).notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.featuresSectionTools,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...features.map((f) {
          // Strip the "Tool Proficiency: " prefix if present for display
          final label = f.startsWith('Tool Proficiency: ')
              ? f.substring('Tool Proficiency: '.length)
              : f;
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: const Icon(Icons.handyman_outlined, size: 20),
              title: Text(
                i18n.toolName(label),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: scheme.error,
                tooltip: l10n.featuresTooltipRemove,
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.featuresRemoveTitle),
                      content: Text(l10n.featuresRemoveContent(label)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l10n.dialogCancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: scheme.error,
                            foregroundColor: scheme.onError,
                          ),
                          child: Text(l10n.dialogRemove),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await notifier.removeToolProficiency(f);
                  }
                },
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _FeatsSection extends ConsumerWidget {
  const _FeatsSection({
    required this.feats,
    required this.character,
    required this.characterId,
    required this.data,
  });

  final List<CharacterExtraFeature> feats;
  final Character character;
  final String characterId;
  final _FeaturesData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final notifier = ref.read(characterDetailProvider(characterId).notifier);
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.featuresSectionFeats,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...feats.map((f) {
          final requests = FeatureChoiceEngine.requestsForFeat(
            catalog: data.featureChoiceCatalog,
            featName: f.name,
            level: character.level,
          );
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              title: Text(
                i18n.featName(f.name) ?? f.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                l10n.featuresSectionFeats,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.tertiary,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: scheme.error,
                tooltip: l10n.featuresTooltipRemove,
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.featuresRemoveTitle),
                      content: Text(l10n.featuresRemoveContent(f.name)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l10n.dialogCancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: scheme.error,
                            foregroundColor: scheme.onError,
                          ),
                          child: Text(l10n.dialogRemove),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await notifier.removeExtraFeature(f.name, 'Feat');
                  }
                },
              ),
              children: [
                ..._featureChoiceWidgets(
                  context: context,
                  ref: ref,
                  characterId: characterId,
                  character: character,
                  requests: requests,
                  data: data,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    i18n.featDescription(f.name) ?? f.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ExtraFeaturesSection extends ConsumerWidget {
  const _ExtraFeaturesSection({
    required this.features,
    required this.characterId,
  });

  final List<CharacterExtraFeature> features;
  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final notifier = ref.read(characterDetailProvider(characterId).notifier);
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;

    final l10n2 = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n2.featuresSectionExtra,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...features.map(
          (f) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      i18n.classFeatureName(f.sourceClass, f.name) ??
                          i18n.anySubclassFeatureName(f.sourceClass, f.name) ??
                          i18n.raceTraitName(f.name),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    f.sourceClass,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.tertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                l10n2.charCardLevel(f.level),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: scheme.error,
                tooltip: AppLocalizations.of(context)!.featuresTooltipRemove,
                onPressed: () async {
                  final l10n = AppLocalizations.of(context)!;
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.featuresRemoveTitle),
                      content: Text(l10n.featuresRemoveContent(f.name)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l10n.dialogCancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: scheme.error,
                            foregroundColor: scheme.onError,
                          ),
                          child: Text(l10n.dialogRemove),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    notifier.removeExtraFeature(f.name, f.sourceClass);
                  }
                },
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    i18n.classFeatureDescription(f.sourceClass, f.name) ??
                        i18n.anySubclassFeatureDescription(
                          f.sourceClass,
                          f.name,
                        ) ??
                        f.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ClassFeaturesSection extends ConsumerWidget {
  const _ClassFeaturesSection({
    required this.className,
    required this.features,
    required this.disabledFeatures,
    required this.onToggle,
    required this.character,
    required this.characterId,
    required this.data,
  });

  final String className;
  final List<SrdClassFeature> features;
  final Set<String> disabledFeatures;
  final void Function(String) onToggle;
  final Character character;
  final String characterId;
  final _FeaturesData data;

  Color _typeColor(String type, ColorScheme scheme) {
    switch (type) {
      case 'active':
        return scheme.primary;
      case 'subclass':
        return scheme.tertiary;
      case 'asi':
        return scheme.secondary;
      default:
        return scheme.outline;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    if (features.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.featuresSectionClass(i18n.className(className)),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(l10n.featuresNoneAvailable),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.featuresSectionClass(i18n.className(className)),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...features.map((f) {
          final typeColor = _typeColor(f.type, scheme);
          final isDisabled = disabledFeatures.contains(f.name);
          final requests = FeatureChoiceEngine.requestsForClassFeature(
            catalog: data.featureChoiceCatalog,
            className: className,
            featureName: f.name,
            level: character.level,
          );
          final card = Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      i18n.classFeatureName(className, f.name) ?? f.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withAlpha(30),
                      border: Border.all(color: typeColor.withAlpha(100)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _featureTypeLabel(f.type, context),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                children: [
                  Text(
                    l10n.charCardLevel(f.level),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (f.uses != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${f.uses!.amount}× / ${f.uses!.rechargeLabel}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: scheme.primary),
                    ),
                  ],
                ],
              ),
              children: [
                ..._featureChoiceWidgets(
                  context: context,
                  ref: ref,
                  characterId: characterId,
                  character: character,
                  requests: requests,
                  data: data,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    i18n.classFeatureDescription(className, f.name) ??
                        f.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
          return GestureDetector(
            onLongPress: () => onToggle(f.name),
            child: isDisabled ? Opacity(opacity: 0.35, child: card) : card,
          );
        }),
      ],
    );
  }
}

// ── Subclass Features Section ─────────────────────────────────────────────────

class _SubclassFeaturesSection extends ConsumerWidget {
  const _SubclassFeaturesSection({
    required this.className,
    required this.subclassName,
    required this.features,
    required this.disabledFeatures,
    required this.onToggle,
    required this.character,
    required this.characterId,
    required this.data,
  });

  final String className;
  final String subclassName;
  final List<SrdClassFeature> features;
  final Set<String> disabledFeatures;
  final void Function(String) onToggle;
  final Character character;
  final String characterId;
  final _FeaturesData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.featuresSectionSubclass(i18n.subclassName(className, subclassName)),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...features.map((f) {
          final typeColor = f.type == 'active'
              ? scheme.primary
              : scheme.outline;
          final isDisabled = disabledFeatures.contains(f.name);
          final requests = FeatureChoiceEngine.requestsForSubclassFeature(
            catalog: data.featureChoiceCatalog,
            className: className,
            subclassName: subclassName,
            featureName: f.name,
            level: character.level,
          );
          final card = Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      i18n.subclassFeatureName(
                            className,
                            subclassName,
                            f.name,
                          ) ??
                          f.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withAlpha(30),
                      border: Border.all(color: typeColor.withAlpha(100)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      f.type == 'active'
                          ? AppLocalizations.of(context)!.labelActive
                          : AppLocalizations.of(context)!.labelPassive,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                l10n.charCardLevel(f.level),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              children: [
                ..._featureChoiceWidgets(
                  context: context,
                  ref: ref,
                  characterId: characterId,
                  character: character,
                  requests: requests,
                  data: data,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    i18n.subclassFeatureDescription(
                          className,
                          subclassName,
                          f.name,
                        ) ??
                        f.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
          return GestureDetector(
            onLongPress: () => onToggle(f.name),
            child: isDisabled ? Opacity(opacity: 0.35, child: card) : card,
          );
        }),
      ],
    );
  }
}

// ── Add Feature Sheet ─────────────────────────────────────────────────────────

class _AddFeatureSheet extends ConsumerStatefulWidget {
  const _AddFeatureSheet({required this.characterId});
  final String characterId;

  @override
  ConsumerState<_AddFeatureSheet> createState() => _AddFeatureSheetState();
}

class _AddFeatureSheetState extends ConsumerState<_AddFeatureSheet>
    with SingleTickerProviderStateMixin {
  final _search = TextEditingController();
  final _customNameCtrl = TextEditingController();
  final _customDescCtrl = TextEditingController();
  bool _customTypeActive = false;

  late final TabController _tabs;

  List<String> _getTabLabels(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.featuresTabFeats,
      l10n.featuresTabClass,
      l10n.labelSubclass,
      l10n.featuresTabRacial,
      l10n.labelBackground,
      l10n.featuresTabTools,
      l10n.featuresTabCustom,
    ];
  }

  Map<String, List<SrdClassFeature>>? _allClassFeatures;
  Map<String, Map<String, List<SrdClassFeature>>>? _allSubclassFeatures;
  List<SrdRace>? _races;
  Map<String, String>? _raceTraits;
  List<SrdBackground>? _backgrounds;
  List<SrdFeat>? _feats;
  List<SrdTool>? _tools;
  String? _loadError;

  static const _classOrder = [
    'Barbarian',
    'Bard',
    'Cleric',
    'Druid',
    'Fighter',
    'Monk',
    'Paladin',
    'Ranger',
    'Rogue',
    'Sorcerer',
    'Warlock',
    'Wizard',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 7, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) {
        _search.clear();
        setState(() {});
      }
    });
    _search.addListener(() => setState(() {}));
    _loadData();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _search.dispose();
    _customNameCtrl.dispose();
    _customDescCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final srd = ref.read(srdDataSourceProvider);
      final results = await Future.wait([
        Future(() async {
          final map = <String, List<SrdClassFeature>>{};
          await Future.wait(
            _classOrder.map((cls) async {
              map[cls] = await srd.getClassFeatures(cls);
            }),
          );
          return map;
        }),
        srd.getAllSubclassFeatures(),
        srd.getRaces(),
        srd.getRaceTraits(),
        srd.getBackgrounds(),
        srd.getFeats(),
        srd.getTools(),
      ]);
      if (mounted) {
        setState(() {
          _allClassFeatures = results[0] as Map<String, List<SrdClassFeature>>;
          _allSubclassFeatures =
              results[1] as Map<String, Map<String, List<SrdClassFeature>>>;
          _races = results[2] as List<SrdRace>;
          _raceTraits = results[3] as Map<String, String>;
          _backgrounds = results[4] as List<SrdBackground>;
          _feats = results[5] as List<SrdFeat>;
          _tools = results[6] as List<SrdTool>;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadError = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final notifier = ref.read(
      characterDetailProvider(widget.characterId).notifier,
    );
    final character = ref
        .watch(characterDetailProvider(widget.characterId))
        .valueOrNull;
    final existingKeys = {
      ...?character?.extraFeatures.map((f) => '${f.sourceClass}:${f.name}'),
    };

    return DraggableScrollableSheet(
      initialChildSize: 0.87,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.featuresAddLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Search field (hidden on Custom tab, index 6)
          if (_tabs.index != 6)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.hintSearch,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _search.clear(),
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          // TabBar
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _getTabLabels(context).map((l) => Tab(text: l)).toList(),
          ),
          // Body
          Expanded(
            child: _loadError != null
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.featuresLoadError,
                      style: TextStyle(color: scheme.error),
                    ),
                  )
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _buildFeatsList(existingKeys, notifier, scheme, i18n),
                      _buildClassList(existingKeys, notifier, scheme, i18n),
                      _buildSubclassList(existingKeys, notifier, scheme, i18n),
                      _buildRacialList(existingKeys, notifier, scheme, i18n),
                      _buildBackgroundList(
                        existingKeys,
                        notifier,
                        scheme,
                        i18n,
                      ),
                      _buildToolsList(
                        character?.features ?? [],
                        notifier,
                        scheme,
                        i18n,
                      ),
                      _buildCustomForm(notifier, scheme, scrollCtrl),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Shared tile builder ───────────────────────────────────────────────────

  Widget _buildTile({
    required SrdClassFeature feature,
    required String sourceLabel,
    required String sourceKey,
    required Set<String> existingKeys,
    required CharacterDetailNotifier notifier,
    required ColorScheme scheme,
    String? subtitle,
    String? Function(String)? nameTranslator,
    String? Function(String)? descriptionTranslator,
  }) {
    final key = '$sourceKey:${feature.name}';
    final alreadyAdded = existingKeys.contains(key);
    final displayName = nameTranslator?.call(feature.name) ?? feature.name;
    final displayDescription =
        descriptionTranslator?.call(feature.name) ?? feature.description;
    final typeLabel = _featureTypeLabel(feature.type, context);
    final displaySubtitle =
        subtitle ??
        '${AppLocalizations.of(context)!.charCardLevel(feature.level)} · $typeLabel';
    return ListTile(
      title: Text(displayName, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        displaySubtitle,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: alreadyAdded
          ? SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: Icon(
                  Icons.check_circle,
                  color: scheme.primary,
                  size: 24,
                ),
              ),
            )
          : IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: scheme.primary,
              onPressed: () async {
                await notifier.addExtraFeature(feature, sourceKey);
                if (mounted) setState(() {});
              },
            ),
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => _FeatureDetailSheet(
            name: displayName,
            description: displayDescription,
            subtitle: displaySubtitle,
          ),
        );
      },
    );
  }

  // ── Feats tab ─────────────────────────────────────────────────────────────

  Widget _buildFeatsList(
    Set<String> existingKeys,
    CharacterDetailNotifier notifier,
    ColorScheme scheme,
    SrdI18nService i18n,
  ) {
    if (_feats == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final l10n = AppLocalizations.of(context)!;
    final q = _search.text.toLowerCase();
    final feats = q.isEmpty
        ? _feats!
        : _feats!.where((f) {
            final name = i18n.featName(f.name) ?? f.name;
            final desc = i18n.featDescription(f.name) ?? f.description;
            return name.toLowerCase().contains(q) ||
                desc.toLowerCase().contains(q) ||
                f.name.toLowerCase().contains(q);
          }).toList();

    if (feats.isEmpty) return _emptySearch(q);

    return ListView.builder(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewPadding.bottom,
      ),
      itemCount: feats.length,
      itemBuilder: (_, i) {
        final feat = feats[i];
        final key = 'Feat:${feat.name}';
        final alreadyAdded = existingKeys.contains(key);
        final displayName = i18n.featName(feat.name) ?? feat.name;
        final displayDesc = i18n.featDescription(feat.name) ?? feat.description;
        final prereq = feat.prerequisite;
        final subtitle = prereq != null
            ? l10n.featPrerequisite(prereq)
            : l10n.labelPassive;
        return ListTile(
          title: Text(displayName, style: const TextStyle(fontSize: 14)),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
          ),
          trailing: alreadyAdded
              ? SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Icon(Icons.check_circle,
                        color: scheme.primary, size: 24),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: scheme.primary,
                  onPressed: () async {
                    await notifier.addFeat(feat);
                    if (mounted) setState(() {});
                  },
                ),
          onTap: () {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => _FeatureDetailSheet(
                name: displayName,
                description: displayDesc,
                subtitle: subtitle,
              ),
            );
          },
        );
      },
    );
  }

  // ── Classe tab ────────────────────────────────────────────────────────────

  Widget _buildClassList(
    Set<String> existingKeys,
    CharacterDetailNotifier notifier,
    ColorScheme scheme,
    SrdI18nService i18n,
  ) {
    if (_allClassFeatures == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final q = _search.text.toLowerCase();

    if (q.isNotEmpty) {
      final results = <(String, SrdClassFeature)>[];
      for (final cls in _classOrder) {
        for (final f in _allClassFeatures![cls] ?? <SrdClassFeature>[]) {
          final localizedName = i18n.classFeatureName(cls, f.name);
          final localizedDesc = i18n.classFeatureDescription(cls, f.name);
          if (f.name.toLowerCase().contains(q) ||
              f.description.toLowerCase().contains(q) ||
              (localizedName != null && localizedName.toLowerCase().contains(q)) ||
              (localizedDesc != null && localizedDesc.toLowerCase().contains(q))) {
            results.add((cls, f));
          }
        }
      }
      if (results.isEmpty) {
        return _emptySearch(q);
      }
      return ListView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
        children: results
            .map(
              (r) => _buildTile(
                feature: r.$2,
                sourceLabel: r.$1,
                sourceKey: r.$1,
                existingKeys: existingKeys,
                notifier: notifier,
                scheme: scheme,
                nameTranslator: (n) => i18n.classFeatureName(r.$1, n),
                descriptionTranslator: (n) =>
                    i18n.classFeatureDescription(r.$1, n),
              ),
            )
            .toList(),
      );
    }

    final slivers = <Widget>[];
    for (final cls in _classOrder) {
      final features = _allClassFeatures![cls] ?? [];
      if (features.isEmpty) continue;
      slivers.add(
        SliverStickyHeader(
          header: _GroupHeader(label: cls),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _buildTile(
                feature: features[i],
                sourceLabel: cls,
                sourceKey: cls,
                existingKeys: existingKeys,
                notifier: notifier,
                scheme: scheme,
                nameTranslator: (n) => i18n.classFeatureName(cls, n),
                descriptionTranslator: (n) =>
                    i18n.classFeatureDescription(cls, n),
              ),
              childCount: features.length,
            ),
          ),
        ),
      );
    }
    slivers.add(
      SliverPadding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
      ),
    );
    return CustomScrollView(slivers: slivers);
  }

  // ── Subclasse tab ─────────────────────────────────────────────────────────

  Widget _buildSubclassList(
    Set<String> existingKeys,
    CharacterDetailNotifier notifier,
    ColorScheme scheme,
    SrdI18nService i18n,
  ) {
    if (_allSubclassFeatures == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final q = _search.text.toLowerCase();
    final allSub = _allSubclassFeatures!;

    if (q.isNotEmpty) {
      // Tuple: (className, subclassName, feature)
      final results = <(String, String, SrdClassFeature)>[];
      for (final cls in _classOrder) {
        final subMap = allSub[cls] ?? {};
        for (final subName in subMap.keys) {
          for (final f in subMap[subName]!) {
            final localizedName = i18n.subclassFeatureName(cls, subName, f.name);
            final localizedDesc = i18n.subclassFeatureDescription(cls, subName, f.name);
            final localizedSub = i18n.subclassName(cls, subName);
            if (f.name.toLowerCase().contains(q) ||
                f.description.toLowerCase().contains(q) ||
                subName.toLowerCase().contains(q) ||
                (localizedName != null && localizedName.toLowerCase().contains(q)) ||
                (localizedDesc != null && localizedDesc.toLowerCase().contains(q)) ||
                localizedSub.toLowerCase().contains(q)) {
              results.add((cls, subName, f));
            }
          }
        }
      }
      if (results.isEmpty) return _emptySearch(q);
      return ListView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
        children: results
            .map(
              (r) => _buildTile(
                feature: r.$3,
                sourceLabel: r.$2,
                sourceKey: r.$2,
                existingKeys: existingKeys,
                notifier: notifier,
                scheme: scheme,
                nameTranslator: (n) => i18n.subclassFeatureName(r.$1, r.$2, n),
                descriptionTranslator: (n) =>
                    i18n.subclassFeatureDescription(r.$1, r.$2, n),
              ),
            )
            .toList(),
      );
    }

    final slivers = <Widget>[];
    for (final cls in _classOrder) {
      final subMap = allSub[cls];
      if (subMap == null || subMap.isEmpty) continue;
      for (final subName in subMap.keys) {
        final features = subMap[subName]!;
        if (features.isEmpty) continue;
        slivers.add(
          SliverStickyHeader(
            header: _GroupHeader(label: '$cls — $subName'),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _buildTile(
                  feature: features[i],
                  sourceLabel: subName,
                  sourceKey: subName,
                  existingKeys: existingKeys,
                  notifier: notifier,
                  scheme: scheme,
                  nameTranslator: (n) =>
                      i18n.subclassFeatureName(cls, subName, n),
                  descriptionTranslator: (n) =>
                      i18n.subclassFeatureDescription(cls, subName, n),
                ),
                childCount: features.length,
              ),
            ),
          ),
        );
      }
    }
    slivers.add(
      SliverPadding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
      ),
    );
    return CustomScrollView(slivers: slivers);
  }

  // ── Racial tab ────────────────────────────────────────────────────────────

  Widget _buildRacialList(
    Set<String> existingKeys,
    CharacterDetailNotifier notifier,
    ColorScheme scheme,
    SrdI18nService i18n,
  ) {
    if (_races == null || _raceTraits == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final q = _search.text.toLowerCase();
    final traitMap = _raceTraits!;

    SrdClassFeature traitToFeature(String traitName) => SrdClassFeature(
      name: traitName,
      level: 1,
      type: 'passive',
      description: traitMap[traitName] ?? '',
    );

    if (q.isNotEmpty) {
      final results = <(String, SrdClassFeature)>[];
      for (final race in _races!) {
        for (final t in race.traits) {
          final f = traitToFeature(t);
          final localizedName = i18n.raceTraitName(t);
          final localizedDesc = i18n.raceTraitDescription(t);
          if (t.toLowerCase().contains(q) ||
              f.description.toLowerCase().contains(q) ||
              localizedName.toLowerCase().contains(q) ||
              (localizedDesc != null && localizedDesc.toLowerCase().contains(q))) {
            results.add((race.name, f));
          }
        }
        for (final sub in race.subraces) {
          for (final t in sub.traits) {
            final f = traitToFeature(t);
            final localizedName = i18n.raceTraitName(t);
            final localizedDesc = i18n.raceTraitDescription(t);
            if (t.toLowerCase().contains(q) ||
                f.description.toLowerCase().contains(q) ||
                localizedName.toLowerCase().contains(q) ||
                (localizedDesc != null && localizedDesc.toLowerCase().contains(q))) {
              results.add((sub.name, f));
            }
          }
        }
      }
      if (results.isEmpty) return _emptySearch(q);
      return ListView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
        children: results
            .map(
              (r) => _buildTile(
                feature: r.$2,
                sourceLabel: r.$1,
                sourceKey: r.$1,
                existingKeys: existingKeys,
                notifier: notifier,
                scheme: scheme,
                subtitle: r.$1,
                nameTranslator: (n) => i18n.raceTraitName(n),
                descriptionTranslator: (n) => i18n.raceTraitDescription(n),
              ),
            )
            .toList(),
      );
    }

    final slivers = <Widget>[];
    for (final race in _races!) {
      final allEntries = <(String sourceKey, SrdClassFeature)>[];
      for (final t in race.traits) {
        allEntries.add((race.name, traitToFeature(t)));
      }
      for (final sub in race.subraces) {
        for (final t in sub.traits) {
          allEntries.add((sub.name, traitToFeature(t)));
        }
      }
      if (allEntries.isEmpty) continue;

      slivers.add(
        SliverStickyHeader(
          header: _GroupHeader(label: race.name),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((_, i) {
              final (key, f) = allEntries[i];
              return _buildTile(
                feature: f,
                sourceLabel: key,
                sourceKey: key,
                existingKeys: existingKeys,
                notifier: notifier,
                scheme: scheme,
                subtitle: key == race.name ? race.name : '${race.name} — $key',
                nameTranslator: (n) => i18n.raceTraitName(n),
                descriptionTranslator: (n) => i18n.raceTraitDescription(n),
              );
            }, childCount: allEntries.length),
          ),
        ),
      );
    }
    slivers.add(
      SliverPadding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
      ),
    );
    return CustomScrollView(slivers: slivers);
  }

  // ── Custom tab ────────────────────────────────────────────────────────────

  Widget _buildCustomForm(
    CharacterDetailNotifier notifier,
    ColorScheme scheme,
    ScrollController scrollCtrl,
  ) {
    return SingleChildScrollView(
      controller: scrollCtrl,
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        32 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _customNameCtrl,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.labelFeatureName,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customDescCtrl,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.labelFeatureDescription,
              border: const OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(AppLocalizations.of(context)!.labelFeatureType),
              const SizedBox(width: 12),
              ChoiceChip(
                label: Text(AppLocalizations.of(context)!.labelPassive),
                selected: !_customTypeActive,
                onSelected: (_) => setState(() => _customTypeActive = false),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(AppLocalizations.of(context)!.labelActive),
                selected: _customTypeActive,
                onSelected: (_) => setState(() => _customTypeActive = true),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _customNameCtrl.text.trim().isEmpty
                ? null
                : () async {
                    final f = SrdClassFeature(
                      name: _customNameCtrl.text.trim(),
                      level: 1,
                      type: _customTypeActive ? 'active' : 'passive',
                      description: _customDescCtrl.text.trim(),
                    );
                    await notifier.addExtraFeature(f, kFeatureSourceCustom);
                    _customNameCtrl.clear();
                    _customDescCtrl.clear();
                    if (mounted) {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.featureAddedSnackbar(f.name)),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.featureAddButton),
          ),
        ],
      ),
    );
  }

  // ── Background tab ───────────────────────────────────────────────────────

  Widget _buildBackgroundList(
    Set<String> existingKeys,
    CharacterDetailNotifier notifier,
    ColorScheme scheme,
    SrdI18nService i18n,
  ) {
    if (_backgrounds == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final q = _search.text.toLowerCase();

    SrdClassFeature bgToFeature(SrdBackground bg) => SrdClassFeature(
      name: bg.feature.name,
      level: 1,
      type: 'passive',
      description: bg.feature.description,
    );

    if (q.isNotEmpty) {
      final results = <(String, SrdClassFeature)>[];
      for (final bg in _backgrounds!) {
        final f = bgToFeature(bg);
        final localizedBgName = i18n.backgroundName(bg.name);
        final localizedFeatureName = i18n.backgroundFeatureName(bg.name);
        if (bg.name.toLowerCase().contains(q) ||
            f.name.toLowerCase().contains(q) ||
            f.description.toLowerCase().contains(q) ||
            localizedBgName.toLowerCase().contains(q) ||
            (localizedFeatureName != null && localizedFeatureName.toLowerCase().contains(q))) {
          results.add((bg.name, f));
        }
      }
      if (results.isEmpty) return _emptySearch(q);
      return ListView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
        children: results
            .map(
              (r) => _buildTile(
                feature: r.$2,
                sourceLabel: r.$1,
                sourceKey: r.$1,
                existingKeys: existingKeys,
                notifier: notifier,
                scheme: scheme,
                subtitle: r.$1,
                nameTranslator: (_) => i18n.backgroundFeatureName(r.$1),
                descriptionTranslator: (_) =>
                    i18n.backgroundFeatureDescription(r.$1),
              ),
            )
            .toList(),
      );
    }

    final slivers = <Widget>[];
    for (final bg in _backgrounds!) {
      final f = bgToFeature(bg);
      slivers.add(
        SliverStickyHeader(
          header: _GroupHeader(label: bg.name),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, _) => _buildTile(
                feature: f,
                sourceLabel: bg.name,
                sourceKey: bg.name,
                existingKeys: existingKeys,
                notifier: notifier,
                scheme: scheme,
                subtitle: bg.name,
                nameTranslator: (_) => i18n.backgroundFeatureName(bg.name),
                descriptionTranslator: (_) =>
                    i18n.backgroundFeatureDescription(bg.name),
              ),
              childCount: 1,
            ),
          ),
        ),
      );
    }
    slivers.add(
      SliverPadding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
      ),
    );
    return CustomScrollView(slivers: slivers);
  }

  Widget _emptySearch(String q) => Center(
    child: Text(
      'Nenhuma feature encontrada para "$q"',
      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );

  // ── Tools tab ────────────────────────────────────────────────────────────

  Widget _buildToolsList(
    List<String> currentFeatures,
    CharacterDetailNotifier notifier,
    ColorScheme scheme,
    SrdI18nService i18n,
  ) {
    if (_tools == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final q = _search.text.toLowerCase();
    final tools = q.isEmpty
        ? _tools!
        : _tools!.where((t) {
            final name = i18n.toolName(t.name);
            return name.toLowerCase().contains(q) ||
                t.name.toLowerCase().contains(q) ||
                t.category.toLowerCase().contains(q);
          }).toList();

    if (tools.isEmpty) return _emptySearch(q);

    // Normalise existing tool proficiencies for quick lookup
    final existing = currentFeatures.map((f) {
      return f.startsWith('Tool Proficiency: ')
          ? f.substring('Tool Proficiency: '.length)
          : f;
    }).toSet();

    return ListView.builder(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewPadding.bottom,
      ),
      itemCount: tools.length,
      itemBuilder: (_, i) {
        final tool = tools[i];
        final alreadyAdded = existing.contains(tool.name);
        final displayName = i18n.toolName(tool.name);
        return ListTile(
          title: Text(displayName, style: const TextStyle(fontSize: 14)),
          subtitle: Text(
            tool.category,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          trailing: alreadyAdded
              ? SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Icon(
                      Icons.check_circle,
                      color: scheme.primary,
                      size: 24,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: scheme.primary,
                  onPressed: () async {
                    await notifier.addToolProficiency(tool.name);
                    if (mounted) setState(() {});
                  },
                ),
        );
      },
    );
  }
}

// ── Feature Detail Sheet ──────────────────────────────────────────────────────

class _FeatureDetailSheet extends StatelessWidget {
  const _FeatureDetailSheet({
    required this.name,
    required this.description,
    required this.subtitle,
  });

  final String name;
  final String description;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 1.0,
      builder: (_, scrollCtrl) => ListView(
        controller: scrollCtrl,
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [
          // Drag handle
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Name
          Text(name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),

          // Subtitle (level · type)
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Description
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
