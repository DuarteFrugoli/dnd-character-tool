import '../../character_detail_dependencies.dart';
import 'feature_support.dart';

PageStorageKey<String> _featureExpansionKey(String scope, List<Object?> parts) {
  final keyParts = [
    'featureExpansion',
    scope,
    for (final part in parts) part?.toString() ?? '',
  ];
  return PageStorageKey<String>(keyParts.join('|'));
}

RoundedRectangleBorder _featureCardShape({required Color accentColor}) {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    side: BorderSide(color: accentColor.withValues(alpha: 0.24)),
  );
}

Widget _featureTypePill({
  required BuildContext context,
  required String label,
  required Color color,
}) {
  return DetailPill(label: label, color: color, dense: true);
}

class RacialTraitsSection extends ConsumerWidget {
  const RacialTraitsSection({
    super.key,
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
    required this.i18n,
  });

  final String raceName;
  final String? subraceName;
  final List<String> raceTraits;
  final List<String> subraceTraits;
  final Map<String, String> traitDescriptions;
  final Set<String> disabledFeatures;
  final FeatureDisabledToggle onToggle;
  final Character character;
  final String characterId;
  final FeaturesData data;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final allTraits = [...raceTraits, ...subraceTraits];
    if (allTraits.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final title = subraceName != null && subraceName!.isNotEmpty
        ? i18n.subraceName(subraceName!)
        : i18n.raceName(raceName);

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: DetailSectionHeader(
            title: l10n.featuresSectionRacialTraits(title),
            icon: Icons.diversity_3_outlined,
            accentColor: scheme.primary,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final trait = allTraits[index];
            final isDisabled = disabledFeatures.contains(trait);
            final desc = traitDescriptions[trait];
            final usageView = FeatureUsageEngine.viewForRef(
              catalog: data.featureUsageCatalog,
              character: character,
              ref: data.featureUsageCatalog.raceTrait(trait),
            );
            final requests = FeatureChoiceEngine.requestsForRaceTrait(
              catalog: data.featureChoiceCatalog,
              traitName: trait,
              level: character.totalLevel,
            );
            Widget card;
            if (desc == null || desc.isEmpty) {
              card = Card(
                margin: const EdgeInsets.only(bottom: 6),
                elevation: 0,
                color: scheme.surfaceContainerLow,
                surfaceTintColor: scheme.primary,
                shape: _featureCardShape(accentColor: scheme.primary),
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
                    if (usageView != null)
                      FeatureUsageControls(
                        view: usageView,
                        characterId: characterId,
                        i18n: i18n,
                      ),
                    ...featureChoiceWidgets(
                      context: context,
                      ref: ref,
                      characterId: characterId,
                      character: character,
                      requests: requests,
                      data: data,
                      i18n: i18n,
                    ),
                  ],
                ),
              );
            } else {
              card = Card(
                margin: const EdgeInsets.only(bottom: 6),
                elevation: 0,
                color: scheme.surfaceContainerLow,
                surfaceTintColor: scheme.primary,
                shape: _featureCardShape(accentColor: scheme.primary),
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  key: _featureExpansionKey('race', [
                    raceName,
                    subraceName,
                    trait,
                  ]),
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
                    ...featureChoiceWidgets(
                      context: context,
                      ref: ref,
                      characterId: characterId,
                      character: character,
                      requests: requests,
                      data: data,
                      i18n: i18n,
                    ),
                    if (usageView != null)
                      FeatureUsageControls(
                        view: usageView,
                        characterId: characterId,
                        i18n: i18n,
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
          }, childCount: allTraits.length),
        ),
      ],
    );
  }
}

class BackgroundFeatureSection extends ConsumerWidget {
  const BackgroundFeatureSection({
    super.key,
    required this.backgroundName,
    required this.featureName,
    required this.featureDescription,
    required this.disabledFeatures,
    required this.onToggle,
    required this.i18n,
  });

  final String backgroundName;
  final String featureName;
  final String featureDescription;
  final Set<String> disabledFeatures;
  final FeatureDisabledToggle onToggle;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final isDisabled = disabledFeatures.contains(featureName);
    final card = Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      surfaceTintColor: scheme.secondary,
      shape: _featureCardShape(accentColor: scheme.secondary),
      child: ExpansionTile(
        key: _featureExpansionKey('background', [backgroundName, featureName]),
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
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: DetailSectionHeader(
            title: l10n.featuresSectionBackground(
              i18n.backgroundName(backgroundName),
            ),
            icon: Icons.history_edu_outlined,
            accentColor: scheme.secondary,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: GestureDetector(
            onLongPress: () => onToggle(featureName),
            child: isDisabled ? Opacity(opacity: 0.35, child: card) : card,
          ),
        ),
      ],
    );
  }
}

// ── Tool Proficiencies Section ────────────────────────────────────────────────

class ToolProficienciesSection extends ConsumerWidget {
  const ToolProficienciesSection({
    super.key,
    required this.features,
    required this.characterId,
    required this.i18n,
  });
  final List<String> features;
  final String characterId;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final notifier = ref.read(characterDetailProvider(characterId).notifier);
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: DetailSectionHeader(
            title: l10n.featuresSectionTools,
            icon: Icons.handyman_outlined,
            accentColor: scheme.secondary,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final f = features[index];
            final label = f.startsWith('Tool Proficiency: ')
                ? f.substring('Tool Proficiency: '.length)
                : f;
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              elevation: 0,
              color: scheme.surfaceContainerLow,
              surfaceTintColor: scheme.secondary,
              shape: _featureCardShape(accentColor: scheme.secondary),
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
                        content: Text(
                          l10n.featuresRemoveContent(i18n.toolName(label)),
                        ),
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
          }, childCount: features.length),
        ),
      ],
    );
  }
}

class FeatsSection extends ConsumerWidget {
  const FeatsSection({
    super.key,
    required this.feats,
    required this.character,
    required this.characterId,
    required this.data,
    required this.i18n,
  });

  final List<CharacterExtraFeature> feats;
  final Character character;
  final String characterId;
  final FeaturesData data;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final notifier = ref.read(characterDetailProvider(characterId).notifier);
    final l10n = AppLocalizations.of(context)!;

    Widget buildFeat(CharacterExtraFeature f) {
      final requests = FeatureChoiceEngine.requestsForFeat(
        catalog: data.featureChoiceCatalog,
        featName: f.name,
        level: character.totalLevel,
      );
      final usageView = FeatureUsageEngine.viewForRef(
        catalog: data.featureUsageCatalog,
        character: character,
        ref: data.featureUsageCatalog.feat(f.name),
      );
      final displayName = i18n.featName(f.name) ?? f.name;
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 0,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: scheme.tertiary,
        shape: _featureCardShape(accentColor: scheme.tertiary),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          key: _featureExpansionKey('feat', [f.name]),
          title: Text(
            displayName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            l10n.featuresSectionFeats,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.tertiary),
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
                  content: Text(l10n.featuresRemoveContent(displayName)),
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
            ...featureChoiceWidgets(
              context: context,
              ref: ref,
              characterId: characterId,
              character: character,
              requests: requests,
              data: data,
              i18n: i18n,
            ),
            if (usageView != null)
              FeatureUsageControls(
                view: usageView,
                characterId: characterId,
                i18n: i18n,
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
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: DetailSectionHeader(
            title: l10n.featuresSectionFeats,
            icon: Icons.workspace_premium_outlined,
            accentColor: scheme.tertiary,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => buildFeat(feats[index]),
            childCount: feats.length,
          ),
        ),
      ],
    );
  }
}

class ExtraFeaturesSection extends ConsumerWidget {
  const ExtraFeaturesSection({
    super.key,
    required this.features,
    required this.characterId,
    required this.character,
    required this.data,
    required this.i18n,
  });

  final List<CharacterExtraFeature> features;
  final String characterId;
  final Character character;
  final FeaturesData data;
  final SrdI18nService i18n;

  List<FeatureChoiceRequest> _requestsForExtra(CharacterExtraFeature feature) {
    final catalog = data.featureChoiceCatalog;
    final sourceClass = _sourceClassForExtra(feature);
    final sourceClassLevel = _sourceClassLevelForExtra(feature);
    final classRequests = FeatureChoiceEngine.requestsForClassFeature(
      catalog: catalog,
      className: sourceClass,
      sourceClassEntryId: feature.sourceClassEntryId,
      featureName: feature.name,
      level: sourceClassLevel,
    );
    if (classRequests.isNotEmpty) return classRequests;

    final subclassRequests = FeatureChoiceEngine.requestsForSubclassFeature(
      catalog: catalog,
      className: sourceClass,
      sourceClassEntryId: feature.sourceClassEntryId,
      subclassName: _sourceSubclassForExtra(feature),
      featureName: feature.name,
      level: sourceClassLevel,
    );
    if (subclassRequests.isNotEmpty) return subclassRequests;

    return FeatureChoiceEngine.requestsForRaceTrait(
      catalog: catalog,
      traitName: feature.name,
      level: character.totalLevel,
    );
  }

  FeatureUsageContext _usageContextForExtra(CharacterExtraFeature feature) {
    if (feature.effectiveSourceType == FeatureChoiceSourceType.feat ||
        feature.sourceClass == 'Feat') {
      return FeatureUsageContext.forCharacter(character);
    }
    return FeatureUsageContext.forCharacter(
      character,
      sourceClass: _sourceClassForExtra(feature),
      sourceClassLevel: _sourceClassLevelForExtra(feature),
    );
  }

  String _sourceClassForExtra(CharacterExtraFeature feature) {
    final sourceClassEntryId = feature.sourceClassEntryId;
    if (sourceClassEntryId != null) {
      for (final entry in character.classEntries) {
        if (entry.id == sourceClassEntryId) return entry.className;
      }
    }
    final subclassName = _sourceSubclassForExtra(feature);
    if (feature.effectiveSourceType ==
            FeatureChoiceSourceType.subclassFeature &&
        (feature.sourceClass.isEmpty || feature.sourceClass == subclassName)) {
      return character.primaryClassName;
    }
    if (feature.sourceClass.isEmpty) return character.primaryClassName;
    return feature.sourceClass;
  }

  String _sourceSubclassForExtra(CharacterExtraFeature feature) {
    final sourceClassEntryId = feature.sourceClassEntryId;
    if (sourceClassEntryId != null) {
      for (final entry in character.classEntries) {
        if (entry.id == sourceClassEntryId) {
          return feature.sourceSubclass ?? entry.subclassName ?? '';
        }
      }
    }
    return feature.sourceSubclass ?? feature.sourceClass;
  }

  int _sourceClassLevelForExtra(CharacterExtraFeature feature) {
    final sourceClassEntryId = feature.sourceClassEntryId;
    if (sourceClassEntryId != null) {
      for (final entry in character.classEntries) {
        if (entry.id == sourceClassEntryId) return entry.level;
      }
    }
    final classLevel = character.classLevel(_sourceClassForExtra(feature));
    return classLevel > 0 ? classLevel : feature.level;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final notifier = ref.read(characterDetailProvider(characterId).notifier);

    final l10n2 = AppLocalizations.of(context)!;
    Widget buildExtra(CharacterExtraFeature f) {
      final sourceClass = _sourceClassForExtra(f);
      final sourceSubclass = _sourceSubclassForExtra(f);
      final requests = _requestsForExtra(f);
      final usageRef =
          data.featureUsageCatalog.classFeature(sourceClass, f.name) ??
          data.featureUsageCatalog.subclassFeature(
            sourceClass,
            sourceSubclass,
            f.name,
          ) ??
          data.featureUsageCatalog.raceTrait(f.name);
      final usageView = FeatureUsageEngine.viewForRef(
        catalog: data.featureUsageCatalog,
        character: character,
        ref: usageRef,
        usageContext: _usageContextForExtra(f),
      );
      final displayName =
          i18n.classFeatureName(sourceClass, f.name) ??
          i18n.anySubclassFeatureName(sourceClass, f.name) ??
          i18n.raceTraitName(f.name);
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 0,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: scheme.primary,
        shape: _featureCardShape(accentColor: scheme.primary),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          key: _featureExpansionKey('extra', [
            f.effectiveSourceType,
            f.sourceClassEntryId,
            f.sourceClass,
            f.sourceSubclass,
            f.name,
          ]),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              DetailPill(
                label: i18n.className(sourceClass),
                color: scheme.tertiary,
                dense: true,
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
                  content: Text(l10n.featuresRemoveContent(displayName)),
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
            ...featureChoiceWidgets(
              context: context,
              ref: ref,
              characterId: characterId,
              character: character,
              requests: requests,
              data: data,
              i18n: i18n,
            ),
            if (usageView != null)
              FeatureUsageControls(
                view: usageView,
                characterId: characterId,
                i18n: i18n,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                i18n.classFeatureDescription(sourceClass, f.name) ??
                    i18n.anySubclassFeatureDescription(sourceClass, f.name) ??
                    f.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: DetailSectionHeader(
            title: l10n2.featuresSectionExtra,
            icon: Icons.auto_awesome_outlined,
            accentColor: scheme.primary,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => buildExtra(features[index]),
            childCount: features.length,
          ),
        ),
      ],
    );
  }
}

class ClassFeaturesSection extends ConsumerWidget {
  const ClassFeaturesSection({
    super.key,
    required this.classEntry,
    required this.features,
    required this.disabledFeatures,
    required this.onToggle,
    required this.character,
    required this.characterId,
    required this.data,
    required this.i18n,
  });

  final CharacterClassEntry classEntry;
  final List<SrdClassFeature> features;
  final Set<String> disabledFeatures;
  final FeatureDisabledToggle onToggle;
  final Character character;
  final String characterId;
  final FeaturesData data;
  final SrdI18nService i18n;

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
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final className = classEntry.className;
    final classLevel = classEntry.level;
    final classLabel = '${i18n.className(className)} $classLevel';

    if (features.isEmpty) {
      return SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: DetailSectionHeader(
              title: l10n.featuresSectionClass(classLabel),
              icon: Icons.shield_outlined,
              accentColor: scheme.primary,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(child: Text(l10n.featuresNoneAvailable)),
        ],
      );
    }

    Widget buildFeature(SrdClassFeature f) {
      final typeColor = _typeColor(f.type, scheme);
      final disabledKey = classFeatureDisabledKey(
        classEntry: classEntry,
        featureName: f.name,
      );
      final isDisabled = featureIsDisabled(
        disabledFeatures,
        disabledKey,
        legacyName: f.name,
      );
      final requests = FeatureChoiceEngine.requestsForClassFeature(
        catalog: data.featureChoiceCatalog,
        className: className,
        sourceClassEntryId: classEntry.id,
        featureName: f.name,
        level: classLevel,
      );
      final usageView = FeatureUsageEngine.viewForRef(
        catalog: data.featureUsageCatalog,
        character: character,
        ref: data.featureUsageCatalog.classFeature(className, f.name),
        usageContext: FeatureUsageContext.forCharacter(
          character,
          sourceClass: className,
          sourceClassLevel: classLevel,
        ),
      );
      final card = Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 0,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: typeColor,
        shape: _featureCardShape(accentColor: typeColor),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          key: _featureExpansionKey('class', [classEntry.id, f.name]),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  i18n.classFeatureName(className, f.name) ?? f.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              _featureTypePill(
                context: context,
                label: featureTypeLabel(f.type, context),
                color: typeColor,
              ),
            ],
          ),
          subtitle: Wrap(
            spacing: 8,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.charCardLevel(f.level),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (usageView != null && !usageView.isUnlimited) ...[
                Text(
                  '${l10n.inventoryDetailUses}: '
                  '${usageView.current}/${usageView.max}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: scheme.primary),
                ),
              ],
            ],
          ),
          children: [
            ...featureChoiceWidgets(
              context: context,
              ref: ref,
              characterId: characterId,
              character: character,
              requests: requests,
              data: data,
              i18n: i18n,
            ),
            if (usageView != null)
              FeatureUsageControls(
                view: usageView,
                characterId: characterId,
                i18n: i18n,
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
        onLongPress: () => onToggle(disabledKey, legacyName: f.name),
        child: isDisabled ? Opacity(opacity: 0.35, child: card) : card,
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: DetailSectionHeader(
            title: l10n.featuresSectionClass(classLabel),
            icon: Icons.shield_outlined,
            accentColor: scheme.primary,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => buildFeature(features[index]),
            childCount: features.length,
          ),
        ),
      ],
    );
  }
}

// ── Subclass Features Section ─────────────────────────────────────────────────

class SubclassFeaturesSection extends ConsumerWidget {
  const SubclassFeaturesSection({
    super.key,
    required this.classEntry,
    required this.features,
    required this.disabledFeatures,
    required this.onToggle,
    required this.character,
    required this.characterId,
    required this.data,
    required this.i18n,
  });

  final CharacterClassEntry classEntry;
  final List<SrdClassFeature> features;
  final Set<String> disabledFeatures;
  final FeatureDisabledToggle onToggle;
  final Character character;
  final String characterId;
  final FeaturesData data;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final className = classEntry.className;
    final subclassName = classEntry.subclassName ?? '';
    final classLevel = classEntry.level;
    final subclassLabel =
        '${i18n.subclassName(className, subclassName)} '
        '(${i18n.className(className)} $classLevel)';
    Widget buildFeature(SrdClassFeature f) {
      final typeColor = f.type == 'active' ? scheme.primary : scheme.outline;
      final disabledKey = subclassFeatureDisabledKey(
        classEntry: classEntry,
        subclassName: subclassName,
        featureName: f.name,
      );
      final isDisabled = featureIsDisabled(
        disabledFeatures,
        disabledKey,
        legacyName: f.name,
      );
      final requests = FeatureChoiceEngine.requestsForSubclassFeature(
        catalog: data.featureChoiceCatalog,
        className: className,
        sourceClassEntryId: classEntry.id,
        subclassName: subclassName,
        featureName: f.name,
        level: classLevel,
      );
      final usageView = FeatureUsageEngine.viewForRef(
        catalog: data.featureUsageCatalog,
        character: character,
        ref: data.featureUsageCatalog.subclassFeature(
          className,
          subclassName,
          f.name,
        ),
        usageContext: FeatureUsageContext.forCharacter(
          character,
          sourceClass: className,
          sourceClassLevel: classLevel,
        ),
      );
      final card = Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 0,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: typeColor,
        shape: _featureCardShape(accentColor: typeColor),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          key: _featureExpansionKey('subclass', [
            classEntry.id,
            subclassName,
            f.name,
          ]),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  i18n.subclassFeatureName(className, subclassName, f.name) ??
                      f.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              _featureTypePill(
                context: context,
                label: f.type == 'active'
                    ? AppLocalizations.of(context)!.labelActive
                    : AppLocalizations.of(context)!.labelPassive,
                color: typeColor,
              ),
            ],
          ),
          subtitle: Wrap(
            spacing: 8,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.charCardLevel(f.level),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (usageView != null && !usageView.isUnlimited) ...[
                Text(
                  '${l10n.inventoryDetailUses}: '
                  '${usageView.current}/${usageView.max}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: scheme.primary),
                ),
              ],
            ],
          ),
          children: [
            ...featureChoiceWidgets(
              context: context,
              ref: ref,
              characterId: characterId,
              character: character,
              requests: requests,
              data: data,
              i18n: i18n,
            ),
            if (usageView != null)
              FeatureUsageControls(
                view: usageView,
                characterId: characterId,
                i18n: i18n,
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
        onLongPress: () => onToggle(disabledKey, legacyName: f.name),
        child: isDisabled ? Opacity(opacity: 0.35, child: card) : card,
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: DetailSectionHeader(
            title: l10n.featuresSectionSubclass(subclassLabel),
            icon: Icons.account_tree_outlined,
            accentColor: scheme.tertiary,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => buildFeature(features[index]),
            childCount: features.length,
          ),
        ),
      ],
    );
  }
}

// ── Add Feature Sheet ─────────────────────────────────────────────────────────
