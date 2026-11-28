import 'remote_character.dart';

/// Cloud side of character sync. The Supabase implementation comes with the
/// project credentials; tests and the disabled build use fakes.
abstract interface class CharacterSyncRemote {
  /// Summaries of every character of the signed-in account, tombstones
  /// included, so each device learns about deletes.
  Future<List<RemoteCharacterSummary>> listCharacters();

  /// Full cloud JSON of one character, or null when it is a tombstone.
  Future<Map<String, dynamic>?> fetchCharacter(String id);

  /// Calls push_character. [baseRevision] is null for a first upload.
  Future<SyncWriteResult> pushCharacter({
    required String id,
    required int? baseRevision,
    required Map<String, dynamic> data,
    required int dataVersion,
    required String rulesetId,
    required String name,
    required String? imageHash,
    required String deviceId,
    bool force = false,
  });

  /// Calls delete_character.
  Future<SyncWriteResult> deleteCharacter({
    required String id,
    required int? baseRevision,
    required String deviceId,
    bool force = false,
  });

  /// Uploads a photo to `{user}/{characterId}/{imageHash}.jpg`.
  Future<void> uploadImage({
    required String characterId,
    required String imageHash,
    required List<int> bytes,
    required String contentType,
  });

  /// Downloads the photo stored under [imageHash].
  Future<List<int>> downloadImage({
    required String characterId,
    required String imageHash,
  });

  /// Removes the character's photos except [keepHash].
  Future<void> removeImages({required String characterId, String? keepHash});
}
