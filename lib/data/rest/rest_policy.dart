import '../character_progression/character_progression.dart';
import '../constants/level_up_rules.dart';
import '../feature_usage_engine.dart';
import '../models/models.dart';
import '../rulesets/ruleset_ids.dart';

/// Rest rules that differ between rulesets.
///
/// Feature resources are resolved asynchronously from the character's content
/// pack by the caller and passed in already restored through
/// [FeatureUsageEngine]; the policy only owns the synchronous character math.
abstract class RestPolicy {
  const RestPolicy();

  factory RestPolicy.forCharacter(Character character) =>
      RestPolicy.forRuleset(character.rulesetId);

  factory RestPolicy.forRuleset(RulesetId rulesetId) => switch (rulesetId) {
    RulesetId.dnd2014 => const Rest2014Policy(),
    RulesetId.dnd2024 => const Rest2024Policy(),
  };

  /// Hit die pools offered by the short rest dialog.
  List<CharacterHitDiePool> hitDicePoolsFor(Character character);

  /// Applies the long rest. [featureResources] must already be restored for
  /// [FeatureUsageRest.longRest]; [raceTraits] are the active species/race
  /// trait names from the character's own content pack.
  Character applyLongRest(
    Character character, {
    required Map<String, int> featureResources,
    Iterable<String> raceTraits = const [],
  });

  /// Spends hit dice and recovers HP and slots. Feature resources are restored
  /// afterwards by the caller, against the returned character.
  Character applyShortRest(
    Character character, {
    required List<int> hitDiceSpentByPool,
    required int hpGained,
  });

  /// Extra short-rest recovery for a resource that does not recharge on short
  /// rests. Returns `null` when the ruleset has no such rule.
  int? shortRestBonusRecovery({
    required FeatureUsageResource resource,
    required FeatureUsageContext usageContext,
    required int current,
    required int max,
  }) => null;
}

class Rest2014Policy extends RestPolicy {
  const Rest2014Policy();

  @override
  List<CharacterHitDiePool> hitDicePoolsFor(Character character) {
    if (character.hitDicePools.isNotEmpty) return character.hitDicePools;
    return [
      CharacterHitDiePool(
        dieSize: levelUpHitDie(character.primaryClassName),
        total: character.totalLevel,
        used: character.hitPoints.hitDiceUsed,
        sourceClass: character.primaryClassName,
        sourceClassEntryId: character.primaryClass.id,
      ),
    ];
  }

  @override
  Character applyLongRest(
    Character character, {
    required Map<String, int> featureResources,
    Iterable<String> raceTraits = const [],
  }) {
    // Recover ceil(level / 2) hit dice on a long rest (PHB rules)
    final hdRecovered = (character.totalLevel / 2).ceil();
    final newHdUsed = (character.totalHitDiceUsed - hdRecovered)
        .clamp(0, character.totalHitDice)
        .toInt();
    return character.copyWith(
      hitPoints: character.hitPoints.copyWith(
        current: character.hitPoints.maximum,
        temporary: 0,
        hitDiceUsed: newHdUsed,
      ),
      hitDicePools: recoverHitDicePools(character.hitDicePools, hdRecovered),
      spellSlots: character.spellSlots.copyWith(used: List.filled(9, 0)),
      pactMagicSlots: character.pactMagicSlots.copyWith(
        used: List.filled(9, 0),
      ),
      innateSpells: character.innateSpells
          .map((s) => s.copyWith(usedToday: 0))
          .toList(),
      featureResources: featureResources,
      concentrationSpell: null,
    );
  }

  @override
  Character applyShortRest(
    Character character, {
    required List<int> hitDiceSpentByPool,
    required int hpGained,
  }) {
    final rested = spendHitDice(
      character,
      hitDiceSpentByPool: hitDiceSpentByPool,
      hpGained: hpGained,
    );
    return CharacterProgressionEngine.syncSpellcastingSlotsFor(rested).copyWith(
      pactMagicSlots: CharacterProgressionEngine.pactMagicSlotsAfterShortRest(
        rested,
      ),
    );
  }

  @override
  int? shortRestBonusRecovery({
    required FeatureUsageResource resource,
    required FeatureUsageContext usageContext,
    required int current,
    required int max,
  }) {
    // Sorcerous Restoration (Sorcerer 20): regain 4 sorcery points.
    if (resource.id == 'sorcery_points' &&
        usageContext.sourceClass?.toLowerCase() == 'sorcerer' &&
        usageContext.effectiveClassLevel >= 20) {
      return (current + 4).clamp(0, max).toInt();
    }
    return null;
  }
}

/// SRD 5.2.1 Rules Glossary: Long Rest and Short Rest.
class Rest2024Policy extends RestPolicy {
  const Rest2024Policy();

  /// Species traits that grant Heroic Inspiration on finishing a long rest.
  static const heroicInspirationLongRestTraits = {'Resourceful'};

  @override
  List<CharacterHitDiePool> hitDicePoolsFor(Character character) =>
      character.hitDicePools;

  @override
  Character applyLongRest(
    Character character, {
    required Map<String, int> featureResources,
    Iterable<String> raceTraits = const [],
  }) {
    final grantsHeroicInspiration = raceTraits.any(
      heroicInspirationLongRestTraits.contains,
    );
    return character.copyWith(
      // Regain all lost HP and all spent Hit Point Dice.
      hitPoints: character.hitPoints.copyWith(
        current: character.hitPoints.maximum,
        temporary: 0,
        hitDiceUsed: 0,
        deathSaveSuccesses: 0,
        deathSaveFailures: 0,
      ),
      hitDicePools: [
        for (final pool in character.hitDicePools) pool.copyWith(used: 0),
      ],
      spellSlots: character.spellSlots.copyWith(used: List.filled(9, 0)),
      pactMagicSlots: character.pactMagicSlots.copyWith(
        used: List.filled(9, 0),
      ),
      featureResources: featureResources,
      inspiration: grantsHeroicInspiration ? true : null,
      concentrationSpell: null,
    );
  }

  @override
  Character applyShortRest(
    Character character, {
    required List<int> hitDiceSpentByPool,
    required int hpGained,
  }) {
    final rested = spendHitDice(
      character,
      hitDiceSpentByPool: hitDiceSpentByPool,
      hpGained: hpGained,
    );
    // Slot totals come from the 2024 class tables saved on the character;
    // a short rest only recovers expended Pact Magic slots.
    return rested.copyWith(
      pactMagicSlots: rested.pactMagicSlots.copyWith(used: List.filled(9, 0)),
    );
  }
}

/// Spends hit dice by pool index and adds [hpGained], clamped to the maximum.
Character spendHitDice(
  Character character, {
  required List<int> hitDiceSpentByPool,
  required int hpGained,
}) {
  final clampedHp = hpGained
      .clamp(0, character.hitPoints.maximum - character.hitPoints.current)
      .toInt();
  final newHitDicePools = spendHitDicePoolsByIndex(
    character.hitDicePools,
    hitDiceSpentByPool,
  );
  final hdSpent = hitDiceSpent(character.hitDicePools, hitDiceSpentByPool);
  final newHdUsed = newHitDicePools.isEmpty
      ? (character.totalHitDiceUsed + hdSpent)
            .clamp(0, character.totalHitDice)
            .toInt()
      : newHitDicePools.fold<int>(0, (sum, pool) => sum + pool.used);
  return character.copyWith(
    hitPoints: character.hitPoints.copyWith(
      current: character.hitPoints.current + clampedHp,
      hitDiceUsed: newHdUsed,
    ),
    hitDicePools: newHitDicePools,
  );
}

int hitDiceSpent(List<CharacterHitDiePool> pools, List<int> spendByPool) {
  if (spendByPool.isEmpty) return 0;
  if (pools.isEmpty) {
    return spendByPool.fold<int>(
      0,
      (sum, count) => sum + count.clamp(0, 20).toInt(),
    );
  }
  var spent = 0;
  for (var i = 0; i < pools.length; i++) {
    final requested = i < spendByPool.length ? spendByPool[i] : 0;
    spent += requested.clamp(0, pools[i].remaining).toInt();
  }
  return spent;
}

List<CharacterHitDiePool> spendHitDicePoolsByIndex(
  List<CharacterHitDiePool> pools,
  List<int> spendByPool,
) {
  if (pools.isEmpty || spendByPool.isEmpty) return pools;
  final updated = <CharacterHitDiePool>[];
  for (var i = 0; i < pools.length; i++) {
    final pool = pools[i];
    final requested = i < spendByPool.length ? spendByPool[i] : 0;
    final spend = requested.clamp(0, pool.remaining).toInt();
    updated.add(pool.copyWith(used: pool.used + spend));
  }
  return updated;
}

List<CharacterHitDiePool> recoverHitDicePools(
  List<CharacterHitDiePool> pools,
  int count,
) {
  if (pools.isEmpty || count <= 0) return pools;
  var remaining = count;
  final updated = <CharacterHitDiePool>[];
  for (final pool in pools) {
    final recovered = remaining < pool.used ? remaining : pool.used;
    updated.add(pool.copyWith(used: pool.used - recovered));
    remaining -= recovered;
  }
  return updated;
}
