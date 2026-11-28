/// A row of `public.characters` without its JSON, enough to compute the
/// sync status of every character without downloading them.
class RemoteCharacterSummary {
  const RemoteCharacterSummary({
    required this.id,
    required this.revision,
    required this.name,
    required this.rulesetId,
    required this.dataVersion,
    required this.updatedAt,
    this.imageHash,
    this.deletedAt,
  });

  /// Columns to select for a summary.
  static const columns =
      'id, revision, name, ruleset_id, data_version, image_hash, deleted_at, updated_at';

  final String id;
  final int revision;
  final String name;
  final String rulesetId;
  final int dataVersion;
  final String? imageHash;
  final DateTime? deletedAt;
  final DateTime updatedAt;

  bool get isDeleted => deletedAt != null;

  factory RemoteCharacterSummary.fromRow(Map<String, dynamic> row) =>
      RemoteCharacterSummary(
        id: row['id'] as String,
        revision: (row['revision'] as num).toInt(),
        name: row['name'] as String,
        rulesetId: row['ruleset_id'] as String,
        dataVersion: (row['data_version'] as num).toInt(),
        imageHash: row['image_hash'] as String?,
        deletedAt: row['deleted_at'] == null
            ? null
            : DateTime.parse(row['deleted_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
      );
}

/// Result of push_character / delete_character.
sealed class SyncWriteResult {
  const SyncWriteResult();

  factory SyncWriteResult.fromJson(Map<String, dynamic> json) {
    final revision = (json['revision'] as num?)?.toInt();
    return switch (json['status']) {
      'pushed' => SyncPushed(revision),
      'conflict' => SyncConflict(revision!),
      'no_entitlement' => const SyncNoEntitlement(),
      final status => throw FormatException('Unknown sync status $status.'),
    };
  }
}

/// The cloud now holds this device's copy at [revision] (null when a delete
/// found nothing to delete).
class SyncPushed extends SyncWriteResult {
  const SyncPushed(this.revision);
  final int? revision;
}

/// Another device changed the character; the cloud is at [revision].
class SyncConflict extends SyncWriteResult {
  const SyncConflict(this.revision);
  final int revision;
}

/// The account has no active Sync subscription.
class SyncNoEntitlement extends SyncWriteResult {
  const SyncNoEntitlement();
}
