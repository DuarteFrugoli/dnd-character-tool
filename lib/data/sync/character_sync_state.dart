import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// What this device knows about a character's cloud copy. Kept outside the
/// character JSON so it never travels in `.dndchar` files or backups.
class CharacterSyncState {
  const CharacterSyncState({
    this.baseRevision,
    this.baseHash,
    this.excluded = false,
  });

  /// Cloud revision this copy was last uploaded as or downloaded from; null
  /// when it was never synced.
  final int? baseRevision;

  /// Content hash at that moment (see CharacterSyncPayload.contentHash).
  final String? baseHash;

  /// The player removed this character from the cloud.
  final bool excluded;

  bool get isSynced => baseRevision != null && baseHash != null;

  CharacterSyncState copyWith({
    int? baseRevision,
    String? baseHash,
    bool? excluded,
  }) => CharacterSyncState(
    baseRevision: baseRevision ?? this.baseRevision,
    baseHash: baseHash ?? this.baseHash,
    excluded: excluded ?? this.excluded,
  );

  factory CharacterSyncState.fromJson(Map<String, dynamic> json) =>
      CharacterSyncState(
        baseRevision: (json['baseRevision'] as num?)?.toInt(),
        baseHash: json['baseHash'] as String?,
        excluded: json['excluded'] == true,
      );

  Map<String, dynamic> toJson() => {
    if (baseRevision != null) 'baseRevision': baseRevision,
    if (baseHash != null) 'baseHash': baseHash,
    if (excluded) 'excluded': true,
  };

  @override
  bool operator ==(Object other) =>
      other is CharacterSyncState &&
      other.baseRevision == baseRevision &&
      other.baseHash == baseHash &&
      other.excluded == excluded;

  @override
  int get hashCode => Object.hash(baseRevision, baseHash, excluded);
}

/// Sync state of every character on this device, in SharedPreferences
/// (available on Android, iOS and web).
class CharacterSyncStateStore {
  CharacterSyncStateStore(this._prefs);

  static const storageKey = 'character_sync_state_v1';

  final SharedPreferences _prefs;

  Map<String, CharacterSyncState> readAll() {
    final raw = _prefs.getString(storageKey);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final entry in decoded.entries)
          if (entry.value is Map<String, dynamic>)
            entry.key: CharacterSyncState.fromJson(entry.value as Map<String, dynamic>),
      };
    } on FormatException {
      return {};
    } on TypeError {
      return {};
    }
  }

  CharacterSyncState read(String characterId) =>
      readAll()[characterId] ?? const CharacterSyncState();

  Future<void> write(String characterId, CharacterSyncState state) async {
    final all = readAll()..[characterId] = state;
    await _save(all);
  }

  Future<void> remove(String characterId) async {
    final all = readAll()..remove(characterId);
    await _save(all);
  }

  /// Forgets every character, e.g. when the player signs out.
  Future<void> clear() => _prefs.remove(storageKey);

  Future<void> _save(Map<String, CharacterSyncState> all) => _prefs.setString(
    storageKey,
    jsonEncode({for (final entry in all.entries) entry.key: entry.value.toJson()}),
  );
}
