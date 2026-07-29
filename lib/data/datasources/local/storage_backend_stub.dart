/// Storage interface plus fallback factory for unsupported platforms.
///
/// The real backend is selected at compile time through conditional imports.
abstract class StorageBackend {
  // ---- Characters ----
  Future<List<Map<String, dynamic>>> loadAllCharacters();
  Future<Map<String, dynamic>?> loadCharacter(String id);

  Future<StorageCharacterScan> scanCharacters() async {
    final records = <StoredCharacterJson>[];
    for (final json in await loadAllCharacters()) {
      final id = json['id'];
      records.add(
        StoredCharacterJson(
          source: id is String && id.isNotEmpty ? id : 'unknown',
          id: id is String && id.isNotEmpty ? id : null,
          json: json,
        ),
      );
    }
    return StorageCharacterScan(records: records);
  }

  Future<StoredCharacterJson?> loadCharacterRecord(String id) async {
    final json = await loadCharacter(id);
    if (json == null) return null;
    return StoredCharacterJson(source: id, id: id, json: json);
  }

  Future<void> saveCharacter(String id, Map<String, dynamic> json);
  Future<void> deleteCharacter(String id);
  Future<bool> characterExists(String id);

  // ---- Images ----
  /// Persists the image and returns the saved file name, or null if unsupported.
  Future<String?> saveImage(String characterId, String sourcePath);

  /// Resolves a stored file name to an absolute path, or null if unavailable.
  Future<String?> resolveImagePath(String? fileName);

  Future<void> deleteImage(String? fileName);
}

class StoredCharacterJson {
  const StoredCharacterJson({
    required this.source,
    required this.json,
    this.id,
  });

  final String source;
  final String? id;
  final Map<String, dynamic> json;
}

class StorageReadIssue {
  const StorageReadIssue({
    required this.source,
    required this.message,
    this.id,
  });

  final String source;
  final String? id;
  final String message;
}

class StorageReadException implements Exception {
  const StorageReadException(this.issue);

  final StorageReadIssue issue;

  @override
  String toString() =>
      'StorageReadException(${issue.message}, ${issue.source})';
}

class StorageCharacterScan {
  const StorageCharacterScan({this.records = const [], this.issues = const []});

  final List<StoredCharacterJson> records;
  final List<StorageReadIssue> issues;
}

StorageBackend createStorageBackend() =>
    throw UnsupportedError('Unsupported storage platform.');
