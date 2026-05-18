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
  Map<String, SrdSpell>? _spellIndex;
  List<SrdWeapon>? _weapons;
  List<SrdArmor>? _armors;
  List<SrdGearItem>? _gear;
  List<SrdMagicItem>? _magicItems;
  Map<String, List<SrdClassFeature>>? _classFeatures;
  Map<String, String>? _raceTraits;
  Map<String, Map<String, List<SrdClassFeature>>>? _subclassFeatures;
  Map<String, SrdItemData>? _items;
  List<SrdTool>? _tools;
  /// Guard against parsing equipment.json multiple times in parallel.
  Future<void>? _equipmentLoadFuture;

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
          startingEquipment: cls.startingEquipment,
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

  /// Returns a spell by exact name (case-insensitive), or null if not found.
  /// Uses a lazy-built index for O(1) lookups after first call.
  Future<SrdSpell?> getSpellByName(String name) async {
    if (_spellIndex == null) {
      final all = await getSpells();
      _spellIndex = {for (final s in all) s.name.toLowerCase(): s};
    }
    return _spellIndex![name.toLowerCase()];
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

  Future<List<SrdTool>> getTools() async {
    _tools ??= await _loadList(
      'assets/data/srd/tools.json',
      SrdTool.fromJson,
    );
    return _tools!;
  }

  Future<Map<String, SrdItemData>> getItems() async {
    if (_items == null) {
      final raw =
          await rootBundle.loadString('assets/data/srd/equipment.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final result = <String, SrdItemData>{};

      // ── Weapons ──────────────────────────────────────────────────────
      for (final entry in (json['weapons'] as List<dynamic>)) {
        final w = entry as Map<String, dynamic>;
        final rawName = (w['name'] as String).toLowerCase();
        final category = w['category'] as String;
        final props = <String, dynamic>{
          'damageDice': w['damage'],
          'damageType': w['damageType'],
          if (w['properties'] != null) 'weaponProperties': w['properties'],
          if (w['range'] != null) 'range': w['range'],
          if (w['versatileDamage'] != null)
            'versatileDamage': w['versatileDamage'],
        };
        final data =
            SrdItemData(itemType: 'weapon', category: category, properties: props);
        result[rawName] = data;
        // Alias "Crossbow, X" → "x crossbow" to match startingEquipment strings
        final alias = _crossbowAlias(rawName);
        if (alias != null) result[alias] = data;
      }

      // ── Armor ────────────────────────────────────────────────────────
      for (final entry in (json['armor'] as List<dynamic>)) {
        final a = entry as Map<String, dynamic>;
        final rawName = (a['name'] as String).toLowerCase();
        final isShield = (a['type'] as String?) == 'shield';
        final Map<String, dynamic> props;
        if (isShield) {
          props = {'isShield': true, 'acBonus': a['acBonus']};
        } else {
          final maxDex = a['maxDexBonus'];
          props = {
            'baseAC': a['baseAC'],
            'addDexModifier': a['addDexModifier'],
            if (maxDex != null && (maxDex as num).toInt() > 0)
              'maxDexBonus': maxDex,
            if (a['stealthDisadvantage'] == true) 'stealthDisadvantage': true,
            if (a['strengthRequired'] != null)
              'strengthRequirement': a['strengthRequired'],
          };
        }
        final data =
            SrdItemData(itemType: 'armor', category: 'armor', properties: props);
        result[rawName] = data;
        // Aliases: "leather" → "leather armor", "shield" → "wooden shield", etc.
        for (final alias in _armorAliases(rawName)) {
          result[alias] = data;
        }
      }

      // ── Gear / Ammunition ────────────────────────────────────────────
      for (final entry in (json['gear'] as List<dynamic>)) {
        final g = entry as Map<String, dynamic>;
        final rawName = (g['name'] as String).toLowerCase();
        final category = g['category'] as String;
        final itemType = category == 'ammunition' ? 'ammunition' : 'gear';
        result[rawName] = SrdItemData(itemType: itemType, category: category);
        // Alias stripped names for ammo bundles:
        // "arrows (20)" → "arrows", "crossbow bolts (20)" → "bolts", etc.
        final parenIdx = rawName.indexOf(' (');
        if (parenIdx > 0) {
          final stripped = rawName.substring(0, parenIdx);
          result[stripped] = result[rawName]!;
          // Also add the last word as a short alias ("bolts", "arrows", "needles")
          final lastWord = stripped.split(' ').last;
          result[lastWord] = result[rawName]!;
        }
      }

      _items = result;
    }
    return _items!;
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

  Future<Map<String, Map<String, List<SrdClassFeature>>>>
      getAllSubclassFeatures() async {
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
    return _subclassFeatures!;
  }

  Future<List<SrdClassFeature>> getSubclassFeatures(
    String className,
    String subclassName,
  ) async {
    final all = await getAllSubclassFeatures();
    return all[className]?[subclassName] ?? [];
  }

  Future<void> _loadEquipment() async {
    if (_weapons != null && _armors != null && _gear != null) return;
    // Reuse the in-flight future so concurrent callers share one parse.
    _equipmentLoadFuture ??= _doLoadEquipment();
    await _equipmentLoadFuture;
  }

  Future<void> _doLoadEquipment() async {
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
    _equipmentLoadFuture = null;
    _magicItems = null;
    _classFeatures = null;
    _raceTraits = null;
    _subclassFeatures = null;
    _items = null;
    _tools = null;
  }
}

// ── Equipment indexing helpers ────────────────────────────────────────────────

/// Maps "crossbow, x" name variants from equipment.json to the canonical
/// starting-equipment strings used in classes.json (e.g. "light crossbow").
String? _crossbowAlias(String lower) {
  if (lower == 'crossbow, light') return 'light crossbow';
  if (lower == 'crossbow, hand') return 'hand crossbow';
  if (lower == 'crossbow, heavy') return 'heavy crossbow';
  return null;
}

/// Returns extra index keys for armor names so that strings like
/// "Leather armor" or "Wooden shield" hit the right entry.
List<String> _armorAliases(String lower) {
  switch (lower) {
    case 'leather':      return ['leather armor'];
    case 'studded leather': return ['studded leather armor'];
    case 'hide':         return ['hide armor'];
    case 'padded':       return ['padded armor'];
    case 'half plate':   return ['half plate armor'];
    case 'splint':       return ['splint armor'];
    case 'plate':        return ['plate armor', 'plate mail'];
    case 'shield':       return ['wooden shield'];
    default:             return [];
  }
}
