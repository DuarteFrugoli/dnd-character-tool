part of 'character_detail_screen.dart';

// ── Level Up Wizard ───────────────────────────────────────────────────────────

// Represents which ASI mode the player has chosen.
enum _AsiMode { asi, feat }

// All wizard decisions held in local state.
class _LevelUpState {
  _LevelUpState({
    required this.newLevel,
    this.hpGained = 0,
    this.hpChosen = false,
    this.asiMode = _AsiMode.asi,
    this.asiChanges = const {},
    this.cantripsLearned = const [],
    this.spellsLearned = const [],
    this.featureChoices = const [],
  });

  final int newLevel;
  int hpGained;
  bool hpChosen;
  _AsiMode asiMode;
  Map<String, int> asiChanges;
  SrdFeat? featChosen;
  String? subclassChosen;
  List<KnownSpell> cantripsLearned;
  List<KnownSpell> spellsLearned;
  List<CharacterFeatureChoice> featureChoices;
  String? spellSwapped;
  // Replacement spell chosen on the dedicated swap page.
  KnownSpell? swapReplacement;

  _LevelUpState copyWith({
    int? hpGained,
    bool? hpChosen,
    _AsiMode? asiMode,
    Map<String, int>? asiChanges,
    Object? featChosen = _sentinel,
    Object? subclassChosen = _sentinel,
    List<KnownSpell>? cantripsLearned,
    List<KnownSpell>? spellsLearned,
    List<CharacterFeatureChoice>? featureChoices,
    Object? spellSwapped = _sentinel,
    Object? swapReplacement = _sentinel,
  }) {
    final s = _LevelUpState(
      newLevel: newLevel,
      hpGained: hpGained ?? this.hpGained,
      hpChosen: hpChosen ?? this.hpChosen,
      asiMode: asiMode ?? this.asiMode,
      asiChanges: asiChanges ?? this.asiChanges,
      cantripsLearned: cantripsLearned ?? this.cantripsLearned,
      spellsLearned: spellsLearned ?? this.spellsLearned,
      featureChoices: featureChoices ?? this.featureChoices,
    );
    s.featChosen = featChosen == _sentinel
        ? this.featChosen
        : featChosen as SrdFeat?;
    s.subclassChosen = subclassChosen == _sentinel
        ? this.subclassChosen
        : subclassChosen as String?;
    s.spellSwapped = spellSwapped == _sentinel
        ? this.spellSwapped
        : spellSwapped as String?;
    s.swapReplacement = swapReplacement == _sentinel
        ? this.swapReplacement
        : swapReplacement as KnownSpell?;
    return s;
  }

  static const _sentinel = Object();
}

// ── Wizard Entry Point ────────────────────────────────────────────────────────

void _openLevelUpWizardSheet(
  BuildContext context,
  Character character,
  String characterId,
) {
  final newLevel = character.level + 1;
  if (newLevel > 20) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.levelUpMaxLevel)),
    );
    return;
  }
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      pageBuilder: (context, _, _) =>
          _LevelUpWizard(character: character, characterId: characterId),
      transitionsBuilder: (_, animation, _, child) {
        final slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeIn);
        return SlideTransition(
          position: slide,
          child: FadeTransition(opacity: fade, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 280),
    ),
  );
}

// ── Wizard Widget ─────────────────────────────────────────────────────────────

class _LevelUpWizard extends ConsumerStatefulWidget {
  const _LevelUpWizard({required this.character, required this.characterId});
  final Character character;
  final String characterId;

  @override
  ConsumerState<_LevelUpWizard> createState() => _LevelUpWizardState();
}

class _LevelUpWizardState extends ConsumerState<_LevelUpWizard> {
  late _LevelUpState _state;
  late PageController _pageController;
  late List<_WizardPage> _pages;

  // Loaded asynchronously
  SrdClass? _srdClass;
  List<SrdClassFeature>? _classFeatures;
  List<SrdClassFeature>? _subclassFeatures;
  Map<String, Map<String, List<SrdClassFeature>>>? _allSubclassFeatures;
  List<SrdSpell>? _allSpells;
  List<SrdFeat>? _allFeats;
  SrdFeatureChoiceCatalog? _featureChoiceCatalog;
  List<SrdSkill> _skills = const [];
  List<SrdTool> _tools = const [];
  List<SrdLanguage> _languages = const [];
  List<SrdWeapon> _weapons = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _state = _LevelUpState(newLevel: widget.character.level + 1);
    _pageController = PageController();
    _pageController.addListener(_handlePageChanged);
    _load();
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    final srd = ref.read(srdDataSourceProvider);
    final className = widget.character.characterClass;
    final results = await Future.wait([
      srd.getClasses(),
      srd.getClassFeatures(className),
      srd.getFeats(),
      srd.getSpells(),
      srd.getFeatureChoiceCatalog(),
      srd.getSkills(),
      srd.getTools(),
      srd.getAllSubclassFeatures(),
      srd.getLanguages(),
      srd.getWeapons(),
    ]);
    if (!mounted) return;
    final classes = results[0] as List<SrdClass>;
    _srdClass = classes.cast<SrdClass?>().firstWhere(
      (c) => c?.name.toLowerCase() == className.toLowerCase(),
      orElse: () => null,
    );
    _classFeatures = results[1] as List<SrdClassFeature>;

    _allFeats = results[2] as List<SrdFeat>;
    _allSpells = results[3] as List<SrdSpell>;
    _featureChoiceCatalog = results[4] as SrdFeatureChoiceCatalog;
    _skills = results[5] as List<SrdSkill>;
    _tools = results[6] as List<SrdTool>;
    _allSubclassFeatures =
        results[7] as Map<String, Map<String, List<SrdClassFeature>>>;
    _languages = results[8] as List<SrdLanguage>;
    _weapons = results[9] as List<SrdWeapon>;

    if (mounted) {
      setState(() {
        _loading = false;
        _rebuildPages();
      });
    }
  }

  String? get _effectiveSubclass =>
      _state.subclassChosen ?? widget.character.subclass;

  SpellcastingEngine? _engineFor(int level, {String? subclass}) {
    return SpellcastingEngine.forClass(
      className: widget.character.characterClass,
      classLevel: level,
      abilityScores: widget.character.abilityScores,
      proficiencyBonus: widget.character.proficiencyBonus,
      subclass: subclass ?? _effectiveSubclass,
    );
  }

  List<String> _newFixedCantripNames(
    SpellcastingEngine? engineOld,
    SpellcastingEngine? engineNew,
  ) {
    if (engineNew == null) return const [];
    final oldFixed = {
      for (final name in engineOld?.fixedCantripNames ?? const <String>[])
        name.toLowerCase(),
    };
    return engineNew.fixedCantripNames
        .where((name) => !oldFixed.contains(name.toLowerCase()))
        .toList();
  }

  List<KnownSpell> _computeFixedCantripsToLearn(
    SpellcastingEngine? engineOld,
    SpellcastingEngine? engineNew,
  ) {
    final knownNames = {
      for (final spell in widget.character.spells) spell.name.toLowerCase(),
    };
    return _newFixedCantripNames(engineOld, engineNew)
        .where((name) => !knownNames.contains(name.toLowerCase()))
        .map((name) => KnownSpell(name: name, level: 0))
        .toList();
  }

  void _rebuildPages() {
    final c = widget.character;
    final newLevel = _state.newLevel;
    final className = c.characterClass;
    final effectiveSubclass = _effectiveSubclass;

    final engineOld = _engineFor(c.level, subclass: c.subclass);
    final engineNew = _engineFor(newLevel);

    _subclassFeatures = effectiveSubclass == null
        ? const []
        : _allSubclassFeatures?[className]?[effectiveSubclass] ?? const [];

    final newFeatures = (_classFeatures ?? [])
        .where((f) => f.level == newLevel)
        .toList();
    final newSubclassFeatures = (_subclassFeatures ?? [])
        .where((f) => f.level == newLevel)
        .toList();

    final needsSubclass = isSubclassUnlockLevel(className, newLevel);
    final needsAsi = isAsiLevel(className, newLevel);

    final fixedCantrips = _computeFixedCantripsToLearn(engineOld, engineNew);
    final fixedCantripSlots = _newFixedCantripNames(
      engineOld,
      engineNew,
    ).length;
    final cantripsToLearn = engineNew != null
        ? (engineNew.maxCantrips -
                  (engineOld?.maxCantrips ?? 0) -
                  fixedCantripSlots)
              .clamp(0, 99)
        : 0;

    // Spells to learn for known-caster/pact
    int spellsToLearn = 0;
    if (engineNew != null) {
      final mech = engineNew.mechanism;
      if (mech == SpellcastingMechanism.known ||
          mech == SpellcastingMechanism.pact) {
        final newKnown = engineNew.maxKnown ?? 0;
        final oldKnown = engineOld?.maxKnown ?? 0;
        spellsToLearn = (newKnown - oldKnown).clamp(0, 99);
      }
    }

    final warlockSwap = engineNew?.mechanism == SpellcastingMechanism.pact;
    final featureChoiceRequests = _featureChoiceCatalog == null
        ? <FeatureChoiceRequest>[]
        : FeatureChoiceEngine.requestsForLevelUp(
            catalog: _featureChoiceCatalog!,
            character: c,
            newLevel: newLevel,
            newClassFeatures: newFeatures,
            newSubclassFeatures: newSubclassFeatures,
            subclassName: effectiveSubclass,
            featChosen:
                _state.asiMode == _AsiMode.feat ? _state.featChosen : null,
          );
    _state.featureChoices = _featureChoicesForRequests(featureChoiceRequests);

    _pages = [
      _WizardPage.features,
      if (needsSubclass) _WizardPage.subclass,
      if (needsAsi) _WizardPage.asi,
      if (featureChoiceRequests.isNotEmpty) _WizardPage.featureChoices,
      _WizardPage.hp,
      if (cantripsToLearn > 0) _WizardPage.cantrips,
      if (warlockSwap) _WizardPage.spellSwap,
      if (spellsToLearn > 0) _WizardPage.spells,
      _WizardPage.summary,
    ];

    _fixedCantripsLearned = fixedCantrips;
    _requiredSpellSchools = engineNew?.restrictedKnownSpellSchools ?? const {};
    _requiredSpellSchoolPicks =
        engineNew?.restrictedKnownSpellPicksRequired(spellsToLearn) ?? 0;
    _cantripsToLearn = cantripsToLearn;
    _spellsToLearn = spellsToLearn;
    _newClassFeatures = newFeatures;
    _newSubclassFeatures = newSubclassFeatures;
    _featureChoiceRequests = featureChoiceRequests;
  }

  List<CharacterFeatureChoice> _featureChoicesForRequests(
    List<FeatureChoiceRequest> requests,
  ) {
    return [
      for (final request in requests)
        request.findIn(_state.featureChoices) ??
            request.findIn(widget.character.featureChoices) ??
            request.emptyChoice(),
    ];
  }

  int _cantripsToLearn = 0;
  int _spellsToLearn = 0;
  List<KnownSpell> _fixedCantripsLearned = const [];
  Set<String> _requiredSpellSchools = const {};
  int _requiredSpellSchoolPicks = 0;
  List<SrdClassFeature> _newClassFeatures = [];
  List<SrdClassFeature> _newSubclassFeatures = [];
  List<FeatureChoiceRequest> _featureChoiceRequests = [];

  int get _currentPage =>
      _pageController.hasClients ? _pageController.page?.round() ?? 0 : 0;

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _confirm() async {
    final result = LevelUpResult(
      hpGained: _state.hpGained,
      asiChanges: _state.asiChanges,
      featChosen: _state.featChosen,
      subclassChosen: _state.subclassChosen,
      cantripsLearned: [..._fixedCantripsLearned, ..._state.cantripsLearned],
      spellsLearned: [
        ..._state.spellsLearned,
        if (_state.swapReplacement != null) _state.swapReplacement!,
      ],
      spellSwapped: _state.spellSwapped,
      featureChoices: _state.featureChoices,
    );
    Navigator.pop(context);
    await ref
        .read(characterDetailProvider(widget.characterId).notifier)
        .levelUp(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Title + close + level badge
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Icon(Icons.upgrade),
                  const SizedBox(width: 8),
                  Text(
                    l10n.levelUpTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '→ Lv ${_state.newLevel}',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Step indicators
            ListenableBuilder(
              listenable: _pageController,
              builder: (ctx, _) => Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: _StepIndicator(pages: _pages, currentPage: _currentPage),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pages.length,
                itemBuilder: (ctx, idx) => _buildPage(ctx, _pages[idx]),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    OutlinedButton(
                      onPressed: _prevPage,
                      child: const Icon(Icons.arrow_back),
                    ),
                  const Spacer(),
                  if (_currentPage != _pages.length - 1)
                    FilledButton(
                      onPressed: _canAdvance(_currentPage) ? _nextPage : null,
                      child: const Icon(Icons.arrow_forward),
                    )
                  else
                    FilledButton(
                      onPressed: _state.hpChosen ? _confirm : null,
                      child: Text(l10n.levelUpConfirm),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _spellSchoolRequirementMet(List<KnownSpell> chosen) {
    if (_requiredSpellSchoolPicks <= 0 || _requiredSpellSchools.isEmpty) {
      return true;
    }
    final spellIndex = {
      for (final spell in _allSpells ?? const <SrdSpell>[])
        spell.name.toLowerCase(): spell,
    };
    final matching = chosen.where((known) {
      final spell = spellIndex[known.name.toLowerCase()];
      return spell != null &&
          _requiredSpellSchools.contains(spell.school.toLowerCase());
    }).length;
    return matching >= _requiredSpellSchoolPicks;
  }

  List<SrdSpell> _spellChoices(
    SpellcastingEngine? engine, {
    required bool isCantrip,
  }) {
    if (engine == null) return const [];
    final fixedCantrips = {
      for (final name in engine.fixedCantripNames) name.toLowerCase(),
    };
    return (_allSpells ?? const <SrdSpell>[])
        .where((spell) => spell.classes.contains(engine.spellListClass))
        .where((spell) {
          if (isCantrip) {
            return spell.level == 0 &&
                !fixedCantrips.contains(spell.name.toLowerCase());
          }
          return spell.level > 0 && spell.level <= engine.maxSpellLevel;
        })
        .toList();
  }

  bool _canAdvance(int pageIdx) {
    if (pageIdx >= _pages.length) return false;
    final page = _pages[pageIdx];
    switch (page) {
      case _WizardPage.features:
        return true;
      case _WizardPage.subclass:
        return _state.subclassChosen != null ||
            widget.character.subclass != null;
      case _WizardPage.asi:
        if (_state.asiMode == _AsiMode.feat) {
          return _state.featChosen != null;
        }
        final total = _state.asiChanges.values.fold(0, (a, b) => a + b);
        return total == 2;
      case _WizardPage.featureChoices:
        return FeatureChoiceEngine.allComplete(
          _featureChoiceRequests,
          _state.featureChoices,
        );
      case _WizardPage.hp:
        return _state.hpChosen;
      case _WizardPage.cantrips:
        return _state.cantripsLearned.length == _cantripsToLearn;
      case _WizardPage.spellSwap:
        // Optional step: can skip (None), but if a spell is chosen to forget
        // a replacement must also be selected before advancing.
        return _state.spellSwapped == null || _state.swapReplacement != null;
      case _WizardPage.spells:
        return _state.spellsLearned.length >= _spellsToLearn &&
            _spellSchoolRequirementMet(_state.spellsLearned);
      case _WizardPage.summary:
        return true;
    }
  }

  Widget _buildPage(BuildContext context, _WizardPage page) {
    switch (page) {
      case _WizardPage.features:
        return _FeaturesPage(
          classFeatures: _newClassFeatures,
          subclassFeatures: _newSubclassFeatures,
          subclassName: _effectiveSubclass,
          srdClass: _srdClass,
          i18n:
              ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english,
        );
      case _WizardPage.subclass:
        return _SubclassPage(
          srdClass: _srdClass,
          character: widget.character,
          currentChoice: _state.subclassChosen,
          i18n:
              ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english,
          onChanged: (name) => setState(() {
            _state = _state.copyWith(
              subclassChosen: name,
              cantripsLearned: const [],
              spellsLearned: const [],
              featureChoices: const [],
              spellSwapped: null,
              swapReplacement: null,
            );
            _rebuildPages();
          }),
        );
      case _WizardPage.asi:
        return _AsiPage(
          character: widget.character,
          mode: _state.asiMode,
          asiChanges: _state.asiChanges,
          featChosen: _state.featChosen,
          allFeats: _allFeats ?? [],
          i18n:
              ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english,
          onModeChanged: (m) => setState(() {
            _state = _state.copyWith(
              asiMode: m,
              asiChanges: {},
              featChosen: null,
              featureChoices: const [],
            );
            _rebuildPages();
          }),
          onAsiChanged: (changes) => setState(() {
            _state = _state.copyWith(asiChanges: changes);
            _rebuildPages();
          }),
          onFeatChosen: (feat) => setState(() {
            _state = _state.copyWith(
              featChosen: feat,
              featureChoices: const [],
            );
            _rebuildPages();
          }),
        );
      case _WizardPage.featureChoices:
        final i18n =
            ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
        return FeatureChoiceEditor(
          requests: _featureChoiceRequests,
          initialChoices: _state.featureChoices,
          catalog: _featureChoiceCatalog!,
          character: widget.character,
          i18n: i18n,
          skills: _skills,
          tools: _tools,
          spells: _allSpells ?? const [],
          languages: _languages,
          weapons: _weapons,
          featureLabelBuilder: (request) =>
              _featureChoiceRequestFeatureLabel(request, i18n),
          onChanged: (choices) {
            setState(() => _state = _state.copyWith(featureChoices: choices));
          },
        );
      case _WizardPage.hp:
        return _HpPage(
          character: widget.character,
          hpGained: _state.hpGained,
          hpChosen: _state.hpChosen,
          onHpChosen: (hp) => setState(() {
            _state = _state.copyWith(hpGained: hp, hpChosen: true);
          }),
        );
      case _WizardPage.cantrips:
        final engine = _engineFor(_state.newLevel);
        return _SpellPickPage(
          classSpells: _spellChoices(engine, isCantrip: true),
          alreadyKnown: widget.character.spells
              .where((s) => s.level == 0)
              .map((s) => s.name)
              .toList(),
          toLearn: _cantripsToLearn,
          chosen: _state.cantripsLearned,
          maxLevel: 0,
          onChanged: (list) =>
              setState(() => _state = _state.copyWith(cantripsLearned: list)),
          isCantrip: true,
          requiredSchools: const {},
          requiredSchoolPickCount: 0,
          i18n:
              ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english,
        );
      case _WizardPage.spellSwap:
        final engine = _engineFor(_state.newLevel);
        return _SpellSwapPage(
          classSpells: _spellChoices(engine, isCantrip: false),
          knownSpells: widget.character.spells
              .where((s) => s.level > 0)
              .toList(),
          swapped: _state.spellSwapped,
          replacement: _state.swapReplacement,
          onSwappedChanged: (name) => setState(() {
            _state = _state.copyWith(spellSwapped: name, swapReplacement: null);
          }),
          onReplacementChanged: (spell) =>
              setState(() => _state = _state.copyWith(swapReplacement: spell)),
          i18n:
              ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english,
        );
      case _WizardPage.spells:
        final engine2 = _engineFor(_state.newLevel);
        return _SpellPickPage(
          classSpells: _spellChoices(engine2, isCantrip: false),
          alreadyKnown: widget.character.spells
              .where((s) => s.level > 0)
              .map((s) => s.name)
              .toList(),
          toLearn: _spellsToLearn,
          chosen: _state.spellsLearned,
          maxLevel: engine2?.maxSpellLevel ?? 9,
          onChanged: (list) =>
              setState(() => _state = _state.copyWith(spellsLearned: list)),
          isCantrip: false,
          requiredSchools: _requiredSpellSchools,
          requiredSchoolPickCount: _requiredSpellSchoolPicks,
          i18n:
              ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english,
        );
      case _WizardPage.summary:
        return _SummaryPage(
          wizardState: _state,
          character: widget.character,
          fixedCantripsLearned: _fixedCantripsLearned,
          featureChoiceRequests: _featureChoiceRequests,
          featureChoiceCatalog: _featureChoiceCatalog,
          i18n:
              ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english,
          skills: _skills,
          tools: _tools,
          spells: _allSpells ?? const [],
          languages: _languages,
          weapons: _weapons,
        );
    }
  }
}

// ── Step Pages Enum ───────────────────────────────────────────────────────────

enum _WizardPage {
  features,
  subclass,
  asi,
  featureChoices,
  hp,
  cantrips,
  spellSwap,
  spells,
  summary,
}

// ── Step Indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.pages, required this.currentPage});
  final List<_WizardPage> pages;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      children: List.generate(pages.length, (i) {
        final active = i == currentPage;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 4,
            decoration: BoxDecoration(
              color: active ? color : color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// ── Page: Features ────────────────────────────────────────────────────────────

class _FeaturesPage extends StatelessWidget {
  const _FeaturesPage({
    required this.classFeatures,
    required this.subclassFeatures,
    required this.srdClass,
    required this.i18n,
    this.subclassName,
  });
  final List<SrdClassFeature> classFeatures;
  final List<SrdClassFeature> subclassFeatures;
  final SrdClass? srdClass;
  final SrdI18nService i18n;
  final String? subclassName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sectionStyle = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.primary,
    );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.levelUpStepFeatures, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        if (classFeatures.isEmpty && subclassFeatures.isEmpty)
          Text(l10n.levelUpNoNewFeatures)
        else ...[
          if (classFeatures.isNotEmpty) ...[
            Text(i18n.className(srdClass?.name ?? ''), style: sectionStyle),
            const SizedBox(height: 4),
          ],
          ...classFeatures.map(
            (f) => Card(
              child: ExpansionTile(
                title: Text(
                  i18n.classFeatureName(srdClass?.name ?? '', f.name) ?? f.name,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      i18n.classFeatureDescription(
                            srdClass?.name ?? '',
                            f.name,
                          ) ??
                          f.description,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (subclassFeatures.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              i18n.subclassName(srdClass?.name ?? '', subclassName ?? ''),
              style: sectionStyle,
            ),
            const SizedBox(height: 4),
            ...subclassFeatures.map(
              (f) => Card(
                child: ExpansionTile(
                  title: Text(
                    i18n.subclassFeatureName(
                          srdClass?.name ?? '',
                          subclassName ?? '',
                          f.name,
                        ) ??
                        f.name,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        i18n.subclassFeatureDescription(
                              srdClass?.name ?? '',
                              subclassName ?? '',
                              f.name,
                            ) ??
                            f.description,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

// ── Page: Subclass ────────────────────────────────────────────────────────────

class _SubclassPage extends StatelessWidget {
  const _SubclassPage({
    required this.srdClass,
    required this.character,
    required this.currentChoice,
    required this.i18n,
    required this.onChanged,
  });
  final SrdClass? srdClass;
  final Character character;
  final String? currentChoice;
  final SrdI18nService i18n;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final featureName = srdClass?.subclassFeatureName ?? 'Subclass';
    final subclasses = srdClass?.subclasses ?? [];
    final existing = character.subclass;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.levelUpStepSubclass(featureName),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (existing != null) ...[
          const SizedBox(height: 8),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.levelUpSubclassAlreadyHas(existing)),
            ),
          ),
        ],
        const SizedBox(height: 12),
        RadioGroup<String>(
          groupValue: currentChoice ?? existing ?? '',
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          child: Column(
            children: subclasses.map((sc) {
              final name = i18n.subclassName(srdClass?.name ?? '', sc.name);
              final selected = (currentChoice ?? existing) == sc.name;
              return Card(
                child: RadioListTile<String>(
                  title: Text(name),
                  subtitle: Text(
                    i18n.subclassDescription(srdClass?.name ?? '', sc.name) ??
                        sc.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  value: sc.name,
                  selected: selected,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Page: ASI / Feat ──────────────────────────────────────────────────────────

class _AsiPage extends StatelessWidget {
  const _AsiPage({
    required this.character,
    required this.mode,
    required this.asiChanges,
    required this.featChosen,
    required this.allFeats,
    required this.i18n,
    required this.onModeChanged,
    required this.onAsiChanged,
    required this.onFeatChosen,
  });
  final Character character;
  final _AsiMode mode;
  final Map<String, int> asiChanges;
  final SrdFeat? featChosen;
  final List<SrdFeat> allFeats;
  final SrdI18nService i18n;
  final ValueChanged<_AsiMode> onModeChanged;
  final ValueChanged<Map<String, int>> onAsiChanged;
  final ValueChanged<SrdFeat?> onFeatChosen;

  static const _abilities = [
    'strength',
    'dexterity',
    'constitution',
    'intelligence',
    'wisdom',
    'charisma',
  ];

  static String _abilityLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'strength':
        return l10n.abilityStr;
      case 'dexterity':
        return l10n.abilityDex;
      case 'constitution':
        return l10n.abilityCon;
      case 'intelligence':
        return l10n.abilityInt;
      case 'wisdom':
        return l10n.abilityWis;
      case 'charisma':
        return l10n.abilityCha;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = asiChanges.values.fold(0, (a, b) => a + b);
    final remaining = 2 - total;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.levelUpStepAsi,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        // Mode switch
        SegmentedButton<_AsiMode>(
          segments: [
            ButtonSegment(
              value: _AsiMode.asi,
              label: Text(l10n.levelUpAsiOption),
            ),
            ButtonSegment(
              value: _AsiMode.feat,
              label: Text(l10n.levelUpFeatOption),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (s) => onModeChanged(s.first),
        ),
        const SizedBox(height: 16),

        if (mode == _AsiMode.asi) ...[
          Text(l10n.levelUpAsiPointsLeft(remaining)),
          const SizedBox(height: 8),
          ..._abilities.map((attr) {
            final current = character.abilityScores[attr];
            final bonus = asiChanges[attr] ?? 0;
            final newVal = (current + bonus).clamp(1, 20);
            return ListTile(
              title: Text(_abilityLabel(attr, l10n)),
              subtitle: Text('$current → $newVal'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: bonus > 0
                        ? () {
                            final updated = Map<String, int>.from(asiChanges);
                            updated[attr] = bonus - 1;
                            if (updated[attr] == 0) updated.remove(attr);
                            onAsiChanged(updated);
                          }
                        : null,
                  ),
                  Text('+$bonus', style: const TextStyle(fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: remaining > 0 && newVal < 20 && bonus < 2
                        ? () {
                            final updated = Map<String, int>.from(asiChanges);
                            updated[attr] = bonus + 1;
                            onAsiChanged(updated);
                          }
                        : null,
                  ),
                ],
              ),
            );
          }),
        ] else ...[
          // Feat picker
          RadioGroup<String>(
            groupValue: featChosen?.name,
            onChanged: (v) {
              if (v == null) return;
              onFeatChosen(allFeats.firstWhere((f) => f.name == v));
            },
            child: Column(
              children: allFeats.map((feat) {
                final featName = i18n.featName(feat.name) ?? feat.name;
                final featDesc =
                    i18n.featDescription(feat.name) ?? feat.description;
                return Card(
                  child: ExpansionTile(
                    leading: Radio<String>(value: feat.name),
                    title: Text(featName),
                    subtitle: feat.prerequisite != null
                        ? Text(
                            l10n.featPrerequisite(feat.prerequisite!),
                            style: const TextStyle(fontSize: 12),
                          )
                        : null,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(featDesc),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Page: HP ──────────────────────────────────────────────────────────────────

class _HpPage extends StatelessWidget {
  const _HpPage({
    required this.character,
    required this.hpGained,
    required this.hpChosen,
    required this.onHpChosen,
  });
  final Character character;
  final int hpGained;
  final bool hpChosen;
  final ValueChanged<int> onHpChosen;

  int get _hitDie => levelUpHitDie(character.characterClass);
  int get _conMod => ((character.abilityScores.constitution - 10) / 2).floor();
  String get _conModStr => _conMod >= 0 ? '+$_conMod' : '$_conMod';

  int get _average => ((_hitDie / 2) + 1).ceil() + _conMod;
  int _roll() => math.max(1, math.Random().nextInt(_hitDie) + 1 + _conMod);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.levelUpStepHp,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.levelUpHpFormula(_hitDie, _conModStr),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
        if (hpChosen)
          Center(
            child: Column(
              children: [
                Text(
                  l10n.levelUpHpGained(hpGained),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => onHpChosen(_roll()),
                  child: Text(l10n.levelUpHpReroll),
                ),
              ],
            ),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _HpButton(
                label: l10n.levelUpHpAverage,
                sublabel: '+${_average.clamp(1, 999)} HP',
                onTap: () => onHpChosen(_average.clamp(1, 999)),
              ),
              _HpButton(
                label: l10n.levelUpHpRoll,
                sublabel: 'd$_hitDie + CON',
                onTap: () => onHpChosen(_roll()),
              ),
            ],
          ),
      ],
    );
  }
}

class _HpButton extends StatelessWidget {
  const _HpButton({
    required this.label,
    required this.sublabel,
    required this.onTap,
  });
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Column(
            children: [
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              Text(sublabel, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Page: Spell / Cantrip Pick ────────────────────────────────────────────────

class _SpellPickPage extends StatelessWidget {
  const _SpellPickPage({
    required this.classSpells,
    required this.alreadyKnown,
    required this.toLearn,
    required this.chosen,
    required this.maxLevel,
    required this.onChanged,
    required this.isCantrip,
    required this.requiredSchools,
    required this.requiredSchoolPickCount,
    required this.i18n,
  });
  final List<SrdSpell> classSpells;
  final List<String> alreadyKnown;
  final int toLearn;
  final List<KnownSpell> chosen;
  final int maxLevel;
  final ValueChanged<List<KnownSpell>> onChanged;
  final bool isCantrip;
  final Set<String> requiredSchools;
  final int requiredSchoolPickCount;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chosenNames = {for (final spell in chosen) _spellKey(spell.name)};
    final alreadyKnownNames = {for (final name in alreadyKnown) _spellKey(name)};
    final spellByName = {
      for (final spell in classSpells) _spellKey(spell.name): spell,
    };
    final restrictedQuota = isCantrip
        ? 0
        : math.min(requiredSchoolPickCount, toLearn);
    final freeQuota = math.max(0, toLearn - restrictedQuota);

    var requiredSlotsLeft = restrictedQuota;
    final requiredSelected = <String>{};
    final freeSelected = <String>{};
    for (final spell in chosen) {
      final key = _spellKey(spell.name);
      final srdSpell = spellByName[key];
      final matchesRequired = srdSpell != null && _isRestricted(srdSpell);
      if (requiredSlotsLeft > 0 && matchesRequired) {
        requiredSelected.add(key);
        requiredSlotsLeft--;
      } else {
        freeSelected.add(key);
      }
    }

    final hasRestrictedSection = restrictedQuota > 0;
    final hasFreeSection = freeQuota > 0;
    final isMixedChoice = hasRestrictedSection && hasFreeSection;
    final restrictedComplete = requiredSelected.length >= restrictedQuota;
    final schoolList = requiredSchools
        .map(i18n.spellSchool)
        .toList()
      ..sort((a, b) => a.compareTo(b));
    final schoolText = schoolList.join(' / ');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          isCantrip
              ? l10n.levelUpCantripsToLearn(toLearn)
              : l10n.levelUpSpellsToLearn(toLearn),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (chosen.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final spell in chosen)
                Chip(label: Text(i18n.spellName(spell.name))),
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (hasRestrictedSection)
          _SpellChoiceSection(
            key: ValueKey('spell_required_$restrictedComplete'),
            title: l10n.levelUpSpellRestrictedSection,
            description: l10n.levelUpSpellRestrictedInstruction(
              restrictedQuota,
              schoolText,
            ),
            selectedCount: requiredSelected.length,
            requiredCount: restrictedQuota,
            initiallyExpanded: !restrictedComplete || !hasFreeSection,
            spells: classSpells.where(_isRestricted).toList(),
            selectedNames: requiredSelected,
            hiddenNames: const <String>{},
            chosenNames: chosenNames,
            alreadyKnownNames: alreadyKnownNames,
            sectionFull: requiredSelected.length >= restrictedQuota,
            globalFull: chosen.length >= toLearn,
            l10n: l10n,
            i18n: i18n,
            isCantrip: isCantrip,
            onChanged: onChanged,
            chosen: chosen,
          ),
        if (hasFreeSection)
          _SpellChoiceSection(
            key: ValueKey('spell_free_${isMixedChoice && !restrictedComplete}'),
            title: l10n.levelUpSpellFreeSection,
            description: l10n.levelUpSpellFreeInstruction(freeQuota),
            selectedCount: freeSelected.length,
            requiredCount: freeQuota,
            initiallyExpanded:
                !isMixedChoice || restrictedComplete || freeSelected.isNotEmpty,
            locked: isMixedChoice && !restrictedComplete,
            lockedMessage: l10n.levelUpSpellFreeLocked,
            spells: classSpells,
            selectedNames: freeSelected,
            hiddenNames: requiredSelected,
            chosenNames: chosenNames,
            alreadyKnownNames: alreadyKnownNames,
            sectionFull: freeSelected.length >= freeQuota,
            globalFull: chosen.length >= toLearn,
            l10n: l10n,
            i18n: i18n,
            isCantrip: isCantrip,
            onChanged: onChanged,
            chosen: chosen,
          ),
      ],
    );
  }

  bool _isRestricted(SrdSpell spell) =>
      requiredSchools.contains(spell.school.toLowerCase());

  static String _spellKey(String name) => name.toLowerCase();
}

// ── Spell Choice Section ──────────────────────────────────────────────────────

class _SpellChoiceSection extends StatelessWidget {
  const _SpellChoiceSection({
    super.key,
    required this.title,
    required this.description,
    required this.selectedCount,
    required this.requiredCount,
    required this.initiallyExpanded,
    required this.spells,
    required this.selectedNames,
    required this.hiddenNames,
    required this.chosenNames,
    required this.alreadyKnownNames,
    required this.sectionFull,
    required this.globalFull,
    required this.l10n,
    required this.i18n,
    required this.isCantrip,
    required this.onChanged,
    required this.chosen,
    this.locked = false,
    this.lockedMessage,
  });

  final String title;
  final String description;
  final int selectedCount;
  final int requiredCount;
  final bool initiallyExpanded;
  final List<SrdSpell> spells;
  final Set<String> selectedNames;
  final Set<String> hiddenNames;
  final Set<String> chosenNames;
  final Set<String> alreadyKnownNames;
  final bool sectionFull;
  final bool globalFull;
  final AppLocalizations l10n;
  final SrdI18nService i18n;
  final bool isCantrip;
  final ValueChanged<List<KnownSpell>> onChanged;
  final List<KnownSpell> chosen;
  final bool locked;
  final String? lockedMessage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visibleSpells = spells
        .where((spell) => !hiddenNames.contains(_spellKey(spell.name)))
        .toList();
    final selectedVisibleSpells = visibleSpells
        .where((spell) => selectedNames.contains(_spellKey(spell.name)))
        .toList();

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 2),
            Text(
              l10n.featureChoicesSelectedCount(selectedCount, requiredCount),
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        children: [
          if (locked)
            ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    lockedMessage ?? '',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
              ),
              ...selectedVisibleSpells.map(
                (spell) => _buildSpellTile(context, spell),
              ),
            ]
          else
            ...visibleSpells.map((spell) => _buildSpellTile(context, spell)),
        ],
      ),
    );
  }

  Widget _buildSpellTile(BuildContext context, SrdSpell spell) {
    final key = _spellKey(spell.name);
    final knownAlready = alreadyKnownNames.contains(key);
    final isSelected = selectedNames.contains(key);
    final isChosenElsewhere = chosenNames.contains(key) && !isSelected;
    final canAdd =
        !knownAlready && !isChosenElsewhere && !sectionFull && !globalFull;
    final canToggle = isSelected || canAdd;
    final translatedName = i18n.spellName(spell.name);
    final translatedSchool = i18n.spellSchool(spell.school);

    return CheckboxListTile(
      title: Text(translatedName),
      subtitle: Text(
        isCantrip
            ? l10n.levelUpSpellCantripSubtitle(translatedSchool)
            : l10n.levelUpSpellSubtitle(spell.level, translatedSchool),
        style: const TextStyle(fontSize: 12),
      ),
      value: isSelected,
      onChanged: knownAlready || isChosenElsewhere || !canToggle
          ? null
          : (v) {
              final updated = List<KnownSpell>.from(chosen);
              if (v == true && canAdd) {
                updated.add(KnownSpell(name: spell.name, level: spell.level));
              } else if (v == false) {
                updated.removeWhere(
                  (known) => _spellKey(known.name) == key,
                );
              }
              onChanged(updated);
            },
      secondary: knownAlready
          ? Tooltip(
              message: l10n.levelUpSpellAlreadyKnown,
              child: IconButton(
                icon: Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: null,
              ),
            )
          : IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => SpellDetailSheet(
                  spell: spell,
                  isKnown: false,
                  readOnly: true,
                ),
              ),
            ),
    );
  }

  static String _spellKey(String name) => name.toLowerCase();
}

// ── Page: Spell Swap (Warlock) ────────────────────────────────────────────────

class _SpellSwapPage extends StatelessWidget {
  const _SpellSwapPage({
    required this.classSpells,
    required this.knownSpells,
    required this.swapped,
    required this.replacement,
    required this.onSwappedChanged,
    required this.onReplacementChanged,
    required this.i18n,
  });

  final List<SrdSpell> classSpells;
  final List<KnownSpell> knownSpells;
  final String? swapped;
  final KnownSpell? replacement;
  final ValueChanged<String?> onSwappedChanged;
  final ValueChanged<KnownSpell?> onReplacementChanged;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final alreadyKnownNames = knownSpells.map((s) => s.name).toSet();
    final available = classSpells
        .where((s) => !alreadyKnownNames.contains(s.name))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.levelUpSpellSwap,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        // ── Which spell to forget? ──────────────────────────────────────
        RadioGroup<String?>(
          groupValue: swapped,
          onChanged: (v) {
            onSwappedChanged(v);
            onReplacementChanged(null);
          },
          child: Column(
            children: [
              ...knownSpells.map(
                (ks) => RadioListTile<String?>(
                  title: Text(i18n.spellName(ks.name)),
                  value: ks.name,
                ),
              ),
              RadioListTile<String?>(
                title: Text(l10n.levelUpSpellSwapNone),
                value: null,
              ),
            ],
          ),
        ),

        // ── Replace it with? (only when a spell is selected to forget) ──
        if (swapped != null) ...[
          const Divider(height: 32),
          Text(
            l10n.levelUpSpellSwapReplaceWith,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          RadioGroup<String>(
            groupValue: replacement?.name ?? '',
            onChanged: (v) {
              if (v == null) return;
              final spell = available.firstWhere((s) => s.name == v);
              onReplacementChanged(
                KnownSpell(name: spell.name, level: spell.level),
              );
            },
            child: Column(
              children: available
                  .map(
                    (spell) => RadioListTile<String>(
                      title: Text(i18n.spellName(spell.name)),
                      subtitle: Text(
                        l10n.levelUpSpellSubtitle(
                          spell.level,
                          i18n.spellSchool(spell.school),
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: spell.name,
                      secondary: IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => SpellDetailSheet(
                            spell: spell,
                            isKnown: false,
                            readOnly: true,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Page: Summary ─────────────────────────────────────────────────────────────

class _SummaryPage extends StatelessWidget {
  const _SummaryPage({
    required this.wizardState,
    required this.character,
    required this.fixedCantripsLearned,
    required this.featureChoiceRequests,
    required this.featureChoiceCatalog,
    required this.i18n,
    required this.skills,
    required this.tools,
    required this.spells,
    required this.languages,
    required this.weapons,
  });
  final _LevelUpState wizardState;
  final Character character;
  final List<KnownSpell> fixedCantripsLearned;
  final List<FeatureChoiceRequest> featureChoiceRequests;
  final SrdFeatureChoiceCatalog? featureChoiceCatalog;
  final SrdI18nService i18n;
  final List<SrdSkill> skills;
  final List<SrdTool> tools;
  final List<SrdSpell> spells;
  final List<SrdLanguage> languages;
  final List<SrdWeapon> weapons;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final rows = <Widget>[];

    rows.add(
      _SummaryRow(
        icon: Icons.trending_up,
        text: l10n.levelUpSummaryLevel(wizardState.newLevel),
        color: cs.primary,
      ),
    );
    rows.add(
      _SummaryRow(
        icon: Icons.favorite,
        text: l10n.levelUpSummaryHp(wizardState.hpGained),
      ),
    );
    if (wizardState.subclassChosen != null) {
      rows.add(
        _SummaryRow(
          icon: Icons.star,
          text: l10n.levelUpSummarySubclass(wizardState.subclassChosen!),
        ),
      );
    }
    if (wizardState.featChosen != null) {
      rows.add(
        _SummaryRow(
          icon: Icons.emoji_events,
          text: l10n.levelUpSummaryFeat(wizardState.featChosen!.name),
        ),
      );
    } else if (wizardState.asiChanges.isNotEmpty) {
      String abilityLabel(String key) {
        switch (key) {
          case 'strength':
            return l10n.abilityStr;
          case 'dexterity':
            return l10n.abilityDex;
          case 'constitution':
            return l10n.abilityCon;
          case 'intelligence':
            return l10n.abilityInt;
          case 'wisdom':
            return l10n.abilityWis;
          case 'charisma':
            return l10n.abilityCha;
          default:
            return key;
        }
      }

      final parts = wizardState.asiChanges.entries
          .map((e) => '${abilityLabel(e.key)} +${e.value}')
          .join(', ');
      rows.add(
        _SummaryRow(icon: Icons.bar_chart, text: l10n.levelUpSummaryAsi(parts)),
      );
    }
    final cantripsLearned =
        fixedCantripsLearned.length + wizardState.cantripsLearned.length;
    if (cantripsLearned > 0) {
      rows.add(
        _SummaryRow(
          icon: Icons.auto_fix_high,
          text: l10n.levelUpSummaryCantripsLearned(cantripsLearned),
        ),
      );
    }
    if (wizardState.spellsLearned.isNotEmpty) {
      rows.add(
        _SummaryRow(
          icon: Icons.menu_book,
          text: l10n.levelUpSummarySpellsLearned(
            wizardState.spellsLearned.length,
          ),
        ),
      );
    }
    if (wizardState.featureChoices.isNotEmpty &&
        featureChoiceCatalog != null) {
      for (final choice in wizardState.featureChoices) {
        if (choice.values.isEmpty) continue;
        final request = featureChoiceRequests.firstWhereOrNull(
          (request) => request.findIn([choice]) != null,
        );
        final labels = choice.values
            .map((value) {
              if (request == null) return value;
              return featureChoiceValueLabelForRequest(
                value: value,
                request: request,
                catalog: featureChoiceCatalog!,
                i18n: i18n,
                skills: skills,
                tools: tools,
                spells: spells,
                languages: languages,
                weapons: weapons,
                character: character,
                relatedRequests: featureChoiceRequests,
                choices: wizardState.featureChoices,
              );
            })
            .join(', ');
        rows.add(
          _SummaryRow(
            icon: Icons.checklist,
            text: request == null
                ? '${choice.featureName}: $labels'
                : '${choice.featureName} - ${request.choiceId}: $labels',
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.levelUpStepSummary,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        ...rows,
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.icon, required this.text, this.color});
  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color ?? cs.onSurface),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
