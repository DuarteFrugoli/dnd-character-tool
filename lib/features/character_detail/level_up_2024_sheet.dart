import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/character_progression/progression_2024_engine.dart';
import '../../data/datasources/srd/srd_i18n_service.dart';
import '../../data/datasources/srd/srd_models.dart';
import '../../data/feature_choice_engine.dart';
import '../../data/models/models.dart';
import '../../l10n/ability_l10n.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/providers/providers.dart';
import 'character_detail_provider.dart';
import 'widgets/feature_choice_editor.dart';

Future<void> openLevelUp2024Sheet(
  BuildContext context,
  Character character,
  String characterId,
) {
  if (character.totalLevel >= Progression2024Engine.maxLevel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.levelUpMaxLevel)),
    );
    return Future.value();
  }
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _LevelUp2024Wizard(characterId: characterId),
    ),
  );
}

enum _Step { classTarget, subclass, feat, hitPoints, choices, summary }

class _LevelUp2024Wizard extends ConsumerStatefulWidget {
  const _LevelUp2024Wizard({required this.characterId});

  final String characterId;

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
  int _stepIndex = 0;

  Character get _character =>
      ref.read(characterDetailProvider(widget.characterId)).requireValue;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final notifier = ref.read(characterDetailProvider(widget.characterId).notifier);
      final data = await notifier.rules2024Data();
      final character = _character;
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
    });
  }

  List<_Step> get _steps {
    final plan = _plan;
    return [
      _Step.classTarget,
      if (plan != null && plan.requiresSubclass) _Step.subclass,
      if (plan != null && plan.featFeature != null) _Step.feat,
      _Step.hitPoints,
      if (_requests.isNotEmpty) _Step.choices,
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
    setState(() => _saving = true);
    try {
      await ref
          .read(characterDetailProvider(widget.characterId).notifier)
          .levelUp2024(
            LevelUp2024Result(
              className: _className!,
              classEntryId: _classEntryId,
              hitPointMethod: _hpMethod,
              hitDieRoll: _roll,
              subclassName: _subclass,
              featName: _feat,
              abilityIncreases: _increases,
              featureChoices: _choices,
            ),
          );
      if (mounted) Navigator.of(context).pop();
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
    final character = ref.watch(characterDetailProvider(widget.characterId)).valueOrNull;
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
          featureLabelBuilder: (request) => _requestLabel(request, i18n),
          onChanged: (choices) => setState(() => _choices = choices),
        ),
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
