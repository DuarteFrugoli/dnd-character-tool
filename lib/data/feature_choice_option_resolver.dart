import 'package:collection/collection.dart';

import 'datasources/srd/srd_i18n_service.dart';
import 'datasources/srd/srd_models.dart';
import 'feature_choice_engine.dart';
import 'models/models.dart';

class FeatureChoiceOptionResolver {
  FeatureChoiceOptionResolver({
    required this.request,
    required this.catalog,
    required this.i18n,
    required this.skills,
    required this.tools,
    required this.spells,
    required this.languages,
    required this.weapons,
    this.character,
    this.relatedRequests = const [],
    this.choices = const [],
  });

  final FeatureChoiceRequest request;
  final SrdFeatureChoiceCatalog catalog;
  final SrdI18nService i18n;
  final List<SrdSkill> skills;
  final List<SrdTool> tools;
  final List<SrdSpell> spells;
  final List<SrdLanguage> languages;
  final List<SrdWeapon> weapons;
  final Character? character;
  final List<FeatureChoiceRequest> relatedRequests;
  final List<CharacterFeatureChoice> choices;

  late final List<SrdFeatureChoiceOption> options = _resolveOptions();
  late final Map<String, SrdFeatureChoiceOption> _optionsById = {
    for (final option in options) option.id: option,
  };

  SrdFeatureChoiceOption? optionFor(String value) => _optionsById[value];

  String? labelFor(String value) => optionFor(value)?.name;

  String? descriptionFor(String value) => optionFor(value)?.description;

  List<SrdFeatureChoiceOption> _resolveOptions() {
    final req = request.requirement;
    if (req.options.isNotEmpty) return _featureOptions(req.options);
    if (req.optionsSource != null) {
      return _featureOptions(
        catalog.optionSources[req.optionsSource!] ?? const [],
        optionsSource: req.optionsSource,
      );
    }

    switch (req.type) {
      case 'skill':
        return _skillOptions();
      case 'skill_expertise':
        return _skillOptions(onlyProficient: true);
      case 'skill_or_tool':
        return [
          ..._skillOptions(prefix: true),
          ..._toolOptions(prefix: true),
        ];
      case 'skill_or_tool_expertise':
        return [
          ..._skillOptions(onlyProficient: true, prefix: true),
          if (req.allowThievesTools) ..._thievesTools(prefix: true),
        ];
      case 'tool':
        return _toolOptions();
      case 'language':
        return languages
            .map(
              (language) => SrdFeatureChoiceOption(
                id: idFromName(language.name),
                name: i18n.languageName(language.name),
              ),
            )
            .toList();
      case 'cantrip':
      case 'spell':
        return _spellOptions();
      case 'weapon':
        return weapons
            .map(
              (weapon) => SrdFeatureChoiceOption(
                id: idFromName(weapon.name),
                name: i18n.equipmentName(weapon.name),
                description: weapon.category,
              ),
            )
            .toList();
      default:
        return const [];
    }
  }

  List<SrdFeatureChoiceOption> _featureOptions(
    Iterable<SrdFeatureChoiceOption> options, {
    String? optionsSource,
  }) {
    return options
        .map(
          (option) => SrdFeatureChoiceOption(
            id: option.id,
            name: i18n.featureChoiceOptionName(
                  sourceType: request.sourceType,
                  sourceClass: request.sourceClass,
                  sourceSubclass: request.sourceSubclass,
                  sourceName: request.sourceName,
                  featureName: request.featureName,
                  choiceId: request.choiceId,
                  optionId: option.id,
                  optionsSource: optionsSource,
                ) ??
                option.name,
            description: i18n.featureChoiceOptionDescription(
                  sourceType: request.sourceType,
                  sourceClass: request.sourceClass,
                  sourceSubclass: request.sourceSubclass,
                  sourceName: request.sourceName,
                  featureName: request.featureName,
                  choiceId: request.choiceId,
                  optionId: option.id,
                  optionsSource: optionsSource,
                ) ??
                option.description,
          ),
        )
        .toList();
  }

  List<SrdFeatureChoiceOption> _skillOptions({
    bool onlyProficient = false,
    bool prefix = false,
  }) {
    final proficiencies = (character?.skillProficiencies ?? const <String>[])
        .map((skill) => skill.toLowerCase())
        .toSet();
    final skillList = onlyProficient && proficiencies.isNotEmpty
        ? skills.where((skill) => proficiencies.contains(skill.name.toLowerCase()))
        : skills;
    return skillList
        .map(
          (skill) => SrdFeatureChoiceOption(
            id: prefix ? 'skill:${idFromName(skill.name)}' : idFromName(skill.name),
            name: i18n.skillName(skill.name),
            description: skill.ability.toUpperCase(),
          ),
        )
        .toList();
  }

  List<SrdFeatureChoiceOption> _toolOptions({bool prefix = false}) {
    final mapped = tools
        .map(
          (tool) => SrdFeatureChoiceOption(
            id: prefix ? 'tool:${idFromName(tool.name)}' : idFromName(tool.name),
            name: i18n.toolName(tool.name),
            description: tool.category,
          ),
        )
        .toList();
    if (!request.requirement.allowThievesTools) return mapped;

    final hasThievesTools = mapped.any(
      (option) => option.id == (prefix ? 'tool:thieves_tools' : 'thieves_tools'),
    );
    if (hasThievesTools) return mapped;
    return [...mapped, ..._thievesTools(prefix: prefix)];
  }

  List<SrdFeatureChoiceOption> _thievesTools({required bool prefix}) {
    return [
      SrdFeatureChoiceOption(
        id: prefix ? 'tool:thieves_tools' : 'thieves_tools',
        name: i18n.toolName("Thieves' tools"),
        description: 'other_tools',
      ),
    ];
  }

  List<SrdFeatureChoiceOption> _spellOptions() {
    final req = request.requirement;
    final spellClass = req.spellClass ?? _selectedChoiceValue(req.spellClassFromChoice);
    if (spellClass == null || spellClass.isEmpty) return const [];
    final anyClass = spellClass == 'any';
    final spellLevel = req.type == 'cantrip' ? 0 : req.spellLevel;
    final minSpellLevel = req.minSpellLevel ?? (req.type == 'spell' ? 1 : 0);
    final maxSpellLevel = req.maxSpellLevelAtLevel(request.level);
    return spells
        .where((spell) =>
            anyClass || spell.classes.contains(spellClass.toLowerCase()))
        .where((spell) {
          if (spellLevel != null) return spell.level == spellLevel;
          if (spell.level < minSpellLevel) return false;
          return maxSpellLevel == null || spell.level <= maxSpellLevel;
        })
        .map(
          (spell) => SrdFeatureChoiceOption(
            id: spell.name,
            name: i18n.spellName(spell.name),
            description: spell.level == 0
                ? i18n.spellSchool(spell.school)
                : '${spell.level} - ${i18n.spellSchool(spell.school)}',
          ),
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  String? _selectedChoiceValue(String? choiceId) {
    if (choiceId == null || choiceId.isEmpty) return null;
    for (final related in relatedRequests) {
      if (related.choiceId != choiceId) continue;
      final values = related.findIn(choices)?.values;
      if (values != null && values.isNotEmpty) return values.first;
    }
    final direct = choices.firstWhereOrNull((choice) => choice.choiceId == choiceId);
    return direct?.values.firstOrNull;
  }

  static String idFromName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9]+"), '_')
        .replaceAll(RegExp(r'_+$'), '')
        .replaceAll(RegExp(r'^_+'), '');
  }
}

String featureChoiceValueLabelForRequest({
  required String value,
  required FeatureChoiceRequest request,
  required SrdFeatureChoiceCatalog catalog,
  required SrdI18nService i18n,
  required List<SrdSkill> skills,
  required List<SrdTool> tools,
  required List<SrdSpell> spells,
  required List<SrdLanguage> languages,
  required List<SrdWeapon> weapons,
  Character? character,
  List<FeatureChoiceRequest> relatedRequests = const [],
  List<CharacterFeatureChoice> choices = const [],
}) {
  final resolver = FeatureChoiceOptionResolver(
    request: request,
    catalog: catalog,
    i18n: i18n,
    skills: skills,
    tools: tools,
    spells: spells,
    languages: languages,
    weapons: weapons,
    character: character,
    relatedRequests: relatedRequests,
    choices: choices,
  );
  return resolver.labelFor(value) ?? value;
}
