import '../datasources/srd/srd_models.dart';
import '../feature_choice_engine.dart';
import '../feature_choice_option_resolver.dart';
import '../models/models.dart';

/// Catalog lookups the effect rules need, provided by each ruleset so saved
/// names follow that ruleset's conventions.
abstract class ChoiceEffectsData {
  SrdFeatureChoiceCatalog get choices;
  List<SrdSpell> get spells;
  SrdFeat? featNamed(String name);

  /// Skills the named background grants by itself.
  Iterable<String> backgroundSkills(String background);

  String skillName(String id);
  String toolName(String id);
  String languageName(String id);
  String weaponName(String id);

  /// 2014 weapon choices grant proficiency; 2024 weapon choices are
  /// masteries, which grant nothing stored elsewhere.
  bool get weaponChoicesGrantProficiency;
}

/// Applies what feature choices grant: skills, expertise, tools, languages,
/// weapon proficiencies, spells and feats granted by an option target. Values
/// added since `before` are applied and removed values are undone, so level
/// up, reset and later edits share one rule set.
class ChoiceEffects {
  const ChoiceEffects._();

  /// Feature names whose spell choices come from the class table.
  static const classSpellFeatures = {'Spellcasting', 'Pact Magic'};

  /// Synthetic choices saved by creation, level up and reset.
  static const classSkillsFeature = 'Skill Proficiencies';
  static const toolFeature = 'Tool Proficiency';
  static const originLanguagesFeature = 'Languages';

  /// Source id of feats granted by an option, e.g. Lessons of the First Ones.
  static String grantedFeatSource(CharacterFeatureChoice choice, String value) =>
      'option:${choice.sourceClassEntryId ?? choice.sourceClass}:'
      '${ChoiceTargetValue.optionId(value)}';

  static Character apply(
    Character before,
    Character after,
    ChoiceEffectsData data,
  ) {
    final previous = {for (final c in before.featureChoices) _key(c): c};
    final current = {for (final c in after.featureChoices) _key(c): c};
    final applicable = {
      for (final entry in current.entries)
        if (isApplicable(data, entry.value, after.featureChoices)) entry.key,
    };
    final skills = _CaseInsensitiveList(after.skillProficiencies);
    final expertise = _CaseInsensitiveList(after.skillExpertises);
    final features = _CaseInsensitiveList(after.features);
    final languages = _CaseInsensitiveList(after.languages);
    final spells = [...after.spells];
    final extraFeatures = [...after.extraFeatures];
    final spellsByName = {
      for (final spell in data.spells) spell.name.toLowerCase(): spell,
    };

    final added = <(CharacterFeatureChoice, String, String)>[];
    final removed = <(CharacterFeatureChoice, String, String)>[];
    for (final key in {...previous.keys, ...current.keys}) {
      final old = previous[key];
      final now = applicable.contains(key) ? current[key] : null;
      final oldValues = old != null && isApplicable(data, old, before.featureChoices)
          ? old.values.toSet()
          : const <String>{};
      final newValues = now?.values.toSet() ?? const <String>{};
      final choice = now ?? old!;
      final type = effectType(data, choice);
      if (type == null) continue;
      for (final value in newValues.difference(oldValues)) {
        added.add((choice, type, value));
      }
      for (final value in oldValues.difference(newValues)) {
        removed.add((choice, type, value));
      }
    }

    // Grants still held by other choices or by the background stay.
    final keptSkills = _CaseInsensitiveList([
      ...data.backgroundSkills(after.background),
      for (final key in applicable)
        for (final value in current[key]!.values)
          ?_skillOf(data, effectType(data, current[key]!), value),
    ]);

    for (final (choice, type, value) in removed) {
      switch (type) {
        case 'skill':
          final skill = data.skillName(value);
          if (!keptSkills.contains(skill)) skills.remove(skill);
        case 'skill_expertise':
          expertise.remove(data.skillName(value));
        case 'skill_or_tool_expertise' when value.startsWith('skill:'):
          expertise.remove(data.skillName(value.substring(6)));
        case 'skill_or_tool' when value.startsWith('skill:'):
          final skill = data.skillName(value.substring(6));
          if (!keptSkills.contains(skill)) skills.remove(skill);
        case 'skill_or_tool' when value.startsWith('tool:'):
          features.remove(_toolLabel(data, value.substring(5)));
        case 'tool':
          features.remove(_toolLabel(data, value));
        case 'weapon':
          features.remove(_weaponLabel(data, value));
        case 'language':
          languages.remove(data.languageName(value));
        case 'cantrip' || 'spell':
          spells.removeWhere(
            (spell) =>
                spell.name.toLowerCase() == value.toLowerCase() &&
                spell.sourceFeature == choice.featureName &&
                spell.sourceClassEntryId == choice.sourceClassEntryId,
          );
        case 'option':
          final source = grantedFeatSource(choice, value);
          extraFeatures.removeWhere(
            (feature) => feature.sourceClassEntryId == source,
          );
      }
    }

    for (final (choice, type, value) in added) {
      switch (type) {
        case 'skill':
          skills.add(data.skillName(value));
        case 'skill_expertise':
          expertise.add(data.skillName(value));
        case 'skill_or_tool_expertise' when value.startsWith('skill:'):
          expertise.add(data.skillName(value.substring(6)));
        case 'skill_or_tool' when value.startsWith('skill:'):
          skills.add(data.skillName(value.substring(6)));
        case 'skill_or_tool' when value.startsWith('tool:'):
          features.add(_toolLabel(data, value.substring(5)));
        case 'tool':
          features.add(_toolLabel(data, value));
        case 'weapon':
          features.add(_weaponLabel(data, value));
        case 'language':
          languages.add(data.languageName(value));
        case 'cantrip' || 'spell':
          final spell = spellsByName[value.toLowerCase()];
          final spellName = spell?.name ?? value;
          if (spells.any((s) => s.name.toLowerCase() == spellName.toLowerCase())) {
            continue;
          }
          final fromClassTable = classSpellFeatures.contains(choice.featureName);
          spells.add(
            KnownSpell(
              name: spellName,
              level: spell?.level ?? (type == 'cantrip' ? 0 : 1),
              isPrepared: true,
              isAlwaysPrepared: type == 'spell' && !fromClassTable,
              sourceType: choice.sourceType,
              sourceClass: choice.sourceClass.isEmpty ? null : choice.sourceClass,
              sourceSubclass: choice.sourceSubclass,
              sourceFeature: choice.featureName,
              sourceClassEntryId: choice.sourceClassEntryId,
            ),
          );
        case 'option':
          final featName = _grantedFeat(data, choice, value);
          if (featName == null) continue;
          final feat = data.featNamed(featName);
          final source = grantedFeatSource(choice, value);
          if (feat == null ||
              extraFeatures.any((f) => f.sourceClassEntryId == source)) {
            continue;
          }
          extraFeatures.add(
            CharacterExtraFeature(
              sourceClass: 'Feat',
              sourceType: FeatureChoiceSourceType.feat,
              sourceFeature: choice.featureName,
              sourceClassEntryId: source,
              name: feat.name,
              level: after.totalLevel,
              type: 'passive',
              description: feat.description,
            ),
          );
      }
    }

    return after.copyWith(
      featureChoices: [
        for (final entry in current.entries)
          if (applicable.contains(entry.key)) entry.value,
      ],
      skillProficiencies: skills.values,
      skillExpertises: expertise.values,
      features: features.values,
      languages: languages.values,
      spells: spells,
      extraFeatures: extraFeatures,
    );
  }

  /// The effect kind of a saved choice, or null when it grants nothing that
  /// the sheet stores elsewhere (masteries, styles, invocation effects...).
  static String? effectType(ChoiceEffectsData data, CharacterFeatureChoice choice) {
    if (choice.sourceType == FeatureChoiceSourceType.multiclassProficiency) {
      return switch (choice.choiceId) {
        'skills' || 'multiclass_skill' => 'skill',
        'tools' || 'multiclass_musical_instrument' => 'tool',
        _ => null,
      };
    }
    if (choice.featureName == classSkillsFeature) return 'skill';
    if (choice.featureName == toolFeature) return 'tool';
    if (choice.sourceType == FeatureChoiceSourceType.origin &&
        choice.featureName == originLanguagesFeature) {
      return 'language';
    }
    if (classSpellFeatures.contains(choice.featureName)) {
      return switch (choice.choiceId) {
        'cantrips' => 'cantrip',
        'prepared_spells' => 'spell',
        _ => null,
      };
    }
    final requirement = requirementFor(data, choice);
    if (requirement == null) return null;
    return switch (requirement.type) {
      'option' => requirement.optionsSource == null ? null : 'option',
      'weapon' => data.weaponChoicesGrantProficiency ? 'weapon' : null,
      final type => type,
    };
  }

  static SrdFeatureChoiceRequirement? requirementFor(
    ChoiceEffectsData data,
    CharacterFeatureChoice choice,
  ) {
    final definition = switch (choice.sourceType) {
      FeatureChoiceSourceType.classFeature =>
        data.choices.classFeature(choice.sourceClass, choice.featureName),
      FeatureChoiceSourceType.subclassFeature => data.choices.subclassFeature(
        choice.sourceClass,
        choice.sourceSubclass ?? '',
        choice.featureName,
      ),
      FeatureChoiceSourceType.feat => data.choices.feat(choice.featureName),
      FeatureChoiceSourceType.raceTrait =>
        data.choices.raceTrait(choice.featureName),
      _ => null,
    };
    for (final requirement
        in definition?.choices ?? const <SrdFeatureChoiceRequirement>[]) {
      if (requirement.id == choice.choiceId) return requirement;
    }
    return null;
  }

  /// Whether a dependent choice (e.g. Pact of the Tome cantrips) is active:
  /// its parent choice of the same source must include the required option.
  static bool isApplicable(
    ChoiceEffectsData data,
    CharacterFeatureChoice choice,
    List<CharacterFeatureChoice> all,
  ) {
    final requirement = requirementFor(data, choice);
    final parentId = requirement?.whenChoiceId;
    final optionId = requirement?.whenOptionId;
    if (parentId == null || optionId == null) return true;
    return all.any(
      (parent) =>
          parent.matches(
            sourceType: choice.sourceType,
            sourceClass: choice.sourceClass,
            sourceClassEntryId: choice.sourceClassEntryId,
            sourceSubclass: choice.sourceSubclass,
            sourceName: choice.sourceName,
            featureName: choice.featureName,
            choiceId: parentId,
          ) &&
          parent.values.any((value) => ChoiceTargetValue.optionId(value) == optionId),
    );
  }

  /// Feat granted by an option whose target is an origin feat.
  static String? _grantedFeat(
    ChoiceEffectsData data,
    CharacterFeatureChoice choice,
    String value,
  ) {
    final target = ChoiceTargetValue.target(value);
    if (target == null) return null;
    final source = requirementFor(data, choice)?.optionsSource;
    if (source == null) return null;
    final option = data.choices.optionSources[source]
        ?.where((o) => o.id == ChoiceTargetValue.optionId(value))
        .firstOrNull;
    return option?.target == 'origin_feat' ? target : null;
  }

  static String? _skillOf(ChoiceEffectsData data, String? type, String value) =>
      switch (type) {
        'skill' => data.skillName(value),
        'skill_or_tool' when value.startsWith('skill:') =>
          data.skillName(value.substring(6)),
        _ => null,
      };

  static String _toolLabel(ChoiceEffectsData data, String id) =>
      'Tool Proficiency: ${data.toolName(id)}';

  static String _weaponLabel(ChoiceEffectsData data, String id) =>
      'Weapon Proficiency: ${data.weaponName(id)}';

  static String _key(CharacterFeatureChoice choice) =>
      '${choice.sourceType}|${choice.sourceClass}|${choice.sourceClassEntryId ?? ''}|'
      '${choice.sourceSubclass ?? ''}|${choice.sourceName ?? ''}|'
      '${choice.featureName}|${choice.choiceId}';
}

/// Keeps saved spelling while matching names regardless of case, since older
/// sheets mix `perception` and `Perception`.
class _CaseInsensitiveList {
  _CaseInsensitiveList(Iterable<String> values) {
    for (final value in values) {
      add(value);
    }
  }

  final List<String> values = [];

  bool contains(String value) =>
      values.any((existing) => existing.toLowerCase() == value.toLowerCase());

  void add(String value) {
    if (!contains(value)) values.add(value);
  }

  void remove(String value) =>
      values.removeWhere((existing) => existing.toLowerCase() == value.toLowerCase());
}
