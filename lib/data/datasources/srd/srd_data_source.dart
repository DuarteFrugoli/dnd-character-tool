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
    _classes ??= await _loadList(
      'assets/data/srd/classes.json',
      SrdClass.fromJson,
    );
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

  Future<void> _loadEquipment() async {
    if (_weapons != null && _armors != null) return;
    final raw = await rootBundle.loadString('assets/data/srd/equipment.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _weapons = (json['weapons'] as List<dynamic>)
        .map((e) => SrdWeapon.fromJson(e as Map<String, dynamic>))
        .toList();
    _armors = (json['armor'] as List<dynamic>)
        .map((e) => SrdArmor.fromJson(e as Map<String, dynamic>))
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
  }
}
