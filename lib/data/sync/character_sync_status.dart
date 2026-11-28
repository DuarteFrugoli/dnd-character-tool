import 'character_sync_state.dart';
import 'remote_character.dart';

/// Where a character stands between this device and the cloud
/// (docs/SYNC_SPEC.md, "Estados por personagem").
enum CharacterSyncStatus {
  /// Same content and revision on both sides.
  inSync,

  /// Changed on this device since the last sync; uploaded automatically.
  localAhead,

  /// Another device uploaded a newer copy; downloaded only when asked.
  cloudAhead,

  /// Changed here and in the cloud; the player chooses what to keep.
  diverged,

  /// Only in the cloud (new on another device or removed from this one).
  cloudOnly,

  /// Only on this device and never uploaded.
  localOnly,

  /// Deleted on another device while this copy still exists.
  deletedInCloud,

  /// The player keeps this character out of the cloud.
  excluded,

  /// The cloud copy needs a newer app version to open.
  needsAppUpdate,
}

class CharacterSyncStatusRules {
  const CharacterSyncStatusRules._();

  /// Status of one character. [localHash] is the current content hash of the
  /// copy on this device (null when it is not on this device).
  static CharacterSyncStatus compute({
    required String? localHash,
    required CharacterSyncState state,
    required RemoteCharacterSummary? remote,
    required int appDataVersion,
  }) {
    if (localHash == null) {
      if (remote == null || remote.isDeleted) {
        throw ArgumentError('A character must exist on one side.');
      }
      return remote.dataVersion > appDataVersion
          ? CharacterSyncStatus.needsAppUpdate
          : CharacterSyncStatus.cloudOnly;
    }
    if (state.excluded) return CharacterSyncStatus.excluded;
    if (remote == null) {
      // Never uploaded, or the cloud copy was purged after the grace period.
      return CharacterSyncStatus.localOnly;
    }
    if (remote.isDeleted) return CharacterSyncStatus.deletedInCloud;

    final changedHere = !state.isSynced || localHash != state.baseHash;
    final changedThere = state.baseRevision != remote.revision;
    if (changedThere && remote.dataVersion > appDataVersion) {
      return CharacterSyncStatus.needsAppUpdate;
    }
    return switch ((changedHere, changedThere)) {
      (false, false) => CharacterSyncStatus.inSync,
      (true, false) => CharacterSyncStatus.localAhead,
      (false, true) => CharacterSyncStatus.cloudAhead,
      (true, true) => CharacterSyncStatus.diverged,
    };
  }

  /// Statuses whose changes the app uploads without asking.
  static const uploadsAutomatically = {
    CharacterSyncStatus.localAhead,
    CharacterSyncStatus.localOnly,
  };
}
