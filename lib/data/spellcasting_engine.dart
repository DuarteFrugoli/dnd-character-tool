import '../../data/models/ability_scores.dart';
import '../../data/models/spell.dart';

/// Encapsulates all D&D 5e SRD spellcasting rules for a single character class.
///
/// Usage:
/// ```dart
/// final engine = SpellcastingEngine.forClass(
///   className: character.characterClass,
///   classLevel: character.level,
///   abilityScores: character.abilityScores,
///   proficiencyBonus: character.proficiencyBonus,
/// );
/// if (engine == null) { /* non-caster */ }
/// print(engine!.saveDC);          // e.g. 14
/// print(engine.spellAttack);       // e.g. +6
/// print(engine.maxPrepared);       // e.g. 7 (null for known-casters)
/// print(engine.mechanism);         // SpellcastingMechanism.prepare
/// ```
class SpellcastingEngine {
  final String className;
  final int classLevel;
  final AbilityScores abilityScores;
  final int proficiencyBonus;

  /// The ability score used for spellcasting (INT / WIS / CHA).
  final String spellcastingAbility;

  /// How spells are acquired for this class.
  final SpellcastingMechanism mechanism;

  /// Slot progression type (full, half, pact).
  final SpellProgressionType progressionType;

  /// Class spell list used when selecting or browsing spells.
  final String spellListClass;

  /// Subclass used to enable subclass spellcasting rules, if any.
  final String? subclass;

  const SpellcastingEngine._({
    required this.className,
    required this.classLevel,
    required this.abilityScores,
    required this.proficiencyBonus,
    required this.spellcastingAbility,
    required this.mechanism,
    required this.progressionType,
    required this.spellListClass,
    this.subclass,
  });

  // ── Factory ───────────────────────────────────────────────────────────────

  /// Returns a [SpellcastingEngine] for [className], or null if the class is
  /// not a spellcaster in the SRD (e.g. Fighter base, Rogue base).
  /// Pass [subclass] to enable spellcasting for Eldritch Knight and Arcane Trickster.
  static SpellcastingEngine? forClass({
    required String className,
    required int classLevel,
    required AbilityScores abilityScores,
    required int proficiencyBonus,
    String? subclass,
  }) {
    final key = className.toLowerCase();
    // Check for 1/3-caster subclasses of Fighter and Rogue
    if ((key == 'fighter' || key == 'rogue') && subclass != null) {
      final sub = subclass.toLowerCase();
      if (sub == 'eldritch knight' || sub == 'arcane trickster') {
        return SpellcastingEngine._(
          className: className,
          classLevel: classLevel,
          abilityScores: abilityScores,
          proficiencyBonus: proficiencyBonus,
          spellcastingAbility: 'INT',
          mechanism: SpellcastingMechanism.known,
          progressionType: SpellProgressionType.third,
          spellListClass: 'wizard',
          subclass: subclass,
        );
      }
    }
    final info = _classInfo[key];
    if (info == null) return null;
    return SpellcastingEngine._(
      className: className,
      classLevel: classLevel,
      abilityScores: abilityScores,
      proficiencyBonus: proficiencyBonus,
      spellcastingAbility: info.ability,
      mechanism: info.mechanism,
      progressionType: info.progression,
      spellListClass: key,
    );
  }

  // ── Computed stats ────────────────────────────────────────────────────────

  /// The ability modifier for the spellcasting ability.
  int get abilityModifier {
    switch (spellcastingAbility.toUpperCase()) {
      case 'INT':
        return abilityScores.intelligenceModifier;
      case 'WIS':
        return abilityScores.wisdomModifier;
      case 'CHA':
        return abilityScores.charismaModifier;
      default:
        return 0;
    }
  }

  /// Spell Save DC = 8 + proficiency bonus + ability modifier.
  int get saveDC => 8 + proficiencyBonus + abilityModifier;

  /// Spell Attack bonus = proficiency bonus + ability modifier.
  int get spellAttack => proficiencyBonus + abilityModifier;

  /// Formatted spell attack string (e.g. "+5" or "-1").
  String get spellAttackFormatted =>
      spellAttack >= 0 ? '+$spellAttack' : '$spellAttack';

  // ── Spell count limits ────────────────────────────────────────────────────

  /// Maximum number of spells prepared per day.
  /// Returns null for *known*-casters (Bard, Sorcerer, Ranger, Warlock)
  /// because they have a fixed known-spells table instead.
  int? get maxPrepared {
    switch (mechanism) {
      case SpellcastingMechanism.prepare:
        // Cleric, Druid: ability_mod + class_level (min 1)
        return (abilityModifier + classLevel).clamp(1, 999);
      case SpellcastingMechanism.prepareHalf:
        // Paladin: ability_mod + floor(level / 2) (min 1)
        return (abilityModifier + (classLevel / 2).floor()).clamp(1, 999);
      case SpellcastingMechanism.prepareArtificer:
        // Artificer: ability_mod + floor(level / 2) (min 1) — same formula
        return (abilityModifier + (classLevel / 2).floor()).clamp(1, 999);
      case SpellcastingMechanism.spellbook:
        // Wizard: ability_mod + class_level (min 1) prepared from spellbook
        return (abilityModifier + classLevel).clamp(1, 999);
      case SpellcastingMechanism.known:
      case SpellcastingMechanism.pact:
        return null; // uses maxKnown instead
    }
  }

  /// Maximum number of spells known (for *known*-casters).
  /// Returns null for prepare/spellbook classes.
  int? get maxKnown {
    switch (mechanism) {
      case SpellcastingMechanism.known:
        final idx = classLevel.clamp(1, 20) - 1;
        // 1/3 casters (EK, AT) use their own table
        if (progressionType == SpellProgressionType.third) {
          return _thirdCasterKnown[idx];
        }
        return _knownSpellsTable[className.toLowerCase()]?[idx];
      case SpellcastingMechanism.pact:
        return _warlockKnown[classLevel.clamp(1, 20) - 1];
      default:
        return null;
    }
  }

  /// Max cantrips known (all classes; scales with character level, not class level,
  /// but we use class level as a proxy for single-class characters).
  int get maxCantrips {
    final idx = classLevel.clamp(1, 20) - 1;
    final classCantrips = _cantripsTable[className.toLowerCase()];
    if (classCantrips != null) return classCantrips[idx];
    if (progressionType == SpellProgressionType.third) {
      final sub = subclass?.toLowerCase();
      if (sub == 'arcane trickster') {
        return _arcaneTricksterCantrips[idx];
      }
      return _eldritchKnightCantrips[idx];
    }
    return 0;
  }

  Set<String> get restrictedKnownSpellSchools {
    if (progressionType != SpellProgressionType.third) return const {};
    switch (subclass?.toLowerCase()) {
      case 'eldritch knight':
        return const {'abjuration', 'evocation'};
      case 'arcane trickster':
        return const {'enchantment', 'illusion'};
      default:
        return const {};
    }
  }

  bool get canLearnAnySchoolThisLevel =>
      progressionType == SpellProgressionType.third &&
      const {8, 14, 20}.contains(classLevel);

  int restrictedKnownSpellPicksRequired(int spellsToLearn) {
    if (restrictedKnownSpellSchools.isEmpty || canLearnAnySchoolThisLevel) {
      return 0;
    }
    if (classLevel == 3) return spellsToLearn.clamp(0, 2);
    return spellsToLearn;
  }

  List<String> get fixedCantripNames {
    if (subclass?.toLowerCase() == 'arcane trickster' && classLevel >= 3) {
      return const ['Mage Hand'];
    }
    return const [];
  }

  /// Highest spell slot level available, or 0 for non-casters.
  int get maxSpellLevel {
    final idx = classLevel.clamp(1, 20) - 1;
    switch (progressionType) {
      case SpellProgressionType.full:
        return _fullCasterMaxSlot[idx];
      case SpellProgressionType.half:
        return _halfCasterMaxSlot[idx];
      case SpellProgressionType.pact:
        return _pactMagicSlotLevel[idx];
      case SpellProgressionType.third:
        return _thirdCasterMaxSlot[idx];
    }
  }

  // ── Slot tables (SRD 5.1) ────────────────────────────────────────────────

  static const List<int> _fullCasterMaxSlot = [
    1, 1, 2, 2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
  ];

  static const List<int> _halfCasterMaxSlot = [
    0, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5,
  ];

  /// 1/3 caster max spell slot level (Eldritch Knight, Arcane Trickster).
  static const List<int> _thirdCasterMaxSlot = [
    0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4,
  ];

  /// 1/3 caster slot table (levels 1-20 of the base class, 9 spell levels).
  static const List<List<int>> _thirdSlotTable = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0], // level 1
    [0, 0, 0, 0, 0, 0, 0, 0, 0], // level 2
    [2, 0, 0, 0, 0, 0, 0, 0, 0], // level 3
    [3, 0, 0, 0, 0, 0, 0, 0, 0], // level 4
    [3, 0, 0, 0, 0, 0, 0, 0, 0], // level 5
    [3, 0, 0, 0, 0, 0, 0, 0, 0], // level 6
    [4, 2, 0, 0, 0, 0, 0, 0, 0], // level 7
    [4, 2, 0, 0, 0, 0, 0, 0, 0], // level 8
    [4, 2, 0, 0, 0, 0, 0, 0, 0], // level 9
    [4, 3, 0, 0, 0, 0, 0, 0, 0], // level 10
    [4, 3, 0, 0, 0, 0, 0, 0, 0], // level 11
    [4, 3, 0, 0, 0, 0, 0, 0, 0], // level 12
    [4, 3, 2, 0, 0, 0, 0, 0, 0], // level 13
    [4, 3, 2, 0, 0, 0, 0, 0, 0], // level 14
    [4, 3, 2, 0, 0, 0, 0, 0, 0], // level 15
    [4, 3, 3, 0, 0, 0, 0, 0, 0], // level 16
    [4, 3, 3, 0, 0, 0, 0, 0, 0], // level 17
    [4, 3, 3, 0, 0, 0, 0, 0, 0], // level 18
    [4, 3, 3, 1, 0, 0, 0, 0, 0], // level 19
    [4, 3, 3, 1, 0, 0, 0, 0, 0], // level 20
  ];

  /// Known spells for Eldritch Knight / Arcane Trickster (index = class level - 1).
  static const List<int> _thirdCasterKnown = [
    0, 0, 3, 4, 4, 4, 5, 6, 6, 7, 8, 8, 9, 10, 10, 11, 11, 11, 12, 13,
  ];

  /// Cantrips for Eldritch Knight.
  static const List<int> _eldritchKnightCantrips = [
    0, 0, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  ];

  /// Cantrips for Arcane Trickster, including the fixed Mage Hand cantrip.
  static const List<int> _arcaneTricksterCantrips = [
    0, 0, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
  ];

  /// Warlock Pact Magic slot level (all slots are this level).
  static const List<int> _pactMagicSlotLevel = [
    1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
  ];

  /// Warlock Pact Magic number of slots per level.
  static const List<int> _pactMagicSlotCount = [
    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4,
  ];

  /// Full caster slot counts per spell level, per class level.
  /// Outer index: class level - 1 (0-19). Inner index: spell level - 1 (0-8).
  static const List<List<int>> _fullSlotTable = [
    [2, 0, 0, 0, 0, 0, 0, 0, 0], // level 1
    [3, 0, 0, 0, 0, 0, 0, 0, 0], // level 2
    [4, 2, 0, 0, 0, 0, 0, 0, 0], // level 3
    [4, 3, 0, 0, 0, 0, 0, 0, 0], // level 4
    [4, 3, 2, 0, 0, 0, 0, 0, 0], // level 5
    [4, 3, 3, 0, 0, 0, 0, 0, 0], // level 6
    [4, 3, 3, 1, 0, 0, 0, 0, 0], // level 7
    [4, 3, 3, 2, 0, 0, 0, 0, 0], // level 8
    [4, 3, 3, 3, 1, 0, 0, 0, 0], // level 9
    [4, 3, 3, 3, 2, 0, 0, 0, 0], // level 10
    [4, 3, 3, 3, 2, 1, 0, 0, 0], // level 11
    [4, 3, 3, 3, 2, 1, 0, 0, 0], // level 12
    [4, 3, 3, 3, 2, 1, 1, 0, 0], // level 13
    [4, 3, 3, 3, 2, 1, 1, 0, 0], // level 14
    [4, 3, 3, 3, 2, 1, 1, 1, 0], // level 15
    [4, 3, 3, 3, 2, 1, 1, 1, 0], // level 16
    [4, 3, 3, 3, 2, 1, 1, 1, 1], // level 17
    [4, 3, 3, 3, 3, 1, 1, 1, 1], // level 18
    [4, 3, 3, 3, 3, 2, 1, 1, 1], // level 19
    [4, 3, 3, 3, 3, 2, 2, 1, 1], // level 20
  ];

  /// Half caster slot counts per spell level, per class level.
  static const List<List<int>> _halfSlotTable = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0], // level 1
    [2, 0, 0, 0, 0, 0, 0, 0, 0], // level 2
    [3, 0, 0, 0, 0, 0, 0, 0, 0], // level 3
    [3, 0, 0, 0, 0, 0, 0, 0, 0], // level 4
    [4, 2, 0, 0, 0, 0, 0, 0, 0], // level 5
    [4, 2, 0, 0, 0, 0, 0, 0, 0], // level 6
    [4, 3, 0, 0, 0, 0, 0, 0, 0], // level 7
    [4, 3, 0, 0, 0, 0, 0, 0, 0], // level 8
    [4, 3, 2, 0, 0, 0, 0, 0, 0], // level 9
    [4, 3, 2, 0, 0, 0, 0, 0, 0], // level 10
    [4, 3, 3, 0, 0, 0, 0, 0, 0], // level 11
    [4, 3, 3, 0, 0, 0, 0, 0, 0], // level 12
    [4, 3, 3, 1, 0, 0, 0, 0, 0], // level 13
    [4, 3, 3, 1, 0, 0, 0, 0, 0], // level 14
    [4, 3, 3, 2, 0, 0, 0, 0, 0], // level 15
    [4, 3, 3, 2, 0, 0, 0, 0, 0], // level 16
    [4, 3, 3, 2, 0, 0, 0, 0, 0], // level 17
    [4, 3, 3, 3, 1, 0, 0, 0, 0], // level 18
    [4, 3, 3, 3, 1, 0, 0, 0, 0], // level 19
    [4, 3, 3, 3, 2, 0, 0, 0, 0], // level 20
  ];

  /// Returns the spell slot totals [lvl1..lvl9] for the current class/level.
  List<int> get slotsPerLevel {
    final idx = classLevel.clamp(1, 20) - 1;
    switch (progressionType) {
      case SpellProgressionType.full:
        return List.from(_fullSlotTable[idx]);
      case SpellProgressionType.half:
        return List.from(_halfSlotTable[idx]);
      case SpellProgressionType.pact:
        // Warlock: only the pact slot level has slots, rest are 0
        final slots = List.filled(9, 0);
        final slotLvl = _pactMagicSlotLevel[idx];
        slots[slotLvl - 1] = _pactMagicSlotCount[idx];
        return slots;
      case SpellProgressionType.third:
        return List.from(_thirdSlotTable[idx]);
    }
  }
}

// ── Enums ─────────────────────────────────────────────────────────────────────

enum SpellcastingMechanism {
  /// Cleric, Druid — prepare from full class list each day.
  prepare,

  /// Paladin — prepare (half-caster formula).
  prepareHalf,

  /// Artificer — prepare (half-caster formula, but treated separately).
  prepareArtificer,

  /// Wizard — has spellbook; prepares a subset each day.
  spellbook,

  /// Bard, Sorcerer, Ranger — fixed number of spells known permanently.
  known,

  /// Warlock — known spells, Pact Magic slots.
  pact,
}

enum SpellProgressionType {
  /// Full casters: Bard, Cleric, Druid, Sorcerer, Wizard.
  full,

  /// Half casters: Paladin, Ranger, Artificer.
  half,

  /// Warlock Pact Magic.
  pact,

  /// 1/3 casters: Eldritch Knight (Fighter), Arcane Trickster (Rogue).
  third,
}

// ── Class info table ──────────────────────────────────────────────────────────

class _ClassSpellInfo {
  final String ability;
  final SpellcastingMechanism mechanism;
  final SpellProgressionType progression;
  const _ClassSpellInfo(this.ability, this.mechanism, this.progression);
}

const _classInfo = <String, _ClassSpellInfo>{
  'bard':      _ClassSpellInfo('CHA', SpellcastingMechanism.known,             SpellProgressionType.full),
  'cleric':    _ClassSpellInfo('WIS', SpellcastingMechanism.prepare,           SpellProgressionType.full),
  'druid':     _ClassSpellInfo('WIS', SpellcastingMechanism.prepare,           SpellProgressionType.full),
  'paladin':   _ClassSpellInfo('CHA', SpellcastingMechanism.prepareHalf,       SpellProgressionType.half),
  'ranger':    _ClassSpellInfo('WIS', SpellcastingMechanism.known,             SpellProgressionType.half),
  'sorcerer':  _ClassSpellInfo('CHA', SpellcastingMechanism.known,             SpellProgressionType.full),
  'warlock':   _ClassSpellInfo('CHA', SpellcastingMechanism.pact,              SpellProgressionType.pact),
  'wizard':    _ClassSpellInfo('INT', SpellcastingMechanism.spellbook,         SpellProgressionType.full),
  'artificer': _ClassSpellInfo('INT', SpellcastingMechanism.prepareArtificer,  SpellProgressionType.half),
};

// ── Known-spells tables (SRD 5.1) ────────────────────────────────────────────
// Index = class level - 1 (levels 1–20)

const _warlockKnown = [2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 11, 11, 12, 12, 13, 13, 14, 14, 15, 15];

const _knownSpellsTable = <String, List<int>>{
  'bard':     [4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 15, 16, 18, 19, 19, 20, 22, 22, 22],
  'ranger':   [2, 3, 3, 4, 4, 5,  5,  6,  6,  7,  7,  8,  8,  9,  9, 10, 10, 11, 11, 11],
  'sorcerer': [2, 3, 4, 5, 6, 7,  8,  9, 10, 11, 12, 12, 13, 13, 14, 14, 15, 15, 15, 15],
};

// ── Cantrip tables ────────────────────────────────────────────────────────────

const _cantripsTable = <String, List<int>>{
  'bard':      [2, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4],
  'cleric':    [3, 3, 3, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5],
  'druid':     [2, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4],
  'sorcerer':  [4, 4, 4, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6],
  'warlock':   [2, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4],
  'wizard':    [3, 3, 3, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5],
  'artificer': [2, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4],
  // Paladin and Ranger have no cantrips in base SRD.
};

// ── Helper extension on KnownSpell ────────────────────────────────────────────

extension KnownSpellCasting on KnownSpell {
  /// Whether this class uses a toggle to prepare spells vs. all being "always on".
  static bool classPrepares(String className) {
    final m = _classInfo[className.toLowerCase()]?.mechanism;
    return m == SpellcastingMechanism.prepare ||
        m == SpellcastingMechanism.prepareHalf ||
        m == SpellcastingMechanism.prepareArtificer ||
        m == SpellcastingMechanism.spellbook;
  }
}
