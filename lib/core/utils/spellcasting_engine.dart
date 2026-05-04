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

  const SpellcastingEngine._({
    required this.className,
    required this.classLevel,
    required this.abilityScores,
    required this.proficiencyBonus,
    required this.spellcastingAbility,
    required this.mechanism,
    required this.progressionType,
  });

  // ── Factory ───────────────────────────────────────────────────────────────

  /// Returns a [SpellcastingEngine] for [className], or null if the class is
  /// not a spellcaster in the SRD (e.g. Fighter base, Rogue base).
  static SpellcastingEngine? forClass({
    required String className,
    required int classLevel,
    required AbilityScores abilityScores,
    required int proficiencyBonus,
  }) {
    final info = _classInfo[className.toLowerCase()];
    if (info == null) return null;
    return SpellcastingEngine._(
      className: className,
      classLevel: classLevel,
      abilityScores: abilityScores,
      proficiencyBonus: proficiencyBonus,
      spellcastingAbility: info.ability,
      mechanism: info.mechanism,
      progressionType: info.progression,
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
        return _knownSpellsTable[className.toLowerCase()]
            ?[classLevel.clamp(1, 20) - 1];
      case SpellcastingMechanism.pact:
        return _warlockKnown[classLevel.clamp(1, 20) - 1];
      default:
        return null;
    }
  }

  /// Max cantrips known (all classes; scales with character level, not class level,
  /// but we use class level as a proxy for single-class characters).
  int get maxCantrips =>
      _cantripsTable[className.toLowerCase()]
          ?[classLevel.clamp(1, 20) - 1] ??
      0;

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
    }
  }

  // ── Cantrip scaling ───────────────────────────────────────────────────────

  /// Number of extra damage dice added to cantrips based on *character* level.
  /// (Pass the total character level, not just the class level.)
  static int cantripBonusDice(int characterLevel) {
    if (characterLevel >= 17) return 3;
    if (characterLevel >= 11) return 2;
    if (characterLevel >= 5) return 1;
    return 0;
  }

  // ── Slot tables (SRD 5.1) ────────────────────────────────────────────────

  static const List<int> _fullCasterMaxSlot = [
    1, 1, 2, 2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
  ];

  static const List<int> _halfCasterMaxSlot = [
    0, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5,
  ];

  /// Warlock Pact Magic slot level (all slots are this level).
  static const List<int> _pactMagicSlotLevel = [
    1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
  ];
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
