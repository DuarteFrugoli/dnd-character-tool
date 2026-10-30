import 'dart:math' as math;

import '../constants/armor_class.dart';
import '../datasources/srd/srd_2024_creation_catalog.dart';
import '../datasources/srd/srd_data_source.dart';
import '../datasources/srd/srd_models.dart';
import '../datasources/srd/srd_monster.dart';
import '../dice/dice.dart';
import '../feature_choice_engine.dart';
import '../feature_choice_option_resolver.dart';
import '../models/models.dart';
import '../rulesets/ruleset_ids.dart';
import '../rulesets/srd_content_pack.dart';
import '../rulesets/wild_shape_rules.dart';
import 'choice_effects.dart';

/// SRD 5.2.1 content the 2024 progression rules read.
class Rules2024Data implements ChoiceEffectsData {
  const Rules2024Data({
    required this.classes,
    required this.subclasses,
    required this.subclassFeatures,
    required this.feats,
    required this.choices,
    required this.spells,
    required this.skills,
    required this.tools,
    required this.languages,
    required this.speciesTraits,
    this.backgrounds = const [],
    this.monsters = const [],
  });

  final List<Creation2024Class> classes;
  final Map<String, List<Creation2024Subclass>> subclasses;
  final Map<String, Map<String, List<SrdClassFeature>>> subclassFeatures;
  final List<SrdFeat> feats;
  @override
  final SrdFeatureChoiceCatalog choices;
  @override
  final List<SrdSpell> spells;
  final List<SrdSkill> skills;
  final List<SrdTool> tools;
  final List<SrdLanguage> languages;
  final List<Creation2024Background> backgrounds;

  /// Stat blocks for Wild Shape forms.
  final List<SrdMonster> monsters;

  /// Trait names of the character's species.
  final List<String> speciesTraits;

  /// Loads the SRD 5.2.1 catalogs; species traits are added per sheet.
  static Future<Rules2024Data> load({SrdDataSource? source}) async {
    final srd = source ?? SrdDataSource.forPack(SrdContentPackRegistry.srd521);
    if (srd.pack.id != SrdContentPackRegistry.srd521.id) {
      throw StateError('2024 rules require SRD 5.2.1.');
    }
    return Rules2024Data(
      classes: await Creation2024Catalog.loadClasses(),
      subclasses: await Creation2024Catalog.loadSubclasses(),
      subclassFeatures: await srd.getAllSubclassFeatures(),
      feats: await srd.getFeats(),
      choices: await srd.getFeatureChoiceCatalog(),
      spells: await srd.getSpells(),
      skills: await srd.getSkills(),
      tools: await srd.getTools(),
      languages: await srd.getLanguages(),
      backgrounds: await Creation2024Catalog.loadBackgrounds(),
      monsters: await srd.getMonsters(),
      speciesTraits: const [],
    );
  }

  Rules2024Data withSpeciesTraits(List<String> traits) => Rules2024Data(
    classes: classes,
    subclasses: subclasses,
    subclassFeatures: subclassFeatures,
    feats: feats,
    choices: choices,
    spells: spells,
    skills: skills,
    tools: tools,
    languages: languages,
    backgrounds: backgrounds,
    monsters: monsters,
    speciesTraits: traits,
  );

  Creation2024Class classNamed(String name) {
    for (final cls in classes) {
      if (cls.name == name) return cls;
    }
    throw ArgumentError('Unknown 2024 class: $name');
  }

  Creation2024Subclass? subclassNamed(String className, String? name) {
    if (name == null) return null;
    for (final subclass in subclasses[className] ?? const <Creation2024Subclass>[]) {
      if (subclass.name == name) return subclass;
    }
    return null;
  }

  Creation2024Background? backgroundNamed(String name) {
    for (final background in backgrounds) {
      if (background.name == name) return background;
    }
    return null;
  }

  @override
  SrdFeat? featNamed(String name) {
    for (final feat in feats) {
      if (feat.name == name) return feat;
    }
    return null;
  }

  @override
  Iterable<String> backgroundSkills(String background) =>
      backgroundNamed(background)?.skills ?? const [];

  /// 2024 sheets save skills in lowercase, as the class and background lists.
  @override
  String skillName(String id) => id.replaceAll('_', ' ');

  @override
  String toolName(String id) => _nameById(tools.map((t) => t.name), id);

  @override
  String languageName(String id) => _nameById(languages.map((l) => l.name), id);

  @override
  String weaponName(String id) => id.replaceAll('_', ' ');

  @override
  bool get weaponChoicesGrantProficiency => false;

  static String _nameById(Iterable<String> names, String id) {
    for (final name in names) {
      if (FeatureChoiceOptionResolver.idFromName(name) == id) return name;
    }
    return id.replaceAll('_', ' ');
  }

  SrdSpell? spellNamed(String name) {
    final lower = name.toLowerCase();
    for (final spell in spells) {
      if (spell.name.toLowerCase() == lower) return spell;
    }
    return null;
  }
}

/// What a level gained in one class unlocks.
class LevelUp2024Plan {
  const LevelUp2024Plan({
    required this.cls,
    required this.classEntryId,
    required this.isNewClass,
    required this.newClassLevel,
    required this.newTotalLevel,
    required this.newFeatures,
    required this.requiresSubclass,
    this.currentSubclass,
    this.featFeature,
  });

  final Creation2024Class cls;
  final String classEntryId;
  final bool isNewClass;
  final int newClassLevel;
  final int newTotalLevel;

  /// Class feature names gained at [newClassLevel].
  final List<String> newFeatures;
  final bool requiresSubclass;
  final String? currentSubclass;

  /// `Ability Score Improvement` or `Epic Boon` when this level grants a feat.
  final String? featFeature;
}

/// A class-table spell replaced when gaining a level.
class SpellSwap2024 {
  const SpellSwap2024({required this.forget, required this.learn});

  final String forget;
  final String learn;
}

/// Decisions taken in the 2024 level-up flow.
class LevelUp2024Result {
  const LevelUp2024Result({
    required this.className,
    this.classEntryId,
    this.hitPointMethod = HitPointGainMethod.average,
    this.hitDieRoll,
    this.subclassName,
    this.featName,
    this.abilityIncreases = const {},
    this.featureChoices = const [],
    this.spellSwaps = const [],
  });

  final String className;

  /// Existing class entry; null adds [className] as a new class.
  final String? classEntryId;
  final String hitPointMethod;
  final int? hitDieRoll;
  final String? subclassName;
  final String? featName;
  final Map<String, int> abilityIncreases;
  final List<CharacterFeatureChoice> featureChoices;
  final List<SpellSwap2024> spellSwaps;
}

/// Spellcasting limits of one class entry, as if single-classed.
class ClassSpellcasting2024 {
  const ClassSpellcasting2024({
    required this.entry,
    required this.cls,
    required this.ability,
    required this.cantripsKnown,
    required this.preparedSpells,
    required this.maxSpellLevel,
  });

  final CharacterClassEntry entry;
  final Creation2024Class cls;
  final String ability;
  final int cantripsKnown;
  final int preparedSpells;
  final int maxSpellLevel;

  /// Wizard spellbooks start with six spells and gain two per level.
  int? get spellbookSize =>
      cls.name == 'Wizard' ? 6 + 2 * (entry.level - 1) : null;
}

class Progression2024Engine {
  const Progression2024Engine._();

  static const maxLevel = 20;
  static const abilityScoreImprovement = 'Ability Score Improvement';
  static const epicBoon = 'Epic Boon';
  static const multiclassFeatureName = 'Multiclass Proficiencies';
  static const _abilities = [
    'strength',
    'dexterity',
    'constitution',
    'intelligence',
    'wisdom',
    'charisma',
  ];

  /// Languages a class grants by itself at level 1.
  static const classLanguages = {'Druid': 'Druidic', 'Rogue': "Thieves' Cant"};

  /// Spells a class feature always prepares at level 1, with that feature.
  static const classLevelOneSpells = {
    'Druid': ('Druidcraft', 'Druidic'),
    'Ranger': ("Hunter's Mark", 'Favored Enemy'),
  };

  static int proficiencyBonus(int totalLevel) => 2 + (totalLevel - 1) ~/ 4;

  static int averageHitDie(int dieSize) => dieSize ~/ 2 + 1;

  static String featSourceId(int characterLevel) => 'level-$characterLevel';

  /// Whether a feat, its choices or spells came from a level, not the origin.
  static bool isLevelFeatSource(String? sourceId) =>
      sourceId != null && sourceId.startsWith('level-');

  static void _require2024(Character character) {
    if (character.rulesetId != RulesetId.dnd2024) {
      throw UnsupportedError('2024 progression requires a 2024 character.');
    }
  }

  // ── History ──────────────────────────────────────────────────────────────

  /// Level records of [character]. Sheets saved before history existed get
  /// their level 1 record from the explicit character update (migration 11).
  static List<CharacterLevelRecord> historyFor(Character character) =>
      character.levelHistory;

  // ── Planning ─────────────────────────────────────────────────────────────

  static LevelUp2024Plan plan(
    Character character,
    Rules2024Data data, {
    required String className,
    String? classEntryId,
  }) {
    _require2024(character);
    final cls = data.classNamed(className);
    final entry = classEntryId == null
        ? null
        : character.classEntries.where((e) => e.id == classEntryId).firstOrNull;
    if (classEntryId != null && entry == null) {
      throw ArgumentError('Unknown class entry: $classEntryId');
    }
    final newClassLevel = (entry?.level ?? 0) + 1;
    final features = cls.featuresAt(newClassLevel);
    return LevelUp2024Plan(
      cls: cls,
      classEntryId: entry?.id ?? _newEntryId(character, className),
      isNewClass: entry == null,
      newClassLevel: newClassLevel,
      newTotalLevel: character.totalLevel + 1,
      newFeatures: features,
      requiresSubclass:
          newClassLevel == cls.subclassLevel && entry?.subclassName == null,
      currentSubclass: entry?.subclassName,
      featFeature: features.contains(epicBoon)
          ? epicBoon
          : features.contains(abilityScoreImprovement)
          ? abilityScoreImprovement
          : null,
    );
  }

  static String _newEntryId(Character character, String className) {
    final base = className.toLowerCase();
    final ids = character.classEntries.map((e) => e.id).toSet();
    var index = character.classEntries.length + 1;
    while (ids.contains('${base}_$index')) {
      index++;
    }
    return '${base}_$index';
  }

  /// Abilities below 13 that block adding [className]: the 2024 rules check
  /// the primary abilities of the new class and of every current class.
  static List<String> missingMulticlassAbilities(
    Character character,
    Rules2024Data data,
    String className,
  ) {
    final missing = <String>{};
    final classNames = {
      for (final entry in character.classEntries) entry.className,
      className,
    };
    for (final name in classNames) {
      final cls = data.classNamed(name);
      final below = [
        for (final ability in cls.primaryAbilities)
          if (character.abilityScores[ability] < 13) ability,
      ];
      final meets = cls.primaryAbilityAny
          ? below.length < cls.primaryAbilities.length
          : below.isEmpty;
      if (!meets) missing.addAll(below);
    }
    return missing.toList();
  }

  static bool _hasClassFeature(
    Iterable<CharacterClassEntry> entries,
    Rules2024Data data,
    String featureName,
  ) {
    for (final entry in entries) {
      final cls = data.classNamed(entry.className);
      for (var level = 1; level <= entry.level; level++) {
        if (cls.featuresAt(level).contains(featureName)) return true;
      }
    }
    return false;
  }

  /// Feats the level's Ability Score Improvement or Epic Boon may grant.
  static List<SrdFeat> eligibleFeats(
    Character character,
    Rules2024Data data,
    LevelUp2024Plan plan,
  ) {
    final featFeature = plan.featFeature;
    if (featFeature == null) return const [];
    final categories = {
      'general',
      'origin',
      'fighting_style',
      if (featFeature == epicBoon) 'epic_boon',
    };
    final entriesAfter = _entriesAfter(character, plan, null);
    final taken = {
      for (final feature in character.extraFeatures)
        if (feature.effectiveSourceType == FeatureChoiceSourceType.feat)
          feature.name,
    };
    return [
      for (final feat in data.feats)
        if (categories.contains(feat.category) &&
            (feat.repeatable || !taken.contains(feat.name)) &&
            _meetsPrerequisite(feat, character, data, plan, entriesAfter))
          feat,
    ];
  }

  static bool _meetsPrerequisite(
    SrdFeat feat,
    Character character,
    Rules2024Data data,
    LevelUp2024Plan plan,
    List<CharacterClassEntry> entriesAfter,
  ) {
    final prerequisite = feat.structuredPrerequisite;
    if (prerequisite == null) return true;
    final minLevel = (prerequisite['minLevel'] as num?)?.toInt();
    if (minLevel != null && plan.newTotalLevel < minLevel) return false;
    final feature = prerequisite['feature'] as String?;
    if (feature != null && !_hasClassFeature(entriesAfter, data, feature)) {
      return false;
    }
    final anyAbility = prerequisite['anyAbilityAtLeast'];
    if (anyAbility is Map) {
      final meets = anyAbility.entries.any(
        (entry) =>
            character.abilityScores[entry.key.toString()] >=
            (entry.value as num).toInt(),
      );
      if (!meets) return false;
    }
    return true;
  }

  /// The ability increase requirement of [featName], handled by the level-up
  /// flow itself instead of the generic choice editor.
  static SrdFeatureChoiceRequirement? featAbilityRequirement(
    Rules2024Data data,
    String featName,
  ) {
    for (final choice
        in data.choices.feat(featName)?.choices ??
            const <SrdFeatureChoiceRequirement>[]) {
      if (choice.type == 'ability_score_increase' || choice.type == 'ability') {
        return choice;
      }
    }
    return null;
  }

  static List<String> abilityOptions(SrdFeatureChoiceRequirement requirement) =>
      requirement.options.isEmpty
      ? _abilities
      : [for (final option in requirement.options) option.id];

  /// Whether [increases] is a legal pick for [requirement].
  static bool validAbilityIncreases(
    Character character,
    SrdFeatureChoiceRequirement requirement,
    Map<String, int> increases,
  ) {
    final picks = {
      for (final entry in increases.entries)
        if (entry.value > 0) entry.key: entry.value,
    };
    final options = abilityOptions(requirement);
    final maximum = requirement.maximum ?? 20;
    if (picks.keys.any((ability) => !options.contains(ability))) return false;
    if (picks.entries.any(
      (entry) => character.abilityScores[entry.key] + entry.value > maximum,
    )) {
      return false;
    }
    if (requirement.type == 'ability') {
      return picks.length == 1 && picks.values.single == requirement.increase;
    }
    final split = picks.values.toList()..sort((a, b) => b - a);
    return requirement.patterns.any((pattern) {
      final sorted = [...pattern]..sort((a, b) => b - a);
      return sorted.length == split.length &&
          [for (var i = 0; i < sorted.length; i++) sorted[i] == split[i]]
              .every((same) => same);
    });
  }

  /// Feature choices newly required by the level, the subclass and the feat.
  /// Choices that may be swapped on gaining a level (Eldritch Invocations) and
  /// choices depending on included ones (Pact of the Tome) are included too.
  /// Ability increases of the feat are excluded.
  static List<FeatureChoiceRequest> requestsFor(
    Character character,
    Rules2024Data data,
    LevelUp2024Plan plan, {
    String? subclassName,
    String? featName,
  }) {
    final subclass = subclassName ?? plan.currentSubclass;
    final subclassFeatures = subclass == null
        ? const <SrdClassFeature>[]
        : (data.subclassFeatures[plan.cls.name]?[subclass] ??
                  const <SrdClassFeature>[])
              .where((feature) => feature.level == plan.newClassLevel)
              .toList();
    final requests = <FeatureChoiceRequest>[
      ...FeatureChoiceEngine.requestsForLevelUp(
        catalog: data.choices,
        character: character,
        newLevel: plan.newClassLevel,
        newClassFeatures: [
          for (final name in plan.newFeatures)
            SrdClassFeature(
              name: name,
              level: plan.newClassLevel,
              type: 'passive',
              description: '',
            ),
        ],
        newSubclassFeatures: subclassFeatures,
        targetClassEntryId: plan.classEntryId,
        targetClassName: plan.cls.name,
        subclassName: subclass,
      ),
    ];
    final keys = {for (final request in requests) request.key};
    void addRequest(FeatureChoiceRequest request) {
      if (keys.add(request.key)) requests.add(request);
    }

    if (!plan.isNewClass) {
      for (final entry
          in data.choices.classFeatures[plan.cls.name]?.entries ??
              const <MapEntry<String, SrdFeatureChoiceDefinition>>[]) {
        if (!_hasClassFeature([
          CharacterClassEntry(
            id: plan.classEntryId,
            className: plan.cls.name,
            level: plan.newClassLevel,
          ),
        ], data, entry.key)) {
          continue;
        }
        for (final request in FeatureChoiceEngine.requestsForClassFeature(
          catalog: data.choices,
          className: plan.cls.name,
          sourceClassEntryId: plan.classEntryId,
          featureName: entry.key,
          level: plan.newClassLevel,
        )) {
          if (request.requirement.replaceOneOnLevelUp) addRequest(request);
        }
      }
    }

    for (final request in [...requests]) {
      if (request.sourceType != FeatureChoiceSourceType.classFeature) continue;
      for (final dependent in FeatureChoiceEngine.requestsForClassFeature(
        catalog: data.choices,
        className: request.sourceClass,
        sourceClassEntryId: request.sourceClassEntryId,
        featureName: request.featureName,
        level: request.level,
      )) {
        if (dependent.requirement.whenChoiceId == request.choiceId) {
          addRequest(dependent);
        }
      }
    }

    if (featName != null) {
      requests.addAll(featRequests(data, featName, plan.newTotalLevel, character));
    }
    if (plan.isNewClass) requests.addAll(_multiclassRequests(character, data, plan));
    return requests;
  }

  /// Non-ability choices of a feat gained at [characterLevel]. Repeatable
  /// feats that must differ in a choice exclude values of other instances.
  static List<FeatureChoiceRequest> featRequests(
    Rules2024Data data,
    String featName,
    int characterLevel, [
    Character? character,
  ]) {
    final feat = data.featNamed(featName);
    final uniqueChoice = feat?.uniqueByChoice;
    final used = {
      if (uniqueChoice != null && character != null)
        for (final choice in character.featureChoices)
          if (choice.sourceType == FeatureChoiceSourceType.feat &&
              choice.sourceName == featName &&
              choice.choiceId == uniqueChoice)
            ...choice.values,
    };
    return [
      for (final request in FeatureChoiceEngine.requestsForFeat(
        catalog: data.choices,
        featName: featName,
        level: characterLevel,
      ))
        if (request.requirement.type != 'ability_score_increase' &&
            request.requirement.type != 'ability')
          FeatureChoiceRequest(
            sourceType: request.sourceType,
            sourceClassEntryId: featSourceId(characterLevel),
            sourceName: request.sourceName,
            featureName: request.featureName,
            level: request.level,
            requirement: request.choiceId == uniqueChoice && used.isNotEmpty
                ? _withoutOptions(data, request.requirement, used)
                : request.requirement,
            requiredCount: request.requiredCount,
          ),
    ];
  }

  static SrdFeatureChoiceRequirement _withoutOptions(
    Rules2024Data data,
    SrdFeatureChoiceRequirement requirement,
    Set<String> excluded,
  ) {
    final options = requirement.options.isNotEmpty
        ? requirement.options
        : data.choices.optionSources[requirement.optionsSource] ??
              const <SrdFeatureChoiceOption>[];
    return SrdFeatureChoiceRequirement(
      id: requirement.id,
      type: requirement.type,
      count: requirement.count,
      options: [
        for (final option in options)
          if (!excluded.contains(option.id)) option,
      ],
    );
  }

  static List<FeatureChoiceRequest> _multiclassRequests(
    Character character,
    Rules2024Data data,
    LevelUp2024Plan plan,
  ) {
    final proficiencies = plan.cls.multiclass;
    return [
      if (proficiencies.skillChoice != null)
        _skillRequest(
          character,
          data,
          FeatureChoiceSourceType.multiclassProficiency,
          plan.cls.name,
          plan.classEntryId,
          multiclassFeatureName,
          proficiencies.skillChoice!,
        ),
      if (proficiencies.toolChoice != null)
        _toolRequest(
          data,
          FeatureChoiceSourceType.multiclassProficiency,
          plan.cls.name,
          plan.classEntryId,
          multiclassFeatureName,
          proficiencies.toolChoice!,
        ),
    ];
  }

  static FeatureChoiceRequest _skillRequest(
    Character character,
    Rules2024Data data,
    String sourceType,
    String className,
    String entryId,
    String featureName,
    SrdSkillChoice choice,
  ) {
    final known = character.skillProficiencies.toSet();
    return FeatureChoiceRequest(
      sourceType: sourceType,
      sourceClass: className,
      sourceClassEntryId: entryId,
      featureName: featureName,
      level: 1,
      requirement: SrdFeatureChoiceRequirement(
        id: 'skills',
        type: 'option',
        count: choice.count,
        options: [
          for (final skill in choice.isAny
              ? [for (final skill in data.skills) skill.name.toLowerCase()]
              : choice.from)
            if (!known.contains(skill))
              SrdFeatureChoiceOption(
                id: FeatureChoiceOptionResolver.idFromName(skill),
                name: _titleCase(skill),
              ),
        ],
      ),
      requiredCount: choice.count,
    );
  }

  static FeatureChoiceRequest _toolRequest(
    Rules2024Data data,
    String sourceType,
    String className,
    String entryId,
    String featureName,
    Creation2024ToolChoice choice,
  ) => FeatureChoiceRequest(
    sourceType: sourceType,
    sourceClass: className,
    sourceClassEntryId: entryId,
    featureName: featureName,
    level: 1,
    requirement: SrdFeatureChoiceRequirement(
      id: 'tools',
      type: 'option',
      count: choice.count,
      options: [
        for (final tool in data.tools)
          if (choice.categories.contains(tool.category))
            SrdFeatureChoiceOption(
              id: FeatureChoiceOptionResolver.idFromName(tool.name),
              name: tool.name,
            ),
      ],
    ),
    requiredCount: choice.count,
  );

  static String _titleCase(String value) => value
      .split(' ')
      .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');

  /// Checks saved values of [requests] against [next]: earlier values stay,
  /// except one per choice that allows replacement on gaining a level, and
  /// options keep their level and invocation prerequisites.
  static void _validateChoices(
    Character character,
    Rules2024Data data,
    List<FeatureChoiceRequest> requests,
    List<CharacterFeatureChoice> next,
  ) {
    for (final request in requests) {
      final before = request.findIn(character.featureChoices)?.values.toSet() ??
          const <String>{};
      final after = request.findIn(next)?.values.toSet() ?? const <String>{};
      final removed = before.difference(after).length;
      final allowed = request.requirement.replaceOneOnLevelUp ? 1 : 0;
      if (removed > allowed) {
        throw ArgumentError('Only $allowed earlier ${request.choiceId} can change.');
      }
      if (request.requirement.type == 'beast_form') {
        final limits = const WildShape2024Rules().limitsAt(request.level);
        final eligible = {
          for (final monster in data.monsters)
            if (limits != null && limits.allows(monster)) monster.id,
        };
        if (!eligible.containsAll(after) || after.length > request.requiredCount) {
          throw ArgumentError('Wild Shape forms must be eligible Beasts.');
        }
        continue;
      }
      final source = request.requirement.optionsSource;
      final options = {
        for (final option
            in data.choices.optionSources[source] ?? const <SrdFeatureChoiceOption>[])
          option.id: option,
      };
      if (options.isEmpty) continue;
      final selected = {for (final value in after) ChoiceTargetValue.optionId(value)};
      final seen = <String>{};
      for (final value in after) {
        final option = options[ChoiceTargetValue.optionId(value)];
        if (option == null) continue;
        if (option.target != null && ChoiceTargetValue.target(value) == null) {
          throw ArgumentError('${option.id} needs a target.');
        }
        if (!seen.add(option.id) && !option.repeatableWithDifferentTarget) {
          throw ArgumentError('${option.id} cannot be repeated.');
        }
        if ((option.minClassLevel ?? 0) > request.level ||
            !selected.containsAll(option.requiresInvocations)) {
          throw ArgumentError('${option.id} prerequisites are not met.');
        }
      }
    }
  }

  // ── Hit points ───────────────────────────────────────────────────────────

  static bool _hasDwarvenToughness(Rules2024Data data) =>
      data.speciesTraits.contains('Dwarven Toughness');

  /// Hit points of the level before any Constitution change from its feat.
  static int hitPointsGained(
    Character character,
    Rules2024Data data,
    LevelUp2024Plan plan, {
    required String method,
    int? roll,
  }) {
    final die = method == HitPointGainMethod.rolled
        ? (roll ?? 0).clamp(1, plan.cls.hitDie).toInt()
        : averageHitDie(plan.cls.hitDie);
    final gained = die + character.abilityScores.constitutionModifier;
    return (gained < 1 ? 1 : gained) + (_hasDwarvenToughness(data) ? 1 : 0);
  }

  static int _levelOneHitPoints(
    Creation2024Class cls,
    AbilityScores scores,
    Rules2024Data data,
  ) => cls.hitDie + scores.constitutionModifier + (_hasDwarvenToughness(data) ? 1 : 0);

  // ── Spellcasting ─────────────────────────────────────────────────────────

  static List<int> _nine(List<dynamic>? values) => [
    for (var i = 0; i < 9; i++)
      values != null && i < values.length ? (values[i] as num).toInt() : 0,
  ];

  static SpellSlots _keepUsed(SpellSlots previous, List<int> total) =>
      SpellSlots(
        total: total,
        used: [
          for (var i = 0; i < 9; i++)
            (i < previous.used.length ? previous.used[i] : 0)
                .clamp(0, total[i])
                .toInt(),
        ],
      );

  /// Standard and Pact Magic slots for the class levels of [character].
  /// Multiclass standard slots add full caster levels and half the Paladin
  /// and Ranger levels rounded up.
  static (SpellSlots, SpellSlots) slotsFor(
    Character character,
    Rules2024Data data,
  ) {
    final casters = <(CharacterClassEntry, Creation2024Class)>[];
    CharacterClassEntry? warlock;
    for (final entry in character.classEntries) {
      final cls = data.classNamed(entry.className);
      if (cls.spellcastingType == 'full' || cls.spellcastingType == 'half') {
        casters.add((entry, cls));
      } else if (cls.spellcastingType == 'warlock') {
        warlock = entry;
      }
    }
    var standard = List<int>.filled(9, 0);
    if (casters.length == 1) {
      final (entry, cls) = casters.single;
      standard = _nine(cls.rowAt(entry.level)['spellSlots'] as List?);
    } else if (casters.length > 1) {
      var casterLevel = 0;
      for (final (entry, cls) in casters) {
        casterLevel += cls.spellcastingType == 'full'
            ? entry.level
            : (entry.level + 1) ~/ 2;
      }
      final fullTable = data.classes.firstWhere(
        (cls) => cls.spellcastingType == 'full',
      );
      standard = _nine(fullTable.rowAt(casterLevel)['spellSlots'] as List?);
    }
    var pact = List<int>.filled(9, 0);
    if (warlock != null) {
      final row = data.classNamed(warlock.className).rowAt(warlock.level);
      final count = (row['pactMagicSlots'] as num?)?.toInt() ?? 0;
      final level = (row['pactMagicSlotLevel'] as num?)?.toInt() ?? 1;
      if (count > 0) pact[level - 1] = count;
    }
    return (
      _keepUsed(character.spellSlots, standard),
      _keepUsed(character.pactMagicSlots, pact),
    );
  }

  /// Per-class spellcasting limits, in class entry order.
  static List<ClassSpellcasting2024> spellcastingFor(
    Character character,
    List<Creation2024Class> classes,
  ) {
    final result = <ClassSpellcasting2024>[];
    for (final entry in character.classEntries) {
      final cls = classes.where((c) => c.name == entry.className).firstOrNull;
      final ability = cls?.spellcastingAbility;
      if (cls == null || ability == null) continue;
      final row = cls.rowAt(entry.level);
      final slots = _nine(row['spellSlots'] as List?);
      var maxSpellLevel = 0;
      for (var i = 0; i < 9; i++) {
        if (slots[i] > 0) maxSpellLevel = i + 1;
      }
      if (cls.spellcastingType == 'warlock') {
        maxSpellLevel = (row['pactMagicSlotLevel'] as num?)?.toInt() ?? 1;
      }
      result.add(
        ClassSpellcasting2024(
          entry: entry,
          cls: cls,
          ability: ability,
          cantripsKnown: (row['cantripsKnown'] as num?)?.toInt() ?? 0,
          preparedSpells: (row['preparedSpells'] as num?)?.toInt() ?? 0,
          maxSpellLevel: maxSpellLevel,
        ),
      );
    }
    return result;
  }

  /// Whether [spell] counts against the class cantrip or prepared limits:
  /// spells from the class table, not from features, feats or subclasses.
  static bool countsAgainstClassLimits(KnownSpell spell, CharacterClassEntry entry) {
    if (spell.isAlwaysPrepared) return false;
    final sameEntry = spell.sourceClassEntryId == null
        ? spell.sourceClass == entry.className
        : spell.sourceClassEntryId == entry.id;
    return sameEntry &&
        (spell.sourceType == 'class' ||
            ChoiceEffects.classSpellFeatures.contains(spell.sourceFeature));
  }

  /// Class-table spells of [entry] that may be replaced on gaining a level.
  static List<KnownSpell> swappableSpells(
    Character character,
    CharacterClassEntry entry, {
    required bool cantrips,
  }) => [
    for (final spell in character.spells)
      if (countsAgainstClassLimits(spell, entry) && (spell.level == 0) == cantrips)
        spell,
  ];

  /// Spells of the class list that could replace a spell at [classLevel].
  static List<SrdSpell> swapCandidates(
    Character character,
    Rules2024Data data,
    Creation2024Class cls,
    int classLevel, {
    required bool cantrips,
  }) {
    final known = {for (final spell in character.spells) spell.name.toLowerCase()};
    final limits = spellcastingFor(
      character.copyWith(
        classes: [
          CharacterClassEntry(id: '_', className: cls.name, level: classLevel),
        ],
      ),
      data.classes,
    ).firstOrNull;
    final maxLevel = limits?.maxSpellLevel ?? 0;
    final className = cls.name.toLowerCase();
    return [
      for (final spell in data.spells)
        if (spell.classes.contains(className) &&
            !known.contains(spell.name.toLowerCase()) &&
            (cantrips ? spell.level == 0 : spell.level >= 1 && spell.level <= maxLevel))
          spell,
    ]..sort((a, b) => a.level != b.level ? a.level - b.level : a.name.compareTo(b.name));
  }

  /// Replaces subclass always-prepared spells with those of the current
  /// subclass levels and choices.
  static List<KnownSpell> syncSubclassSpells(
    Character character,
    Rules2024Data data,
  ) {
    final spellLevels = {
      for (final spell in data.spells) spell.name.toLowerCase(): spell.level,
    };
    final kept = [
      for (final spell in character.spells)
        if (spell.sourceType != FeatureChoiceSourceType.subclassFeature ||
            !spell.isAlwaysPrepared ||
            spell.sourceFeature != null)
          spell,
    ];
    final names = {for (final spell in kept) spell.name.toLowerCase()};
    for (final entry in character.classEntries) {
      final subclass = data.subclassNamed(entry.className, entry.subclassName);
      if (subclass == null) continue;
      final byLevel = <int, List<String>>{...subclass.alwaysPreparedSpells};
      final byChoice = subclass.spellsByChoice;
      if (byChoice != null) {
        final selected = character.featureChoices
            .where(
              (choice) =>
                  choice.sourceType == FeatureChoiceSourceType.subclassFeature &&
                  choice.sourceClassEntryId == entry.id &&
                  choice.featureName == byChoice.featureName &&
                  choice.choiceId == byChoice.choiceId,
            )
            .firstOrNull
            ?.values
            .firstOrNull;
        byLevel.addAll(byChoice.options[selected] ?? const {});
      }
      final levels = byLevel.keys.toList()..sort();
      for (final level in levels) {
        if (level > entry.level) continue;
        for (final name in byLevel[level]!) {
          if (!names.add(name.toLowerCase())) continue;
          kept.add(
            KnownSpell(
              name: name,
              level: spellLevels[name.toLowerCase()] ?? 1,
              isPrepared: true,
              isAlwaysPrepared: true,
              sourceType: FeatureChoiceSourceType.subclassFeature,
              sourceClass: entry.className,
              sourceSubclass: subclass.name,
              sourceClassEntryId: entry.id,
            ),
          );
        }
      }
    }
    return kept;
  }

  /// Applies feature choice edits made outside level up: their effects and
  /// subclass spells follow the new values.
  static Character applyChoiceEdits(
    Character before,
    Character after,
    Rules2024Data data,
  ) {
    final edited = ChoiceEffects.apply(before, after, data);
    return edited.copyWith(spells: syncSubclassSpells(edited, data));
  }

  /// Weapon proficiencies: the starting class grants all of its own, later
  /// classes only their multiclass weapons.
  static List<String> weaponProficiencies(
    Character character,
    List<Creation2024Class> classes,
  ) {
    final result = <String>{};
    for (final entry in character.classEntries) {
      final cls = classes.where((c) => c.name == entry.className).firstOrNull;
      if (cls == null) continue;
      result.addAll(
        entry.isStartingClass ? cls.weaponProficiencies : cls.multiclass.weapons,
      );
    }
    return result.toList();
  }

  // ── Resource effects ─────────────────────────────────────────────────────

  /// Hit points healed by a resource spend effect such as Uncanny Metabolism.
  static int healForSpendEffect(
    String formula,
    Character character,
    Rules2024Data data, {
    math.Random? random,
  }) {
    switch (formula) {
      case 'monk_level_plus_martial_arts_die':
        final level = character.classLevel('Monk');
        if (level <= 0) return 0;
        final die = data.classNamed('Monk').rowAt(level)['martialArtsDie'] as String?;
        final expression = DiceParser.parse(die ?? '1d6');
        final roll = DiceRoller(
          rollDie: random == null ? null : (sides) => random.nextInt(sides) + 1,
        ).roll(expression);
        return level + roll.total;
      default:
        return 0;
    }
  }

  // ── Level up ─────────────────────────────────────────────────────────────

  static List<CharacterClassEntry> _entriesAfter(
    Character character,
    LevelUp2024Plan plan,
    String? subclassName,
  ) {
    if (plan.isNewClass) {
      return [
        ...character.classEntries,
        CharacterClassEntry(
          id: plan.classEntryId,
          className: plan.cls.name,
          level: 1,
          subclassName: subclassName,
          isStartingClass: false,
        ),
      ];
    }
    return [
      for (final entry in character.classEntries)
        entry.id == plan.classEntryId
            ? entry.copyWith(
                level: plan.newClassLevel,
                subclassName: subclassName ?? entry.subclassName,
              )
            : entry,
    ];
  }

  static Character applyLevelUp(
    Character character,
    Rules2024Data data,
    LevelUp2024Result result,
  ) {
    if (character.levelHistory.length != character.totalLevel) {
      throw StateError('Update this character before gaining a level.');
    }
    final plan = Progression2024Engine.plan(
      character,
      data,
      className: result.className,
      classEntryId: result.classEntryId,
    );
    if (plan.newTotalLevel > maxLevel) {
      throw ArgumentError('A character cannot exceed level $maxLevel.');
    }
    if (plan.isNewClass &&
        missingMulticlassAbilities(character, data, plan.cls.name).isNotEmpty) {
      throw ArgumentError('Multiclass prerequisites are not met.');
    }
    if (plan.requiresSubclass &&
        data.subclassNamed(plan.cls.name, result.subclassName) == null) {
      throw ArgumentError('Choose a subclass for ${plan.cls.name}.');
    }
    final subclassName = plan.requiresSubclass ? result.subclassName : null;
    final featName = result.featName;
    SrdFeat? feat;
    if (plan.featFeature != null) {
      feat = featName == null ? null : data.featNamed(featName);
      if (feat == null ||
          !eligibleFeats(character, data, plan).any((f) => f.name == feat!.name)) {
        throw ArgumentError('Choose an eligible feat.');
      }
      final requirement = featAbilityRequirement(data, feat.name);
      if (requirement != null &&
          !validAbilityIncreases(character, requirement, result.abilityIncreases)) {
        throw ArgumentError('Invalid ability increases for ${feat.name}.');
      }
    }
    final increases = feat == null ? const <String, int>{} : {
      for (final entry in result.abilityIncreases.entries)
        if (entry.value > 0) entry.key: entry.value,
    };

    final requests = requestsFor(
      character,
      data,
      plan,
      subclassName: subclassName,
      featName: feat?.name,
    );
    final newChoices = [
      for (final request in requests)
        if (request.isApplicable(result.featureChoices))
          request.findIn(result.featureChoices) ?? request.emptyChoice(),
    ];
    if (!FeatureChoiceEngine.allComplete(requests, newChoices)) {
      throw ArgumentError('Some feature choices are incomplete.');
    }
    _validateChoices(character, data, requests, newChoices);

    // Hit points use the Constitution before this level's feat; a higher
    // modifier then raises every level retroactively.
    final hpGained = hitPointsGained(
      character,
      data,
      plan,
      method: result.hitPointMethod,
      roll: result.hitDieRoll,
    );
    var scores = character.abilityScores;
    for (final entry in increases.entries) {
      scores = _withScore(scores, entry.key, scores[entry.key] + entry.value);
    }
    final conDelta = scores.constitutionModifier -
        character.abilityScores.constitutionModifier;
    final hpIncrease = hpGained + conDelta * plan.newTotalLevel;
    final maxHp = character.hitPoints.maximum + hpIncrease;

    final entries = _entriesAfter(character, plan, subclassName);
    final pools = _hitDicePoolsAfter(character, plan);
    var extraFeatures = character.extraFeatures;
    var choices = FeatureChoiceEngine.upsertChoices(
      character.featureChoices,
      newChoices,
    );
    if (feat != null) {
      extraFeatures = [
        ...extraFeatures,
        CharacterExtraFeature(
          sourceClass: 'Feat',
          sourceType: FeatureChoiceSourceType.feat,
          sourceFeature: plan.featFeature,
          sourceClassEntryId: featSourceId(plan.newTotalLevel),
          name: feat.name,
          level: plan.newTotalLevel,
          type: 'passive',
          description: feat.description,
        ),
      ];
      final requirement = featAbilityRequirement(data, feat.name);
      if (requirement != null) {
        choices = FeatureChoiceEngine.upsertChoices(choices, [
          CharacterFeatureChoice(
            sourceType: FeatureChoiceSourceType.feat,
            sourceClassEntryId: featSourceId(plan.newTotalLevel),
            sourceName: feat.name,
            featureName: feat.name,
            choiceId: requirement.id,
            values: [
              for (final entry in increases.entries)
                requirement.type == 'ability'
                    ? entry.key
                    : '${entry.key}:${entry.value}',
            ],
          ),
        ]);
      }
    }

    final starting = entries.firstWhere((entry) => entry.isStartingClass);
    var updated = character.copyWith(
      level: plan.newTotalLevel,
      characterClass: starting.className,
      subclass: starting.subclassName,
      clearSubclass: starting.subclassName == null,
      classes: entries,
      abilityScores: scores,
      proficiencyBonus: proficiencyBonus(plan.newTotalLevel),
      hitPoints: character.hitPoints.copyWith(
        maximum: maxHp,
        current: (character.hitPoints.current + hpIncrease).clamp(0, maxHp).toInt(),
      ),
      hitDicePools: pools,
      extraFeatures: extraFeatures,
      featureChoices: choices,
      features: [
        ...character.features,
        if (plan.isNewClass)
          for (final tool in plan.cls.multiclass.tools)
            if (!character.features.contains('Tool Proficiency: $tool'))
              'Tool Proficiency: $tool',
      ],
    );
    updated = ChoiceEffects.apply(character, updated, data);
    if (!plan.isNewClass) {
      updated = _applySpellSwaps(updated, data, plan, result.spellSwaps);
    } else if (result.spellSwaps.isNotEmpty) {
      throw ArgumentError('A new class has no spells to replace.');
    }
    final (standard, pact) = slotsFor(updated, data);
    updated = updated.copyWith(
      spellSlots: standard,
      pactMagicSlots: pact,
      levelHistory: [
        ...historyFor(character),
        CharacterLevelRecord(
          characterLevel: plan.newTotalLevel,
          classEntryId: plan.classEntryId,
          className: plan.cls.name,
          classLevel: plan.newClassLevel,
          hitPointsGained: hpGained,
          hitPointMethod: result.hitPointMethod,
          subclassName: subclassName,
          featName: feat?.name,
          featFeature: feat == null ? null : plan.featFeature,
          abilityIncreases: increases,
        ),
      ],
    );
    updated = updated.copyWith(spells: syncSubclassSpells(updated, data));
    return updated.copyWith(armorClass: calcArmorClass(updated));
  }

  static Character _applySpellSwaps(
    Character character,
    Rules2024Data data,
    LevelUp2024Plan plan,
    List<SpellSwap2024> swaps,
  ) {
    if (swaps.isEmpty) return character;
    final entry = character.classEntries.firstWhere((e) => e.id == plan.classEntryId);
    var cantripSwaps = 0;
    var spellSwaps = 0;
    var spells = [...character.spells];
    for (final swap in swaps) {
      final index = spells.indexWhere(
        (spell) =>
            spell.name == swap.forget && countsAgainstClassLimits(spell, entry),
      );
      if (index < 0) throw ArgumentError('${swap.forget} cannot be replaced.');
      final forgotten = spells[index];
      final cantrip = forgotten.level == 0;
      final candidates = swapCandidates(
        character.copyWith(spells: spells),
        data,
        plan.cls,
        plan.newClassLevel,
        cantrips: cantrip,
      );
      final learned = candidates.where((s) => s.name == swap.learn).firstOrNull;
      if (learned == null) throw ArgumentError('${swap.learn} is not eligible.');
      if (cantrip ? ++cantripSwaps > plan.cls.levelUpCantripSwaps
                  : ++spellSwaps > plan.cls.levelUpSpellSwaps) {
        throw ArgumentError('Too many spell replacements for ${plan.cls.name}.');
      }
      spells[index] = forgotten.copyWith(name: learned.name, level: learned.level);
    }
    return character.copyWith(spells: spells);
  }

  static AbilityScores _withScore(AbilityScores scores, String ability, int value) {
    final clamped = value.clamp(1, 30).toInt();
    return switch (ability) {
      'strength' => scores.copyWith(strength: clamped),
      'dexterity' => scores.copyWith(dexterity: clamped),
      'constitution' => scores.copyWith(constitution: clamped),
      'intelligence' => scores.copyWith(intelligence: clamped),
      'wisdom' => scores.copyWith(wisdom: clamped),
      'charisma' => scores.copyWith(charisma: clamped),
      _ => scores,
    };
  }

  static List<CharacterHitDiePool> _hitDicePoolsAfter(
    Character character,
    LevelUp2024Plan plan,
  ) {
    if (plan.isNewClass) {
      return [
        ...character.hitDicePools,
        CharacterHitDiePool(
          dieSize: plan.cls.hitDie,
          total: 1,
          sourceClass: plan.cls.name,
          sourceClassEntryId: plan.classEntryId,
        ),
      ];
    }
    return [
      for (final pool in character.hitDicePools)
        pool.sourceClassEntryId == plan.classEntryId
            ? pool.copyWith(total: pool.total + 1)
            : pool,
    ];
  }

  // ── Level reset ──────────────────────────────────────────────────────────

  static bool canResetToLevelOne(Character character) =>
      character.rulesetId == RulesetId.dnd2024 &&
      historyFor(character).length == character.totalLevel;

  /// The character with every class-derived choice and grant removed, so a
  /// level 1 class can be applied on top of its origin.
  static Character _withoutClasses(Character character, Rules2024Data data) {
    final history = historyFor(character);
    var scores = character.abilityScores;
    for (final record in history.skip(1)) {
      for (final entry in record.abilityIncreases.entries) {
        scores = _withScore(scores, entry.key, scores[entry.key] - entry.value);
      }
    }
    bool classDerived(CharacterFeatureChoice choice) =>
        switch (choice.sourceType) {
          FeatureChoiceSourceType.classFeature ||
          FeatureChoiceSourceType.subclassFeature ||
          FeatureChoiceSourceType.multiclassProficiency => true,
          FeatureChoiceSourceType.feat => isLevelFeatSource(choice.sourceClassEntryId),
          _ => false,
        };
    final withoutChoices = character.copyWith(
      featureChoices: [
        for (final choice in character.featureChoices)
          if (!classDerived(choice)) choice,
      ],
    );
    var stripped = ChoiceEffects.apply(character, withoutChoices, data);

    final classTools = <String>{};
    final languages = <String>{};
    for (final entry in character.classEntries) {
      final cls = data.classNamed(entry.className);
      classTools.addAll(entry.isStartingClass ? cls.toolProficiencies : cls.multiclass.tools);
      final language = classLanguages[entry.className];
      if (entry.isStartingClass && language != null) languages.add(language);
    }
    final classEntryIds = {for (final entry in character.classEntries) entry.id};
    stripped = stripped.copyWith(
      abilityScores: scores,
      features: [
        for (final feature in stripped.features)
          if (!classTools.any((tool) => feature == 'Tool Proficiency: $tool')) feature,
      ],
      languages: [
        for (final language in stripped.languages)
          if (!languages.contains(language)) language,
      ],
      spells: [
        for (final spell in stripped.spells)
          if (!classEntryIds.contains(spell.sourceClassEntryId) &&
              spell.sourceType != FeatureChoiceSourceType.subclassFeature &&
              spell.sourceType != FeatureChoiceSourceType.classFeature &&
              spell.sourceType != 'class' &&
              !isLevelFeatSource(spell.sourceClassEntryId))
            spell,
      ],
      extraFeatures: [
        for (final feature in stripped.extraFeatures)
          if (!isLevelFeatSource(feature.sourceClassEntryId) &&
              !classEntryIds.contains(feature.sourceClassEntryId))
            feature,
      ],
    );
    return stripped;
  }

  /// Choices a level 1 class asks for: class skills and tools, level 1
  /// feature choices, and class-table cantrips and spells.
  static List<FeatureChoiceRequest> levelOneRequests(
    Character character,
    Rules2024Data data,
    String className,
  ) {
    final base = _withoutClasses(character, data);
    final cls = data.classNamed(className);
    final entryId = character.primaryClass.id;
    final requests = <FeatureChoiceRequest>[
      _skillRequest(
        base,
        data,
        FeatureChoiceSourceType.classFeature,
        cls.name,
        entryId,
        ChoiceEffects.classSkillsFeature,
        cls.skillChoices,
      ),
      if (cls.toolChoice != null)
        _toolRequest(
          data,
          FeatureChoiceSourceType.classFeature,
          cls.name,
          entryId,
          ChoiceEffects.toolFeature,
          cls.toolChoice!,
        ),
      for (final name in cls.featuresAt(1))
        ...FeatureChoiceEngine.requestsForClassFeature(
          catalog: data.choices,
          className: cls.name,
          sourceClassEntryId: entryId,
          featureName: name,
          level: 1,
        ),
    ];
    final row = cls.rowAt(1);
    final cantrips = (row['cantripsKnown'] as num?)?.toInt() ?? 0;
    final spells = cls.name == 'Wizard'
        ? 6
        : (row['preparedSpells'] as num?)?.toInt() ?? 0;
    final spellFeature = cls.spellcastingType == 'warlock' ? 'Pact Magic' : 'Spellcasting';
    for (final (id, type, count) in [
      ('cantrips', 'cantrip', cantrips),
      ('prepared_spells', 'spell', spells),
    ]) {
      if (count <= 0) continue;
      requests.add(
        FeatureChoiceRequest(
          sourceType: FeatureChoiceSourceType.classFeature,
          sourceClass: cls.name,
          sourceClassEntryId: entryId,
          featureName: spellFeature,
          level: 1,
          requirement: SrdFeatureChoiceRequirement(
            id: id,
            type: type,
            count: count,
            spellClass: cls.name.toLowerCase(),
            spellLevel: type == 'spell' ? 1 : 0,
          ),
          requiredCount: count,
        ),
      );
    }
    return requests;
  }

  /// Choices saved for [className] at level 1, to prefill a reset into the
  /// same class.
  static List<CharacterFeatureChoice> currentLevelOneChoices(
    Character character,
    Rules2024Data data,
  ) {
    final entry = character.primaryClass;
    final requests = levelOneRequests(character, data, entry.className);
    final classSpells = [
      for (final spell in character.spells)
        if (countsAgainstClassLimits(spell, entry)) spell,
    ];
    return [
      for (final request in requests)
        switch (request.choiceId) {
          'cantrips' when ChoiceEffects.classSpellFeatures.contains(request.featureName) =>
            request.toChoice([for (final s in classSpells) if (s.level == 0) s.name]),
          'prepared_spells' when ChoiceEffects.classSpellFeatures.contains(request.featureName) =>
            request.toChoice([for (final s in classSpells) if (s.level == 1) s.name]),
          _ => request.toChoice(request.findIn(character.featureChoices)?.values ?? const []),
        },
    ];
  }

  /// Returns the sheet to level 1 in [className] (the starting class by
  /// default), keeping origin choices, narrative data, inventory and manual
  /// ability edits. Later levels are undone from the saved history.
  static Character resetToLevelOne(
    Character character,
    Rules2024Data data, {
    String? className,
    List<CharacterFeatureChoice>? choices,
  }) {
    _require2024(character);
    if (!canResetToLevelOne(character)) {
      throw StateError('This sheet has no complete level history.');
    }
    final history = historyFor(character);
    final cls = data.classNamed(className ?? character.primaryClass.className);
    final requests = levelOneRequests(character, data, cls.name);
    final selected = choices ?? currentLevelOneChoices(character, data);
    final newChoices = [
      for (final request in requests)
        if (request.isApplicable(selected))
          request.findIn(selected) ?? request.emptyChoice(),
    ];
    if (!FeatureChoiceEngine.allComplete(requests, newChoices)) {
      throw ArgumentError('Some level 1 choices are incomplete.');
    }
    final base = _withoutClasses(character, data);
    final entry = CharacterClassEntry(
      id: character.primaryClass.id,
      className: cls.name,
      level: 1,
      isStartingClass: true,
    );
    final maxHp = _levelOneHitPoints(cls, base.abilityScores, data);
    final fixedSpell = classLevelOneSpells[cls.name];
    final language = classLanguages[cls.name];
    var reset = base.copyWith(
      level: 1,
      characterClass: cls.name,
      clearSubclass: true,
      classes: [entry],
      proficiencyBonus: proficiencyBonus(1),
      savingThrowProficiencies: cls.savingThrows,
      hitPoints: base.hitPoints.copyWith(
        maximum: maxHp,
        current: maxHp,
        hitDiceUsed: 0,
        deathSaveSuccesses: 0,
        deathSaveFailures: 0,
      ),
      hitDicePools: [
        CharacterHitDiePool(
          dieSize: cls.hitDie,
          total: 1,
          sourceClass: cls.name,
          sourceClassEntryId: entry.id,
        ),
      ],
      features: [
        ...base.features,
        for (final tool in cls.toolProficiencies)
          if (!base.features.contains('Tool Proficiency: $tool'))
            'Tool Proficiency: $tool',
      ],
      languages: [
        ...base.languages,
        if (language != null && !base.languages.contains(language)) language,
      ],
      spells: [
        ...base.spells,
        if (fixedSpell != null &&
            !base.spells.any((s) => s.name == fixedSpell.$1))
          KnownSpell(
            name: fixedSpell.$1,
            level: data.spellNamed(fixedSpell.$1)?.level ?? 0,
            isAlwaysPrepared: true,
            isPrepared: true,
            sourceType: FeatureChoiceSourceType.classFeature,
            sourceClass: cls.name,
            sourceFeature: fixedSpell.$2,
          ),
      ],
      concentrationSpell: null,
      // Level 1 Druids have no Wild Shape.
      wildShape: null,
    );
    reset = ChoiceEffects.apply(
      base,
      reset.copyWith(
        featureChoices: FeatureChoiceEngine.upsertChoices(reset.featureChoices, newChoices),
      ),
      data,
    );
    final limits = spellcastingFor(reset, data.classes).firstOrNull;
    if (limits?.spellbookSize != null) {
      var prepared = 0;
      reset = reset.copyWith(
        spells: [
          for (final spell in reset.spells)
            if (spell.level > 0 && countsAgainstClassLimits(spell, entry))
              spell.copyWith(isPrepared: ++prepared <= limits!.preparedSpells)
            else
              spell,
        ],
      );
    }
    final (standard, pact) = slotsFor(reset, data);
    reset = reset.copyWith(
      spellSlots: standard,
      pactMagicSlots: pact,
      levelHistory: [
        CharacterLevelRecord(
          characterLevel: 1,
          classEntryId: entry.id,
          className: cls.name,
          classLevel: 1,
          hitPointsGained: maxHp,
          hitPointMethod: HitPointGainMethod.maximum,
          baseAbilityScores: history.first.baseAbilityScores,
        ),
      ],
    );
    return reset.copyWith(armorClass: calcArmorClass(reset));
  }
}
