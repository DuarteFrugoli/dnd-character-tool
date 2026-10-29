import '../feature_usage_engine.dart';
import '../models/models.dart';

enum ShortRestRecoveryKind { spellSlots, resourcePoints }

/// A once-per-long-rest feature used when finishing a short rest, such as
/// Arcane Recovery or Sorcerous Restoration.
class ShortRestRecoveryRule {
  const ShortRestRecoveryRule.spellSlots({
    required this.resourceId,
    required this.featureName,
  }) : kind = ShortRestRecoveryKind.spellSlots,
       targetResourceId = null;

  const ShortRestRecoveryRule.resourcePoints({
    required this.resourceId,
    required this.featureName,
    required String this.targetResourceId,
  }) : kind = ShortRestRecoveryKind.resourcePoints;

  /// Resource spent when the feature is used.
  final String resourceId;
  final String featureName;
  final ShortRestRecoveryKind kind;

  /// Resource refilled by [ShortRestRecoveryKind.resourcePoints].
  final String? targetResourceId;

  static const maxSlotLevel = 5;

  /// Slots: half the class level rounded up, in combined slot levels.
  /// Points: half the class level rounded down.
  int budgetFor(int classLevel) => switch (kind) {
    ShortRestRecoveryKind.spellSlots => (classLevel + 1) ~/ 2,
    ShortRestRecoveryKind.resourcePoints => classLevel ~/ 2,
  };
}

/// A recovery the character can use right now.
class ShortRestRecoveryOption {
  const ShortRestRecoveryOption({
    required this.rule,
    required this.resourceName,
    required this.budget,
    required this.remainingUses,
    this.recoverableSlots = const [],
    this.recoverablePoints = 0,
    this.targetCurrent = 0,
  });

  final ShortRestRecoveryRule rule;
  final String resourceName;
  final int budget;
  final int remainingUses;

  /// Expended standard slots per level (index 0 = level 1), up to level 5.
  final List<int> recoverableSlots;

  /// Points that can be regained, already limited by [budget].
  final int recoverablePoints;

  /// Current value of the refilled resource.
  final int targetCurrent;

  String get resourceId => rule.resourceId;
}

/// What the player chose for one [ShortRestRecoveryOption].
class ShortRestRecoverySelection {
  const ShortRestRecoverySelection.slots(this.resourceId, this.slotsByLevel)
    : points = 0;

  const ShortRestRecoverySelection.points(this.resourceId, this.points)
    : slotsByLevel = const [];

  final String resourceId;

  /// Slots to recover per level (index 0 = level 1).
  final List<int> slotsByLevel;
  final int points;

  int get combinedSlotLevels {
    var total = 0;
    for (var i = 0; i < slotsByLevel.length; i++) {
      total += slotsByLevel[i] * (i + 1);
    }
    return total;
  }

  bool get isEmpty =>
      points <= 0 && slotsByLevel.every((count) => count <= 0);
}

class ShortRestRecoveryEngine {
  const ShortRestRecoveryEngine._();

  /// Options available for [character] given its active resource bindings.
  static List<ShortRestRecoveryOption> optionsFor({
    required Character character,
    required Iterable<ShortRestRecoveryRule> rules,
    required Iterable<FeatureUsageBinding> bindings,
  }) {
    final byId = {for (final binding in bindings) binding.resource.id: binding};
    final options = <ShortRestRecoveryOption>[];
    for (final rule in rules) {
      final binding = byId[rule.resourceId];
      if (binding == null) continue;
      final remainingUses = _remaining(character, binding);
      if (remainingUses < 1) continue;
      final budget = rule.budgetFor(binding.usageContext.effectiveClassLevel);
      if (budget < 1) continue;
      switch (rule.kind) {
        case ShortRestRecoveryKind.spellSlots:
          final recoverable = [
            for (var level = 1; level <= ShortRestRecoveryRule.maxSlotLevel; level++)
              level > budget ? 0 : _expendedSlots(character.spellSlots, level),
          ];
          if (recoverable.every((count) => count == 0)) continue;
          options.add(
            ShortRestRecoveryOption(
              rule: rule,
              resourceName: binding.resource.name,
              budget: budget,
              remainingUses: remainingUses,
              recoverableSlots: recoverable,
            ),
          );
        case ShortRestRecoveryKind.resourcePoints:
          final target = byId[rule.targetResourceId];
          if (target == null) continue;
          final max = _max(character, target);
          if (max == null) continue;
          final targetCurrent = _remaining(character, target);
          final missing = max - targetCurrent;
          if (missing < 1) continue;
          options.add(
            ShortRestRecoveryOption(
              rule: rule,
              resourceName: binding.resource.name,
              budget: budget,
              remainingUses: remainingUses,
              recoverablePoints: missing < budget ? missing : budget,
              targetCurrent: targetCurrent,
            ),
          );
      }
    }
    return options;
  }

  /// Applies [selections] that match an available option; anything outside
  /// the option's limits is rejected with an [ArgumentError].
  static Character apply(
    Character character, {
    required List<ShortRestRecoveryOption> options,
    required Iterable<ShortRestRecoverySelection> selections,
  }) {
    var updated = character;
    for (final selection in selections) {
      if (selection.isEmpty) continue;
      final option = options
          .where((option) => option.resourceId == selection.resourceId)
          .firstOrNull;
      if (option == null) {
        throw ArgumentError('${selection.resourceId} is not available.');
      }
      final resources = Map<String, int>.from(updated.featureResources);
      resources[option.resourceId] = option.remainingUses - 1;
      switch (option.rule.kind) {
        case ShortRestRecoveryKind.spellSlots:
          _checkSlots(option, selection);
          final used = List<int>.from(updated.spellSlots.used);
          for (var i = 0; i < selection.slotsByLevel.length; i++) {
            used[i] -= selection.slotsByLevel[i];
          }
          updated = updated.copyWith(
            spellSlots: updated.spellSlots.copyWith(used: used),
            featureResources: resources,
          );
        case ShortRestRecoveryKind.resourcePoints:
          if (selection.points > option.recoverablePoints) {
            throw ArgumentError('Too many points for ${option.resourceId}.');
          }
          resources[option.rule.targetResourceId!] =
              option.targetCurrent + selection.points;
          updated = updated.copyWith(featureResources: resources);
      }
    }
    return updated;
  }

  static void _checkSlots(
    ShortRestRecoveryOption option,
    ShortRestRecoverySelection selection,
  ) {
    if (selection.slotsByLevel.length > option.recoverableSlots.length ||
        selection.combinedSlotLevels > option.budget) {
      throw ArgumentError('Too many slots for ${option.resourceId}.');
    }
    for (var i = 0; i < selection.slotsByLevel.length; i++) {
      final count = selection.slotsByLevel[i];
      if (count < 0 || count > option.recoverableSlots[i]) {
        throw ArgumentError('Invalid level ${i + 1} slots.');
      }
    }
  }

  static int _expendedSlots(SpellSlots slots, int level) {
    final index = level - 1;
    if (index >= slots.used.length || index >= slots.total.length) return 0;
    final used = slots.used[index].clamp(0, slots.total[index]).toInt();
    return used;
  }

  static int? _max(Character character, FeatureUsageBinding binding) =>
      FeatureUsageEngine.maxFor(
        binding.resource,
        character,
        usageContext: binding.usageContext,
      );

  static int _remaining(Character character, FeatureUsageBinding binding) {
    final max = _max(character, binding);
    return FeatureUsageEngine.currentFor(character, binding.resource, max) ??
        0;
  }
}
