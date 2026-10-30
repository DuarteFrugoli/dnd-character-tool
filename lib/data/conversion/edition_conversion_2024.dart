import '../character_progression/character_progression_engine.dart';
import '../datasources/srd/srd_2024_creation_catalog.dart';
import '../datasources/srd/srd_models.dart';
import '../models/models.dart';
import '../rulesets/ruleset_ids.dart';

const _abilities = [
  'strength', 'dexterity', 'constitution', 'intelligence', 'wisdom', 'charisma',
];

/// What a 2014 sheet suggests for its 2024 version. The player reviews every
/// value in the 2024 creation flow before anything is saved.
class Conversion2024Prefill {
  const Conversion2024Prefill({
    required this.className,
    required this.speciesName,
    required this.backgroundName,
    required this.baseAbilities,
    required this.abilityIncreasesUnknown,
    required this.skills,
    required this.languages,
  });

  final String? className;

  /// Null when the 2014 race has no 2024 species (Half-Elf, Half-Orc).
  final String? speciesName;
  final String? backgroundName;

  /// Scores without 2014 racial bonuses and recorded level increases; the
  /// 2024 background adds its own increases on top.
  final Map<String, int> baseAbilities;

  /// True when increases chosen freely (Half-Elf, Variant Human) or gained
  /// before level history was recorded may still be in [baseAbilities].
  final bool abilityIncreasesUnknown;
  final List<String> skills;
  final List<String> languages;
}

/// Builds a new 2024 sheet from a 2014 one. The 2014 sheet is never changed.
class EditionConversion2024 {
  const EditionConversion2024._();

  /// 2014 races renamed or folded into a 2024 species.
  static const _speciesFor2014Race = {'Variant Human': 'Human'};

  static Conversion2024Prefill prefill(
    Character old, {
    required List<SrdRace> races2014,
    required Creation2024Catalog catalog,
  }) {
    if (old.rulesetId != RulesetId.dnd2014) {
      throw ArgumentError('Only 2014 sheets can be converted.');
    }
    final race = races2014.where((r) => r.name == old.race).firstOrNull;
    final subrace = race?.subraces.where((s) => s.name == old.subrace).firstOrNull;
    // Race models title-case ability names; free picks (Half-Elf, Variant
    // Human) are counted apart because the sheet does not say where they went.
    final racial = <String, int>{};
    for (final increases in [?race?.abilityScoreIncreases, ?subrace?.abilityScoreIncreases]) {
      for (final entry in increases.entries) {
        final ability = entry.key.toLowerCase();
        racial[ability] = (racial[ability] ?? 0) + entry.value;
      }
    }
    final freeIncreases = (race?.freeAsiPoints ?? 0) > 0;
    final recorded = <String, int>{};
    for (final record in old.levelHistory) {
      for (final entry in record.abilityIncreases.entries) {
        final ability = entry.key.toLowerCase();
        recorded[ability] = (recorded[ability] ?? 0) + entry.value;
      }
    }
    final historyComplete = CharacterProgressionEngine.hasCompleteHistory(old);
    final base = {
      for (final ability in _abilities)
        ability: (old.abilityScores[ability] - (racial[ability] ?? 0) - (recorded[ability] ?? 0))
            .clamp(1, 20)
            .toInt(),
    };

    final startingClass = old.classEntries.where((e) => e.isStartingClass).firstOrNull ??
        old.primaryClass;
    final cls = catalog.classes.where((c) => c.name == startingClass.className).firstOrNull;
    final speciesName = _speciesFor2014Race[old.race] ?? old.race;
    final species = catalog.species.where((s) => s.name == speciesName).firstOrNull;
    final background = catalog.backgrounds.where((b) => b.name == old.background).firstOrNull;
    final known = {for (final skill in old.skillProficiencies) skill.toLowerCase()};
    final allowed = cls == null
        ? const <String>[]
        : cls.skillChoices.isAny
            ? [for (final skill in catalog.skills) skill.name.toLowerCase()]
            : cls.skillChoices.from;
    final skills = [
      for (final skill in allowed)
        if (known.contains(skill.toLowerCase()) &&
            !(background?.skills.contains(skill.toLowerCase()) ?? false))
          skill,
    ].take(cls?.skillChoices.count ?? 0).toList();
    final languageNames = {for (final language in catalog.languages) language.name};
    final languages = [
      for (final language in old.languages)
        if (language != 'Common' && languageNames.contains(language)) language,
    ].take(2).toList();

    return Conversion2024Prefill(
      className: cls?.name,
      speciesName: species?.name,
      backgroundName: background?.name,
      baseAbilities: base,
      abilityIncreasesUnknown: freeIncreases || (!historyComplete && old.totalLevel >= 4),
      skills: skills,
      languages: languages,
    );
  }

  /// Copies what does not depend on the rules from [old] into [converted]:
  /// identity, story, notes, inventory, money, experience and preferences.
  /// Inventory items take the 2024 catalog data of the same item (e.g. weapon
  /// mastery) and keep their quantity, equipped state and container.
  static Character carryOver(
    Character old,
    Character converted, {
    required Map<String, SrdItemData> items,
  }) {
    final equipment = [
      for (final item in old.equipment)
        if (items[item.name.toLowerCase()] case final data?)
          item.copyWith(
            category: data.category,
            weight: data.weight,
            properties: {...?item.properties, ...?data.properties},
          )
        else
          item,
    ];
    return converted.copyWith(
      name: old.name,
      playerName: old.playerName,
      alignment: old.alignment,
      appearance: old.appearance,
      personality: old.personality,
      backstory: old.backstory,
      notes: old.notes,
      equipment: equipment,
      currency: old.currency,
      experiencePoints: old.experiencePoints,
      xpTrackingEnabled: old.xpTrackingEnabled,
      weightTrackingEnabled: old.weightTrackingEnabled,
      inspiration: old.inspiration,
      sheetPreferences: old.sheetPreferences,
    );
  }
}
