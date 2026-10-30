import '../constants/armor_class.dart';
import '../datasources/srd/srd_2024_creation_catalog.dart';
import '../datasources/srd/srd_models.dart';
import '../feature_choice_engine.dart';
import '../feature_choice_option_resolver.dart';
import '../models/models.dart';
import '../rulesets/ruleset_ids.dart';

/// SRD 5.2.1 content the 2024 progression rules read.
class Rules2024Data {
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
  });

  final List<Creation2024Class> classes;
  final Map<String, List<Creation2024Subclass>> subclasses;
  final Map<String, Map<String, List<SrdClassFeature>>> subclassFeatures;
  final List<SrdFeat> feats;
  final SrdFeatureChoiceCatalog choices;
  final List<SrdSpell> spells;
  final List<SrdSkill> skills;
  final List<SrdTool> tools;
  final List<SrdLanguage> languages;

  /// Trait names of the character's species.
  final List<String> speciesTraits;

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

  SrdFeat? featNamed(String name) {
    for (final feat in feats) {
      if (feat.name == name) return feat;
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

  /// Spells chosen through the class table rather than a feature choice.
  static const _classSpellFeatures = {'Spellcasting', 'Pact Magic'};

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

  /// Level records of [character]. Sheets created before history was saved
  /// can only be reconstructed while they are still level 1.
  static List<CharacterLevelRecord> historyFor(Character character) {
    if (character.levelHistory.isNotEmpty) return character.levelHistory;
    if (character.totalLevel != 1) return const [];
    final entry = character.primaryClass;
    final bonuses = backgroundAbilityBonuses(character);
    return [
      CharacterLevelRecord(
        characterLevel: 1,
        classEntryId: entry.id,
        className: entry.className,
        classLevel: 1,
        hitPointsGained: character.hitPoints.maximum,
        hitPointMethod: HitPointGainMethod.maximum,
        baseAbilityScores: {
          for (final ability in _abilities)
            ability: character.abilityScores[ability] - (bonuses[ability] ?? 0),
        },
      ),
    ];
  }

  /// Background increases saved by 2024 creation as `ability:bonus` values.
  static Map<String, int> backgroundAbilityBonuses(Character character) {
    final result = <String, int>{};
    for (final choice in character.featureChoices) {
      if (choice.sourceType != FeatureChoiceSourceType.background ||
          choice.choiceId != 'ability_scores') {
        continue;
      }
      for (final value in choice.values) {
        final parts = value.split(':');
        final bonus = parts.length == 2 ? int.tryParse(parts[1]) : null;
        if (bonus != null) result[parts[0]] = bonus;
      }
    }
    return result;
  }

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
      if (featName != null) ...featRequests(data, featName, plan.newTotalLevel),
      if (plan.isNewClass) ..._multiclassRequests(character, data, plan),
    ];
    return requests;
  }

  /// Non-ability choices of a feat gained at [characterLevel].
  static List<FeatureChoiceRequest> featRequests(
    Rules2024Data data,
    String featName,
    int characterLevel,
  ) {
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
            requirement: request.requirement,
            requiredCount: request.requiredCount,
          ),
    ];
  }

  static List<FeatureChoiceRequest> _multiclassRequests(
    Character character,
    Rules2024Data data,
    LevelUp2024Plan plan,
  ) {
    final proficiencies = plan.cls.multiclass;
    final requests = <FeatureChoiceRequest>[];
    final skillChoice = proficiencies.skillChoice;
    if (skillChoice != null) {
      final known = character.skillProficiencies.toSet();
      requests.add(
        _multiclassRequest(
          plan,
          SrdFeatureChoiceRequirement(
            id: 'skills',
            type: 'option',
            count: skillChoice.count,
            options: [
              for (final skill in skillChoice.isAny
                  ? [for (final skill in data.skills) skill.name.toLowerCase()]
                  : skillChoice.from)
                if (!known.contains(skill))
                  SrdFeatureChoiceOption(
                    id: FeatureChoiceOptionResolver.idFromName(skill),
                    name: _titleCase(skill),
                  ),
            ],
          ),
          skillChoice.count,
        ),
      );
    }
    final toolChoice = proficiencies.toolChoice;
    if (toolChoice != null) {
      requests.add(
        _multiclassRequest(
          plan,
          SrdFeatureChoiceRequirement(
            id: 'tools',
            type: 'option',
            count: toolChoice.count,
            options: [
              for (final tool in data.tools)
                if (toolChoice.categories.contains(tool.category))
                  SrdFeatureChoiceOption(
                    id: FeatureChoiceOptionResolver.idFromName(tool.name),
                    name: tool.name,
                  ),
            ],
          ),
          toolChoice.count,
        ),
      );
    }
    return requests;
  }

  static FeatureChoiceRequest _multiclassRequest(
    LevelUp2024Plan plan,
    SrdFeatureChoiceRequirement requirement,
    int count,
  ) => FeatureChoiceRequest(
    sourceType: FeatureChoiceSourceType.multiclassProficiency,
    sourceClass: plan.cls.name,
    sourceClassEntryId: plan.classEntryId,
    featureName: multiclassFeatureName,
    level: 1,
    requirement: requirement,
    requiredCount: count,
  );

  static String _titleCase(String value) => value
      .split(' ')
      .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');

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
            _classSpellFeatures.contains(spell.sourceFeature));
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
            !spell.isAlwaysPrepared)
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
    updated = _applyChoiceEffects(updated, data, requests, character.featureChoices);
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

  /// Applies skills, expertise, tools, languages and spells from values that
  /// [requests] added compared to [previous].
  static Character _applyChoiceEffects(
    Character character,
    Rules2024Data data,
    List<FeatureChoiceRequest> requests,
    List<CharacterFeatureChoice> previous,
  ) {
    final skills = {...character.skillProficiencies};
    final expertise = {...character.skillExpertises};
    final features = [...character.features];
    final languages = [...character.languages];
    final spells = [...character.spells];
    final spellsByName = {
      for (final spell in data.spells) spell.name.toLowerCase(): spell,
    };
    final toolNames = {
      for (final tool in data.tools)
        FeatureChoiceOptionResolver.idFromName(tool.name): tool.name,
    };
    final languageNames = {
      for (final language in data.languages)
        FeatureChoiceOptionResolver.idFromName(language.name): language.name,
    };
    void addTool(String id) {
      final label = 'Tool Proficiency: ${toolNames[id] ?? id.replaceAll('_', ' ')}';
      if (!features.contains(label)) features.add(label);
    }

    for (final request in requests) {
      final choice = request.findIn(character.featureChoices);
      if (choice == null || !request.isApplicable(character.featureChoices)) {
        continue;
      }
      final before = request.findIn(previous)?.values.toSet() ?? const {};
      for (final value in choice.values.where((v) => !before.contains(v))) {
        final name = value.replaceAll('_', ' ');
        switch (request.requirement.type) {
          case 'skill':
            skills.add(name);
          case 'skill_expertise':
            expertise.add(name);
          case 'skill_or_tool_expertise':
            if (value.startsWith('skill:')) {
              expertise.add(value.substring(6).replaceAll('_', ' '));
            }
          case 'skill_or_tool':
            if (value.startsWith('skill:')) {
              skills.add(value.substring(6).replaceAll('_', ' '));
            } else if (value.startsWith('tool:')) {
              addTool(value.substring(5));
            }
          case 'tool':
            addTool(value);
          case 'language':
            final language = languageNames[value] ?? name;
            if (!languages.contains(language)) languages.add(language);
          case 'cantrip':
          case 'spell':
            final spell = spellsByName[value.toLowerCase()] ??
                spellsByName[name.toLowerCase()];
            final spellName = spell?.name ?? value;
            if (spells.any((s) => s.name.toLowerCase() == spellName.toLowerCase())) {
              continue;
            }
            spells.add(
              KnownSpell(
                name: spellName,
                level: spell?.level ?? (request.requirement.type == 'cantrip' ? 0 : 1),
                isPrepared: true,
                isAlwaysPrepared: request.requirement.type == 'spell',
                sourceType: request.sourceType,
                sourceClass: request.sourceClass.isEmpty ? null : request.sourceClass,
                sourceSubclass: request.sourceSubclass,
                sourceFeature: request.featureName,
                sourceClassEntryId: request.sourceClassEntryId,
              ),
            );
          case 'option':
            if (request.sourceType == FeatureChoiceSourceType.multiclassProficiency) {
              if (request.choiceId == 'skills') skills.add(name);
              if (request.choiceId == 'tools') addTool(value);
            }
        }
      }
    }
    return character.copyWith(
      skillProficiencies: skills.toList(),
      skillExpertises: expertise.toList(),
      features: features,
      languages: languages,
      spells: spells,
    );
  }

  // ── Level reset ──────────────────────────────────────────────────────────

  static bool canResetToLevelOne(Character character) =>
      character.rulesetId == RulesetId.dnd2024 &&
      character.totalLevel > 1 &&
      historyFor(character).length == character.totalLevel;

  /// Returns the sheet to level 1 in its starting class, undoing every later
  /// level from the saved history while keeping origin choices, narrative
  /// data, inventory and manual ability edits.
  static Character resetToLevelOne(Character character, Rules2024Data data) {
    _require2024(character);
    if (!canResetToLevelOne(character)) {
      throw StateError('This sheet has no complete level history.');
    }
    final history = historyFor(character);
    final starting = character.primaryClass;
    final cls = data.classNamed(starting.className);
    var scores = character.abilityScores;
    for (final record in history.skip(1)) {
      for (final entry in record.abilityIncreases.entries) {
        scores = _withScore(scores, entry.key, scores[entry.key] - entry.value);
      }
    }
    final maxHp = cls.hitDie +
        scores.constitutionModifier +
        (_hasDwarvenToughness(data) ? 1 : 0);
    final entry = CharacterClassEntry(
      id: starting.id,
      className: starting.className,
      level: 1,
      isStartingClass: true,
    );

    final levelOneRequests = <String>{
      for (final name in cls.featuresAt(1))
        for (final request in FeatureChoiceEngine.requestsForClassFeature(
          catalog: data.choices,
          className: cls.name,
          sourceClassEntryId: starting.id,
          featureName: name,
          level: 1,
        ))
          request.key,
    };
    final kept = <CharacterFeatureChoice>[];
    final dropped = <CharacterFeatureChoice>[];
    for (final choice in character.featureChoices) {
      final keep = switch (choice.sourceType) {
        FeatureChoiceSourceType.classFeature =>
          choice.sourceClassEntryId == starting.id &&
              (_classSpellFeatures.contains(choice.featureName) ||
                  choice.featureName == 'Tool Proficiency' ||
                  choice.featureName == 'Starting Equipment' ||
                  levelOneRequests.contains(_choiceKey(choice))),
        FeatureChoiceSourceType.subclassFeature ||
        FeatureChoiceSourceType.multiclassProficiency => false,
        FeatureChoiceSourceType.feat =>
          !isLevelFeatSource(choice.sourceClassEntryId),
        _ => true,
      };
      if (!keep) {
        dropped.add(choice);
        continue;
      }
      final definition = choice.sourceType == FeatureChoiceSourceType.classFeature
          ? data.choices
                .classFeature(cls.name, choice.featureName)
                ?.choices
                .where((c) => c.id == choice.choiceId)
                .firstOrNull
          : null;
      if (definition != null && definition.countByLevel.isNotEmpty) {
        final count = definition.requiredCountAtLevel(1);
        dropped.add(choice.copyWith(values: choice.values.skip(count).toList()));
        kept.add(choice.copyWith(values: choice.values.take(count).toList()));
      } else {
        kept.add(choice);
      }
    }

    final droppedTools = <String>{};
    final droppedSkills = <String>{};
    final droppedExpertise = <String>{};
    final droppedLanguages = <String>{};
    final languageNames = {
      for (final language in data.languages)
        FeatureChoiceOptionResolver.idFromName(language.name): language.name,
    };
    final toolNames = {
      for (final tool in data.tools)
        FeatureChoiceOptionResolver.idFromName(tool.name): tool.name,
    };
    for (final choice in dropped) {
      final type = _requirementFor(data, choice)?.type ??
          (choice.sourceType == FeatureChoiceSourceType.multiclassProficiency
              ? 'multiclass_${choice.choiceId}'
              : null);
      for (final value in choice.values) {
        final name = value.replaceAll('_', ' ');
        switch (type) {
          case 'skill' || 'multiclass_skills':
            droppedSkills.add(name);
          case 'skill_expertise':
            droppedExpertise.add(name);
          case 'skill_or_tool_expertise' when value.startsWith('skill:'):
            droppedExpertise.add(value.substring(6).replaceAll('_', ' '));
          case 'skill_or_tool' when value.startsWith('skill:'):
            droppedSkills.add(value.substring(6).replaceAll('_', ' '));
          case 'skill_or_tool' when value.startsWith('tool:'):
            droppedTools.add(toolNames[value.substring(5)] ?? value.substring(5));
          case 'tool' || 'multiclass_tools':
            droppedTools.add(toolNames[value] ?? name);
          case 'language':
            droppedLanguages.add(languageNames[value] ?? name);
        }
      }
    }
    for (final record in history.skip(1)) {
      if (record.classEntryId == starting.id) continue;
      for (final tool in data.classNamed(record.className).multiclass.tools) {
        droppedTools.add(tool);
      }
    }

    final removedEntryIds = {
      for (final e in character.classEntries)
        if (e.id != starting.id) e.id,
    };
    final spells = [
      for (final spell in character.spells)
        if (!removedEntryIds.contains(spell.sourceClassEntryId) &&
            spell.sourceType != FeatureChoiceSourceType.subclassFeature &&
            !isLevelFeatSource(spell.sourceClassEntryId) &&
            !(spell.sourceClass == starting.className && spell.level > 1))
          spell,
    ];
    final spellcasting = spellcastingFor(
      character.copyWith(classes: [entry]),
      data.classes,
    ).firstOrNull;
    var prepared = 0;
    final limitedSpells = [
      for (final spell in spells)
        if (spellcasting != null &&
            spell.level > 0 &&
            spell.isPrepared &&
            countsAgainstClassLimits(spell, entry) &&
            ++prepared > spellcasting.preparedSpells)
          spell.copyWith(isPrepared: false)
        else
          spell,
    ];

    var reset = character.copyWith(
      level: 1,
      characterClass: starting.className,
      clearSubclass: true,
      classes: [entry],
      abilityScores: scores,
      proficiencyBonus: proficiencyBonus(1),
      hitPoints: character.hitPoints.copyWith(
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
          sourceClassEntryId: starting.id,
        ),
      ],
      extraFeatures: [
        for (final feature in character.extraFeatures)
          if (!isLevelFeatSource(feature.sourceClassEntryId) &&
              !removedEntryIds.contains(feature.sourceClassEntryId))
            feature,
      ],
      featureChoices: kept,
      skillProficiencies: [
        for (final skill in character.skillProficiencies)
          if (!droppedSkills.contains(skill)) skill,
      ],
      skillExpertises: [
        for (final skill in character.skillExpertises)
          if (!droppedExpertise.contains(skill)) skill,
      ],
      languages: [
        for (final language in character.languages)
          if (!droppedLanguages.contains(language)) language,
      ],
      features: [
        for (final feature in character.features)
          if (!droppedTools.any((tool) => feature == 'Tool Proficiency: $tool'))
            feature,
      ],
      spells: limitedSpells,
      concentrationSpell: null,
      levelHistory: [history.first],
    );
    final (standard, pact) = slotsFor(reset, data);
    reset = reset.copyWith(spellSlots: standard, pactMagicSlots: pact);
    return reset.copyWith(armorClass: calcArmorClass(reset));
  }

  static String _choiceKey(CharacterFeatureChoice choice) =>
      '${choice.sourceType}|${choice.sourceClass}|${choice.sourceClassEntryId ?? ''}|'
      '${choice.sourceSubclass ?? ''}|${choice.sourceName ?? ''}|'
      '${choice.featureName}|${choice.choiceId}';

  static SrdFeatureChoiceRequirement? _requirementFor(
    Rules2024Data data,
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
      _ => null,
    };
    return definition?.choices.where((c) => c.id == choice.choiceId).firstOrNull;
  }
}
