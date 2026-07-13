// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Character _$CharacterFromJson(Map<String, dynamic> json) => Character(
  id: json['id'] as String,
  name: json['name'] as String,
  playerName: json['playerName'] as String? ?? '',
  race: json['race'] as String,
  subrace: json['subrace'] as String?,
  characterClass: json['characterClass'] as String,
  subclass: json['subclass'] as String?,
  level: (json['level'] as num?)?.toInt() ?? 1,
  experiencePoints: (json['experiencePoints'] as num?)?.toInt() ?? 0,
  background: json['background'] as String? ?? '',
  alignment: json['alignment'] as String? ?? '',
  abilityScores: AbilityScores.fromJson(
    json['abilityScores'] as Map<String, dynamic>,
  ),
  hitPoints: HitPoints.fromJson(json['hitPoints'] as Map<String, dynamic>),
  armorClass: (json['armorClass'] as num?)?.toInt() ?? 10,
  speed: (json['speed'] as num?)?.toInt() ?? 30,
  proficiencyBonus: (json['proficiencyBonus'] as num?)?.toInt() ?? 2,
  savingThrowProficiencies:
      (json['savingThrowProficiencies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  skillProficiencies:
      (json['skillProficiencies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  skillExpertises:
      (json['skillExpertises'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  equipment:
      (json['equipment'] as List<dynamic>?)
          ?.map((e) => EquipmentItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  currency:
      (json['currency'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {'cp': 0, 'sp': 0, 'ep': 0, 'gp': 0, 'pp': 0},
  spells:
      (json['spells'] as List<dynamic>?)
          ?.map((e) => KnownSpell.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  spellSlots: json['spellSlots'] == null
      ? const SpellSlots()
      : SpellSlots.fromJson(json['spellSlots'] as Map<String, dynamic>),
  innateSpells:
      (json['innateSpells'] as List<dynamic>?)
          ?.map((e) => InnateSpell.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  features:
      (json['features'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  extraFeatures:
      (json['extraFeatures'] as List<dynamic>?)
          ?.map((e) => CharacterExtraFeature.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  featureChoices:
      (json['featureChoices'] as List<dynamic>?)
          ?.map(
            (e) => CharacterFeatureChoice.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  featureResources:
      (json['featureResources'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  disabledFeatures:
      (json['disabledFeatures'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  disabledSpells:
      (json['disabledSpells'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  languages:
      (json['languages'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  personality: json['personality'] == null
      ? const CharacterPersonality()
      : CharacterPersonality.fromJson(
          json['personality'] as Map<String, dynamic>,
        ),
  appearance: json['appearance'] == null
      ? const CharacterAppearance()
      : CharacterAppearance.fromJson(
          json['appearance'] as Map<String, dynamic>,
        ),
  backstory: json['backstory'] as String? ?? '',
  inspiration: json['inspiration'] as bool? ?? false,
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => CharacterNote.fromJson(e as Map<String, dynamic>))
      .toList() ??
      const [],
  imagePath: json['imagePath'] as String?,
  creationMode:
      $enumDecodeNullable(_$CreationModeEnumMap, json['creationMode']) ??
      CreationMode.manual,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isPinned: json['isPinned'] as bool? ?? false,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  xpTrackingEnabled: json['xpTrackingEnabled'] as bool? ?? false,
  weightTrackingEnabled: json['weightTrackingEnabled'] as bool? ?? false,
  activeConditions: (json['activeConditions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList() ?? const [],
  concentrationSpell: json['concentrationSpell'] as String?,
);

Map<String, dynamic> _$CharacterToJson(Character instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'playerName': instance.playerName,
  'race': instance.race,
  'subrace': instance.subrace,
  'characterClass': instance.characterClass,
  'subclass': instance.subclass,
  'level': instance.level,
  'experiencePoints': instance.experiencePoints,
  'background': instance.background,
  'alignment': instance.alignment,
  'abilityScores': instance.abilityScores.toJson(),
  'hitPoints': instance.hitPoints.toJson(),
  'armorClass': instance.armorClass,
  'speed': instance.speed,
  'proficiencyBonus': instance.proficiencyBonus,
  'savingThrowProficiencies': instance.savingThrowProficiencies,
  'skillProficiencies': instance.skillProficiencies,
  'skillExpertises': instance.skillExpertises,
  'equipment': instance.equipment.map((e) => e.toJson()).toList(),
  'currency': instance.currency,
  'spells': instance.spells.map((e) => e.toJson()).toList(),
  'spellSlots': instance.spellSlots.toJson(),
  'innateSpells': instance.innateSpells.map((e) => e.toJson()).toList(),
  'features': instance.features,
  'extraFeatures': instance.extraFeatures.map((e) => e.toJson()).toList(),
  'featureChoices': instance.featureChoices.map((e) => e.toJson()).toList(),
  'featureResources': instance.featureResources,
  'disabledFeatures': instance.disabledFeatures,
  'disabledSpells': instance.disabledSpells,
  'languages': instance.languages,
  'personality': instance.personality.toJson(),
  'appearance': instance.appearance.toJson(),
  'backstory': instance.backstory,
  'inspiration': instance.inspiration,
  'notes': instance.notes.map((e) => e.toJson()).toList(),
  'imagePath': instance.imagePath,
  'creationMode': _$CreationModeEnumMap[instance.creationMode]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'isPinned': instance.isPinned,
  'sortOrder': instance.sortOrder,
  'xpTrackingEnabled': instance.xpTrackingEnabled,
  'weightTrackingEnabled': instance.weightTrackingEnabled,
  'activeConditions': instance.activeConditions,
  'concentrationSpell': instance.concentrationSpell,
};

const _$CreationModeEnumMap = {
  CreationMode.random: 'random',
  CreationMode.semiRandom: 'semiRandom',
  CreationMode.guided: 'guided',
  CreationMode.manual: 'manual',
};
