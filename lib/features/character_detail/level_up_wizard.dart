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
  String? spellSwapped;

  _LevelUpState copyWith({
    int? hpGained,
    bool? hpChosen,
    _AsiMode? asiMode,
    Map<String, int>? asiChanges,
    Object? featChosen = _sentinel,
    Object? subclassChosen = _sentinel,
    List<KnownSpell>? cantripsLearned,
    List<KnownSpell>? spellsLearned,
    Object? spellSwapped = _sentinel,
  }) {
    final s = _LevelUpState(
      newLevel: newLevel,
      hpGained: hpGained ?? this.hpGained,
      hpChosen: hpChosen ?? this.hpChosen,
      asiMode: asiMode ?? this.asiMode,
      asiChanges: asiChanges ?? this.asiChanges,
      cantripsLearned: cantripsLearned ?? this.cantripsLearned,
      spellsLearned: spellsLearned ?? this.spellsLearned,
    );
    s.featChosen = featChosen == _sentinel ? this.featChosen : featChosen as SrdFeat?;
    s.subclassChosen = subclassChosen == _sentinel ? this.subclassChosen : subclassChosen as String?;
    s.spellSwapped = spellSwapped == _sentinel ? this.spellSwapped : spellSwapped as String?;
    return s;
  }

  static const _sentinel = Object();
}

// ── Wizard Entry Point ────────────────────────────────────────────────────────

void _openLevelUpWizardSheet(BuildContext context, Character character, String characterId) {
  final newLevel = character.level + 1;
  if (newLevel > 20) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.levelUpMaxLevel)),
    );
    return;
  }
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      pageBuilder: (context, _, _) => _LevelUpWizard(
        character: character,
        characterId: characterId,
      ),
      transitionsBuilder: (_, animation, _, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
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
  List<SrdSpell>? _classSpells;
  List<SrdFeat>? _allFeats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _state = _LevelUpState(newLevel: widget.character.level + 1);
    _pageController = PageController();
    _load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final srd = ref.read(srdDataSourceProvider);
    final className = widget.character.characterClass;
    final results = await Future.wait([
      srd.getClasses(),
      srd.getClassFeatures(className),
      srd.getFeats(),
      srd.getSpellsForClass(className),
    ]);
    if (!mounted) return;
    final classes = results[0] as List<SrdClass>;
    _srdClass = classes.cast<SrdClass?>().firstWhere(
      (c) => c?.name.toLowerCase() == className.toLowerCase(),
      orElse: () => null,
    );
    _classFeatures = results[1] as List<SrdClassFeature>;

    // Load subclass features if character has a subclass
    if (widget.character.subclass != null) {
      _subclassFeatures = await srd.getSubclassFeatures(
        className,
        widget.character.subclass!,
      );
    }

    _allFeats = results[2] as List<SrdFeat>;
    _classSpells = results[3] as List<SrdSpell>;

    if (mounted) {
      setState(() {
        _loading = false;
        _buildPages();
      });
    }
  }

  SpellcastingEngine? _engineFor(int level) {
    return SpellcastingEngine.forClass(
      className: widget.character.characterClass,
      classLevel: level,
      abilityScores: widget.character.abilityScores,
      proficiencyBonus: widget.character.proficiencyBonus,
      subclass: widget.character.subclass,
    );
  }

  void _buildPages() {
    final c = widget.character;
    final newLevel = _state.newLevel;
    final className = c.characterClass;

    final engineOld = _engineFor(c.level);
    final engineNew = _engineFor(newLevel);

    final newFeatures = (_classFeatures ?? [])
        .where((f) => f.level == newLevel)
        .toList();
    final newSubclassFeatures = (_subclassFeatures ?? [])
        .where((f) => f.level == newLevel)
        .toList();

    final needsSubclass = isSubclassUnlockLevel(className, newLevel);
    final needsAsi = isAsiLevel(className, newLevel);

    final cantripsToLearn = engineNew != null && engineOld != null
        ? (engineNew.maxCantrips - engineOld.maxCantrips).clamp(0, 99)
        : 0;

    // Spells to learn for known-caster/pact
    int spellsToLearn = 0;
    if (engineNew != null && engineOld != null) {
      final mech = engineNew.mechanism;
      if (mech == SpellcastingMechanism.known ||
          mech == SpellcastingMechanism.pact) {
        final newKnown = engineNew.maxKnown ?? 0;
        final oldKnown = engineOld.maxKnown ?? 0;
        spellsToLearn = (newKnown - oldKnown).clamp(0, 99);
      }
    }

    final warlockSwap = engineNew?.mechanism == SpellcastingMechanism.pact;

    _pages = [
      _WizardPage.features,
      if (needsSubclass) _WizardPage.subclass,
      if (needsAsi) _WizardPage.asi,
      _WizardPage.hp,
      if (cantripsToLearn > 0) _WizardPage.cantrips,
      if (spellsToLearn > 0 || warlockSwap) _WizardPage.spells,
      _WizardPage.summary,
    ];

    setState(() {
      _cantripsToLearn = cantripsToLearn;
      _spellsToLearn = spellsToLearn;
      _warlockSwap = warlockSwap;
      _newFeatures = [...newFeatures, ...newSubclassFeatures];
    });
  }

  int _cantripsToLearn = 0;
  int _spellsToLearn = 0;
  bool _warlockSwap = false;
  List<SrdClassFeature> _newFeatures = [];

  int get _currentPage => _pageController.hasClients
      ? _pageController.page?.round() ?? 0
      : 0;

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
      cantripsLearned: _state.cantripsLearned,
      spellsLearned: _state.spellsLearned,
      spellSwapped: _state.spellSwapped,
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
                  Chip(
                    label: Text(
                      '→ Lv ${_state.newLevel}',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: colorScheme.primary,
                  ),
                ],
              ),
            ),

            // Step indicators
            ListenableBuilder(
              listenable: _pageController,
              builder: (ctx, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: _StepIndicator(
                  pages: _pages,
                  currentPage: _currentPage,
                ),
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
              child: StatefulBuilder(
                builder: (ctx, setSt) {
                  _pageController.addListener(() => setSt(() {}));
                  final pageIdx = _pageController.hasClients
                      ? (_pageController.page?.round() ?? 0)
                      : 0;
                  final isLast = pageIdx == _pages.length - 1;
                  final isFirst = pageIdx == 0;
                  return Row(
                    children: [
                      if (!isFirst)
                        OutlinedButton(
                          onPressed: _prevPage,
                          child: const Icon(Icons.arrow_back),
                        ),
                      const Spacer(),
                      if (!isLast)
                        FilledButton(
                          onPressed: _canAdvance(pageIdx) ? _nextPage : null,
                          child: const Icon(Icons.arrow_forward),
                        )
                      else
                        FilledButton(
                          onPressed: _state.hpChosen ? _confirm : null,
                          child: Text(l10n.levelUpConfirm),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
      case _WizardPage.hp:
        return _state.hpChosen;
      case _WizardPage.cantrips:
        return _state.cantripsLearned.length == _cantripsToLearn;
      case _WizardPage.spells:
        return _state.spellsLearned.length >= _spellsToLearn;
      case _WizardPage.summary:
        return true;
    }
  }

  Widget _buildPage(BuildContext context, _WizardPage page) {
    switch (page) {
      case _WizardPage.features:
        return _FeaturesPage(
          features: _newFeatures,
          srdClass: _srdClass,
          i18n: ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english,
        );
      case _WizardPage.subclass:
        return _SubclassPage(
          srdClass: _srdClass,
          character: widget.character,
          currentChoice: _state.subclassChosen,
          i18n: ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english,
          onChanged: (name) => setState(() {
            _state = _state.copyWith(subclassChosen: name);
          }),
        );
      case _WizardPage.asi:
        return _AsiPage(
          character: widget.character,
          mode: _state.asiMode,
          asiChanges: _state.asiChanges,
          featChosen: _state.featChosen,
          allFeats: _allFeats ?? [],
          i18n: ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english,
          onModeChanged: (m) => setState(() {
            _state = _state.copyWith(
              asiMode: m,
              asiChanges: {},
              featChosen: null,
            );
          }),
          onAsiChanged: (changes) =>
              setState(() => _state = _state.copyWith(asiChanges: changes)),
          onFeatChosen: (feat) =>
              setState(() => _state = _state.copyWith(featChosen: feat)),
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
        return _SpellPickPage(
          classSpells: (_classSpells ?? []).where((s) => s.level == 0).toList(),
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
          i18n: ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english,
        );
      case _WizardPage.spells:
        final engine = _engineFor(_state.newLevel);
        return _SpellPickPage(
          classSpells: (_classSpells ?? [])
              .where((s) => s.level > 0 && s.level <= (engine?.maxSpellLevel ?? 9))
              .toList(),
          alreadyKnown: widget.character.spells
              .where((s) => s.level > 0)
              .map((s) => s.name)
              .toList(),
          toLearn: _spellsToLearn,
          chosen: _state.spellsLearned,
          maxLevel: engine?.maxSpellLevel ?? 9,
          onChanged: (list) =>
              setState(() => _state = _state.copyWith(spellsLearned: list)),
          isCantrip: false,
          allowSwap: _warlockSwap,
          knownSpells: widget.character.spells
              .where((s) => s.level > 0)
              .toList(),
          swapped: _state.spellSwapped,
          onSwapChanged: (name) =>
              setState(() => _state = _state.copyWith(spellSwapped: name)),
          i18n: ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english,
        );
      case _WizardPage.summary:
        return _SummaryPage(
          wizardState: _state,
          character: widget.character,
        );
    }
  }
}

// ── Step Pages Enum ───────────────────────────────────────────────────────────

enum _WizardPage { features, subclass, asi, hp, cantrips, spells, summary }

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
              color: active
                  ? color
                  : color.withValues(alpha: 0.25),
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
    required this.features,
    required this.srdClass,
    required this.i18n,
  });
  final List<SrdClassFeature> features;
  final SrdClass? srdClass;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.levelUpStepFeatures,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (features.isEmpty)
          Text(l10n.levelUpNoNewFeatures)
        else
          ...features.map(
            (f) => Card(
              child: ExpansionTile(
                title: Text(i18n.classFeatureName(srdClass?.name ?? '', f.name) ?? f.name),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      i18n.classFeatureDescription(srdClass?.name ?? '', f.name) ?? f.description,
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
    final featureName =
        srdClass?.subclassFeatureName ?? 'Subclass';
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
          onChanged: (v) { if (v != null) onChanged(v); },
          child: Column(
            children: subclasses.map((sc) {
              final name = i18n.subclassName(srdClass?.name ?? '', sc.name);
              final selected = (currentChoice ?? existing) == sc.name;
              return Card(
                child: RadioListTile<String>(
                  title: Text(name),
                  subtitle: Text(
                    i18n.subclassDescription(srdClass?.name ?? '', sc.name) ?? sc.description,
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
      case 'strength': return l10n.abilityStr;
      case 'dexterity': return l10n.abilityDex;
      case 'constitution': return l10n.abilityCon;
      case 'intelligence': return l10n.abilityInt;
      case 'wisdom': return l10n.abilityWis;
      case 'charisma': return l10n.abilityCha;
      default: return key;
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
                final featDesc = i18n.featDescription(feat.name) ?? feat.description;
                return Card(
                  child: ExpansionTile(
                    leading: Radio<String>(
                      value: feat.name,
                    ),
                    title: Text(featName),
                    subtitle: feat.prerequisite != null
                        ? Text(l10n.featPrerequisite(feat.prerequisite!),
                            style: const TextStyle(fontSize: 12))
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
  int get _conMod =>
      ((character.abilityScores.constitution - 10) / 2).floor();
  String get _conModStr => _conMod >= 0 ? '+$_conMod' : '$_conMod';

  int get _average => ((_hitDie / 2) + 1).ceil() + _conMod;
  int _roll() =>
      math.max(1, math.Random().nextInt(_hitDie) + 1 + _conMod);

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
    required this.i18n,
    this.allowSwap = false,
    this.knownSpells = const [],
    this.swapped,
    this.onSwapChanged,
  });
  final List<SrdSpell> classSpells;
  final List<String> alreadyKnown;
  final int toLearn;
  final List<KnownSpell> chosen;
  final int maxLevel;
  final ValueChanged<List<KnownSpell>> onChanged;
  final bool isCantrip;
  final SrdI18nService i18n;
  final bool allowSwap;
  final List<KnownSpell> knownSpells;
  final String? swapped;
  final ValueChanged<String?>? onSwapChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chosenNames = chosen.map((s) => s.name).toSet();

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

        // Spell swap for Warlock
        if (allowSwap && !isCantrip) ...[
          const Divider(),
          ListTile(
            title: Text(l10n.levelUpSpellSwap),
            trailing: const Icon(Icons.swap_horiz),
          ),
          RadioGroup<String?>(
            groupValue: swapped,
            onChanged: (v) => onSwapChanged?.call(v),
            child: Column(
              children: [
                ...knownSpells.map((ks) => RadioListTile<String?>(
                  title: Text(ks.name),
                  value: ks.name,
                )),
                RadioListTile<String?>(
                  title: Text(l10n.levelUpSpellSwapNone),
                  value: null,
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
        ],

        ...classSpells.map((spell) {
          final knownAlready = alreadyKnown.contains(spell.name);
          final isChosen = chosenNames.contains(spell.name);
          final canAdd = !knownAlready && !isChosen && chosen.length < toLearn;
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
            value: isChosen,
            onChanged: knownAlready
                ? null
                : (v) {
                    final updated = List<KnownSpell>.from(chosen);
                    if (v == true && canAdd) {
                      updated.add(KnownSpell(name: spell.name, level: spell.level));
                    } else if (v == false) {
                      updated.removeWhere((s) => s.name == spell.name);
                    }
                    onChanged(updated);
                  },
            secondary: knownAlready
                ? Tooltip(
                    message: l10n.levelUpSpellAlreadyKnown,
                    child: Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.secondary,
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
        }),
      ],
    );
  }
}

// ── Page: Summary ─────────────────────────────────────────────────────────────

class _SummaryPage extends StatelessWidget {
  const _SummaryPage({
    required this.wizardState,
    required this.character,
  });
  final _LevelUpState wizardState;
  final Character character;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final rows = <Widget>[];

    rows.add(_SummaryRow(
      icon: Icons.trending_up,
      text: l10n.levelUpSummaryLevel(wizardState.newLevel),
      color: cs.primary,
    ));
    rows.add(_SummaryRow(
      icon: Icons.favorite,
      text: l10n.levelUpSummaryHp(wizardState.hpGained),
    ));
    if (wizardState.subclassChosen != null) {
      rows.add(_SummaryRow(
        icon: Icons.star,
        text: l10n.levelUpSummarySubclass(wizardState.subclassChosen!),
      ));
    }
    if (wizardState.featChosen != null) {
      rows.add(_SummaryRow(
        icon: Icons.emoji_events,
        text: l10n.levelUpSummaryFeat(wizardState.featChosen!.name),
      ));
    } else if (wizardState.asiChanges.isNotEmpty) {
      String abilityLabel(String key) {
        switch (key) {
          case 'strength': return l10n.abilityStr;
          case 'dexterity': return l10n.abilityDex;
          case 'constitution': return l10n.abilityCon;
          case 'intelligence': return l10n.abilityInt;
          case 'wisdom': return l10n.abilityWis;
          case 'charisma': return l10n.abilityCha;
          default: return key;
        }
      }
      final parts = wizardState.asiChanges.entries
          .map((e) => '${abilityLabel(e.key)} +${e.value}')
          .join(', ');
      rows.add(_SummaryRow(
        icon: Icons.bar_chart,
        text: l10n.levelUpSummaryAsi(parts),
      ));
    }
    if (wizardState.cantripsLearned.isNotEmpty) {
      rows.add(_SummaryRow(
        icon: Icons.auto_fix_high,
        text: l10n.levelUpSummaryCantripsLearned(
            wizardState.cantripsLearned.length),
      ));
    }
    if (wizardState.spellsLearned.isNotEmpty) {
      rows.add(_SummaryRow(
        icon: Icons.menu_book,
        text: l10n.levelUpSummarySpellsLearned(
            wizardState.spellsLearned.length),
      ));
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
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
