import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'review_prompt_policy.dart';
import 'review_prompt_state.dart';

enum ReviewMilestone {
  backupExported,
  levelUpCompleted,
  noteSaved,
  characterCreated,
}

abstract class AppReviewGateway {
  Future<bool> isAvailable();
  Future<void> requestReview();
  Future<void> openStoreListing();
}

class InAppReviewGateway implements AppReviewGateway {
  InAppReviewGateway({InAppReview? inAppReview})
    : _inAppReview = inAppReview ?? InAppReview.instance;

  final InAppReview _inAppReview;

  @override
  Future<bool> isAvailable() => _inAppReview.isAvailable();

  @override
  Future<void> requestReview() => _inAppReview.requestReview();

  @override
  Future<void> openStoreListing() => _inAppReview.openStoreListing();
}

final appReviewServiceProvider = Provider<AppReviewService>(
  (ref) => AppReviewService(),
);

class AppReviewService {
  AppReviewService({
    SharedPreferences? sharedPreferences,
    AppReviewGateway? gateway,
    ReviewPromptPolicy policy = const ReviewPromptPolicy(),
    DateTime Function()? now,
    Future<String?> Function()? currentVersion,
  }) : _sharedPreferences = sharedPreferences,
       _gateway = gateway ?? InAppReviewGateway(),
       _policy = policy,
       _now = now ?? DateTime.now,
       _currentVersion = currentVersion;

  final SharedPreferences? _sharedPreferences;
  final AppReviewGateway _gateway;
  final ReviewPromptPolicy _policy;
  final DateTime Function() _now;
  final Future<String?> Function()? _currentVersion;

  static const _firstSeenAtKey = 'review_first_seen_at';
  static const _appOpenCountKey = 'review_app_open_count';
  static const _lastPromptAttemptAtKey = 'review_last_prompt_attempt_at';
  static const _promptAttemptCountKey = 'review_prompt_attempt_count';
  static const _lastPromptedVersionKey = 'review_last_prompted_version';
  static const _significantActionCountKey = 'review_significant_action_count';

  static bool get isPlayStoreReviewSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> recordAppOpen() async {
    final prefs = await _prefs();
    final state = _loadState(prefs);
    final firstSeenAt = state.firstSeenAt ?? _now();
    await _saveState(
      prefs,
      state.copyWith(
        firstSeenAt: firstSeenAt,
        appOpenCount: state.appOpenCount + 1,
      ),
    );
  }

  Future<void> recordSignificantAction(ReviewMilestone milestone) async {
    final prefs = await _prefs();
    final state = _loadState(prefs);
    await _saveState(
      prefs,
      state.copyWith(significantActionCount: state.significantActionCount + 1),
    );
  }

  Future<bool> recordMilestoneAndMaybeRequest({
    required ReviewMilestone milestone,
    required int characterCount,
  }) async {
    await recordSignificantAction(milestone);
    return maybeRequestReview(characterCount: characterCount);
  }

  Future<bool> maybeRequestReview({required int characterCount}) async {
    final isAndroid = _isAndroid;
    final isReviewAvailable = isAndroid && await _safeIsAvailable();
    final currentVersion = isAndroid ? await _safeCurrentVersion() : null;
    final prefs = await _prefs();
    final state = _loadState(prefs);
    final now = _now();

    final canRequest = _policy.shouldRequest(
      state: state,
      now: now,
      isAndroid: isAndroid,
      isReviewAvailable: isReviewAvailable,
      characterCount: characterCount,
      currentVersion: currentVersion,
    );
    if (!canRequest) return false;

    await _saveState(
      prefs,
      state.copyWith(
        lastPromptAttemptAt: now,
        lastPromptedVersion: currentVersion,
        promptAttemptCount: state.promptAttemptCount + 1,
      ),
    );

    try {
      await _gateway.requestReview();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> openStoreListing() async {
    if (!_isAndroid) return false;
    try {
      await _gateway.openStoreListing();
      return true;
    } catch (_) {
      return false;
    }
  }

  bool get _isAndroid => isPlayStoreReviewSupported;

  Future<bool> _safeIsAvailable() async {
    try {
      return await _gateway.isAvailable();
    } catch (_) {
      return false;
    }
  }

  Future<String?> _safeCurrentVersion() async {
    try {
      final override = _currentVersion;
      if (override != null) return override();
      final info = await PackageInfo.fromPlatform();
      final build = info.buildNumber.trim();
      return build.isEmpty ? info.version : '${info.version}+$build';
    } catch (_) {
      return null;
    }
  }

  Future<SharedPreferences> _prefs() async {
    return _sharedPreferences ?? SharedPreferences.getInstance();
  }

  ReviewPromptState _loadState(SharedPreferences prefs) {
    return ReviewPromptState(
      firstSeenAt: _readDateTime(prefs, _firstSeenAtKey),
      lastPromptAttemptAt: _readDateTime(prefs, _lastPromptAttemptAtKey),
      lastPromptedVersion: prefs.getString(_lastPromptedVersionKey),
      appOpenCount: prefs.getInt(_appOpenCountKey) ?? 0,
      promptAttemptCount: prefs.getInt(_promptAttemptCountKey) ?? 0,
      significantActionCount: prefs.getInt(_significantActionCountKey) ?? 0,
    );
  }

  Future<void> _saveState(
    SharedPreferences prefs,
    ReviewPromptState state,
  ) async {
    await _writeDateTime(prefs, _firstSeenAtKey, state.firstSeenAt);
    await _writeDateTime(
      prefs,
      _lastPromptAttemptAtKey,
      state.lastPromptAttemptAt,
    );
    final lastPromptedVersion = state.lastPromptedVersion;
    if (lastPromptedVersion == null) {
      await prefs.remove(_lastPromptedVersionKey);
    } else {
      await prefs.setString(_lastPromptedVersionKey, lastPromptedVersion);
    }
    await prefs.setInt(_appOpenCountKey, state.appOpenCount);
    await prefs.setInt(_promptAttemptCountKey, state.promptAttemptCount);
    await prefs.setInt(
      _significantActionCountKey,
      state.significantActionCount,
    );
  }

  DateTime? _readDateTime(SharedPreferences prefs, String key) {
    final milliseconds = prefs.getInt(key);
    if (milliseconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  Future<void> _writeDateTime(
    SharedPreferences prefs,
    String key,
    DateTime? value,
  ) async {
    if (value == null) {
      await prefs.remove(key);
      return;
    }
    await prefs.setInt(key, value.millisecondsSinceEpoch);
  }
}
