import 'package:collection/collection.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../data/datasources/srd/srd_i18n_service.dart';
import '../../../data/datasources/srd/srd_models.dart';
import '../../../data/feature_choice_engine.dart';
import '../../../data/feature_choice_option_resolver.dart';
import '../../../data/models/models.dart';
import 'feature_choice_display_helpers.dart';

typedef FeatureChoiceLabelBuilder =
    String Function(FeatureChoiceRequest request);

class FeatureChoiceEditor extends StatefulWidget {
  const FeatureChoiceEditor({
    super.key,
    required this.requests,
    required this.initialChoices,
    required this.catalog,
    required this.character,
    required this.i18n,
    required this.skills,
    required this.tools,
    required this.spells,
    required this.languages,
    required this.weapons,
    required this.feats,
    required this.onChanged,
    this.featureLabelBuilder,
  });

  final List<FeatureChoiceRequest> requests;
  final List<CharacterFeatureChoice> initialChoices;
  final SrdFeatureChoiceCatalog catalog;
  final Character character;
  final SrdI18nService i18n;
  final List<SrdSkill> skills;
  final List<SrdTool> tools;
  final List<SrdSpell> spells;
  final List<SrdLanguage> languages;
  final List<SrdWeapon> weapons;
  final List<SrdFeat> feats;
  final ValueChanged<List<CharacterFeatureChoice>> onChanged;
  final FeatureChoiceLabelBuilder? featureLabelBuilder;

  @override
  State<FeatureChoiceEditor> createState() => _FeatureChoiceEditorState();
}

class _FeatureChoiceEditorState extends State<FeatureChoiceEditor> {
  late Map<String, List<String>> _values;

  @override
  void initState() {
    super.initState();
    _values = _initialValues();
  }

  @override
  void didUpdateWidget(covariant FeatureChoiceEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.requests != widget.requests ||
        oldWidget.initialChoices != widget.initialChoices) {
      _values = _initialValues();
    }
  }

  Map<String, List<String>> _initialValues() {
    return {
      for (final request in widget.requests)
        request.key: List<String>.from(
          request.findIn(widget.initialChoices)?.values ?? const [],
        ),
    };
  }

  List<CharacterFeatureChoice> get _currentChoices {
    return [
      for (final request in widget.requests)
        request.toChoice(_values[request.key] ?? const []),
    ];
  }

  void _emit() {
    widget.onChanged(_currentChoices);
  }

  void _setSingle(FeatureChoiceRequest request, String value) {
    setState(() {
      _values[request.key] = [value];
    });
    _emit();
  }

  void _toggle(FeatureChoiceRequest request, String value, bool selected) {
    setState(() {
      final current = List<String>.from(_values[request.key] ?? const []);
      if (selected) {
        if (!current.contains(value) &&
            current.length < request.requiredCount) {
          current.add(value);
        }
      } else {
        current.remove(value);
      }
      _values[request.key] = current;
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.requests.isEmpty) return const SizedBox.shrink();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          AppLocalizations.of(context)!.featureChoicesTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        for (final request in widget.requests) _buildRequest(context, request),
      ],
    );
  }

  Widget _buildRequest(BuildContext context, FeatureChoiceRequest request) {
    final l10n = AppLocalizations.of(context)!;
    final values = _values[request.key] ?? const [];
    final options = _optionsFor(request);
    final complete = values.toSet().length >= request.requiredCount;
    final scheme = Theme.of(context).colorScheme;
    final featureLabel =
        widget.featureLabelBuilder?.call(request) ?? request.featureName;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    featureLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Chip(
                  label: Text(
                    l10n.featureChoicesSelectedCount(
                      values.toSet().length,
                      request.requiredCount,
                    ),
                  ),
                  backgroundColor: complete
                      ? scheme.primaryContainer
                      : scheme.errorContainer,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.featureChoicesChooseCount(
                _choiceLabel(context, request.requirement),
                request.requiredCount,
              ),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            if (options.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.featureChoicesChooseDependencyFirst,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              )
            else if (request.requiredCount == 1)
              RadioGroup<String>(
                groupValue: values.firstOrNull,
                onChanged: (value) {
                  if (value != null) _setSingle(request, value);
                },
                child: Column(
                  children: [
                    for (final option in options)
                      _buildRadioOption(context, request, option),
                  ],
                ),
              )
            else
              Column(
                children: [
                  for (final option in options)
                    _buildCheckboxOption(context, request, option, values),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<SrdFeatureChoiceOption> _optionsFor(FeatureChoiceRequest request) {
    return FeatureChoiceOptionResolver(
      request: request,
      catalog: widget.catalog,
      i18n: widget.i18n,
      skills: widget.skills,
      tools: widget.tools,
      spells: widget.spells,
      languages: widget.languages,
      weapons: widget.weapons,
      feats: widget.feats,
      character: widget.character,
      relatedRequests: widget.requests,
      choices: _currentChoices,
    ).options;
  }

  Widget _buildRadioOption(
    BuildContext context,
    FeatureChoiceRequest request,
    SrdFeatureChoiceOption option,
  ) {
    final subtitle = featureChoiceOptionSubtitle(
      context: context,
      request: request,
      option: option,
      i18n: widget.i18n,
    );
    return RadioListTile<String>(
      value: option.id,
      dense: true,
      title: Text(option.name),
      subtitle: subtitle == null ? null : Text(subtitle),
    );
  }

  Widget _buildCheckboxOption(
    BuildContext context,
    FeatureChoiceRequest request,
    SrdFeatureChoiceOption option,
    List<String> values,
  ) {
    final subtitle = featureChoiceOptionSubtitle(
      context: context,
      request: request,
      option: option,
      i18n: widget.i18n,
    );
    return CheckboxListTile(
      value: values.contains(option.id),
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(option.name),
      subtitle: subtitle == null ? null : Text(subtitle),
      onChanged: (checked) {
        _toggle(request, option.id, checked ?? false);
      },
    );
  }

  String _choiceLabel(
    BuildContext context,
    SrdFeatureChoiceRequirement requirement,
  ) {
    final l10n = AppLocalizations.of(context)!;
    switch (requirement.type) {
      case 'ability':
        return l10n.creationStepAttributes.toLowerCase();
      case 'cantrip':
        return l10n.spellCantrip.toLowerCase();
      case 'damageType':
        return l10n.inventoryCustomDamageType.toLowerCase();
      case 'feat':
        return l10n.levelUpFeatOption.toLowerCase();
      case 'language':
        return l10n.labelLanguages.toLowerCase();
      case 'skill':
      case 'skill_expertise':
        return l10n.creationStepSkills.toLowerCase();
      case 'skill_or_tool':
      case 'skill_or_tool_expertise':
        return '${l10n.creationStepSkills.toLowerCase()} / '
            '${l10n.featuresTabTools.toLowerCase()}';
      case 'spell':
        return l10n.detailTabSpells.toLowerCase();
      case 'tool':
        return l10n.featuresTabTools.toLowerCase();
      case 'weapon':
        return l10n.inventoryTypeWeapon.toLowerCase();
      default:
        return l10n.stepOptionsLabel.toLowerCase();
    }
  }
}
