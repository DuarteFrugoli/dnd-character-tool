import 'review_prompt_state.dart';

enum ReviewPromptBlockReason {
  unsupportedPlatform,
  unavailableApi,
  noCharacters,
  notEnoughAppOpens,
  firstSeenMissing,
  tooEarly,
  noSignificantAction,
  cooldown,
  versionAlreadyPrompted,
}

class ReviewPromptPolicy {
  const ReviewPromptPolicy({
    this.minAppOpenCount = 4,
    this.minUsageAge = const Duration(days: 3),
    this.promptCooldown = const Duration(days: 60),
    this.minSignificantActionCount = 1,
  });

  final int minAppOpenCount;
  final Duration minUsageAge;
  final Duration promptCooldown;
  final int minSignificantActionCount;

  bool shouldRequest({
    required ReviewPromptState state,
    required DateTime now,
    required bool isAndroid,
    required bool isReviewAvailable,
    required int characterCount,
    required String? currentVersion,
  }) {
    return firstBlockReason(
          state: state,
          now: now,
          isAndroid: isAndroid,
          isReviewAvailable: isReviewAvailable,
          characterCount: characterCount,
          currentVersion: currentVersion,
        ) ==
        null;
  }

  ReviewPromptBlockReason? firstBlockReason({
    required ReviewPromptState state,
    required DateTime now,
    required bool isAndroid,
    required bool isReviewAvailable,
    required int characterCount,
    required String? currentVersion,
  }) {
    if (!isAndroid) return ReviewPromptBlockReason.unsupportedPlatform;
    if (!isReviewAvailable) return ReviewPromptBlockReason.unavailableApi;
    if (characterCount <= 0) return ReviewPromptBlockReason.noCharacters;
    if (state.appOpenCount < minAppOpenCount) {
      return ReviewPromptBlockReason.notEnoughAppOpens;
    }

    final firstSeenAt = state.firstSeenAt;
    if (firstSeenAt == null) return ReviewPromptBlockReason.firstSeenMissing;
    if (now.difference(firstSeenAt) < minUsageAge) {
      return ReviewPromptBlockReason.tooEarly;
    }

    if (state.significantActionCount < minSignificantActionCount) {
      return ReviewPromptBlockReason.noSignificantAction;
    }

    final lastPromptAttemptAt = state.lastPromptAttemptAt;
    if (lastPromptAttemptAt != null &&
        now.difference(lastPromptAttemptAt) < promptCooldown) {
      return ReviewPromptBlockReason.cooldown;
    }

    if (currentVersion != null &&
        state.lastPromptedVersion != null &&
        currentVersion == state.lastPromptedVersion) {
      return ReviewPromptBlockReason.versionAlreadyPrompted;
    }

    return null;
  }
}
