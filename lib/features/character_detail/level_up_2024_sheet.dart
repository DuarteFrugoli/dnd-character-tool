import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/character_progression/progression_2024_engine.dart';
import '../../data/constants/level_up_rules.dart';
import '../../data/datasources/srd/srd_i18n_service.dart';
import '../../data/datasources/srd/srd_models.dart';
import '../../data/feature_choice_engine.dart';
import '../../data/models/models.dart';
import '../../l10n/ability_l10n.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/character_changes_dialog.dart';
import 'character_detail_provider.dart';
import 'widgets/feature_choice_editor.dart';

/// Opens the 2024 level up. By default the level is saved on confirm; with
/// `applyOnConfirm: false` the wizard works on [character] in memory (e.g. a
/// reset being rebuilt) and returns the decisions without saving.
Future<LevelUp2024Result?> openLevelUp2024Sheet(
  BuildContext context,
  Character character,
  String characterId, {
  bool applyOnConfirm = true,
}) {
  if (character.totalLevel >= Progression2024Engine.maxLevel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.levelUpMaxLevel)),
    );
    return Future.value();
  }
  return Navigator.of(context).push<LevelUp2024Result>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _LevelUp2024Wizard(
        characterId: characterId,
        character: applyOnConfirm ? null : character,
      ),
    ),
  );
}

enum _Step { classTarget, subclass, feat, hitPoints, choices, swaps, summary }

class _LevelUp2024Wizard extends ConsumerStatefulWidget {
  const _LevelUp2024Wizard({required this.characterId, this.character});

  final String characterId;

  /// In-memory sheet being rebuilt; when set, the result is returned instead
  /// of saved.
  final Character? character;

  @override
  ConsumerState<_LevelUp2024Wizard> createState() => _LevelUp2024WizardState();
}

class _LevelUp2024WizardState extends ConsumerState<_LevelUp2024Wizard> {
  Rules2024Data? _data;
  List<SrdWeapon> _weapons = const [];
  Object? _loadError;
  bool _saving = false;

  String? _className;
  String? _classEntryId;
  LevelUp2024Plan? _plan;
  String? _subclass;
  String? _feat;
  Map<String, int> _increases = {};
  String _hpMethod = HitPointGainMethod.average;
  int? _roll;
  List<CharacterFeatureChoice> _choices = const [];
  final Map<bool, (String?, String?)> _swaps = {};
  int _stepIndex = 0;

  Character get _character =>
      widget.character ??
      ref.read(characterDetailProvider(widget.characterId)).requireValue;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final character = _character;
      final data = await ref.read(srd2024RulesForSpeciesProvider(character.race).future);
      final weapons = await ref.read(
        srdWeaponsForPackProvider(character.contentPackId).future,
      );
      if (!mounted) return;
      setState(() {
        _data = data;
        _weapons = weapons;
      });
      _selectClass(character.primaryClass.className, character.primaryClass.id);
    } catch (error) {
      if (mounted) setState(() => _loadError = error);
    }
  }

  void _selectClass(String className, String? classEntryId) {
    final data = _data!;
    setState(() {
      _className = className;
      _classEntryId = classEntryId;
      _plan = Progression2024Engine.plan(
        _character,
        data,
        className: className,
        classEntryId: classEntryId,
      );
      _subclass = null;
      _feat = null;
      _increases = {};
      _choices = const [];
      _swaps.clear();
    });
  }

  /// Bards, Sorcerers and Warlocks may replace class-table spells on gaining
  /// a level; `true` keys the cantrip swap.
  List<bool> get _swapKinds {
    final plan = _plan;
    if (plan == null || plan.isNewClass) return const [];
    final entry = _character.classEntries.firstWhere((e) => e.id == plan.classEntryId);
    return [
      if (plan.cls.levelUpCantripSwaps > 0 &&
          Progression2024Engine.swappableSpells(_character, entry, cantrips: true).isNotEmpty)
        true,
      if (plan.cls.levelUpSpellSwaps > 0 &&
          Progression2024Engine.swappableSpells(_character, entry, cantrips: false).isNotEmpty)
        false,
    ];
  }

  List<SpellSwap2024> get _spellSwaps => [
    for (final (forget, learn) in _swaps.values)
      if (forget != null && learn != null)
        SpellSwap2024(forget: forget, learn: learn),
  ];

  List<_Step> get _steps {
    final plan = _plan;
    return [
      _Step.classTarget,
      if (plan != null && plan.requiresSubclass) _Step.subclass,
      if (plan != null && plan.featFeature != null) _Step.feat,
      _Step.hitPoints,
      if (_requests.isNotEmpty) _Step.choices,
      if (_swapKinds.isNotEmpty) _Step.swaps,
      _Step.summary,
    ];
  }

  List<FeatureChoiceRequest> get _requests {
    final plan = _plan;
    final data = _data;
    if (plan == null || data == null) return const [];
    if (plan.requiresSubclass && _subclass == null) return const [];
    return Progression2024Engine.requestsFor(
      _character,
      data,
      plan,
      subclassName: _subclass,
      featName: _feat,
    );
  }

  SrdFeatureChoiceRequirement? get _abilityRequirement => _feat == null
      ? null
      : Progression2024Engine.featAbilityRequirement(_data!, _feat!);

  bool _stepComplete(_Step step) {
    final plan = _plan;
    if (plan == null) return false;
    return switch (step) {
      _Step.classTarget => true,
      _Step.subclass => _subclass != null,
      _Step.feat =>
        _feat != null &&
            (_abilityRequirement == null ||
                Progression2024Engine.validAbilityIncreases(
                  _character,
                  _abilityRequirement!,
                  _increases,
                )),
      _Step.hitPoints =>
        _hpMethod == HitPointGainMethod.average || _roll != null,
      _Step.choices => FeatureChoiceEngine.allComplete(_requests, _choices),
      _Step.swaps => _swaps.values.every(
        (swap) => (swap.$1 == null) == (swap.$2 == null),
      ),
      _Step.summary => true,
    };
  }

  int get _hpGained {
    final plan = _plan;
    if (plan == null) return 0;
    return Progression2024Engine.hitPointsGained(
      _character,
      _data!,
      plan,
      method: _hpMethod,
      roll: _roll,
    );
  }

  Future<void> _confirm() async {
    final result = LevelUp2024Result(
      className: _className!,
      classEntryId: _classEntryId,
      hitPointMethod: _hpMethod,
      hitDieRoll: _roll,
      subclassName: _subclass,
      featName: _feat,
      abilityIncreases: _increases,
      featureChoices: _choices,
      spellSwaps: _spellSwaps,
    );
    if (widget.character != null) {
      try {
        // Validate in memory so a rebuild never stops on an invalid level.
        Progression2024Engine.applyLevelUp(_character, _data!, result);
        Navigator.of(context).pop(result);
      } catch (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(characterDetailProvider(widget.characterId).notifier)
          .levelUp2024(result);
      if (mounted) Navigator.of(context).pop(result);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final character = widget.character ??
        ref.watch(characterDetailProvider(widget.characterId)).valueOrNull;
    final i18n = character == null
        ? null
        : ref.watch(srdI18nForPackProvider(character.contentPackId)).valueOrNull;
    final data = _data;
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.levelUpTitle)),
        body: Center(child: Text(_loadError.toString())),
      );
    }
    if (character == null || data == null || i18n == null || _plan == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.levelUpTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final steps = _steps;
    final index = _stepIndex.clamp(0, steps.length - 1);
    final step = steps[index];
    final isLast = index == steps.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${l10n.levelUpTitle} · ${l10n.levelUpSummaryLevel(_plan!.newTotalLevel)}',
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (index + 1) / steps.length),
        ),
      ),
      body: switch (step) {
        _Step.classTarget => _buildClassStep(context, character, data, i18n),
        _Step.subclass => _buildSubclassStep(context, data, i18n),
        _Step.feat => _buildFeatStep(context, character, data, i18n),
        _Step.hitPoints => _buildHitPointStep(context, character),
        _Step.choices => FeatureChoiceEditor(
          key: ValueKey('choices-$_className-$_subclass-$_feat'),
          requests: _requests,
          initialChoices: _choices.isEmpty ? character.featureChoices : _choices,
          catalog: data.choices,
          character: character,
          i18n: i18n,
          skills: data.skills,
          tools: data.tools,
          spells: data.spells,
          languages: data.languages,
          weapons: _weapons,
          feats: data.feats,
          monsters: data.monsters,
          featureLabelBuilder: (request) => _requestLabel(request, i18n),
          onChanged: (choices) => setState(() => _choices = choices),
        ),
        _Step.swaps => _buildSwapStep(context, character, data, i18n),
        _Step.summary => _buildSummaryStep(context, character, data, i18n),
      },
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              if (index > 0)
                TextButton(
                  onPressed: _saving ? null : () => setState(() => _stepIndex = index - 1),
                  child: Text(l10n.creationBack),
                )
              else
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.levelUpCancel),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _saving || !_stepComplete(step)
                    ? null
                    : isLast
                    ? _confirm
                    : () {
                        if (steps[index + 1] == _Step.choices && _choices.isEmpty) {
                          _choices = [
                            for (final request in _requests)
                              request.findIn(character.featureChoices) ??
                                  request.emptyChoice(),
                          ];
                        }
                        setState(() => _stepIndex = index + 1);
                      },
                child: Text(isLast ? l10n.levelUpConfirm : l10n.dialogContinue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _requestLabel(FeatureChoiceRequest request, SrdI18nService i18n) =>
      switch (request.sourceType) {
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
        FeatureChoiceSourceType.feat =>
          i18n.featName(request.featureName) ?? request.featureName,
        FeatureChoiceSourceType.multiclassProficiency =>
          '${i18n.className(request.sourceClass)} · ${AppLocalizations.of(context)!.levelUpClassTargetAddClass}',
        _ => request.featureName,
      };

  Widget _buildClassStep(
    BuildContext context,
    Character character,
    Rules2024Data data,
    SrdI18nService i18n,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final current = character.classEntries.map((e) => e.className).toSet();
    const newPrefix = 'new:';
    return RadioGroup<String>(
      groupValue: _classEntryId ?? '$newPrefix$_className',
      onChanged: (value) {
        if (value == null) return;
        if (value.startsWith(newPrefix)) {
          _selectClass(value.substring(newPrefix.length), null);
          return;
        }
        final entry = character.classEntries.firstWhere((e) => e.id == value);
        _selectClass(entry.className, entry.id);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.levelUpStepClassTarget, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l10n.levelUpClassTargetExisting, style: Theme.of(context).textTheme.labelLarge),
          for (final entry in character.classEntries)
            RadioListTile<String>(
              value: entry.id,
              title: Text(i18n.className(entry.className)),
              subtitle: Text(
                '${l10n.levelUpClassTargetCurrentLevel(entry.level)} → '
                '${l10n.levelUpClassTargetNextClassLevel(entry.level + 1)}',
              ),
            ),
          const Divider(height: 24),
          Text(l10n.levelUpClassTargetAddClass, style: Theme.of(context).textTheme.labelLarge),
          for (final cls in data.classes)
            if (!current.contains(cls.name))
              Builder(
                builder: (context) {
                  final missing = Progression2024Engine.missingMulticlassAbilities(
                    character,
                    data,
                    cls.name,
                  );
                  return RadioListTile<String>(
                    value: '$newPrefix${cls.name}',
                    enabled: missing.isEmpty,
                    title: Text(i18n.className(cls.name)),
                    subtitle: Text(
                      missing.isEmpty
                          ? l10n.levelUpClassTargetRequirement(
                              _abilityList(l10n, cls.primaryAbilities, cls.primaryAbilityAny),
                            )
                          : l10n.levelUpClassTargetRequirementMissing(
                              _abilityList(l10n, missing, false),
                            ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  String _abilityList(AppLocalizations l10n, List<String> abilities, bool any) =>
      abilities
          .map((ability) => '${abilityName(l10n, ability)} 13')
          .join(any ? ' / ' : ' + ');

  Widget _buildSubclassStep(BuildContext context, Rules2024Data data, SrdI18nService i18n) {
    final l10n = AppLocalizations.of(context)!;
    final plan = _plan!;
    final subclasses = data.subclasses[plan.cls.name] ?? const [];
    return RadioGroup<String>(
      groupValue: _subclass,
      onChanged: (value) => setState(() {
        _subclass = value;
        _choices = const [];
      }),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.levelUpStepSubclass(
              i18n.classSubclassFeatureName(plan.cls.name) ?? i18n.className(plan.cls.name),
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final subclass in subclasses)
            RadioListTile<String>(
              value: subclass.name,
              title: Text(i18n.subclassName(plan.cls.name, subclass.name)),
              subtitle: Text(
                i18n.subclassDescription(plan.cls.name, subclass.name) ?? subclass.description,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatStep(
    BuildContext context,
    Character character,
    Rules2024Data data,
    SrdI18nService i18n,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final feats = Progression2024Engine.eligibleFeats(character, data, _plan!);
    final requirement = _abilityRequirement;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.levelUpFeatOption, style: Theme.of(context).textTheme.titleMedium),
        RadioGroup<String>(
          groupValue: _feat,
          onChanged: (value) => setState(() {
            _feat = value;
            _increases = {};
            _choices = const [];
          }),
          child: Column(
            children: [
              for (final feat in feats)
                RadioListTile<String>(
                  value: feat.name,
                  title: Text(i18n.featName(feat.name) ?? feat.name),
                  subtitle: Text(
                    i18n.featDescription(feat.name) ?? feat.description,
                    maxLines: _feat == feat.name ? null : 2,
                    overflow: _feat == feat.name ? null : TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
        if (requirement != null) ...[
          const Divider(height: 24),
          Text(
            requirement.type == 'ability'
                ? l10n.levelUp2024AbilityHint(
                    requirement.increase,
                    requirement.maximum ?? 20,
                  )
                : l10n.levelUp2024AsiHint(requirement.maximum ?? 20),
          ),
          for (final ability in Progression2024Engine.abilityOptions(requirement))
            _AbilityIncreaseRow(
              label: abilityName(l10n, ability),
              score: character.abilityScores[ability],
              increase: _increases[ability] ?? 0,
              canIncrease: _canIncrease(character, requirement, ability),
              onChanged: (value) => setState(() {
                _increases = {..._increases, ability: value};
              }),
            ),
        ],
      ],
    );
  }

  bool _canIncrease(
    Character character,
    SrdFeatureChoiceRequirement requirement,
    String ability,
  ) {
    final current = _increases[ability] ?? 0;
    final next = {..._increases, ability: current + 1};
    final total = next.values.fold<int>(0, (sum, value) => sum + value);
    final maximum = requirement.maximum ?? 20;
    if (character.abilityScores[ability] + current + 1 > maximum) return false;
    if (requirement.type == 'ability') {
      return total <= requirement.increase &&
          next.values.where((value) => value > 0).length == 1;
    }
    final largest = requirement.patterns
        .map((pattern) => pattern.fold<int>(0, (sum, value) => sum + value))
        .fold<int>(0, math.max);
    return total <= largest;
  }

  Widget _buildSwapStep(
    BuildContext context,
    Character character,
    Rules2024Data data,
    SrdI18nService i18n,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final plan = _plan!;
    final entry = character.classEntries.firstWhere((e) => e.id == plan.classEntryId);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.levelUp2024SwapTitle, style: Theme.of(context).textTheme.titleMedium),
        for (final cantrips in _swapKinds) ...[
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              final (forget, learn) = _swaps[cantrips] ?? (null, null);
              final known = Progression2024Engine.swappableSpells(
                character,
                entry,
                cantrips: cantrips,
              );
              final candidates = Progression2024Engine.swapCandidates(
                character,
                data,
                plan.cls,
                plan.newClassLevel,
                cantrips: cantrips,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String?>(
                    initialValue: forget,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: cantrips
                          ? l10n.levelUp2024SwapCantrip
                          : l10n.levelUp2024SwapSpell,
                    ),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.levelUpSpellSwapNone)),
                      for (final spell in known)
                        DropdownMenuItem(value: spell.name, child: Text(i18n.spellName(spell.name))),
                    ],
                    onChanged: (value) => setState(
                      () => _swaps[cantrips] = (value, value == null ? null : learn),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    key: ValueKey('learn-$cantrips-$forget'),
                    initialValue: learn,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.levelUp2024SwapLearn),
                    items: [
                      for (final spell in candidates)
                        DropdownMenuItem(
                          value: spell.name,
                          child: Text(
                            spell.level == 0
                                ? i18n.spellName(spell.name)
                                : '${i18n.spellName(spell.name)} · ${l10n.spellsLevelN(spell.level)}',
                          ),
                        ),
                    ],
                    onChanged: forget == null
                        ? null
                        : (value) => setState(() => _swaps[cantrips] = (forget, value)),
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildHitPointStep(BuildContext context, Character character) {
    final l10n = AppLocalizations.of(context)!;
    final plan = _plan!;
    final conMod = character.abilityScores.constitutionModifier;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.levelUpStepHp, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(l10n.levelUpHpFormula(plan.cls.hitDie, conMod >= 0 ? '+$conMod' : '$conMod')),
        RadioGroup<String>(
          groupValue: _hpMethod,
          onChanged: (value) => setState(() => _hpMethod = value!),
          child: Column(
            children: [
              RadioListTile<String>(
                value: HitPointGainMethod.average,
                title: Text(l10n.levelUpHpAverage),
                subtitle: Text('${Progression2024Engine.averageHitDie(plan.cls.hitDie)}'),
              ),
              RadioListTile<String>(
                value: HitPointGainMethod.rolled,
                title: Text(l10n.levelUpHpRoll),
                subtitle: _roll == null ? null : Text('$_roll'),
                secondary: _hpMethod == HitPointGainMethod.rolled
                    ? IconButton(
                        tooltip: _roll == null ? l10n.levelUpHpRoll : l10n.levelUpHpReroll,
                        icon: const Icon(Icons.casino_outlined),
                        onPressed: () => setState(
                          () => _roll = math.Random().nextInt(plan.cls.hitDie) + 1,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
        if (_stepComplete(_Step.hitPoints))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.levelUpHpGained(_hpGained),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryStep(
    BuildContext context,
    Character character,
    Rules2024Data data,
    SrdI18nService i18n,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final plan = _plan!;
    final subclassFeatures = [
      for (final feature in data.subclassFeatures[plan.cls.name]
              ?[_subclass ?? plan.currentSubclass] ??
          const <SrdClassFeature>[])
        if (feature.level == plan.newClassLevel) feature.name,
    ];
    final spellcasting = Progression2024Engine.spellcastingFor(
      character.copyWith(
        classes: [
          for (final entry in character.classEntries)
            if (entry.id == plan.classEntryId)
              entry.copyWith(level: plan.newClassLevel)
            else
              entry,
          if (plan.isNewClass)
            CharacterClassEntry(
              id: plan.classEntryId,
              className: plan.cls.name,
              level: 1,
            ),
        ],
      ),
      data.classes,
    ).where((casting) => casting.entry.id == plan.classEntryId).firstOrNull;
    final increases = _increases.entries.where((e) => e.value > 0).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.levelUpStepSummary, style: Theme.of(context).textTheme.titleMedium),
        ListTile(
          title: Text(l10n.levelUpSummaryLevel(plan.newTotalLevel)),
          subtitle: Text(
            l10n.levelUpSummaryClassLevel(
              i18n.className(plan.cls.name),
              plan.newClassLevel,
            ),
          ),
        ),
        ListTile(title: Text(l10n.levelUpSummaryHp(_hpGained))),
        if (_subclass != null)
          ListTile(
            title: Text(
              l10n.levelUpSummarySubclass(i18n.subclassName(plan.cls.name, _subclass!)),
            ),
          ),
        if (_feat != null)
          ListTile(title: Text(l10n.levelUpSummaryFeat(i18n.featName(_feat!) ?? _feat!))),
        if (increases.isNotEmpty)
          ListTile(
            title: Text(
              l10n.levelUpSummaryAsi(
                increases
                    .map((e) => '${abilityName(l10n, e.key)} +${e.value}')
                    .join(', '),
              ),
            ),
          ),
        const Divider(),
        Text(l10n.levelUpStepFeatures, style: Theme.of(context).textTheme.titleSmall),
        if (plan.newFeatures.isEmpty && subclassFeatures.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l10n.levelUpNoNewFeatures),
          ),
        for (final name in plan.newFeatures)
          ListTile(
            dense: true,
            leading: const Icon(Icons.star_outline),
            title: Text(i18n.classFeatureName(plan.cls.name, name) ?? name),
          ),
        for (final name in subclassFeatures)
          ListTile(
            dense: true,
            leading: const Icon(Icons.auto_awesome_outlined),
            title: Text(
              i18n.subclassFeatureName(
                    plan.cls.name,
                    _subclass ?? plan.currentSubclass ?? '',
                    name,
                  ) ??
                  name,
            ),
          ),
        if (spellcasting != null) ...[
          const Divider(),
          Text(
            l10n.levelUp2024SpellLimits(
              i18n.className(plan.cls.name),
              spellcasting.cantripsKnown,
              spellcasting.preparedSpells,
              spellcasting.maxSpellLevel,
            ),
          ),
        ],
      ],
    );
  }
}

class _AbilityIncreaseRow extends StatelessWidget {
  const _AbilityIncreaseRow({
    required this.label,
    required this.score,
    required this.increase,
    required this.canIncrease,
    required this.onChanged,
  });

  final String label;
  final int score;
  final int increase;
  final bool canIncrease;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(increase > 0 ? '$score → ${score + increase}' : '$score'),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: increase > 0 ? () => onChanged(increase - 1) : null,
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: canIncrease ? () => onChanged(increase + 1) : null,
        ),
      ],
    );
  }
}

/// Runs the level up wizard in memory from [levelOne] up to [targetLevel]
/// (a reset being rebuilt, or a 2014 sheet being converted). Nothing is
/// saved; returns null when the player cancels any step.
Future<Character?> rebuildLevels2024(
  BuildContext context,
  Character levelOne,
  int targetLevel,
  Rules2024Data data, {
  bool keepExperience = false,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  var current = levelOne;
  while (current.totalLevel < targetLevel) {
    final l10n = AppLocalizations.of(context)!;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(l10n.resetLevelsRebuildStep(current.totalLevel + 1, targetLevel)),
        ),
      );
    final result = await openLevelUp2024Sheet(
      context,
      current,
      current.id,
      applyOnConfirm: false,
    );
    if (!context.mounted || result == null) return null;
    current = Progression2024Engine.applyLevelUp(current, data, result);
    if (current.xpTrackingEnabled && !keepExperience) {
      current = current.copyWith(experiencePoints: levelToMinXp(current.totalLevel));
    }
  }
  messenger.hideCurrentSnackBar();
  return current;
}

/// Opens the 2024 level reset: pick the level 1 class (the current starting
/// class by default) and its level 1 choices, then rebuild the sheet.
Future<bool?> openLevelReset2024Sheet(BuildContext context, String characterId) {
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _LevelReset2024Flow(characterId: characterId),
    ),
  );
}

class _LevelReset2024Flow extends ConsumerStatefulWidget {
  const _LevelReset2024Flow({required this.characterId});

  final String characterId;

  @override
  ConsumerState<_LevelReset2024Flow> createState() => _LevelReset2024FlowState();
}

class _LevelReset2024FlowState extends ConsumerState<_LevelReset2024Flow> {
  Rules2024Data? _data;
  List<SrdWeapon> _weapons = const [];
  Object? _loadError;
  String? _className;
  List<FeatureChoiceRequest> _requests = const [];
  List<CharacterFeatureChoice> _choices = const [];
  bool _saving = false;
  late bool _rebuild = _character.totalLevel > 1;

  Character get _character =>
      ref.read(characterDetailProvider(widget.characterId)).requireValue;

  Future<Character?> _rebuildLevels(Character levelOne, int targetLevel) =>
      rebuildLevels2024(context, levelOne, targetLevel, _data!);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ref
          .read(characterDetailProvider(widget.characterId).notifier)
          .rules2024Data();
      final weapons = await ref.read(
        srdWeaponsForPackProvider(_character.contentPackId).future,
      );
      if (!mounted) return;
      setState(() {
        _data = data;
        _weapons = weapons;
      });
      _selectClass(_character.primaryClass.className);
    } catch (error) {
      if (mounted) setState(() => _loadError = error);
    }
  }

  void _selectClass(String className) {
    final data = _data!;
    final character = _character;
    setState(() {
      _className = className;
      _requests = Progression2024Engine.levelOneRequests(character, data, className);
      _choices = className == character.primaryClass.className
          ? Progression2024Engine.currentLevelOneChoices(character, data)
          : [for (final request in _requests) request.emptyChoice()];
    });
  }

  Future<void> _apply() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final character = _character;
    final i18n = await ref.read(
      srdI18nForPackProvider(character.contentPackId).future,
    );
    if (!mounted) return;
    final Character preview;
    try {
      preview = Progression2024Engine.resetToLevelOne(
        character,
        _data!,
        className: _className,
        choices: _choices,
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
      return;
    }
    var result = preview;
    if (_rebuild && character.totalLevel > 1) {
      final rebuilt = await _rebuildLevels(preview, character.totalLevel);
      if (!mounted) return;
      if (rebuilt == null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.resetLevelsRebuildCancelled)),
        );
        return;
      }
      result = rebuilt;
    }
    final confirmed = await showCharacterChangesDialog(
      context,
      before: character,
      after: result,
      i18n: i18n,
    );
    if (!confirmed || !mounted) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(characterDetailProvider(widget.characterId).notifier)
          .saveLevelReset2024(result);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.totalLevel > 1
                ? l10n.resetLevelsRebuiltApplied(result.totalLevel)
                : l10n.resetLevelsApplied,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final character = ref.watch(characterDetailProvider(widget.characterId)).valueOrNull;
    final i18n = character == null
        ? null
        : ref.watch(srdI18nForPackProvider(character.contentPackId)).valueOrNull;
    final data = _data;
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.resetLevelsTitle)),
        body: Center(child: Text(_loadError.toString())),
      );
    }
    if (character == null || data == null || i18n == null || _className == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.resetLevelsTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final complete = FeatureChoiceEngine.allComplete(_requests, _choices);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.resetLevelsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: DropdownButtonFormField<String>(
              initialValue: _className,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.resetLevels2024ClassTitle),
              items: [
                for (final cls in data.classes)
                  DropdownMenuItem(value: cls.name, child: Text(i18n.className(cls.name))),
              ],
              onChanged: _saving
                  ? null
                  : (value) {
                      if (value != null) _selectClass(value);
                    },
            ),
          ),
          if (character.totalLevel > 1)
            SwitchListTile(
              value: _rebuild,
              onChanged: _saving ? null : (value) => setState(() => _rebuild = value),
              title: Text(l10n.resetLevelsRebuildTitle(character.totalLevel)),
              subtitle: Text(l10n.resetLevelsRebuildSubtitle(character.totalLevel)),
            ),
          Expanded(
            child: FeatureChoiceEditor(
              key: ValueKey('reset-$_className'),
              requests: _requests,
              initialChoices: _choices,
              catalog: data.choices,
              character: character,
              i18n: i18n,
              skills: data.skills,
              tools: data.tools,
              spells: data.spells,
              languages: data.languages,
              weapons: _weapons,
              feats: data.feats,
              monsters: data.monsters,
              featureLabelBuilder: (request) =>
                  i18n.classFeatureName(request.sourceClass, request.featureName) ??
                  request.featureName,
              onChanged: (choices) => setState(() => _choices = choices),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: _saving || !complete ? null : _apply,
            child: Text(
              !complete
                  ? l10n.resetLevelsIncomplete
                  : _rebuild && character.totalLevel > 1
                  ? l10n.resetLevelsApplyAndRebuild(character.totalLevel)
                  : l10n.resetLevelsApply,
            ),
          ),
        ),
      ),
    );
  }
}
