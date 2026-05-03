import 'dart:convert';

import 'package:flutter/services.dart';

import 'srd_models.dart';

/// Lê e parseia os assets SRD bundados no app.
/// Os dados são carregados sob demanda e cacheados em memória após a primeira leitura.
class SrdDataSource {
  SrdDataSource._();

  static final SrdDataSource instance = SrdDataSource._();

  List<SrdSkill>? _skills;
  List<SrdRace>? _races;
  List<SrdClass>? _classes;
  List<SrdBackground>? _backgrounds;
  List<SrdSpell>? _spells;
  List<SrdWeapon>? _weapons;
  List<SrdArmor>? _armors;
  List<SrdGearItem>? _gear;
  List<SrdMagicItem>? _magicItems;
  Map<String, List<SrdClassFeature>>? _classFeatures;
  Map<String, String>? _raceTraits;
  Map<String, Map<String, List<SrdClassFeature>>>? _subclassFeatures;

  Future<List<SrdSkill>> getSkills() async {
    _skills ??= await _loadList(
      'assets/data/srd/skills.json',
      SrdSkill.fromJson,
    );
    return _skills!;
  }

  Future<List<SrdRace>> getRaces() async {
    _races ??= await _loadList(
      'assets/data/srd/races.json',
      SrdRace.fromJson,
    );
    return _races!;
  }

  Future<List<SrdClass>> getClasses() async {
    if (_classes == null) {
      final classes = await _loadList(
        'assets/data/srd/classes.json',
        SrdClass.fromJson,
      );
      final subclassRaw = await rootBundle.loadString(
        'assets/data/srd/subclasses.json',
      );
      final subclassMap =
          jsonDecode(subclassRaw) as Map<String, dynamic>;
      _classes = classes.map((cls) {
        final subs = (subclassMap[cls.name] as List<dynamic>? ?? [])
            .map((e) => SrdSubclass.fromJson(e as Map<String, dynamic>))
            .toList();
        return SrdClass(
          name: cls.name,
          hitDie: cls.hitDie,
          primaryAbility: cls.primaryAbility,
          savingThrows: cls.savingThrows,
          armorProficiencies: cls.armorProficiencies,
          weaponProficiencies: cls.weaponProficiencies,
          toolProficiencies: cls.toolProficiencies,
          skillChoices: cls.skillChoices,
          spellcastingAbility: cls.spellcastingAbility,
          spellcastingType: cls.spellcastingType,
          subclassLevel: cls.subclassLevel,
          subclassFeatureName: cls.subclassFeatureName,
          startingGoldDice: cls.startingGoldDice,
          subclasses: subs,
        );
      }).toList();
    }
    return _classes!;
  }

  Future<List<SrdBackground>> getBackgrounds() async {
    _backgrounds ??= await _loadList(
      'assets/data/srd/backgrounds.json',
      SrdBackground.fromJson,
    );
    return _backgrounds!;
  }

  Future<List<SrdSpell>> getSpells() async {
    _spells ??= await _loadList(
      'assets/data/srd/spells.json',
      SrdSpell.fromJson,
    );
    return _spells!;
  }

  Future<List<SrdSpell>> getSpellsForClass(String className) async {
    final all = await getSpells();
    return all
        .where((s) => s.classes.contains(className.toLowerCase()))
        .toList();
  }

  Future<List<SrdSpell>> getCantrips() async {
    final all = await getSpells();
    return all.where((s) => s.isCantrip).toList();
  }

  Future<List<SrdSpell>> getSpellsByLevel(int level) async {
    final all = await getSpells();
    return all.where((s) => s.level == level).toList();
  }

  Future<List<SrdWeapon>> getWeapons() async {
    await _loadEquipment();
    return _weapons!;
  }

  Future<List<SrdArmor>> getArmors() async {
    await _loadEquipment();
    return _armors!;
  }

  Future<List<SrdGearItem>> getGear() async {
    await _loadEquipment();
    return _gear!;
  }

  Future<List<SrdMagicItem>> getMagicItems() async {
    _magicItems ??= await _loadList(
      'assets/data/srd/magic_items.json',
      SrdMagicItem.fromJson,
    );
    return _magicItems!;
  }

  Future<Map<String, String>> getRaceTraits() async {
    if (_raceTraits == null) {
      final raw = await rootBundle.loadString('assets/data/srd/race_traits.json');
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _raceTraits = map.map((k, v) => MapEntry(k, v as String));
    }
    return _raceTraits!;
  }

  Future<List<SrdClassFeature>> getClassFeatures(String className) async {
    if (_classFeatures == null) {
      final raw = await rootBundle.loadString(
        'assets/data/srd/class_features.json',
      );
      final list = jsonDecode(raw) as List<dynamic>;
      _classFeatures = {};
      for (final entry in list) {
        final map = entry as Map<String, dynamic>;
        final name = map['class'] as String;
        final features = (map['features'] as List<dynamic>)
            .map((e) =>
                SrdClassFeature.fromJson(e as Map<String, dynamic>))
            .toList();
        _classFeatures![name] = features;
      }
    }
    return _classFeatures![className] ?? [];
  }

  Future<List<SrdClassFeature>> getSubclassFeatures(
    String className,
    String subclassName,
  ) async {
    if (_subclassFeatures == null) {
      final raw = await rootBundle.loadString(
        'assets/data/srd/subclass_features.json',
      );
      final list = jsonDecode(raw) as List<dynamic>;
      _subclassFeatures = {};
      for (final entry in list) {
        final map = entry as Map<String, dynamic>;
        final cls = map['class'] as String;
        final sub = map['subclass'] as String;
        final features = (map['features'] as List<dynamic>)
            .map((e) => SrdClassFeature.fromJson(e as Map<String, dynamic>))
            .toList();
        (_subclassFeatures![cls] ??= {})[sub] = features;
      }
    }
    return _subclassFeatures![className]?[subclassName] ?? [];
  }

  Future<void> _loadEquipment() async {
    if (_weapons != null && _armors != null && _gear != null) return;
    final raw = await rootBundle.loadString('assets/data/srd/equipment.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _weapons = (json['weapons'] as List<dynamic>)
        .map((e) => SrdWeapon.fromJson(e as Map<String, dynamic>))
        .toList();
    _armors = (json['armor'] as List<dynamic>)
        .map((e) => SrdArmor.fromJson(e as Map<String, dynamic>))
        .toList();
    _gear = (json['gear'] as List<dynamic>)
        .map((e) => SrdGearItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<T>> _loadList<T>(
    String assetPath,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = await rootBundle.loadString(assetPath);
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Limpa o cache (útil em testes).
  void clearCache() {
    _skills = null;
    _races = null;
    _classes = null;
    _backgrounds = null;
    _spells = null;
    _weapons = null;
    _armors = null;
    _gear = null;
    _magicItems = null;
    _classFeatures = null;
    _raceTraits = null;
    _subclassFeatures = null;
  }
}
