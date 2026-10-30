import '../datasources/srd/srd_monster.dart';
import '../models/models.dart';
import 'ruleset_ids.dart';

/// One row of the Beast Shapes table.
class WildShapeLimits {
  const WildShapeLimits({
    required this.maxChallengeRating,
    required this.allowsFly,
    required this.allowsSwim,
    this.knownForms,
  });

  /// As printed, e.g. `1/4`.
  final String maxChallengeRating;
  final bool allowsFly;
  final bool allowsSwim;

  /// 2024: number of known forms; 2014 has no known forms.
  final int? knownForms;

  double get maxChallenge => SrdMonster.challengeRatingValue(maxChallengeRating);

  /// A swarm whose speed is "Climb or Fly" counts as having a Fly Speed.
  bool allows(SrdMonster monster) =>
      monster.isBeast &&
      monster.challengeValue <= maxChallenge &&
      (allowsFly || monster.speed.fly == null) &&
      (allowsSwim || monster.speed.swim == null);
}

/// Wild Shape of each edition: which Beasts a Druid can become and what the
/// form changes on the sheet.
sealed class WildShapeRules {
  const WildShapeRules();

  static const druid = 'Druid';
  static const featureName = 'Wild Shape';
  static const minDruidLevel = 2;

  static WildShapeRules forRuleset(RulesetId rulesetId) => switch (rulesetId) {
    RulesetId.dnd2014 => const WildShape2014Rules(),
    RulesetId.dnd2024 => const WildShape2024Rules(),
  };

  static WildShapeRules forCharacter(Character character) =>
      forRuleset(character.rulesetId);

  /// Row of the Beast Shapes table, or null before Druid level 2.
  WildShapeLimits? limitsAt(int druidLevel);

  WildShapeLimits? limitsFor(Character character) =>
      limitsAt(character.classLevel(druid));

  /// Hours a form lasts: half the Druid level, rounded down.
  int durationHours(int druidLevel) => druidLevel ~/ 2;

  /// 2014 forms have their own hit points; 2024 forms keep yours.
  bool get usesBeastHitPoints;

  /// Temporary hit points gained when assuming a form.
  int temporaryHitPointsOnAssume(int druidLevel);
}

/// SRD 5.1: any Beast the Druid has seen, within the table's limits.
class WildShape2014Rules extends WildShapeRules {
  const WildShape2014Rules();

  @override
  WildShapeLimits? limitsAt(int druidLevel) {
    if (druidLevel >= 8) {
      return const WildShapeLimits(maxChallengeRating: '1', allowsFly: true, allowsSwim: true);
    }
    if (druidLevel >= 4) {
      return const WildShapeLimits(maxChallengeRating: '1/2', allowsFly: false, allowsSwim: true);
    }
    if (druidLevel >= WildShapeRules.minDruidLevel) {
      return const WildShapeLimits(maxChallengeRating: '1/4', allowsFly: false, allowsSwim: false);
    }
    return null;
  }

  @override
  bool get usesBeastHitPoints => true;

  @override
  int temporaryHitPointsOnAssume(int druidLevel) => 0;
}

/// SRD 5.2.1: known forms chosen within the table's limits; a form keeps the
/// Druid's hit points and grants Temporary Hit Points.
class WildShape2024Rules extends WildShapeRules {
  const WildShape2024Rules();

  /// Feature choice that stores the known forms.
  static const knownFormsChoice = 'known_forms';

  @override
  WildShapeLimits? limitsAt(int druidLevel) {
    if (druidLevel >= 8) {
      return const WildShapeLimits(
        maxChallengeRating: '1',
        allowsFly: true,
        allowsSwim: true,
        knownForms: 8,
      );
    }
    if (druidLevel >= 4) {
      return const WildShapeLimits(
        maxChallengeRating: '1/2',
        allowsFly: false,
        allowsSwim: true,
        knownForms: 6,
      );
    }
    if (druidLevel >= WildShapeRules.minDruidLevel) {
      return const WildShapeLimits(
        maxChallengeRating: '1/4',
        allowsFly: false,
        allowsSwim: true,
        knownForms: 4,
      );
    }
    return null;
  }

  @override
  bool get usesBeastHitPoints => false;

  @override
  int temporaryHitPointsOnAssume(int druidLevel) => druidLevel;
}
