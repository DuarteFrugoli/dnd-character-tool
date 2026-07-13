import 'dart:convert';

import 'package:flutter/services.dart';

/// Provides translated SRD strings for a given locale.
///
/// Keys are always English identifiers; values are localised strings.
/// Returning `null` means "use the original English string".
class SrdI18nService {
  SrdI18nService._(this.locale, this._data, this._subraceNames,
      this._bgEquipmentNames);

  final String locale;

  // filename (without .json) → englishKey → { "name": ..., "description": ..., ... }
  final Map<String, Map<String, dynamic>> _data;

  // English subrace name → translated name (built by crossing SRD + i18n races)
  final Map<String, String> _subraceNames;

  // English background equipment string → translated (built by crossing SRD + i18n backgrounds)
  final Map<String, String> _bgEquipmentNames;

  /// No-op service: every lookup returns null, so callers fall back to English.
  static final SrdI18nService english =
      SrdI18nService._('en', const {}, const {}, const {});

  static const _files = [
    'backgrounds',
    'classes',
    'class_features',
    'conditions',
    'equipment',
    'feats',
    'feature_choices',
    'feature_usages',
    'languages',
    'magic_items',
    'races',
    'race_traits',
    'skills',
    'spells',
    'subclasses',
    'subclass_features',
    'tools',
  ];

  /// Loads the i18n overlay for [locale] from bundled assets.
  /// Gracefully skips files that are missing, empty, or malformed.
  static Future<SrdI18nService> load(String locale) async {
    if (locale == 'en') return english;
    final data = <String, Map<String, dynamic>>{};
    for (final file in _files) {
      try {
        final raw =
            await rootBundle.loadString('assets/data/i18n/$locale/$file.json');
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic> && decoded.isNotEmpty) {
          data[file] = _lowercaseKeys(decoded);
        }
      } catch (_) {
        // Missing, empty, or invalid JSON — fall back to English for this file.
      }
    }
    // Build English→translated subrace index by crossing SRD races with the
    // i18n overlay. Subraces in the i18n file are stored as a positional array,
    // so we match them by index against the SRD source.
    final subraceNames = <String, String>{};
    try {
      final srdRaw =
          await rootBundle.loadString('assets/data/srd/races.json');
      final srdRaces = jsonDecode(srdRaw) as List<dynamic>;
      final i18nRaces = data['races'];
      if (i18nRaces != null) {
        for (final srdRace in srdRaces) {
          final raceEnName = srdRace['name'] as String?;
          if (raceEnName == null) continue;
          final srdSubraces = srdRace['subraces'] as List<dynamic>? ?? [];
          final i18nEntry = i18nRaces[raceEnName.toLowerCase()];
          if (i18nEntry is! Map) continue;
          final i18nSubraces = i18nEntry['subraces'] as List<dynamic>? ?? [];
          for (var i = 0; i < srdSubraces.length; i++) {
            final enName = srdSubraces[i]['name'] as String?;
            final translatedName = i < i18nSubraces.length
                ? i18nSubraces[i]['name'] as String?
                : null;
            if (enName != null && translatedName != null) {
              subraceNames[enName] = translatedName;
            }
          }
        }
      }
    } catch (_) {}

    // Build English→translated background equipment index by crossing SRD
    // backgrounds with the i18n overlay (positional arrays).
    final bgEquipmentNames = <String, String>{};
    try {
      final srdRaw =
          await rootBundle.loadString('assets/data/srd/backgrounds.json');
      final srdBackgrounds = jsonDecode(srdRaw) as List<dynamic>;
      final i18nBackgrounds = data['backgrounds'];
      if (i18nBackgrounds != null) {
        for (final srdBg in srdBackgrounds) {
          final bgEnName = srdBg['name'] as String?;
          if (bgEnName == null) continue;
          final srdItems =
              List<String>.from(srdBg['startingEquipment'] as List? ?? []);
          final i18nEntry = i18nBackgrounds[bgEnName.toLowerCase()];
          if (i18nEntry is! Map) continue;
          final i18nItems =
              List<dynamic>.from(i18nEntry['startingequipment'] as List? ?? []);
          for (var i = 0; i < srdItems.length; i++) {
            final enItem = srdItems[i];
            final translated =
                i < i18nItems.length ? i18nItems[i] as String? : null;
            if (translated != null && translated != enItem) {
              bgEquipmentNames[enItem] = translated;
            }
          }
        }
      }
    } catch (_) {}

    // Also add class starting equipment (fixed + choices) by positional cross-ref.
    try {
      final srdClsRaw =
          await rootBundle.loadString('assets/data/srd/classes.json');
      final srdClasses = jsonDecode(srdClsRaw) as List<dynamic>;
      final i18nClasses = data['classes'];
      if (i18nClasses != null) {
        void crossItems(List<dynamic> enList, List<dynamic> trList) {
          for (var i = 0; i < enList.length && i < trList.length; i++) {
            final en = enList[i] is String ? enList[i] as String : null;
            final tr = trList[i] is String ? trList[i] as String : null;
            if (en != null && tr != null && tr != en) {
              bgEquipmentNames[en] = tr;
            }
          }
        }

        for (final srdCls in srdClasses) {
          final clsName = srdCls['name'] as String?;
          if (clsName == null) continue;
          final i18nEntry = i18nClasses[clsName.toLowerCase()];
          if (i18nEntry is! Map) continue;
          final srdEquip = srdCls['startingEquipment'] as Map?;
          final i18nEquip = i18nEntry['startingequipment'] as Map?;
          if (srdEquip == null || i18nEquip == null) continue;

          // Fixed items
          crossItems(
            List<dynamic>.from(srdEquip['fixed'] as List? ?? []),
            List<dynamic>.from(i18nEquip['fixed'] as List? ?? []),
          );

          // Choice options (choices[g].options[o][i])
          final srdChoices =
              List<dynamic>.from(srdEquip['choices'] as List? ?? []);
          final i18nChoices =
              List<dynamic>.from(i18nEquip['choices'] as List? ?? []);
          for (var g = 0;
              g < srdChoices.length && g < i18nChoices.length;
              g++) {
            final srdOpts =
                List<dynamic>.from(srdChoices[g]['options'] as List? ?? []);
            final i18nOpts =
                List<dynamic>.from(i18nChoices[g]['options'] as List? ?? []);
            for (var o = 0;
                o < srdOpts.length && o < i18nOpts.length;
                o++) {
              crossItems(
                List<dynamic>.from(srdOpts[o] as List? ?? []),
                List<dynamic>.from(i18nOpts[o] as List? ?? []),
              );
            }
          }
        }
      }
    } catch (_) {}

    // Add short-name aliases for "(N)" equipment entries so that items stored
    // with stripped names (e.g. "bolts" from "20 bolts") can be looked up.
    // Mirrors the alias strategy in srd_data_source.dart:
    //   "Crossbow Bolts (20)" → add "crossbow bolts" and "bolts" aliases.
    //   "Arrows (20)"         → add "arrows" alias.
    final equipData = data['equipment'];
    if (equipData != null) {
      final parenRe = RegExp(r'^(.+?)\s*\(\d+\)$');
      final aliases = <String, dynamic>{};
      for (final entry in equipData.entries) {
        final m = parenRe.firstMatch(entry.key);
        if (m != null) {
          final base = m.group(1)!.trim(); // e.g. "crossbow bolts"
          aliases.putIfAbsent(base, () => entry.value);
          final lastWord = base.split(' ').last; // e.g. "bolts"
          if (lastWord != base) {
            aliases.putIfAbsent(lastWord, () => entry.value);
          }
        }
      }
      equipData.addAll(aliases);
    }

    return SrdI18nService._(locale, data, subraceNames, bgEquipmentNames);
  }

  // ── Key normalisation ──────────────────────────────────────────────────────

  /// Recursively lowercases all [String] map keys so every lookup is
  /// case-insensitive at O(1) cost. Called once at load time.
  static Map<String, dynamic> _lowercaseKeys(Map<String, dynamic> map) => {
        for (final e in map.entries)
          e.key.toLowerCase(): e.value is Map<String, dynamic>
              ? _lowercaseKeys(e.value as Map<String, dynamic>)
              : e.value,
      };

  // ── Generic helpers ────────────────────────────────────────────────────────

  String? _str(String file, String key, String field) {
    final entry = _data[file]?[key.toLowerCase()];
    if (entry is! Map) return null;
    return entry[field.toLowerCase()] as String?;
  }

  String? _nested2(String file, String k1, String k2, String field) {
    final level1 = _data[file]?[k1.toLowerCase()];
    if (level1 is! Map) return null;
    final entry = level1[k2.toLowerCase()];
    if (entry is! Map) return null;
    return entry[field.toLowerCase()] as String?;
  }

  String? _nested3(
      String file, String k1, String k2, String k3, String field) {
    final level1 = _data[file]?[k1.toLowerCase()];
    if (level1 is! Map) return null;
    final level2 = level1[k2.toLowerCase()];
    if (level2 is! Map) return null;
    final entry = level2[k3.toLowerCase()];
    if (entry is! Map) return null;
    return entry[field.toLowerCase()] as String?;
  }

  // ── Race traits ────────────────────────────────────────────────────────────

  String raceTraitName(String en) => _str('race_traits', en, 'name') ?? en;

  String? raceTraitDescription(String en) => _str('race_traits', en, 'description');

  // ── Skills ─────────────────────────────────────────────────────────────────

  String skillName(String en) => _str('skills', en, 'name') ?? en;

  // ── Spells ─────────────────────────────────────────────────────────────────

  String spellName(String en) => _str('spells', en, 'name') ?? en;

  String? spellDescription(String en) => _str('spells', en, 'description');

  String? spellHigherLevels(String en) => _str('spells', en, 'higherLevels');

  String? spellMaterial(String en) => _str('spells', en, 'material');

  // ── Races ──────────────────────────────────────────────────────────────────

  String raceName(String en) => _str('races', en, 'name') ?? en;

  String subraceName(String en) => _subraceNames[en] ?? en;

  // ── Background equipment ───────────────────────────────────────────────────

  /// Translates an equipment item name, checking sources in priority order:
  /// 1. Positional cross-ref from background/class JSON arrays (most exact)
  /// 2. Equipment i18n data (handles weapons in "any X" sub-choice dropdowns)
  /// 3. Tools i18n data (handles kits, instruments, artisan/gaming tools)
  String backgroundEquipmentName(String en) =>
      _bgEquipmentNames[en] ??
      _str('equipment', en, 'name') ??
      _str('tools', en, 'name') ??
      en;

  // ── Tools ──────────────────────────────────────────────────────────────────

  String toolName(String en) => _str('tools', en, 'name') ?? en;

  // ── Backgrounds ────────────────────────────────────────────────────────────

  String backgroundName(String en) => _str('backgrounds', en, 'name') ?? en;

  // ── Classes ────────────────────────────────────────────────────────────────

  String className(String en) => _str('classes', en, 'name') ?? en;

  String subclassName(String classEn, String subclassEn) =>
      _nested2('subclasses', classEn, subclassEn, 'name') ?? subclassEn;

  String? subclassDescription(String classEn, String subclassEn) =>
      _nested2('subclasses', classEn, subclassEn, 'description');

  String? classSubclassFeatureName(String classEn) =>
      _str('classes', classEn, 'subclassFeatureName');

  // ── Backgrounds ────────────────────────────────────────────────────────────

  String? backgroundFeatureName(String backgroundEn) {
    final entry = _data['backgrounds']?[backgroundEn.toLowerCase()];
    if (entry is! Map) return null;
    final feature = entry['feature'];
    if (feature is! Map) return null;
    return feature['name'] as String?;
  }

  String? backgroundFeatureDescription(String backgroundEn) {
    final entry = _data['backgrounds']?[backgroundEn.toLowerCase()];
    if (entry is! Map) return null;
    final feature = entry['feature'];
    if (feature is! Map) return null;
    return feature['description'] as String?;
  }

  // ── Class features ─────────────────────────────────────────────────────────

  String? classFeatureName(String className, String featureName) =>
      _nested2('class_features', className, featureName, 'name');

  String? classFeatureDescription(String className, String featureName) =>
      _nested2('class_features', className, featureName, 'description');

  // ── Feats ──────────────────────────────────────────────────────────────────

  String? featName(String en) => _str('feats', en, 'name');

  String? featDescription(String en) => _str('feats', en, 'description');

  // ── Subclass features ──────────────────────────────────────────────────────

  String? subclassFeatureName(
          String className, String subclassName, String featureName) =>
      _nested3(
          'subclass_features', className, subclassName, featureName, 'name');

  String? subclassFeatureDescription(
          String className, String subclassName, String featureName) =>
      _nested3('subclass_features', className, subclassName, featureName,
          'description');

  // ── Conditions ─────────────────────────────────────────────────────────────

  String conditionName(String en) => _str('conditions', en, 'name') ?? en;

  String? conditionDescription(String en) =>
      _str('conditions', en, 'description');

  // ── Equipment ──────────────────────────────────────────────────────────────

  String equipmentName(String en) {
    final direct = _str('equipment', en, 'name');
    if (direct != null) return direct;
    // Armor items stored as e.g. "Leather armor" may only have a key "Leather"
    // in the i18n file (matching the SRD equipment.json canonical name).
    // Strip common armor/mail suffixes and retry.
    final lower = en.toLowerCase();
    final stripped = lower
        .replaceFirst(RegExp(r'\s+armor$'), '')
        .replaceFirst(RegExp(r'\s+mail$'), '');
    if (stripped != lower) return _str('equipment', stripped, 'name') ?? en;
    return en;
  }

  String? equipmentDescription(String en) => _str('equipment', en, 'description');

  String magicItemName(String en) => _str('magic_items', en, 'name') ?? en;

  String? magicItemDescription(String en) => _str('magic_items', en, 'description');

  // ── Languages ──────────────────────────────────────────────────────────────

  String languageName(String en) => _str('languages', en, 'name') ?? en;

  String featureUsageResourceName(String resourceId, String fallback) {
    final resources = _data['feature_usages']?['resources'];
    if (resources is! Map) return fallback;
    final entry = resources[resourceId.toLowerCase()];
    if (entry is! Map) return fallback;
    return entry['name'] as String? ?? fallback;
  }

  String? featureChoiceOptionName({
    required String sourceType,
    required String sourceClass,
    String? sourceSubclass,
    String? sourceName,
    required String featureName,
    required String choiceId,
    required String optionId,
    String? optionsSource,
  }) =>
      _featureChoiceOptionField(
        sourceType: sourceType,
        sourceClass: sourceClass,
        sourceSubclass: sourceSubclass,
        sourceName: sourceName,
        featureName: featureName,
        choiceId: choiceId,
        optionId: optionId,
        optionsSource: optionsSource,
        field: 'name',
      );

  String? featureChoiceOptionDescription({
    required String sourceType,
    required String sourceClass,
    String? sourceSubclass,
    String? sourceName,
    required String featureName,
    required String choiceId,
    required String optionId,
    String? optionsSource,
  }) =>
      _featureChoiceOptionField(
        sourceType: sourceType,
        sourceClass: sourceClass,
        sourceSubclass: sourceSubclass,
        sourceName: sourceName,
        featureName: featureName,
        choiceId: choiceId,
        optionId: optionId,
        optionsSource: optionsSource,
        field: 'description',
      );

  String? _featureChoiceOptionField({
    required String sourceType,
    required String sourceClass,
    String? sourceSubclass,
    String? sourceName,
    required String featureName,
    required String choiceId,
    required String optionId,
    String? optionsSource,
    required String field,
  }) {
    final bySource = optionsSource == null
        ? null
        : _featureChoiceAt([
            'optionsources',
            optionsSource,
            optionId,
            field,
          ]);
    if (bySource is String) return bySource;

    final sourcePath = switch (sourceType) {
      'classFeature' => [
          'classfeatures',
          sourceClass,
          featureName,
        ],
      'subclassFeature' => [
          'subclassfeatures',
          sourceClass,
          sourceSubclass,
          featureName,
        ],
      'raceTrait' => [
          'racetraits',
          sourceName ?? featureName,
        ],
      'feat' => [
          'feats',
          sourceName ?? featureName,
        ],
      _ => const <String?>[],
    };
    if (sourcePath.isEmpty || sourcePath.any((part) => part == null)) {
      return null;
    }

    final inline = _featureChoiceAt([
      ...sourcePath.cast<String>(),
      'choices',
      choiceId,
      'options',
      optionId,
      field,
    ]);
    return inline is String ? inline : null;
  }

  dynamic _featureChoiceAt(List<String> path) {
    dynamic current = _data['feature_choices'];
    for (final part in path) {
      if (current is! Map) return null;
      current = current[part.toLowerCase()];
    }
    return current;
  }

  // ── Game term translations ─────────────────────────────────────────────────
  // Fixed finite sets of D&D terms that appear as raw values in SRD data.

  static const _ptTerms = <String, String>{
    // Casting times
    '1 action': '1 ação',
    '1 bonus action': '1 ação bônus',
    '1 reaction': '1 reação',
    '1 minute': '1 minuto',
    '10 minutes': '10 minutos',
    '1 hour': '1 hora',
    '8 hours': '8 horas',
    '24 hours': '24 horas',
    // Duration specials
    'instantaneous': 'instantânea',
    '1 round': '1 turno',
    'until dispelled': 'até ser dissipado',
    'until dispelled or triggered': 'até ser dissipado ou ativado',
    'permanent': 'permanente',
    '7 days': '7 dias',
    '10 days': '10 dias',
    '30 days': '30 dias',
    // Duration prefixes (with trailing space)
    'up to ': 'até ',
    'concentration, up to ': 'concentração, até ',
    // Damage types
    'bludgeoning': 'concussão',
    'piercing': 'perfurante',
    'slashing': 'cortante',
    'acid': 'ácido',
    'cold': 'frio',
    'fire': 'fogo',
    'force': 'energia',
    'lightning': 'elétrico',
    'necrotic': 'necrótico',
    'poison': 'veneno',
    'psychic': 'psíquico',
    'radiant': 'radiante',
    'thunder': 'trovão',
    'none': 'nenhum',
    // Weapon properties
    'ammunition': 'munição',
    'finesse': 'finesse',
    'heavy': 'pesada',
    'light': 'leve',
    'loading': 'recarga',
    'reach': 'alcance adicional',
    'special': 'especial',
    'thrown': 'arremessável',
    'two-handed': 'duas mãos',
    'versatile': 'versátil',
    // Spell schools
    'abjuration': 'abjuração',
    'conjuration': 'conjuração',
    'divination': 'adivinhação',
    'enchantment': 'encantamento',
    'evocation': 'evocação',
    'illusion': 'ilusão',
    'necromancy': 'necromancia',
    'transmutation': 'transmutação',
    // UI game terms
    'shield': 'escudo',
    // Armor abbreviations
    'AC': 'CA',
    'DEX': 'DES',
    // Magic item rarities
    'common': 'comum',
    'uncommon': 'incomum',
    'rare': 'raro',
    'very rare': 'muito raro',
    'legendary': 'lendário',
    'artifact': 'artefato',
    // Attunement
    'attunement': 'sintonia',
  };

  static Map<String, String>? _getTermsMap(String locale) {
    switch (locale) {
      case 'pt': return _ptTerms;
      default:   return null;
    }
  }

  /// Translates a single game term via case-insensitive exact match.
  String term(String en) {
    final map = _getTermsMap(locale);
    if (map == null) return en;
    return map[en] ?? map[en.toLowerCase()] ?? en;
  }

  /// Translates a spell casting time string.
  /// Handles "1 reaction, which you take when..." by translating the prefix.
  String castingTime(String en) {
    final map = _getTermsMap(locale);
    if (map == null) return en;
    final exact = map[en] ?? map[en.toLowerCase()];
    if (exact != null) return exact;
    final lower = en.toLowerCase();
    if (lower.startsWith('1 reaction')) {
      final tr = map['1 reaction'] ?? '1 reaction';
      return en.length > '1 reaction'.length
          ? '$tr${en.substring('1 reaction'.length)}'
          : tr;
    }
    return en;
  }

  /// Translates a spell duration string.
  /// Handles "Up to X" and "Concentration, up to X" prefixes.
  String spellDuration(String en) {
    final map = _getTermsMap(locale);
    if (map == null) return en;
    final exact = map[en] ?? map[en.toLowerCase()];
    if (exact != null) return exact;
    final lower = en.toLowerCase();
    const concPrefix = 'concentration, up to ';
    if (lower.startsWith(concPrefix)) {
      final tail = en.substring(concPrefix.length);
      return '${map[concPrefix] ?? 'Concentration, up to '}${map[tail.toLowerCase()] ?? tail}';
    }
    const upToPrefix = 'up to ';
    if (lower.startsWith(upToPrefix)) {
      final tail = en.substring(upToPrefix.length);
      return '${map[upToPrefix] ?? 'Up to '}${map[tail.toLowerCase()] ?? tail}';
    }
    return en;
  }

  /// Translates a damage type string.
  String damageType(String en) => term(en);

  /// Translates a spell school name.
  String spellSchool(String en) => term(en.toLowerCase());

  /// Translates and joins weapon property strings.
  String weaponProperties(List<String> props) =>
      props.map((p) => term(p)).join(', ');

  /// Searches all classes to find a subclass feature name by subclass key alone.
  String? anySubclassFeatureName(String subclassKey, String featureName) {
    final file = _data['subclass_features'];
    if (file == null) return null;
    for (final classEntry in file.values) {
      if (classEntry is! Map) continue;
      final sub = classEntry[subclassKey];
      if (sub is! Map) continue;
      final feat = sub[featureName];
      if (feat is! Map) continue;
      return feat['name'] as String?;
    }
    return null;
  }

  /// Searches all classes to find a subclass feature description by subclass key alone.
  String? anySubclassFeatureDescription(String subclassKey, String featureName) {
    final file = _data['subclass_features'];
    if (file == null) return null;
    for (final classEntry in file.values) {
      if (classEntry is! Map) continue;
      final sub = classEntry[subclassKey];
      if (sub is! Map) continue;
      final feat = sub[featureName];
      if (feat is! Map) continue;
      return feat['description'] as String?;
    }
    return null;
  }
}
