import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dnd_character_tool/l10n/app_localizations.dart';

import '../../data/constants/level_up_rules.dart';
import '../../data/character_progression/character_progression.dart';
import '../../data/datasources/srd/srd_i18n_service.dart';
import '../../data/datasources/srd/srd_models.dart';
import '../../data/feature_choice_engine.dart';
import '../../data/feature_choice_option_resolver.dart';
import '../../data/models/models.dart';
import '../../data/spellcasting_engine.dart';
import '../../shared/providers/providers.dart';
import 'application/level_up/level_up_wizard_state.dart';
import 'character_detail_provider.dart';
import 'spell_browser_sheet.dart';
import 'widgets/feature_choice_editor.dart';

// Level Up Wizard

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
    FeatureChoiceSourceType.raceTrait => i18n.raceTraitName(
      request.sourceName ?? request.featureName,
    ),
    FeatureChoiceSourceType.feat =>
      i18n.featName(request.sourceName ?? request.featureName) ??
          request.featureName,
    _ => request.featureName,
  };
}

void openLevelUpWizardSheet(
  BuildContext context,
  Character character,
  String characterId,
) {
  final newLevel = character.totalLevel + 1;
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

class _LevelUpWizard extends ConsumerStatefulWidget {
  const _LevelUpWizard({required this.character, required this.characterId});

  final Character character;
  final String characterId;

  @override
  ConsumerState<_LevelUpWizard> createState() => _LevelUpWizardState();
}

class _LevelUpWizardState extends ConsumerState<_LevelUpWizard> {
  late LevelUpWizardState _state;
  late PageController _pageController;
  late List<LevelUpWizardPage> _pages;

  SrdClass? _srdClass;
  List<SrdClass> _classes = const [];
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

  int _cantripsToLearn = 0;
  int _spellsToLearn = 0;
  List<KnownSpell> _fixedCantripsLearned = const [];
  Set<String> _requiredSpellSchools = const {};
  int _requiredSpellSchoolPicks = 0;
  List<SrdClassFeature> _newClassFeatures = [];
  List<SrdClassFeature> _newSubclassFeatures = [];
  List<FeatureChoiceRequest> _featureChoiceRequests = [];

  @override
  void initState() {
    super.initState();
    final primaryClass = widget.character.primaryClass;
    _state = LevelUpWizardState(
      newLevel: widget.character.totalLevel + 1,
      targetClassEntryId: primaryClass.id,
      targetClassName: primaryClass.className,
    );
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

  String get _targetClassName =>
      _state.targetClassName ?? widget.character.primaryClass.className;

  String get _targetClassEntryId =>
      _state.targetClassEntryId ?? widget.character.primaryClass.id;

  CharacterClassEntry get _targetClassEntry {
    final existing = widget.character.classEntries.firstWhereOrNull(
      (entry) => entry.id == _targetClassEntryId,
    );
    if (existing != null) return existing;
    return CharacterClassEntry(
      id: _targetClassEntryId,
      className: _targetClassName,
      level: 0,
    );
  }

  bool get _isAddingClass => _targetClassEntry.level == 0;

  int get _newClassLevel => _targetClassEntry.level + 1;

  int get _currentPage =>
      _pageController.hasClients ? _pageController.page?.round() ?? 0 : 0;

  String? get _effectiveSubclass =>
      _state.subclassChosen ?? _targetClassEntry.subclassName;

  void _handlePageChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    final srd = ref.read(srdDataSourceProvider);
    final className = _targetClassName;
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
    _classes = results[0] as List<SrdClass>;
    _srdClass = _findSrdClass(className);
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

    setState(() {
      _loading = false;
      _rebuildPages();
    });
  }

  SrdClass? _findSrdClass(String className) {
    return _classes.cast<SrdClass?>().firstWhere(
      (c) => c?.name.toLowerCase() == className.toLowerCase(),
      orElse: () => null,
    );
  }

  Future<void> _selectTargetClass({
    required String entryId,
    required String className,
  }) async {
    setState(() {
      _loading = true;
      _state = _state.copyWith(
        targetClassEntryId: entryId,
        targetClassName: className,
        hpGained: 0,
        hpChosen: false,
        asiMode: LevelUpAsiMode.asi,
        asiChanges: const {},
        featChosen: null,
        subclassChosen: null,
        cantripsLearned: const [],
        spellsLearned: const [],
        featureChoices: const [],
        spellSwapped: null,
        swapReplacement: null,
      );
    });
    final features = await ref
        .read(srdDataSourceProvider)
        .getClassFeatures(className);
    if (!mounted) return;
    setState(() {
      _srdClass = _findSrdClass(className);
      _classFeatures = features;
      _loading = false;
      _rebuildPages();
    });
  }

  String _newClassEntryId(String className) {
    final ids = {for (final entry in widget.character.classEntries) entry.id};
    var base = className
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    if (base.isEmpty) base = 'class';
    var candidate = base;
    var suffix = 2;
    while (ids.contains(candidate)) {
      candidate = '${base}_$suffix';
      suffix++;
    }
    return candidate;
  }

  SpellcastingEngine? _engineFor(int level, {String? subclass}) {
    return SpellcastingEngine.forClass(
      className: _targetClassName,
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

  List<KnownSpell> _knownSpellsForTarget({required bool includeCantrips}) {
    return widget.character.spells.where((spell) {
      if (!includeCantrips && spell.level == 0) return false;
      if (spell.sourceClassEntryId == _targetClassEntryId) return true;
      return spell.sourceClassEntryId == null &&
          spell.sourceClass?.toLowerCase() == _targetClassName.toLowerCase();
    }).toList();
  }

  void _rebuildPages() {
    final character = widget.character;
    final newClassLevel = _newClassLevel;
    final className = _targetClassName;
    final effectiveSubclass = _effectiveSubclass;

    final engineOld = _isAddingClass
        ? null
        : _engineFor(
            _targetClassEntry.level,
            subclass: _targetClassEntry.subclassName,
          );
    final engineNew = _engineFor(newClassLevel);

    _subclassFeatures = effectiveSubclass == null
        ? const []
        : _allSubclassFeatures?[className]?[effectiveSubclass] ?? const [];

    final newFeatures = (_classFeatures ?? [])
        .where((feature) => feature.level == newClassLevel)
        .toList();
    final newSubclassFeatures = (_subclassFeatures ?? [])
        .where((feature) => feature.level == newClassLevel)
        .toList();

    final needsSubclass =
        _targetClassEntry.subclassName == null &&
        isSubclassUnlockLevel(className, newClassLevel);
    final needsAsi = isAsiLevel(className, newClassLevel);

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

    var spellsToLearn = 0;
    if (engineNew != null) {
      final mechanism = engineNew.mechanism;
      if (mechanism == SpellcastingMechanism.known ||
          mechanism == SpellcastingMechanism.pact) {
        final newKnown = engineNew.maxKnown ?? 0;
        final oldKnown = engineOld?.maxKnown ?? 0;
        spellsToLearn = (newKnown - oldKnown).clamp(0, 99);
      }
    }

    final warlockSwap =
        !_isAddingClass &&
        engineNew?.mechanism == SpellcastingMechanism.pact &&
        _knownSpellsForTarget(includeCantrips: false).isNotEmpty;
    final featureChoiceRequests = _featureChoiceCatalog == null
        ? <FeatureChoiceRequest>[]
        : FeatureChoiceEngine.requestsForLevelUp(
            catalog: _featureChoiceCatalog!,
            character: character,
            newLevel: newClassLevel,
            newClassFeatures: newFeatures,
            newSubclassFeatures: newSubclassFeatures,
            targetClassEntryId: _targetClassEntry.id,
            targetClassName: _targetClassEntry.className,
            subclassName: effectiveSubclass,
            featChosen: _state.asiMode == LevelUpAsiMode.feat
                ? _state.featChosen
                : null,
          );
    _state.featureChoices = _featureChoicesForRequests(featureChoiceRequests);

    _pages = [
      LevelUpWizardPage.classTarget,
      LevelUpWizardPage.features,
      if (needsSubclass) LevelUpWizardPage.subclass,
      if (needsAsi) LevelUpWizardPage.asi,
      if (featureChoiceRequests.isNotEmpty) LevelUpWizardPage.featureChoices,
      LevelUpWizardPage.hp,
      if (cantripsToLearn > 0) LevelUpWizardPage.cantrips,
      if (warlockSwap) LevelUpWizardPage.spellSwap,
      if (spellsToLearn > 0) LevelUpWizardPage.spells,
      LevelUpWizardPage.summary,
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
    final targetClassEntry = _targetClassEntry;

    KnownSpell withSource(KnownSpell spell) {
      return spell.copyWith(
        sourceType: 'class',
        sourceClass: targetClassEntry.className,
        sourceSubclass: _effectiveSubclass,
        sourceClassEntryId: targetClassEntry.id,
      );
    }

    final result = LevelUpResult(
      targetClassEntryId: targetClassEntry.id,
      targetClassName: targetClassEntry.className,
      oldTotalLevel: widget.character.totalLevel,
      newTotalLevel: _state.newLevel,
      oldClassLevel: targetClassEntry.level,
      newClassLevel: _newClassLevel,
      targetHitDie:
          _srdClass?.hitDie ?? levelUpHitDie(targetClassEntry.className),
      hpGained: _state.hpGained,
      asiChanges: _state.asiChanges,
      featChosen: _state.featChosen,
      subclassChosen: _state.subclassChosen,
      cantripsLearned: [
        ..._fixedCantripsLearned.map(withSource),
        ..._state.cantripsLearned.map(withSource),
      ],
      spellsLearned: [
        ..._state.spellsLearned.map(withSource),
        if (_state.swapReplacement != null) withSource(_state.swapReplacement!),
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
            ListenableBuilder(
              listenable: _pageController,
              builder: (context, _) => Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: _StepIndicator(pages: _pages, currentPage: _currentPage),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pages.length,
                itemBuilder: (context, index) =>
                    _buildPage(context, _pages[index]),
              ),
            ),
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

  bool _canAdvance(int pageIndex) {
    if (pageIndex >= _pages.length) return false;
    final page = _pages[pageIndex];
    switch (page) {
      case LevelUpWizardPage.classTarget:
        return _state.targetClassEntryId != null &&
            _state.targetClassName != null;
      case LevelUpWizardPage.features:
        return true;
      case LevelUpWizardPage.subclass:
        return _state.subclassChosen != null ||
            _targetClassEntry.subclassName != null;
      case LevelUpWizardPage.asi:
        if (_state.asiMode == LevelUpAsiMode.feat) {
          return _state.featChosen != null;
        }
        final total = _state.asiChanges.values.fold(0, (a, b) => a + b);
        return total == 2;
      case LevelUpWizardPage.featureChoices:
        return FeatureChoiceEngine.allComplete(
          _featureChoiceRequests,
          _state.featureChoices,
        );
      case LevelUpWizardPage.hp:
        return _state.hpChosen;
      case LevelUpWizardPage.cantrips:
        return _state.cantripsLearned.length == _cantripsToLearn;
      case LevelUpWizardPage.spellSwap:
        return _state.spellSwapped == null || _state.swapReplacement != null;
      case LevelUpWizardPage.spells:
        return _state.spellsLearned.length >= _spellsToLearn &&
            _spellSchoolRequirementMet(_state.spellsLearned);
      case LevelUpWizardPage.summary:
        return true;
    }
  }

  Widget _buildPage(BuildContext context, LevelUpWizardPage page) {
    switch (page) {
      case LevelUpWizardPage.classTarget:
        return _ClassTargetPage(
          character: widget.character,
          classes: _classes,
          selectedClassEntryId: _targetClassEntryId,
          i18n:
              ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english,
          newClassEntryId: _newClassEntryId,
          onChanged: (entryId, className) {
            if (entryId == _targetClassEntryId &&
                className == _targetClassName) {
              return;
            }
            _selectTargetClass(entryId: entryId, className: className);
          },
        );
      case LevelUpWizardPage.features:
        return _FeaturesPage(
          classFeatures: _newClassFeatures,
          subclassFeatures: _newSubclassFeatures,
          subclassName: _effectiveSubclass,
          srdClass: _srdClass,
          i18n:
              ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english,
        );
      case LevelUpWizardPage.subclass:
        return _SubclassPage(
          srdClass: _srdClass,
          existingSubclass: _targetClassEntry.subclassName,
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
      case LevelUpWizardPage.asi:
        return _AsiPage(
          character: widget.character,
          mode: _state.asiMode,
          asiChanges: _state.asiChanges,
          featChosen: _state.featChosen,
          allFeats: _allFeats ?? const [],
          i18n:
              ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english,
          onModeChanged: (mode) => setState(() {
            _state = _state.copyWith(
              asiMode: mode,
              asiChanges: const {},
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
      case LevelUpWizardPage.featureChoices:
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
          feats: _allFeats ?? const [],
          featureLabelBuilder: (request) =>
              _featureChoiceRequestFeatureLabel(request, i18n),
          onChanged: (choices) {
            setState(() => _state = _state.copyWith(featureChoices: choices));
          },
        );
      case LevelUpWizardPage.hp:
        return _HpPage(
          character: widget.character,
          hitDie: _srdClass?.hitDie ?? levelUpHitDie(_targetClassName),
          hpGained: _state.hpGained,
          hpChosen: _state.hpChosen,
          onHpChosen: (hp) => setState(() {
            _state = _state.copyWith(hpGained: hp, hpChosen: true);
          }),
        );
      case LevelUpWizardPage.cantrips:
        final engine = _engineFor(_newClassLevel);
        return _SpellPickPage(
          classSpells: _spellChoices(engine, isCantrip: true),
          alreadyKnown: widget.character.spells
              .where((spell) => spell.level == 0)
              .map((spell) => spell.name)
              .toList(),
          toLearn: _cantripsToLearn,
          chosen: _state.cantripsLearned,
          maxLevel: 0,
          onChanged: (spells) =>
              setState(() => _state = _state.copyWith(cantripsLearned: spells)),
          isCantrip: true,
          requiredSchools: const {},
          requiredSchoolPickCount: 0,
          i18n:
              ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english,
        );
      case LevelUpWizardPage.spellSwap:
        final engine = _engineFor(_newClassLevel);
        return _SpellSwapPage(
          classSpells: _spellChoices(engine, isCantrip: false),
          knownSpells: _knownSpellsForTarget(includeCantrips: false),
          alreadyKnownSpellNames: widget.character.spells
              .where((spell) => spell.level > 0)
              .map((spell) => spell.name)
              .toSet(),
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
      case LevelUpWizardPage.spells:
        final engine = _engineFor(_newClassLevel);
        return _SpellPickPage(
          classSpells: _spellChoices(engine, isCantrip: false),
          alreadyKnown: widget.character.spells
              .where((spell) => spell.level > 0)
              .map((spell) => spell.name)
              .toList(),
          toLearn: _spellsToLearn,
          chosen: _state.spellsLearned,
          maxLevel: engine?.maxSpellLevel ?? 9,
          onChanged: (spells) =>
              setState(() => _state = _state.copyWith(spellsLearned: spells)),
          isCantrip: false,
          requiredSchools: _requiredSpellSchools,
          requiredSchoolPickCount: _requiredSpellSchoolPicks,
          i18n:
              ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english,
        );
      case LevelUpWizardPage.summary:
        return _SummaryPage(
          wizardState: _state,
          character: widget.character,
          targetClassName: _targetClassName,
          targetClassLevel: _newClassLevel,
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
          feats: _allFeats ?? const [],
        );
    }
  }
}

// ── Page: Class Target ────────────────────────────────────────────────────────

class _ClassTargetPage extends StatelessWidget {
  const _ClassTargetPage({
    required this.character,
    required this.classes,
    required this.selectedClassEntryId,
    required this.i18n,
    required this.newClassEntryId,
    required this.onChanged,
  });

  final Character character;
  final List<SrdClass> classes;
  final String selectedClassEntryId;
  final SrdI18nService i18n;
  final String Function(String className) newClassEntryId;
  final void Function(String entryId, String className) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final existingClassNames = {
      for (final entry in character.classEntries) entry.className.toLowerCase(),
    };
    final targetNamesById = <String, String>{
      for (final entry in character.classEntries) entry.id: entry.className,
      for (final srdClass in classes)
        if (!existingClassNames.contains(srdClass.name.toLowerCase()))
          newClassEntryId(srdClass.name): srdClass.name,
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.levelUpStepClassTarget,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        RadioGroup<String>(
          groupValue: selectedClassEntryId,
          onChanged: (entryId) {
            if (entryId == null) return;
            final className = targetNamesById[entryId];
            if (className != null) onChanged(entryId, className);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ClassTargetSectionHeader(l10n.levelUpClassTargetExisting),
              ...character.classEntries.map((entry) {
                return Card(
                  child: RadioListTile<String>(
                    title: Text(i18n.className(entry.className)),
                    subtitle: Text(
                      '${l10n.levelUpClassTargetCurrentLevel(entry.level)} • '
                      '${l10n.levelUpClassTargetNextClassLevel(entry.level + 1)}',
                    ),
                    value: entry.id,
                    selected: selectedClassEntryId == entry.id,
                  ),
                );
              }),
              const SizedBox(height: 12),
              _ClassTargetSectionHeader(l10n.levelUpClassTargetAddClass),
              ...classes
                  .where(
                    (srdClass) => !existingClassNames.contains(
                      srdClass.name.toLowerCase(),
                    ),
                  )
                  .map((srdClass) {
                    final check = MulticlassPrerequisites.validateAddClass(
                      character: character,
                      targetClass: srdClass.name,
                    );
                    final entryId = newClassEntryId(srdClass.name);
                    final requirement = _requirementsLabel(
                      check.targetClassResult,
                      l10n,
                    );
                    final subtitle = check.canAddClass
                        ? [
                            l10n.levelUpClassTargetNextClassLevel(1),
                            if (requirement.isNotEmpty)
                              l10n.levelUpClassTargetRequirement(requirement),
                          ].join(' • ')
                        : check.currentClassesMeetRequirements
                        ? l10n.levelUpClassTargetRequirementMissing(requirement)
                        : l10n.levelUpClassTargetCurrentRequirementsMissing;
                    return Card(
                      child: RadioListTile<String>(
                        title: Text(i18n.className(srdClass.name)),
                        subtitle: Text(subtitle),
                        value: entryId,
                        enabled: check.canAddClass,
                        selected: selectedClassEntryId == entryId,
                      ),
                    );
                  }),
            ],
          ),
        ),
      ],
    );
  }

  static String _requirementsLabel(
    MulticlassPrerequisiteResult result,
    AppLocalizations l10n,
  ) {
    return result.options
        .map(
          (option) => option.requirements
              .map(
                (requirement) =>
                    '${_abilityLabel(requirement.ability, l10n)} '
                    '${requirement.minimum}',
              )
              .join(' + '),
        )
        .join(' / ');
  }

  static String _abilityLabel(String ability, AppLocalizations l10n) {
    switch (ability.toLowerCase()) {
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
        return ability;
    }
  }
}

class _ClassTargetSectionHeader extends StatelessWidget {
  const _ClassTargetSectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.pages, required this.currentPage});
  final List<LevelUpWizardPage> pages;
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
    required this.existingSubclass,
    required this.currentChoice,
    required this.i18n,
    required this.onChanged,
  });
  final SrdClass? srdClass;
  final String? existingSubclass;
  final String? currentChoice;
  final SrdI18nService i18n;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final featureName = srdClass?.subclassFeatureName ?? 'Subclass';
    final subclasses = srdClass?.subclasses ?? [];
    final existing = existingSubclass;

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
  final LevelUpAsiMode mode;
  final Map<String, int> asiChanges;
  final SrdFeat? featChosen;
  final List<SrdFeat> allFeats;
  final SrdI18nService i18n;
  final ValueChanged<LevelUpAsiMode> onModeChanged;
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
        SegmentedButton<LevelUpAsiMode>(
          segments: [
            ButtonSegment(
              value: LevelUpAsiMode.asi,
              label: Text(l10n.levelUpAsiOption),
            ),
            ButtonSegment(
              value: LevelUpAsiMode.feat,
              label: Text(l10n.levelUpFeatOption),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (s) => onModeChanged(s.first),
        ),
        const SizedBox(height: 16),

        if (mode == LevelUpAsiMode.asi) ...[
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
    required this.hitDie,
    required this.hpGained,
    required this.hpChosen,
    required this.onHpChosen,
  });
  final Character character;
  final int hitDie;
  final int hpGained;
  final bool hpChosen;
  final ValueChanged<int> onHpChosen;

  int get _conMod => ((character.abilityScores.constitution - 10) / 2).floor();
  String get _conModStr => _conMod >= 0 ? '+$_conMod' : '$_conMod';

  int get _average => ((hitDie / 2) + 1).ceil() + _conMod;
  int _roll() => math.max(1, math.Random().nextInt(hitDie) + 1 + _conMod);

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
          l10n.levelUpHpFormula(hitDie, _conModStr),
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
                sublabel: 'd$hitDie + CON',
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
    final alreadyKnownNames = {
      for (final name in alreadyKnown) _spellKey(name),
    };
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
    final schoolList = requiredSchools.map(i18n.spellSchool).toList()
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
          if (locked) ...[
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
          ] else
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
                updated.removeWhere((known) => _spellKey(known.name) == key);
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
    required this.alreadyKnownSpellNames,
    required this.swapped,
    required this.replacement,
    required this.onSwappedChanged,
    required this.onReplacementChanged,
    required this.i18n,
  });

  final List<SrdSpell> classSpells;
  final List<KnownSpell> knownSpells;
  final Set<String> alreadyKnownSpellNames;
  final String? swapped;
  final KnownSpell? replacement;
  final ValueChanged<String?> onSwappedChanged;
  final ValueChanged<KnownSpell?> onReplacementChanged;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final alreadyKnownNames = alreadyKnownSpellNames.map(_spellKey).toSet();
    final available = classSpells
        .where((s) => !alreadyKnownNames.contains(_spellKey(s.name)))
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

  static String _spellKey(String name) => name.toLowerCase();
}

// ── Page: Summary ─────────────────────────────────────────────────────────────

class _SummaryPage extends StatelessWidget {
  const _SummaryPage({
    required this.wizardState,
    required this.character,
    required this.targetClassName,
    required this.targetClassLevel,
    required this.fixedCantripsLearned,
    required this.featureChoiceRequests,
    required this.featureChoiceCatalog,
    required this.i18n,
    required this.skills,
    required this.tools,
    required this.spells,
    required this.languages,
    required this.weapons,
    required this.feats,
  });
  final LevelUpWizardState wizardState;
  final Character character;
  final String targetClassName;
  final int targetClassLevel;
  final List<KnownSpell> fixedCantripsLearned;
  final List<FeatureChoiceRequest> featureChoiceRequests;
  final SrdFeatureChoiceCatalog? featureChoiceCatalog;
  final SrdI18nService i18n;
  final List<SrdSkill> skills;
  final List<SrdTool> tools;
  final List<SrdSpell> spells;
  final List<SrdLanguage> languages;
  final List<SrdWeapon> weapons;
  final List<SrdFeat> feats;

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
        icon: Icons.school_outlined,
        text: l10n.levelUpSummaryClassLevel(
          i18n.className(targetClassName),
          targetClassLevel,
        ),
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
    if (wizardState.featureChoices.isNotEmpty && featureChoiceCatalog != null) {
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
                feats: feats,
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
