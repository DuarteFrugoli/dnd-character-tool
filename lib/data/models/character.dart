import 'package:json_annotation/json_annotation.dart';

import 'ability_scores.dart';
import 'character_appearance.dart';
import 'character_personality.dart';
import 'equipment_item.dart';
import 'hit_points.dart';
import 'spell.dart';

part 'character.g.dart';

enum CreationMode { random, semiRandom, guided, manual }

@JsonSerializable(explicitToJson: true)
class Character {
  final String id;
  final String name;
  final String playerName;
  final String race;
  final String? subrace;
  final String characterClass;
  final String? subclass;
  final int level;
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
  final List<String> features;
  final List<String> languages;
  final CharacterPersonality personality;
  final CharacterAppearance appearance;
  final String backstory;
  final String? imagePath;
  final CreationMode creationMode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Character({
    required this.id,
    required this.name,
    this.playerName = '',
    required this.race,
    this.subrace,
    required this.characterClass,
    this.subclass,
    this.level = 1,
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
    this.features = const [],
    this.languages = const [],
    this.personality = const CharacterPersonality(),
    this.appearance = const CharacterAppearance(),
    this.backstory = '',
    this.imagePath,
    this.creationMode = CreationMode.manual,
    required this.createdAt,
    required this.updatedAt,
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

  Character copyWith({
    String? id,
    String? name,
    String? playerName,
    String? race,
    String? subrace,
    String? characterClass,
    String? subclass,
    int? level,
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
    List<String>? features,
    List<String>? languages,
    CharacterPersonality? personality,
    CharacterAppearance? appearance,
    String? backstory,
    String? imagePath,
    CreationMode? creationMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      playerName: playerName ?? this.playerName,
      race: race ?? this.race,
      subrace: subrace ?? this.subrace,
      characterClass: characterClass ?? this.characterClass,
      subclass: subclass ?? this.subclass,
      level: level ?? this.level,
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
      features: features ?? this.features,
      languages: languages ?? this.languages,
      personality: personality ?? this.personality,
      appearance: appearance ?? this.appearance,
      backstory: backstory ?? this.backstory,
      imagePath: imagePath ?? this.imagePath,
      creationMode: creationMode ?? this.creationMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Character.fromJson(Map<String, dynamic> json) =>
      _$CharacterFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterToJson(this);
}
