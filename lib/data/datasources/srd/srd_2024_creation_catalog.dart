import 'dart:convert';

import 'package:flutter/services.dart';

import '../../rulesets/srd_content_pack.dart';
import 'srd_data_source.dart';
import 'srd_models.dart';

class Creation2024Item {
  const Creation2024Item({this.name, this.category, this.selection, this.choiceFrom, this.variant, required this.quantity});

  final String? name;
  final String? category;
  final String? selection;
  final String? choiceFrom;
  final String? variant;
  final int quantity;

  factory Creation2024Item.fromJson(Map<String, dynamic> json) => Creation2024Item(
    name: json['name'] as String?,
    category: json['category'] as String?,
    selection: json['selection'] as String?,
    choiceFrom: json['choiceFrom'] as String?,
    variant: json['variant'] as String?,
    quantity: (json['quantity'] as num? ?? 1).toInt(),
  );
}

class Creation2024ToolChoice {
  const Creation2024ToolChoice({required this.categories, required this.count});

  final List<String> categories;
  final int count;

  factory Creation2024ToolChoice.fromJson(Map<String, dynamic> json) => Creation2024ToolChoice(
    categories: json['categories'] is List
        ? List<String>.from(json['categories'] as List)
        : [json['category'] as String],
    count: (json['count'] as num).toInt(),
  );
}

class Creation2024Equipment {
  const Creation2024Equipment({required this.id, required this.items, required this.gp});

  final String id;
  final List<Creation2024Item> items;
  final int gp;

  factory Creation2024Equipment.fromJson(Map<String, dynamic> json) => Creation2024Equipment(
    id: json['id'] as String,
    items: (json['items'] as List<dynamic>).map((item) => Creation2024Item.fromJson(item as Map<String, dynamic>)).toList(),
    gp: (json['gp'] as num).toInt(),
  );
}

class Creation2024MulticlassProficiencies {
  const Creation2024MulticlassProficiencies({
    this.armor = const [],
    this.weapons = const [],
    this.tools = const [],
    this.toolChoice,
    this.skillChoice,
  });

  final List<String> armor;
  final List<String> weapons;
  final List<String> tools;
  final Creation2024ToolChoice? toolChoice;
  final SrdSkillChoice? skillChoice;

  factory Creation2024MulticlassProficiencies.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Creation2024MulticlassProficiencies();
    final toolChoices = json['toolChoices'] as List<dynamic>? ?? const [];
    return Creation2024MulticlassProficiencies(
      armor: List<String>.from(json['armor'] as List? ?? const []),
      weapons: List<String>.from(json['weapons'] as List? ?? const []),
      tools: List<String>.from(json['tools'] as List? ?? const []),
      toolChoice: toolChoices.isEmpty
          ? null
          : Creation2024ToolChoice.fromJson(toolChoices.first as Map<String, dynamic>),
      skillChoice: json['skills'] is Map<String, dynamic>
          ? SrdSkillChoice.fromJson(json['skills'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Creation2024Class {
  const Creation2024Class({
    required this.name,
    required this.hitDie,
    required this.savingThrows,
    required this.skillChoices,
    required this.weaponProficiencies,
    required this.toolProficiencies,
    required this.toolChoice,
    required this.equipmentChoices,
    required this.levelOne,
    this.spellcastingAbility,
    this.spellcastingType,
    this.primaryAbilities = const [],
    this.primaryAbilityAny = false,
    this.subclassLevel = 3,
    this.progression = const [],
    this.multiclass = const Creation2024MulticlassProficiencies(),
  });

  final String name;
  final int hitDie;
  final List<String> savingThrows;
  final SrdSkillChoice skillChoices;
  final List<String> weaponProficiencies;
  final String? spellcastingAbility;

  /// `full`, `half`, `warlock` or null.
  final String? spellcastingType;
  final List<String> primaryAbilities;

  /// True when any one primary ability is enough (Fighter); otherwise all are
  /// required, e.g. for multiclass prerequisites.
  final bool primaryAbilityAny;
  final int subclassLevel;
  final List<String> toolProficiencies;
  final Creation2024ToolChoice? toolChoice;
  final List<Creation2024Equipment> equipmentChoices;
  final Map<String, dynamic> levelOne;

  /// Rows of the class table, index 0 = class level 1.
  final List<Map<String, dynamic>> progression;
  final Creation2024MulticlassProficiencies multiclass;

  Map<String, dynamic> rowAt(int classLevel) {
    if (progression.isEmpty) return levelOne;
    return progression[(classLevel - 1).clamp(0, progression.length - 1)];
  }

  List<String> featuresAt(int classLevel) =>
      List<String>.from(rowAt(classLevel)['features'] as List? ?? const []);

  factory Creation2024Class.fromJson(Map<String, dynamic> json) {
    final progression = (json['progression'] as List<dynamic>).cast<Map<String, dynamic>>();
    return Creation2024Class(
      name: json['name'] as String,
      hitDie: json['hitDie'] as int,
      savingThrows: List<String>.from(json['savingThrows'] as List),
      skillChoices: SrdSkillChoice.fromJson(json['skillChoices'] as Map<String, dynamic>),
      weaponProficiencies: List<String>.from(json['weaponProficiencies'] as List),
      spellcastingAbility: json['spellcastingAbility'] as String?,
      spellcastingType: json['spellcastingType'] as String?,
      primaryAbilities: List<String>.from(json['primaryAbility'] as List? ?? const []),
      primaryAbilityAny: json['primaryAbilityMode'] == 'any',
      subclassLevel: (json['subclassLevel'] as num?)?.toInt() ?? 3,
      toolProficiencies: List<String>.from(json['toolProficiencies'] as List),
      toolChoice: (json['toolProficiencyChoices'] as List<dynamic>? ?? const []).isEmpty
          ? null
          : Creation2024ToolChoice.fromJson((json['toolProficiencyChoices'] as List<dynamic>).first as Map<String, dynamic>),
      equipmentChoices: (json['equipmentChoices'] as List<dynamic>).map((choice) => Creation2024Equipment.fromJson(choice as Map<String, dynamic>)).toList(),
      levelOne: progression.first,
      progression: progression,
      multiclass: Creation2024MulticlassProficiencies.fromJson(
        json['multiclassProficiencies'] as Map<String, dynamic>?,
      ),
    );
  }
}

class Creation2024Subclass {
  const Creation2024Subclass({
    required this.className,
    required this.name,
    required this.description,
    this.alwaysPreparedSpells = const {},
    this.spellsByChoice,
  });

  final String className;
  final String name;
  final String description;

  /// Spells always prepared from a class level on, keyed by class level.
  final Map<int, List<String>> alwaysPreparedSpells;

  /// Spells that depend on a feature choice (Circle of the Land terrain).
  final Creation2024SubclassChoiceSpells? spellsByChoice;

  factory Creation2024Subclass.fromJson(String className, Map<String, dynamic> json) {
    final byChoice = json['alwaysPreparedSpellsByChoice'] as Map<String, dynamic>?;
    return Creation2024Subclass(
      className: className,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      alwaysPreparedSpells: _spellLevels(json['alwaysPreparedSpells']),
      spellsByChoice: byChoice == null
          ? null
          : Creation2024SubclassChoiceSpells(
              featureName: byChoice['feature'] as String,
              choiceId: byChoice['choiceId'] as String,
              options: {
                for (final entry in (byChoice['options'] as Map<String, dynamic>).entries)
                  entry.key: _spellLevels(entry.value),
              },
            ),
    );
  }

  static Map<int, List<String>> _spellLevels(Object? json) => json is Map
      ? {
          for (final entry in json.entries)
            int.parse(entry.key.toString()): List<String>.from(entry.value as List),
        }
      : const {};
}

class Creation2024SubclassChoiceSpells {
  const Creation2024SubclassChoiceSpells({
    required this.featureName,
    required this.choiceId,
    required this.options,
  });

  final String featureName;
  final String choiceId;
  final Map<String, Map<int, List<String>>> options;
}

class Creation2024Species {
  const Creation2024Species({required this.name, required this.speed, required this.sizes, required this.traits, required this.lineages});

  final String name;
  final int speed;
  final List<String> sizes;
  final List<String> traits;
  final List<Map<String, dynamic>> lineages;

  factory Creation2024Species.fromJson(Map<String, dynamic> json) => Creation2024Species(
    name: json['name'] as String,
    speed: json['speed'] as int,
    sizes: List<String>.from(json['sizeOptions'] as List),
    traits: List<String>.from(json['traits'] as List),
    lineages: (json['lineages'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>(),
  );
}

class Creation2024Background {
  const Creation2024Background({required this.name, required this.abilities, required this.featName, required this.featChoices, required this.skills, required this.tools, required this.toolChoice, required this.equipmentChoices});

  final String name;
  final List<String> abilities;
  final String featName;
  final Map<String, String> featChoices;
  final List<String> skills;
  final List<String> tools;
  final Creation2024ToolChoice? toolChoice;
  final List<Creation2024Equipment> equipmentChoices;

  factory Creation2024Background.fromJson(Map<String, dynamic> json) {
    final ref = json['originFeatRef'] as String;
    final id = ref.split('/').last;
    return Creation2024Background(
      name: json['name'] as String,
      abilities: List<String>.from(json['abilityScoreOptions'] as List),
      featName: id.split('_').map((word) => '${word[0].toUpperCase()}${word.substring(1)}').join(' '),
      featChoices: (json['originFeatChoices'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key, value as String)),
      skills: List<String>.from(json['skillProficiencies'] as List),
      tools: List<String>.from(json['toolProficiencies'] as List),
      toolChoice: (json['toolProficiencyChoices'] as List<dynamic>? ?? const []).isEmpty
          ? null
          : Creation2024ToolChoice.fromJson((json['toolProficiencyChoices'] as List<dynamic>).first as Map<String, dynamic>),
      equipmentChoices: (json['equipmentChoices'] as List<dynamic>).map((choice) => Creation2024Equipment.fromJson(choice as Map<String, dynamic>)).toList(),
    );
  }
}

class Creation2024Catalog {
  const Creation2024Catalog({required this.classes, required this.species, required this.backgrounds, required this.skills, required this.languages, required this.tools, required this.spells, required this.feats, required this.weapons, required this.choices, required this.items});

  final List<Creation2024Class> classes;
  final List<Creation2024Species> species;
  final List<Creation2024Background> backgrounds;
  final List<SrdSkill> skills;
  final List<SrdLanguage> languages;
  final List<SrdTool> tools;
  final List<SrdSpell> spells;
  final List<SrdFeat> feats;
  final List<SrdWeapon> weapons;
  final SrdFeatureChoiceCatalog choices;
  final Map<String, SrdItemData> items;

  static Future<List<Creation2024Class>> loadClasses() async {
    final raw = await rootBundle.loadString(
      SrdContentPackRegistry.srd521.srdAsset('classes'),
    );
    return (jsonDecode(raw) as List<dynamic>)
        .map((entry) => Creation2024Class.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  static Future<Map<String, List<Creation2024Subclass>>> loadSubclasses() async {
    final raw = await rootBundle.loadString(
      SrdContentPackRegistry.srd521.srdAsset('subclasses'),
    );
    return {
      for (final entry in (jsonDecode(raw) as Map<String, dynamic>).entries)
        entry.key: [
          for (final subclass in entry.value as List<dynamic>)
            Creation2024Subclass.fromJson(entry.key, subclass as Map<String, dynamic>),
        ],
    };
  }

  static Future<List<Creation2024Species>> loadSpecies() async {
    final raw = await rootBundle.loadString(
      SrdContentPackRegistry.srd521.srdAsset('races'),
    );
    return (jsonDecode(raw) as List<dynamic>)
        .map((entry) => Creation2024Species.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  static Future<Creation2024Catalog> load({
    SrdDataSource? source,
    List<Creation2024Species>? species,
    List<Creation2024Class>? classes,
  }) async {
    final srd = source ?? SrdDataSource.forPack(SrdContentPackRegistry.srd521);
    if (srd.pack.id != SrdContentPackRegistry.srd521.id) {
      throw StateError('The 2024 creation catalog requires SRD 5.2.1.');
    }
    Future<List<Map<String, dynamic>>> read(String name) async {
      final raw = await rootBundle.loadString(srd.pack.srdAsset(name));
      return (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
    }
    final backgrounds = await read('backgrounds');
    return Creation2024Catalog(
      classes: classes ?? await loadClasses(),
      species: species ?? await loadSpecies(),
      backgrounds: backgrounds.map(Creation2024Background.fromJson).toList(),
      skills: await srd.getSkills(),
      languages: await srd.getLanguages(),
      tools: await srd.getTools(),
      spells: await srd.getSpells(),
      feats: await srd.getFeats(),
      weapons: await srd.getWeapons(),
      choices: await srd.getFeatureChoiceCatalog(),
      items: await srd.getItems(),
    );
  }
}
