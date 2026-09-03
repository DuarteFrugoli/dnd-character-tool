import '../../character_detail_dependencies.dart';
import 'feature_detail_sheet.dart';
import 'feature_support.dart';

class AddFeatureSheet extends ConsumerStatefulWidget {
  const AddFeatureSheet({super.key, required this.characterId});
  final String characterId;

  @override
  ConsumerState<AddFeatureSheet> createState() => _AddFeatureSheetState();
}

class _AddFeatureSheetState extends ConsumerState<AddFeatureSheet>
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
      final results = await Future.wait([
        Future(() async {
          final map = <String, List<SrdClassFeature>>{};
          await Future.wait(
            _classOrder.map((cls) async {
              map[cls] = await ref.read(srdClassFeaturesProvider(cls).future);
            }),
          );
          return map;
        }),
        ref.read(srdAllSubclassFeaturesProvider.future),
        ref.read(srdRacesProvider.future),
        ref.read(srdRaceTraitsProvider.future),
        ref.read(srdBackgroundsProvider.future),
        ref.read(srdFeatsProvider.future),
        ref.read(srdToolsProvider.future),
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
      for (final feature
          in character?.extraFeatures ?? const <CharacterExtraFeature>[]) ...[
        '${feature.sourceClass}:${feature.name}',
        if (feature.sourceSubclass != null)
          '${feature.sourceSubclass}:${feature.name}',
        if (feature.sourceClassEntryId != null)
          '${feature.sourceClassEntryId}:${feature.name}',
      ],
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
    final typeLabel = featureTypeLabel(feature.type, context);
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
          builder: (_) => FeatureDetailSheet(
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
                    await notifier.addFeat(feat);
                    if (mounted) setState(() {});
                  },
                ),
          onTap: () {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => FeatureDetailSheet(
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
              (localizedName != null &&
                  localizedName.toLowerCase().contains(q)) ||
              (localizedDesc != null &&
                  localizedDesc.toLowerCase().contains(q))) {
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
          header: DetailGroupHeader(label: cls),
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
            final localizedName = i18n.subclassFeatureName(
              cls,
              subName,
              f.name,
            );
            final localizedDesc = i18n.subclassFeatureDescription(
              cls,
              subName,
              f.name,
            );
            final localizedSub = i18n.subclassName(cls, subName);
            if (f.name.toLowerCase().contains(q) ||
                f.description.toLowerCase().contains(q) ||
                subName.toLowerCase().contains(q) ||
                (localizedName != null &&
                    localizedName.toLowerCase().contains(q)) ||
                (localizedDesc != null &&
                    localizedDesc.toLowerCase().contains(q)) ||
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
            header: DetailGroupHeader(label: '$cls — $subName'),
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
              (localizedDesc != null &&
                  localizedDesc.toLowerCase().contains(q))) {
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
                (localizedDesc != null &&
                    localizedDesc.toLowerCase().contains(q))) {
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
          header: DetailGroupHeader(label: race.name),
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
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.featureAddedSnackbar(f.name),
                          ),
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
            (localizedFeatureName != null &&
                localizedFeatureName.toLowerCase().contains(q))) {
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
          header: DetailGroupHeader(label: bg.name),
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
