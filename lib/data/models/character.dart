import 'package:json_annotation/json_annotation.dart';

import '../json_helpers.dart';
import 'ability_scores.dart';
import 'character_appearance.dart';
import 'character_class_entry.dart';
import 'character_extra_feature.dart';
import 'character_feature_choice.dart';
import 'character_hit_die_pool.dart';
import 'character_note.dart';
import 'character_personality.dart';
import 'character_sheet_preferences.dart';
import 'equipment_item.dart';
import 'hit_points.dart';
import 'spell.dart';

part 'character.g.dart';

// Sentinel used to distinguish "not passed" from explicit null in copyWith.
const _keep = Object();
const currentCharacterDataVersion = 9;

CharacterSheetPreferences _characterSheetPreferencesFromJson(Object? json) =>
    CharacterSheetPreferences.fromJson(json);

Map<String, dynamic> _characterSheetPreferencesToJson(
  CharacterSheetPreferences value,
) =>
    value.toJson();

enum CreationMode { random, semiRandom, guided, manual }

@JsonSerializable(explicitToJson: true)
class Character {
  final String id;
  final int dataVersion;
  final String name;
  final String playerName;
  final String race;
  final String? subrace;

  /// Legacy mirror of the starting class.
  ///
  /// New class-rule code should use [classEntries], [primaryClass], or
  /// [classLevel] instead. This field remains persisted so older `.dndchar`
  /// and `.dndbackup` payloads can still be read safely.
  final String characterClass;

  /// Legacy mirror of the starting class subclass.
  ///
  /// New subclass-rule code should use [primaryClass] or the target
  /// [CharacterClassEntry] instead.
  final String? subclass;

  /// Persisted total character level.
  ///
  /// Class-specific rules should use the level on the relevant
  /// [CharacterClassEntry]. Total-level rules such as proficiency bonus and XP
  /// can use [totalLevel] or this synchronized mirror.
  final int level;
  final List<CharacterClassEntry> classes;
  final int experiencePoints;
  final String background;
  final String alignment;
  final AbilityScores abilityScores;
  final HitPoints hitPoints;
  final int armorClass;
  final int speed;
  final int proficiencyBonus;
  final List<String> savingThrowProficiencies;
  final List<String> skillProficiencies;
  final List<String> skillExpertises;
  final List<EquipmentItem> equipment;
  final Map<String, int> currency;
  final List<KnownSpell> spells;
  final SpellSlots spellSlots;
  final SpellSlots pactMagicSlots;
  final List<CharacterHitDiePool> hitDicePools;
  final List<InnateSpell> innateSpells;
  final List<String> features;
  final List<CharacterExtraFeature> extraFeatures;
  final List<CharacterFeatureChoice> featureChoices;
  final Map<String, int> featureResources;
  final List<String> disabledFeatures;
  final List<String> disabledSpells;
  final List<String> languages;
  final CharacterPersonality personality;
  final CharacterAppearance appearance;
  final String backstory;
  @JsonKey(fromJson: readBool)
  final bool inspiration;
  final List<CharacterNote> notes;
  @JsonKey(
    fromJson: _characterSheetPreferencesFromJson,
    toJson: _characterSheetPreferencesToJson,
  )
  final CharacterSheetPreferences sheetPreferences;
  final String? imagePath;
  final CreationMode creationMode;
  final DateTime createdAt;
  final DateTime updatedAt;
  @JsonKey(fromJson: readBool)
  final bool isPinned;
  final int sortOrder;
  @JsonKey(fromJson: readBool)
  final bool xpTrackingEnabled;
  @JsonKey(fromJson: readBool)
  final bool weightTrackingEnabled;
  final List<String> activeConditions;
  final String? concentrationSpell;

  const Character({
    required this.id,
    this.dataVersion = currentCharacterDataVersion,
    required this.name,
    this.playerName = '',
    required this.race,
    this.subrace,
    required this.characterClass,
    this.subclass,
    this.level = 1,
    this.classes = const [],
    this.experiencePoints = 0,
    this.background = '',
    this.alignment = '',
    required this.abilityScores,
    required this.hitPoints,
    this.armorClass = 10,
    this.speed = 30,
    this.proficiencyBonus = 2,
    this.savingThrowProficiencies = const [],
    this.skillProficiencies = const [],
    this.skillExpertises = const [],
    this.equipment = const [],
    this.currency = const {'cp': 0, 'sp': 0, 'ep': 0, 'gp': 0, 'pp': 0},
    this.spells = const [],
    this.spellSlots = const SpellSlots(),
    this.pactMagicSlots = const SpellSlots(),
    this.hitDicePools = const [],
    this.innateSpells = const [],
    this.features = const [],
    this.extraFeatures = const [],
    this.featureChoices = const [],
    this.featureResources = const {},
    this.disabledFeatures = const [],
    this.disabledSpells = const [],
    this.languages = const [],
    this.personality = const CharacterPersonality(),
    this.appearance = const CharacterAppearance(),
    this.backstory = '',
    this.inspiration = false,
    this.notes = const [],
    this.sheetPreferences = const CharacterSheetPreferences(),
    this.imagePath,
    this.creationMode = CreationMode.manual,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.sortOrder = 0,
    this.xpTrackingEnabled = false,
    this.weightTrackingEnabled = false,
    this.activeConditions = const [],
    this.concentrationSpell,
  });

  /// Passive perception = 10 + perception modifier
  int get passivePerception {
    final wisdomMod = abilityScores.wisdomModifier;
    final hasProficiency = skillProficiencies.contains('perception');
    final hasExpertise = skillExpertises.contains('perception');
    final profBonus = hasProficiency ? proficiencyBonus : 0;
    final expertiseBonus = hasExpertise ? proficiencyBonus : 0;
    return 10 + wisdomMod + profBonus + expertiseBonus;
  }

  /// Initiative = dexterity modifier
  int get initiative => abilityScores.dexterityModifier;

  List<CharacterClassEntry> get classEntries {
    if (classes.isNotEmpty) return classes;
    return [
      CharacterClassEntry(
        id: 'primary',
        className: characterClass,
        subclassName: subclass,
        level: level,
        isStartingClass: true,
      ),
    ];
  }

  bool get isMulticlass => classEntries.length > 1;

  String get primaryClassName => primaryClass.className;

  String? get primarySubclassName => primaryClass.subclassName;

  String get classLevelSummary => classEntries
      .map((entry) => '${entry.className} ${entry.level}')
      .join(' / ');

  int get totalLevel {
    if (classes.isEmpty) return level;
    return classes.fold<int>(0, (sum, entry) => sum + entry.level);
  }

  CharacterClassEntry get primaryClass {
    for (final entry in classEntries) {
      if (entry.isStartingClass) return entry;
    }
    return classEntries.first;
  }

  int classLevel(String className) {
    final lower = className.toLowerCase();
    var total = 0;
    for (final entry in classEntries) {
      if (entry.className.toLowerCase() == lower) total += entry.level;
    }
    return total;
  }

  String? subclassFor(String className) {
    final lower = className.toLowerCase();
    for (final entry in classEntries) {
      if (entry.className.toLowerCase() == lower) return entry.subclassName;
    }
    return null;
  }

  Map<String, CharacterClassEntry> get classEntriesByName => {
    for (final entry in classEntries) entry.className: entry,
  };

  String? classEntryIdFor(String className) {
    final lower = className.toLowerCase();
    for (final entry in classEntries) {
      if (entry.className.toLowerCase() == lower) return entry.id;
    }
    return null;
  }

  int get totalHitDice {
    if (hitDicePools.isEmpty) return level;
    return hitDicePools.fold<int>(0, (sum, pool) => sum + pool.total);
  }

  int get totalHitDiceUsed {
    if (hitDicePools.isEmpty) return hitPoints.hitDiceUsed;
    return hitDicePools.fold<int>(0, (sum, pool) => sum + pool.used);
  }

  int get availableHitDice =>
      (totalHitDice - totalHitDiceUsed).clamp(0, totalHitDice).toInt();

  Character copyWith({
    String? id,
    int? dataVersion,
    String? name,
    String? playerName,
    String? race,
    String? subrace,
    String? characterClass,
    String? subclass,
    bool clearSubclass = false,
    int? level,
    List<CharacterClassEntry>? classes,
    int? experiencePoints,
    String? background,
    String? alignment,
    AbilityScores? abilityScores,
    HitPoints? hitPoints,
    int? armorClass,
    int? speed,
    int? proficiencyBonus,
    List<String>? savingThrowProficiencies,
    List<String>? skillProficiencies,
    List<String>? skillExpertises,
    List<EquipmentItem>? equipment,
    Map<String, int>? currency,
    List<KnownSpell>? spells,
    SpellSlots? spellSlots,
    SpellSlots? pactMagicSlots,
    List<CharacterHitDiePool>? hitDicePools,
    List<InnateSpell>? innateSpells,
    List<String>? features,
    List<CharacterExtraFeature>? extraFeatures,
    List<CharacterFeatureChoice>? featureChoices,
    Map<String, int>? featureResources,
    List<String>? disabledFeatures,
    List<String>? disabledSpells,
    List<String>? languages,
    CharacterPersonality? personality,
    CharacterAppearance? appearance,
    String? backstory,
    bool? inspiration,
    List<CharacterNote>? notes,
    CharacterSheetPreferences? sheetPreferences,
    String? imagePath,
    bool clearImagePath = false,
    CreationMode? creationMode,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    int? sortOrder,
    bool? xpTrackingEnabled,
    bool? weightTrackingEnabled,
    List<String>? activeConditions,
    Object? concentrationSpell = _keep,
  }) {
    return Character(
      id: id ?? this.id,
      dataVersion: dataVersion ?? this.dataVersion,
      name: name ?? this.name,
      playerName: playerName ?? this.playerName,
      race: race ?? this.race,
      subrace: subrace ?? this.subrace,
      characterClass: characterClass ?? this.characterClass,
      subclass: clearSubclass ? null : (subclass ?? this.subclass),
      level: level ?? this.level,
      classes: classes ?? this.classes,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      background: background ?? this.background,
      alignment: alignment ?? this.alignment,
      abilityScores: abilityScores ?? this.abilityScores,
      hitPoints: hitPoints ?? this.hitPoints,
      armorClass: armorClass ?? this.armorClass,
      speed: speed ?? this.speed,
      proficiencyBonus: proficiencyBonus ?? this.proficiencyBonus,
      savingThrowProficiencies:
          savingThrowProficiencies ?? this.savingThrowProficiencies,
      skillProficiencies: skillProficiencies ?? this.skillProficiencies,
      skillExpertises: skillExpertises ?? this.skillExpertises,
      equipment: equipment ?? this.equipment,
      currency: currency ?? this.currency,
      spells: spells ?? this.spells,
      spellSlots: spellSlots ?? this.spellSlots,
      pactMagicSlots: pactMagicSlots ?? this.pactMagicSlots,
      hitDicePools: hitDicePools ?? this.hitDicePools,
      innateSpells: innateSpells ?? this.innateSpells,
      features: features ?? this.features,
      extraFeatures: extraFeatures ?? this.extraFeatures,
      featureChoices: featureChoices ?? this.featureChoices,
      featureResources: featureResources ?? this.featureResources,
      disabledFeatures: disabledFeatures ?? this.disabledFeatures,
      disabledSpells: disabledSpells ?? this.disabledSpells,
      languages: languages ?? this.languages,
      personality: personality ?? this.personality,
      appearance: appearance ?? this.appearance,
      backstory: backstory ?? this.backstory,
      inspiration: inspiration ?? this.inspiration,
      notes: notes ?? this.notes,
      sheetPreferences: sheetPreferences ?? this.sheetPreferences,
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
      creationMode: creationMode ?? this.creationMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      sortOrder: sortOrder ?? this.sortOrder,
      xpTrackingEnabled: xpTrackingEnabled ?? this.xpTrackingEnabled,
      weightTrackingEnabled:
          weightTrackingEnabled ?? this.weightTrackingEnabled,
      activeConditions: activeConditions ?? this.activeConditions,
      concentrationSpell: concentrationSpell == _keep
          ? this.concentrationSpell
          : concentrationSpell as String?,
    );
  }

  factory Character.fromJson(Map<String, dynamic> json) =>
      _$CharacterFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterToJson(this);
}
