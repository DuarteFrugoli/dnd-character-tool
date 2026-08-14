import 'package:dnd_character_tool/core/review/review_prompt_policy.dart';
import 'package:dnd_character_tool/core/review/review_prompt_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReviewPromptPolicy', () {
    const policy = ReviewPromptPolicy();
    final now = DateTime(2026, 8, 14, 12);
    final eligibleState = ReviewPromptState(
      firstSeenAt: now.subtract(const Duration(days: 4)),
      appOpenCount: 4,
      significantActionCount: 1,
    );

    bool shouldRequest({
      ReviewPromptState? state,
      bool isAndroid = true,
      bool isReviewAvailable = true,
      int characterCount = 1,
      String? currentVersion = '2.0.0+24',
      DateTime? at,
    }) {
      return policy.shouldRequest(
        state: state ?? eligibleState,
        now: at ?? now,
        isAndroid: isAndroid,
        isReviewAvailable: isReviewAvailable,
        characterCount: characterCount,
        currentVersion: currentVersion,
      );
    }

    test('allows a prompt after real usage and a significant action', () {
      expect(shouldRequest(), isTrue);
    });

    test('blocks unsupported platforms', () {
      expect(shouldRequest(isAndroid: false), isFalse);
    });

    test('blocks unavailable review API', () {
      expect(shouldRequest(isReviewAvailable: false), isFalse);
    });

    test('blocks users without characters', () {
      expect(shouldRequest(characterCount: 0), isFalse);
    });

    test('blocks before four app opens', () {
      expect(
        shouldRequest(state: eligibleState.copyWith(appOpenCount: 3)),
        isFalse,
      );
    });

    test('blocks before three days of usage', () {
      expect(
        shouldRequest(
          state: eligibleState.copyWith(
            firstSeenAt: now.subtract(const Duration(days: 2, hours: 23)),
          ),
        ),
        isFalse,
      );
    });

    test('blocks when no significant action was recorded', () {
      expect(
        shouldRequest(state: eligibleState.copyWith(significantActionCount: 0)),
        isFalse,
      );
    });

    test('blocks attempts inside the cooldown window', () {
      expect(
        shouldRequest(
          state: eligibleState.copyWith(
            lastPromptAttemptAt: now.subtract(const Duration(days: 59)),
          ),
        ),
        isFalse,
      );
    });

    test('allows a new attempt after the cooldown window', () {
      expect(
        shouldRequest(
          state: eligibleState.copyWith(
            lastPromptAttemptAt: now.subtract(const Duration(days: 60)),
            lastPromptedVersion: '1.9.9+23',
          ),
        ),
        isTrue,
      );
    });

    test('blocks a second attempt on the same version', () {
      expect(
        shouldRequest(
          state: eligibleState.copyWith(
            lastPromptAttemptAt: now.subtract(const Duration(days: 61)),
            lastPromptedVersion: '2.0.0+24',
          ),
        ),
        isFalse,
      );
    });

    test('does not apply version block when version is unavailable', () {
      expect(
        shouldRequest(
          state: eligibleState.copyWith(
            lastPromptAttemptAt: now.subtract(const Duration(days: 61)),
            lastPromptedVersion: '2.0.0+24',
          ),
          currentVersion: null,
        ),
        isTrue,
      );
    });
  });
}
