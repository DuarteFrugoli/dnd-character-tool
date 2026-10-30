import 'package:collection/collection.dart';

import 'datasources/srd/srd_i18n_service.dart';
import 'datasources/srd/srd_models.dart';
import 'datasources/srd/srd_monster.dart';
import 'feature_choice_engine.dart';
import 'models/models.dart';
import 'rulesets/ruleset_ids.dart';
import 'rulesets/wild_shape_rules.dart';

/// Values of options that need a target are saved as `option@target`, e.g.
/// `agonizing_blast@Eldritch Blast`, so each instance is a distinct value.
class ChoiceTargetValue {
  const ChoiceTargetValue._();

  static const separator = '@';

  static String optionId(String value) => value.split(separator).first;

  static String? target(String value) {
    final index = value.indexOf(separator);
    return index < 0 ? null : value.substring(index + 1);
  }

  static String withTarget(String optionId, String target) =>
      '$optionId$separator$target';
}

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
    required this.feats,
    this.monsters = const [],
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
  final List<SrdFeat> feats;

  /// Stat blocks for `beast_form` choices such as 2024 Wild Shape forms.
  final List<SrdMonster> monsters;
  final Character? character;
  final List<FeatureChoiceRequest> relatedRequests;
  final List<CharacterFeatureChoice> choices;

  late final List<SrdFeatureChoiceOption> options = _resolveOptions();
  late final Map<String, SrdFeatureChoiceOption> _optionsById = {
    for (final option in options) option.id: option,
  };

  SrdFeatureChoiceOption? optionFor(String value) =>
      _optionsById[value] ?? _optionsById[ChoiceTargetValue.optionId(value)];

  String? labelFor(String value) {
    final name = optionFor(value)?.name;
    final target = ChoiceTargetValue.target(value);
    if (name == null || target == null) return name;
    return '$name (${targetLabel(optionFor(value)!.target, target)})';
  }

  String targetLabel(String? target, String value) => switch (target) {
    'origin_feat' => i18n.featName(value) ?? value,
    _ => i18n.spellName(value),
  };

  /// Valid targets of an option, e.g. known Warlock damage cantrips for
  /// Agonizing Blast or Origin feats for Lessons of the First Ones.
  List<SrdFeatureChoiceOption> targetOptions(String target) {
    if (target == 'origin_feat') {
      final taken = {
        for (final feature in character?.extraFeatures ?? const <CharacterExtraFeature>[])
          feature.name,
      };
      return [
        for (final feat in feats)
          if (feat.category == 'origin' && (feat.repeatable || !taken.contains(feat.name)))
            SrdFeatureChoiceOption(
              id: feat.name,
              name: i18n.featName(feat.name) ?? feat.name,
              description: i18n.featDescription(feat.name) ?? feat.description,
            ),
      ];
    }
    final byName = {for (final spell in spells) spell.name.toLowerCase(): spell};
    final cantrips = [
      for (final known in character?.spells ?? const <KnownSpell>[])
        if (known.level == 0 && known.sourceClass?.toLowerCase() == 'warlock')
          ?byName[known.name.toLowerCase()],
    ];
    bool matches(SrdSpell spell) => switch (target) {
      'warlock_damage_cantrip' => spell.damageTypes.isNotEmpty,
      'warlock_ranged_damage_cantrip' =>
        spell.damageTypes.isNotEmpty && (spell.rangeInFeet ?? 0) >= 10,
      'warlock_attack_cantrip' => spell.attackType != null,
      _ => false,
    };
    return [
      for (final spell in cantrips)
        if (matches(spell))
          SrdFeatureChoiceOption(id: spell.name, name: i18n.spellName(spell.name)),
    ];
  }

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
      case 'feat':
        return _featOptions();
      case 'skill':
        return _skillOptions();
      case 'skill_expertise':
        return _skillOptions(onlyProficient: true);
      case 'skill_or_tool':
        return [..._skillOptions(prefix: true), ..._toolOptions(prefix: true)];
      case 'skill_or_tool_expertise':
        return [
          ..._skillOptions(onlyProficient: true, prefix: true),
          if (req.allowThievesTools) ..._thievesTools(prefix: true),
        ];
      case 'tool':
        return _toolOptions();
      case 'language':
        final known = character?.languages.map((name) => name.toLowerCase()).toSet() ?? const <String>{};
        final selected = request.findIn(choices)?.values.toSet() ?? const <String>{};
        return languages
            .where((language) =>
                !known.contains(language.name.toLowerCase()) ||
                selected.contains(idFromName(language.name)))
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
      case 'beast_form':
        return _beastFormOptions();
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

  /// Beasts the Beast Shapes table allows at the request's Druid level. The
  /// description carries the challenge rating for the subtitle.
  List<SrdFeatureChoiceOption> _beastFormOptions() {
    final rules = WildShapeRules.forRuleset(character?.rulesetId ?? RulesetId.dnd2024);
    final limits = rules.limitsAt(request.level);
    if (limits == null) return const [];
    return [
      for (final monster in monsters)
        if (limits.allows(monster))
          SrdFeatureChoiceOption(
            id: monster.id,
            name: i18n.monsterName(monster.name),
            description: monster.challengeRating,
          ),
    ];
  }

  List<SrdFeatureChoiceOption> _featureOptions(
    Iterable<SrdFeatureChoiceOption> options, {
    String? optionsSource,
  }) {
    final proficiencyNames = character?.skillProficiencies
        .map((name) => name.toLowerCase())
        .toSet();
    final selectedIds = request.findIn(choices)?.values.toSet() ?? const <String>{};
    return options
        .where((option) {
          if (!selectedIds.contains(option.id)) {
            if (option.minClassLevel != null && request.level < option.minClassLevel!) {
              return false;
            }
            if (!selectedIds.containsAll(option.requiresInvocations)) {
              return false;
            }
          }
          if (proficiencyNames == null || selectedIds.contains(option.id)) {
            return true;
          }
          final skill = option.name.toLowerCase();
          if (request.requirement.type == 'skill') {
            return !proficiencyNames.contains(skill);
          }
          if (request.requirement.type == 'skill_expertise') {
            return proficiencyNames.contains(skill);
          }
          return true;
        })
        .map(
          (option) => SrdFeatureChoiceOption(
            id: option.id,
            name: _explicitOptionName(option, optionsSource),
            description:
                i18n.featureChoiceOptionDescription(
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
            minClassLevel: option.minClassLevel,
            requiresInvocations: option.requiresInvocations,
            target: option.target,
            repeatableWithDifferentTarget: option.repeatableWithDifferentTarget,
          ),
        )
        .toList();
  }

  String _explicitOptionName(
    SrdFeatureChoiceOption option,
    String? optionsSource,
  ) {
    final translated = i18n.featureChoiceOptionName(
      sourceType: request.sourceType,
      sourceClass: request.sourceClass,
      sourceSubclass: request.sourceSubclass,
      sourceName: request.sourceName,
      featureName: request.featureName,
      choiceId: request.choiceId,
      optionId: option.id,
      optionsSource: optionsSource,
    );
    if (translated != null) return translated;
    return switch (request.requirement.type) {
      'skill' || 'skill_expertise' => i18n.skillName(option.name),
      'tool' => i18n.toolName(option.name),
      'weapon' => i18n.equipmentName(option.name),
      _ => option.name,
    };
  }

  List<SrdFeatureChoiceOption> _skillOptions({
    bool onlyProficient = false,
    bool prefix = false,
  }) {
    final proficiencies = (character?.skillProficiencies ?? const <String>[])
        .map((skill) => skill.toLowerCase())
        .toSet();
    final skillList = onlyProficient && proficiencies.isNotEmpty
        ? skills.where(
            (skill) => proficiencies.contains(skill.name.toLowerCase()),
          )
        : skills.where((skill) {
            final id = prefix
                ? 'skill:${idFromName(skill.name)}'
                : idFromName(skill.name);
            return !proficiencies.contains(skill.name.toLowerCase()) ||
                (request.findIn(choices)?.values.contains(id) ?? false);
          });
    return skillList
        .map(
          (skill) => SrdFeatureChoiceOption(
            id: prefix
                ? 'skill:${idFromName(skill.name)}'
                : idFromName(skill.name),
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
            id: prefix
                ? 'tool:${idFromName(tool.name)}'
                : idFromName(tool.name),
            name: i18n.toolName(tool.name),
            description: tool.category,
          ),
        )
        .toList();
    if (!request.requirement.allowThievesTools) return mapped;

    final hasThievesTools = mapped.any(
      (option) =>
          option.id == (prefix ? 'tool:thieves_tools' : 'thieves_tools'),
    );
    if (hasThievesTools) return mapped;
    return [...mapped, ..._thievesTools(prefix: prefix)];
  }

  List<SrdFeatureChoiceOption> _featOptions() {
    return feats
        .where((feat) =>
            request.requirement.featCategory == null ||
            feat.category == request.requirement.featCategory)
        .map(
          (feat) => SrdFeatureChoiceOption(
            id: feat.name,
            name: i18n.featName(feat.name) ?? feat.name,
            description: i18n.featDescription(feat.name) ?? feat.description,
          ),
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
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
    final spellClass =
        req.spellClass ?? _selectedChoiceValue(req.spellClassFromChoice);
    if ((spellClass == null || spellClass.isEmpty) && req.spellClasses.isEmpty) {
      return const [];
    }
    final anyClass = spellClass == 'any';
    final spellLevel = req.type == 'cantrip' ? 0 : req.spellLevel;
    final minSpellLevel = req.minSpellLevel ?? (req.type == 'spell' ? 1 : 0);
    final maxSpellLevel = req.maxSpellLevelAtLevel(request.level);
    return spells
        .where(
          (spell) =>
              anyClass ||
              (spellClass != null && spell.classes.contains(spellClass.toLowerCase())) ||
              req.spellClasses.any((name) => spell.classes.contains(name.toLowerCase())),
        )
        .where((spell) => !req.ritualOnly || spell.ritual)
        .where((spell) => !req.excludePreparedSpells ||
            !(character?.spells.any((known) =>
                known.name == spell.name &&
                (known.isPrepared || known.isAlwaysPrepared)) ?? false))
        .where((spell) => req.spellSchool == null ||
            spell.school.toLowerCase() == req.spellSchool!.toLowerCase())
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
      if (related.choiceId != choiceId ||
          related.sourceType != request.sourceType ||
          related.sourceClass != request.sourceClass ||
          related.sourceClassEntryId != request.sourceClassEntryId ||
          related.sourceSubclass != request.sourceSubclass ||
          related.sourceName != request.sourceName ||
          related.featureName != request.featureName) {
        continue;
      }
      final values = related.findIn(choices)?.values;
      if (values != null && values.isNotEmpty) return values.first;
    }
    final direct = choices.firstWhereOrNull((choice) =>
        choice.choiceId == choiceId &&
        choice.sourceType == request.sourceType &&
        choice.sourceClass == request.sourceClass &&
        choice.sourceClassEntryId == request.sourceClassEntryId &&
        choice.sourceSubclass == request.sourceSubclass &&
        choice.sourceName == request.sourceName &&
        choice.featureName == request.featureName);
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
  List<SrdFeat> feats = const [],
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
    feats: feats,
    character: character,
    relatedRequests: relatedRequests,
    choices: choices,
  );
  return resolver.labelFor(value) ?? value;
}
