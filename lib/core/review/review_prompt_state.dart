class ReviewPromptState {
  const ReviewPromptState({
    this.firstSeenAt,
    this.lastPromptAttemptAt,
    this.lastPromptedVersion,
    this.appOpenCount = 0,
    this.promptAttemptCount = 0,
    this.significantActionCount = 0,
  });

  final DateTime? firstSeenAt;
  final DateTime? lastPromptAttemptAt;
  final String? lastPromptedVersion;
  final int appOpenCount;
  final int promptAttemptCount;
  final int significantActionCount;

  ReviewPromptState copyWith({
    DateTime? firstSeenAt,
    DateTime? lastPromptAttemptAt,
    Object? lastPromptedVersion = _keep,
    int? appOpenCount,
    int? promptAttemptCount,
    int? significantActionCount,
  }) {
    return ReviewPromptState(
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastPromptAttemptAt: lastPromptAttemptAt ?? this.lastPromptAttemptAt,
      lastPromptedVersion: lastPromptedVersion == _keep
          ? this.lastPromptedVersion
          : lastPromptedVersion as String?,
      appOpenCount: appOpenCount ?? this.appOpenCount,
      promptAttemptCount: promptAttemptCount ?? this.promptAttemptCount,
      significantActionCount:
          significantActionCount ?? this.significantActionCount,
    );
  }

  static const _keep = Object();
}
