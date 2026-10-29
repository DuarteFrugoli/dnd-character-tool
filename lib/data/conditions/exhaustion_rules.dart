import '../models/models.dart';
import '../rulesets/ruleset_ids.dart';

/// Exhaustion rules that differ between rulesets.
abstract class ExhaustionRules {
  const ExhaustionRules();

  static const conditionName = 'Exhaustion';
  static const maxLevel = 6;

  factory ExhaustionRules.forCharacter(Character character) =>
      ExhaustionRules.forRuleset(character.rulesetId);

  factory ExhaustionRules.forRuleset(RulesetId rulesetId) =>
      switch (rulesetId) {
        RulesetId.dnd2014 => const Exhaustion2014Rules(),
        RulesetId.dnd2024 => const Exhaustion2024Rules(),
      };

  /// Whether Exhaustion is tracked as [Character.exhaustionLevel] instead of
  /// a plain entry in [Character.activeConditions].
  bool get tracksLevels;

  int levelFor(Character character);

  /// Modifier added to every D20 Test (ability checks, saves, attacks).
  int d20TestModifier(Character character);

  /// Speed after Exhaustion, in feet.
  int speedFor(Character character);

  int levelAfterLongRest(int level);
}

class Exhaustion2014Rules extends ExhaustionRules {
  const Exhaustion2014Rules();

  @override
  bool get tracksLevels => false;

  @override
  int levelFor(Character character) => 0;

  @override
  int d20TestModifier(Character character) => 0;

  @override
  int speedFor(Character character) => character.speed;

  @override
  int levelAfterLongRest(int level) => level;
}

/// SRD 5.2.1 Exhaustion: each level imposes -2 on D20 Tests and -5 feet of
/// Speed; a long rest removes one level; level 6 is death.
class Exhaustion2024Rules extends ExhaustionRules {
  const Exhaustion2024Rules();

  @override
  bool get tracksLevels => true;

  @override
  int levelFor(Character character) =>
      character.exhaustionLevel.clamp(0, ExhaustionRules.maxLevel).toInt();

  @override
  int d20TestModifier(Character character) => -2 * levelFor(character);

  @override
  int speedFor(Character character) {
    final speed = character.speed - 5 * levelFor(character);
    return speed < 0 ? 0 : speed;
  }

  @override
  int levelAfterLongRest(int level) =>
      (level - 1).clamp(0, ExhaustionRules.maxLevel).toInt();
}
