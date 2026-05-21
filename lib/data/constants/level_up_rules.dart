import '../datasources/srd/srd_models.dart';
import '../models/spell.dart';

// ── Level Up Result ───────────────────────────────────────────────────────────

/// Holds all decisions made by the user during the Level Up Wizard.
class LevelUpResult {
  const LevelUpResult({
    required this.hpGained,
    this.asiChanges = const {},
    this.featChosen,
    this.subclassChosen,
    this.cantripsLearned = const [],
    this.spellsLearned = const [],
    this.spellSwapped,
  });

  final int hpGained;

  /// Maps lowercase full ability name (e.g. 'strength') to delta (+1 or +2).
  final Map<String, int> asiChanges;

  final SrdFeat? featChosen;

  /// The chosen subclass name, or null if unchanged.
  final String? subclassChosen;

  final List<KnownSpell> cantripsLearned;
  final List<KnownSpell> spellsLearned;

  /// Name of an existing known spell to forget (Warlock swap). Null if none.
  final String? spellSwapped;
}

// ── XP Thresholds (SRD 5.1) ──────────────────────────────────────────────────

/// Minimum XP required for each level.  Index 0 = level 1 (0 XP).
const List<int> kXpThresholds = [
  0, 300, 900, 2_700, 6_500, 14_000, 23_000, 34_000, 48_000, 64_000,
  85_000, 100_000, 120_000, 140_000, 165_000, 195_000, 225_000, 265_000,
  305_000, 355_000,
];

/// Returns the level corresponding to [xp] (1–20).
int xpToLevel(int xp) {
  for (int i = kXpThresholds.length - 1; i >= 0; i--) {
    if (xp >= kXpThresholds[i]) return i + 1;
  }
  return 1;
}

/// Returns the minimum XP required for [level] (1–20).
int levelToMinXp(int level) => kXpThresholds[(level - 1).clamp(0, 19)];

// ── Static Tables (SRD 5.1) ───────────────────────────────────────────────────

/// Level at which each class first chooses a subclass.
const Map<String, int> subclassUnlockLevel = {
  'Barbarian': 3,
  'Bard': 3,
  'Cleric': 1,
  'Druid': 2,
  'Fighter': 3,
  'Monk': 3,
  'Paladin': 3,
  'Ranger': 3,
  'Rogue': 3,
  'Sorcerer': 1,
  'Warlock': 1,
  'Wizard': 2,
};

/// Levels at which each class gains an Ability Score Improvement.
const Map<String, List<int>> asiLevelsByClass = {
  'Barbarian': [4, 8, 12, 16, 19],
  'Bard': [4, 8, 12, 16, 19],
  'Cleric': [4, 8, 12, 16, 19],
  'Druid': [4, 8, 12, 16, 19],
  'Fighter': [4, 6, 8, 12, 14, 16, 19],
  'Monk': [4, 8, 12, 16, 19],
  'Paladin': [4, 8, 12, 16, 19],
  'Ranger': [4, 8, 12, 16, 19],
  'Rogue': [4, 8, 10, 12, 16, 19],
  'Sorcerer': [4, 8, 12, 16, 19],
  'Warlock': [4, 8, 12, 16, 19],
  'Wizard': [4, 8, 12, 16, 19],
};

/// Hit die size by class.
const Map<String, int> hitDieByClass = {
  'Barbarian': 12,
  'Fighter': 10,
  'Paladin': 10,
  'Ranger': 10,
  'Bard': 8,
  'Cleric': 8,
  'Druid': 8,
  'Monk': 8,
  'Rogue': 8,
  'Warlock': 8,
  'Sorcerer': 6,
  'Wizard': 6,
};

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Returns true if [newLevel] is an ASI level for [className].
bool isAsiLevel(String className, int newLevel) =>
    asiLevelsByClass[className]?.contains(newLevel) ?? false;

/// Returns true if [newLevel] is the subclass selection level for [className].
bool isSubclassUnlockLevel(String className, int newLevel) =>
    subclassUnlockLevel[className] == newLevel;

/// Returns the hit die size for [className], defaulting to 8.
int levelUpHitDie(String className) => hitDieByClass[className] ?? 8;
