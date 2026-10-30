import 'dart:async';
import 'dart:math';

import 'package:dnd_character_tool/l10n/ability_l10n.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/review/app_review_service.dart';
import '../../core/units/unit_formatter.dart';
import '../../core/units/unit_system_provider.dart';
import '../../data/datasources/srd/srd_i18n_service.dart';
import '../../data/feature_choice_engine.dart';
import '../../data/models/models.dart';
import '../../data/rulesets/ruleset_ids.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/confirmation_dialog_styles.dart';
import '../character_detail/widgets/feature_choice_editor.dart';
import '../character_list/character_list_provider.dart';
import '../../data/datasources/srd/srd_2024_creation_catalog.dart';
import 'creation_2024_draft.dart';
import 'widgets/step_indicator.dart';
import 'custom_background_2024_page.dart';

class Creation2024Screen extends ConsumerStatefulWidget {
  const Creation2024Screen({super.key});

  @override
  ConsumerState<Creation2024Screen> createState() => _Creation2024ScreenState();
}

class _Creation2024ScreenState extends ConsumerState<Creation2024Screen> {
  final draft = Creation2024Draft();
  late final Future<Creation2024Catalog> _catalogFuture;
  int _step = 0;
  bool _saving = false;
  bool _splitBonus = true;

  @override
  void initState() {
    super.initState();
    _catalogFuture = ref.read(srd2024CreationCatalogProvider.future);
  }

  bool _valid(Creation2024Catalog catalog) => switch (_step) {
    0 => draft.characterClass != null,
    1 => draft.species != null && draft.size != null,
    2 => draft.background != null,
    3 => draft.abilitiesComplete,
    4 => draft.proficienciesComplete,
    5 => draft.choicesComplete(catalog),
    6 => draft.equipmentComplete,
    _ => draft.name.trim().isNotEmpty &&
        (draft.characterClass?.name != 'Wizard' ||
            draft.preparedWizardSpells.length == 4 &&
                draft.wizardSpellbook.toSet().containsAll(draft.preparedWizardSpells)),
  };

  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context)!;
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.creationDiscardTitle),
        content: Text(l10n.creationDiscardContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: neutralDialogTextButtonStyle(dialogContext),
            child: Text(l10n.dialogKeepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: destructiveDialogFilledButtonStyle(dialogContext),
            child: Text(l10n.dialogDiscard),
          ),
        ],
      ),
    );
    if (discard == true && mounted) context.go('/');
  }

  Future<void> _finish(Creation2024Catalog catalog) async {
    if (_saving || !_valid(catalog)) return;
    setState(() => _saving = true);
    try {
      final character = draft.build(
        catalog,
        fallbackName: AppLocalizations.of(context)!.reviewUnnamedHero,
      );
      final saved = await ref.read(characterRepositoryProvider).save(character);
      await ref.read(characterListProvider.notifier).updateSingle(saved);
      unawaited(ref.read(appReviewServiceProvider).recordMilestoneAndMaybeRequest(
        milestone: ReviewMilestone.characterCreated,
        characterCount: 1,
      ));
      if (mounted) context.go('/');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.featuresLoadError),
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final i18nState = ref.watch(srdI18nForPackProvider(ContentPackId.srd521));
    final titles = [
      l10n.creationStepClass,
      l10n.creation2024Species,
      l10n.creationStepBackground,
      l10n.creationStepAttributes,
      l10n.creationStepSkills,
      l10n.featureChoicesTitle,
      l10n.reviewStartingEquipment,
      l10n.creationStepReview,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_step]),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.creationTooltipCancel,
          onPressed: _cancel,
        ),
      ),
      body: FutureBuilder<Creation2024Catalog>(
        future: _catalogFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text(l10n.featuresLoadError));
          }
          if (i18nState.hasError) {
            return Center(child: Text(l10n.featuresLoadError));
          }
          final i18n = i18nState.valueOrNull;
          if (i18n == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final catalog = snapshot.data!;
          return Column(children: [
            StepIndicator(totalSteps: titles.length, currentStep: _step),
            Expanded(child: _body(catalog, i18n, l10n)),
          ]);
        },
      ),
      bottomNavigationBar: FutureBuilder<Creation2024Catalog>(
        future: _catalogFuture,
        builder: (context, snapshot) {
          final catalog = snapshot.data;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                if (_step > 0)
                  OutlinedButton(
                    onPressed: _saving ? null : () => setState(() => _step--),
                    child: Text(l10n.creationBack),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: catalog == null || _saving || !_valid(catalog)
                      ? null
                      : _step == 7
                          ? () => _finish(catalog)
                          : () => setState(() {
                              if (_step == 4) draft.reconcileChoices(catalog);
                              _step++;
                            }),
                  child: Text(_step == 7 ? l10n.creationCreateCharacter : l10n.dialogContinue),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _body(Creation2024Catalog catalog, SrdI18nService i18n, AppLocalizations l10n) {
    return switch (_step) {
      0 => _classStep(catalog, i18n, l10n),
      1 => _speciesStep(catalog, i18n, l10n),
      2 => _backgroundStep(catalog, i18n, l10n),
      3 => _attributesStep(l10n),
      4 => _proficienciesStep(catalog, i18n, l10n),
      5 => _choicesStep(catalog, i18n),
      6 => _equipmentStep(catalog, i18n, l10n),
      _ => _reviewStep(i18n, l10n),
    };
  }

  Widget _classStep(Creation2024Catalog catalog, SrdI18nService i18n, AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: catalog.classes.length,
      itemBuilder: (context, index) {
        final cls = catalog.classes[index];
        return Card(
          child: ListTile(
            selected: draft.characterClass?.name == cls.name,
            title: Text(i18n.className(cls.name)),
            subtitle: Text('${l10n.reviewRowHitDie}: d${cls.hitDie}'),
            trailing: draft.characterClass?.name == cls.name ? const Icon(Icons.check_circle) : null,
            onTap: () {
              if (draft.characterClass?.name != cls.name) {
                setState(() => draft.selectClass(cls));
              }
            },
          ),
        );
      },
    );
  }

  Widget _speciesStep(Creation2024Catalog catalog, SrdI18nService i18n, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final species in catalog.species)
          Card(
            child: Column(children: [
              ListTile(
                selected: draft.species?.name == species.name,
                title: Text(i18n.raceName(species.name)),
                subtitle: Text('${l10n.reviewRowSpeed}: ${formatDistance(species.speed, ref.watch(unitSystemProvider))}'),
                trailing: draft.species?.name == species.name ? const Icon(Icons.check_circle) : null,
                onTap: () {
                  if (draft.species?.name != species.name) {
                    setState(() => draft.selectSpecies(species));
                  }
                },
              ),
              if (draft.species?.name == species.name && species.sizes.length > 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('size:${species.name}'),
                    initialValue: draft.size,
                    decoration: InputDecoration(labelText: l10n.creation2024Size),
                    items: [
                      for (final size in species.sizes)
                        DropdownMenuItem(
                          value: size,
                          child: Text(size == 'Small'
                              ? l10n.creation2024SizeSmall
                              : l10n.creation2024SizeMedium),
                        ),
                    ],
                    onChanged: (value) => setState(() => draft.size = value),
                  ),
                ),
            ]),
          ),
      ],
    );
  }

  Widget _backgroundStep(Creation2024Catalog catalog, SrdI18nService i18n, AppLocalizations l10n) {
    final custom = draft.background?.isCustom == true ? draft.background : null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            selected: custom != null,
            leading: const Icon(Icons.edit_note_outlined),
            title: Text(custom?.name ?? l10n.customBackgroundTitle),
            subtitle: Text(
              custom == null
                  ? l10n.customBackgroundSubtitle
                  : '${l10n.creation2024OriginFeat}: ${i18n.featName(custom.featName) ?? custom.featName}',
            ),
            trailing: Icon(custom != null ? Icons.check_circle : Icons.chevron_right),
            onTap: () async {
              final result = await openCustomBackground2024Page(
                context,
                catalog: catalog,
                i18n: i18n,
                initial: custom,
              );
              if (result == null || !mounted) return;
              setState(() {
                draft.selectBackground(result);
                _splitBonus = true;
              });
            },
          ),
        ),
        for (final bg in catalog.backgrounds)
          Card(
            child: ListTile(
              selected: custom == null && draft.background?.name == bg.name,
              title: Text(i18n.backgroundName(bg.name)),
              subtitle: Text('${l10n.creation2024OriginFeat}: ${i18n.featName(bg.featName) ?? bg.featName}'),
              trailing: custom == null && draft.background?.name == bg.name ? const Icon(Icons.check_circle) : null,
              onTap: () {
                if (custom != null || draft.background?.name != bg.name) {
                  setState(() {
                    draft.selectBackground(bg);
                    _splitBonus = true;
                  });
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _attributesStep(AppLocalizations l10n) {
    final bg = draft.background!;
    const pointCosts = <int, int>{8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9};
    final spent = draft.baseAbilities.values.fold<int>(
      0, (sum, score) => sum + (pointCosts[score] ?? 0),
    );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.stepChooseMethod, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<Creation2024AbilityMethod>(
          segments: [
            ButtonSegment(value: Creation2024AbilityMethod.standardArray, label: Text(l10n.stepStandardArray)),
            ButtonSegment(value: Creation2024AbilityMethod.pointBuy, label: Text(l10n.stepPointBuy)),
            ButtonSegment(value: Creation2024AbilityMethod.rolledDice, label: Text(l10n.stepRoll4d6)),
          ],
          selected: {draft.abilityMethod},
          onSelectionChanged: (selected) => setState(() {
            draft.abilityMethod = selected.first;
            draft.baseAbilities.clear();
            draft.assignedRolls.clear();
            draft.rolledScores.clear();
            if (draft.abilityMethod == Creation2024AbilityMethod.pointBuy) {
              for (final ability in creation2024Abilities) {
                draft.baseAbilities[ability] = 8;
              }
            }
          }),
        ),
        const SizedBox(height: 12),
        if (draft.abilityMethod == Creation2024AbilityMethod.standardArray) ...[
          Text(l10n.creation2024StandardArray),
          const SizedBox(height: 8),
          for (final ability in creation2024Abilities)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DropdownButtonFormField<int>(
                key: ValueKey('base:$ability'),
                initialValue: draft.baseAbilities[ability],
                decoration: InputDecoration(labelText: abilityName(l10n, ability)),
                items: [
                  for (final score in const [15, 14, 13, 12, 10, 8])
                    if (!draft.baseAbilities.values.contains(score) || draft.baseAbilities[ability] == score)
                      DropdownMenuItem(value: score, child: Text('$score')),
                ],
                onChanged: (value) => setState(() {
                  if (value == null) {
                    draft.baseAbilities.remove(ability);
                  } else {
                    draft.baseAbilities[ability] = value;
                  }
                }),
              ),
            ),
        ] else if (draft.abilityMethod == Creation2024AbilityMethod.pointBuy) ...[
          Text('${l10n.stepPointsRemaining}${27 - spent} / 27'),
          const SizedBox(height: 8),
          for (final ability in creation2024Abilities)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DropdownButtonFormField<int>(
                key: ValueKey('point:$ability'),
                initialValue: draft.baseAbilities[ability] ?? 8,
                decoration: InputDecoration(labelText: abilityName(l10n, ability)),
                items: [
                  for (final score in pointCosts.keys)
                    if (spent - pointCosts[draft.baseAbilities[ability] ?? 8]! + pointCosts[score]! <= 27)
                      DropdownMenuItem(value: score, child: Text('$score')),
                ],
                onChanged: (value) => setState(() {
                  if (value != null) draft.baseAbilities[ability] = value;
                }),
              ),
            ),
        ] else ...[
          FilledButton.tonalIcon(
            onPressed: () => setState(() {
              final random = Random();
              draft.rolledScores
                ..clear()
                ..addAll(List.generate(6, (_) {
                  final dice = List.generate(4, (_) => random.nextInt(6) + 1)..sort();
                  return dice.skip(1).reduce((a, b) => a + b);
                }));
              draft.rollGeneration++;
              draft.baseAbilities.clear();
              draft.assignedRolls.clear();
            }),
            icon: const Icon(Icons.casino_outlined),
            label: Text(draft.rolledScores.isEmpty ? l10n.stepRollDice : l10n.stepReroll),
          ),
          if (draft.rolledScores.isEmpty) Text(l10n.stepRollHint),
          if (draft.rolledScores.length == 6)
            for (final ability in creation2024Abilities)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DropdownButtonFormField<int>(
                  key: ValueKey('rolled:$ability:${draft.rollGeneration}'),
                  initialValue: draft.assignedRolls[ability],
                  decoration: InputDecoration(labelText: abilityName(l10n, ability)),
                  items: [
                    for (var index = 0; index < 6; index++)
                      if (!draft.assignedRolls.values.contains(index) || draft.assignedRolls[ability] == index)
                        DropdownMenuItem(value: index, child: Text('${draft.rolledScores[index]}')),
                  ],
                  onChanged: (value) => setState(() {
                    if (value == null) {
                      draft.assignedRolls.remove(ability);
                      draft.baseAbilities.remove(ability);
                    } else {
                      draft.assignedRolls[ability] = value;
                      draft.baseAbilities[ability] = draft.rolledScores[value];
                    }
                  }),
                ),
              ),
        ],
        const SizedBox(height: 12),
        Text(l10n.creation2024OriginBonuses, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: true, label: Text(l10n.creation2024BonusTwoOne)),
            ButtonSegment(value: false, label: Text(l10n.creation2024BonusThree)),
          ],
          selected: {_splitBonus},
          onSelectionChanged: (selected) => setState(() {
            _splitBonus = selected.first;
            draft.backgroundBonuses.clear();
            if (!_splitBonus) {
              for (final ability in bg.abilities) {
                draft.backgroundBonuses[ability] = 1;
              }
            }
          }),
        ),
        if (_splitBonus) ...[
          const SizedBox(height: 8),
          for (final bonus in const [2, 1])
            DropdownButtonFormField<String>(
              key: ValueKey('bonus:$bonus:${bg.name}'),
              initialValue: draft.backgroundBonuses.entries.where((entry) => entry.value == bonus).firstOrNull?.key,
              decoration: InputDecoration(labelText: '+$bonus'),
              items: [
                for (final ability in bg.abilities)
                  if (!draft.backgroundBonuses.containsKey(ability) || draft.backgroundBonuses[ability] == bonus)
                    DropdownMenuItem(value: ability, child: Text(abilityName(l10n, ability))),
              ],
              onChanged: (value) => setState(() {
                draft.backgroundBonuses.removeWhere((_, amount) => amount == bonus);
                if (value != null) draft.backgroundBonuses[value] = bonus;
              }),
            ),
        ],
      ],
    );
  }

  Widget _proficienciesStep(Creation2024Catalog catalog, SrdI18nService i18n, AppLocalizations l10n) {
    final cls = draft.characterClass!;
    final bg = draft.background!;
    final allowed = cls.skillChoices.isAny
        ? catalog.skills.map((skill) => skill.name.toLowerCase()).toList()
        : cls.skillChoices.from;
    final languages = catalog.languages.where((entry) =>
        entry.name != 'Common' && entry.category == 'standard').toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.stepChooseSkillsHint(cls.skillChoices.count), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          for (final skill in allowed)
            if (!bg.skills.contains(skill))
              FilterChip(
                label: Text(i18n.skillName(creation2024AbilityName(skill))),
                selected: draft.skills.contains(skill),
                onSelected: (selected) => setState(() {
                  if (selected && draft.skills.length < cls.skillChoices.count) {
                    draft.skills.add(skill);
                  } else if (!selected) {
                    draft.skills.remove(skill);
                  }
                }),
              ),
        ]),
        const SizedBox(height: 20),
        Text(l10n.creation2024Languages, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          for (final language in languages)
            FilterChip(
              label: Text(i18n.languageName(language.name)),
              selected: draft.languages.contains(language.name),
              onSelected: (selected) => setState(() {
                if (selected && draft.languages.length < 2) {
                  draft.languages.add(language.name);
                } else if (!selected) {
                  draft.languages.remove(language.name);
                }
              }),
            ),
        ]),
        if (cls.toolChoice != null) ...[
          const SizedBox(height: 20),
          _toolProficiencyChoices(catalog, i18n,
              '${l10n.creationStepClass} - ${l10n.reviewToolProficiencies}',
              cls.toolChoice!, draft.classTools),
        ],
        if (bg.toolChoice != null) ...[
          const SizedBox(height: 20),
          _toolProficiencyChoices(catalog, i18n,
              '${l10n.creationStepBackground} - ${l10n.reviewToolProficiencies}',
              bg.toolChoice!, draft.backgroundTools),
        ],
      ],
    );
  }

  Widget _toolProficiencyChoices(Creation2024Catalog catalog,
      SrdI18nService i18n,
      String title,
      Creation2024ToolChoice choice, Set<String> selected) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [
        for (final tool in catalog.tools)
          if (choice.categories.contains(tool.category))
            FilterChip(
              label: Text(i18n.toolName(tool.name)),
              selected: selected.contains(tool.name),
              onSelected: (value) => setState(() {
                if (value && selected.length < choice.count) {
                  selected.add(tool.name);
                } else if (!value) {
                  selected.remove(tool.name);
                }
              }),
            ),
      ]),
    ]);
  }

  Widget _choicesStep(Creation2024Catalog catalog, SrdI18nService i18n) {
    draft.reconcileChoices(catalog);
    final requests = draft.requests(catalog);
    final selectedSkills = <String>{...draft.background!.skills, ...draft.skills};
    for (final choice in draft.featureChoices) {
      final request = requests.where((entry) => entry.findIn([choice]) != null).firstOrNull;
      if (request?.requirement.type == 'skill') {
        selectedSkills.addAll(choice.values.map((value) => value.replaceAll('_', ' ')));
      } else if (request?.requirement.type == 'skill_or_tool') {
        selectedSkills.addAll(choice.values
            .where((value) => value.startsWith('skill:'))
            .map((value) => value.substring('skill:'.length).replaceAll('_', ' ')));
      }
    }
    final attrs = draft.finalAbilities;
    final preview = Character(
      id: draft.id,
      name: draft.name.isEmpty ? 'Preview' : draft.name,
      race: draft.species!.name,
      characterClass: draft.characterClass!.name,
      background: draft.background!.name,
      abilityScores: AbilityScores(
        strength: attrs['strength']!, dexterity: attrs['dexterity']!,
        constitution: attrs['constitution']!, intelligence: attrs['intelligence']!,
        wisdom: attrs['wisdom']!, charisma: attrs['charisma']!,
      ),
      hitPoints: const HitPoints(maximum: 1, current: 1),
      skillProficiencies: selectedSkills.toList(),
      languages: ['Common', ...draft.languages],
      rulesetId: RulesetId.dnd2024,
      contentPackId: ContentPackId.srd521,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return FeatureChoiceEditor(
      requests: requests,
      initialChoices: draft.featureChoices,
      catalog: catalog.choices,
      character: preview,
      i18n: i18n,
      skills: catalog.skills,
      tools: catalog.tools,
      spells: catalog.spells,
      languages: catalog.languages,
      weapons: catalog.weapons,
      feats: catalog.feats.where((feat) =>
          feat.name != draft.background?.featName || feat.repeatable).toList(),
      featureLabelBuilder: (request) => switch (request.sourceType) {
        FeatureChoiceSourceType.classFeature =>
          i18n.classFeatureName(request.sourceClass, request.featureName) ?? request.featureName,
        FeatureChoiceSourceType.raceTrait => i18n.raceTraitName(request.featureName),
        FeatureChoiceSourceType.feat => i18n.featName(request.featureName) ?? request.featureName,
        _ => request.featureName,
      },
      onChanged: (choices) => setState(() {
        draft.setChoices(catalog, choices);
        draft.preparedWizardSpells.removeWhere(
          (spell) => !draft.wizardSpellbook.contains(spell),
        );
      }),
    );
  }

  Widget _equipmentStep(Creation2024Catalog catalog, SrdI18nService i18n, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _equipmentOptions(
          title: l10n.creation2024ClassEquipment,
          choices: draft.characterClass!.equipmentChoices,
          selected: draft.classEquipmentId,
          onSelected: (id) => setState(() {
            draft.classEquipmentId = id;
            draft.specificEquipment.removeWhere((key, _) => key.startsWith('class:'));
          }),
          source: 'class', catalog: catalog, i18n: i18n, l10n: l10n,
        ),
        const SizedBox(height: 16),
        _equipmentOptions(
          title: l10n.creation2024BackgroundEquipment,
          choices: draft.background!.equipmentChoices,
          selected: draft.backgroundEquipmentId,
          onSelected: (id) => setState(() {
            draft.backgroundEquipmentId = id;
            draft.specificEquipment.removeWhere((key, _) => key.startsWith('background:'));
          }),
          source: 'background', catalog: catalog, i18n: i18n, l10n: l10n,
        ),
      ],
    );
  }

  Widget _equipmentOptions({required String title, required List<Creation2024Equipment> choices,
    required String? selected, required ValueChanged<String> onSelected,
    required String source, required Creation2024Catalog catalog,
    required SrdI18nService i18n, required AppLocalizations l10n}) {
    final choice = choices.where((entry) => entry.id == selected).firstOrNull;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      RadioGroup<String>(
        groupValue: selected,
        onChanged: (value) { if (value != null) onSelected(value); },
        child: Column(children: [
          for (final option in choices)
            RadioListTile<String>(
              value: option.id,
              title: Text(option.items.isEmpty
                  ? '${option.gp} gp'
                  : option.items.map((item) => '${item.quantity}x ${item.name == null ? l10n.creation2024SpecificTool : i18n.equipmentName(item.name!)}').join(', ')),
              subtitle: option.items.isEmpty ? null : Text('${option.gp} gp'),
            ),
        ]),
      ),
      if (choice != null)
        for (final (index, item) in choice.items.indexed)
          if (item.choiceFrom == null &&
              !(item.selection == 'proficient_tool' && draft.classTools.length == 1) &&
              (item.category != null || item.selection != null))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: DropdownButtonFormField<String>(
                key: ValueKey('tool:$source:$index:${choice.id}'),
                initialValue: draft.specificEquipment['$source:$index'],
                decoration: InputDecoration(labelText: l10n.creation2024SpecificTool),
                items: [
                  for (final tool in catalog.tools)
                    if (item.selection == 'proficient_tool' ||
                        item.category == tool.category ||
                        item.name == 'Gaming Set' && tool.category == 'gaming_sets')
                      DropdownMenuItem(value: tool.name, child: Text(i18n.toolName(tool.name))),
                ],
                onChanged: (value) => setState(() {
                  if (value == null) {
                    draft.specificEquipment.remove('$source:$index');
                  } else {
                    draft.specificEquipment['$source:$index'] = value;
                  }
                }),
              ),
            ),
    ]);
  }

  Widget _reviewStep(SrdI18nService i18n, AppLocalizations l10n) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      if (draft.characterClass?.name == 'Wizard') ...[
        Text(l10n.creation2024PrepareSpells, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          for (final spell in draft.wizardSpellbook)
            FilterChip(
              label: Text(i18n.spellName(spell)),
              selected: draft.preparedWizardSpells.contains(spell),
              onSelected: (selected) => setState(() {
                if (selected && draft.preparedWizardSpells.length < 4) {
                  draft.preparedWizardSpells.add(spell);
                } else if (!selected) {
                  draft.preparedWizardSpells.remove(spell);
                }
              }),
            ),
        ]),
        const SizedBox(height: 20),
      ],
      TextFormField(
        initialValue: draft.name,
        decoration: InputDecoration(labelText: l10n.creationStepName),
        textCapitalization: TextCapitalization.words,
        onChanged: (value) => setState(() => draft.name = value),
      ),
      const SizedBox(height: 12),
      TextFormField(
        initialValue: draft.playerName,
        decoration: InputDecoration(labelText: l10n.reviewRowPlayer),
        onChanged: (value) => draft.playerName = value,
      ),
      const SizedBox(height: 20),
      ListTile(title: Text(l10n.creationStepClass), subtitle: Text(i18n.className(draft.characterClass!.name))),
      ListTile(
        title: Text(l10n.creation2024Species),
        subtitle: Text('${i18n.raceName(draft.species!.name)} - '
            '${draft.size == 'Small' ? l10n.creation2024SizeSmall : l10n.creation2024SizeMedium}'),
      ),
      ListTile(title: Text(l10n.creationStepBackground), subtitle: Text(i18n.backgroundName(draft.background!.name))),
      ListTile(title: Text(l10n.creation2024OriginFeat), subtitle: Text(i18n.featName(draft.background!.featName) ?? draft.background!.featName)),
      for (final ability in creation2024Abilities)
        ListTile(
          title: Text(abilityName(l10n, ability)),
          subtitle: Text('${draft.baseAbilities[ability]} + ${draft.backgroundBonuses[ability] ?? 0}'),
          trailing: Text('${draft.finalAbilities[ability]}'),
        ),
      const Divider(),
      ListTile(
        title: Text(l10n.creationStepSkills),
        subtitle: Text([
          ...draft.background!.skills,
          ...draft.skills,
        ].map((skill) => i18n.skillName(creation2024AbilityName(skill))).join(', ')),
      ),
      ListTile(
        title: Text(l10n.reviewRowLanguages),
        subtitle: Text(['Common', ...draft.languages]
            .map(i18n.languageName).join(', ')),
      ),
      ListTile(
        title: Text(l10n.reviewToolProficiencies),
        subtitle: Text([
          ...draft.background!.tools,
          ...draft.characterClass!.toolProficiencies,
          ...draft.classTools,
          ...draft.backgroundTools,
        ].map(i18n.toolName).join(', ')),
      ),
      if (draft.featureChoices.any((choice) =>
          choice.choiceId == 'cantrips' ||
          choice.choiceId == 'prepared_spells' ||
          choice.choiceId == 'spell'))
        ListTile(
          title: Text(l10n.detailTabSpells),
          subtitle: Text(draft.featureChoices
              .where((choice) =>
                  choice.choiceId == 'cantrips' ||
                  choice.choiceId == 'prepared_spells' ||
                  choice.choiceId == 'spell')
              .expand((choice) => choice.values)
              .map(i18n.spellName)
              .join(', ')),
        ),
      ListTile(
        title: Text(l10n.reviewStartingEquipment),
        subtitle: Text([
          _equipmentSummary(
            draft.characterClass!.equipmentChoices.firstWhere(
                (entry) => entry.id == draft.classEquipmentId),
            'class', i18n),
          _equipmentSummary(
            draft.background!.equipmentChoices.firstWhere(
                (entry) => entry.id == draft.backgroundEquipmentId),
            'background', i18n),
        ].join(' / ')),
      ),
    ]);
  }

  String _equipmentSummary(Creation2024Equipment option, String source,
      SrdI18nService i18n) {
    final items = <String>[];
    for (final (index, item) in option.items.indexed) {
      final name = item.choiceFrom == 'toolProficiencyChoices'
          ? draft.backgroundTools.firstOrNull
          : item.selection == 'proficient_tool' && draft.classTools.length == 1
              ? draft.classTools.first
              : draft.specificEquipment['$source:$index'] ?? item.name;
      if (name != null) {
        items.add('${item.quantity}x ${i18n.equipmentName(name)}');
      }
    }
    if (option.gp > 0) items.add('${option.gp} gp');
    return items.join(', ');
  }
}
