import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/character.dart';

/// What a character looks like in the cloud (docs/SYNC_SPEC.md).
///
/// Device-only fields never leave the device: the local image path and the
/// list organization (pin and manual order) of this device. The photo is
/// synced separately by its hash.
class CharacterSyncPayload {
  const CharacterSyncPayload._();

  /// Fields that belong to this device and are never uploaded.
  static const deviceOnlyFields = {'imagePath', 'isPinned', 'sortOrder'};

  /// Fields uploaded but ignored when deciding whether the sheet changed,
  /// because saving can touch them without changing the character.
  static const hashIgnoredFields = {'updatedAt'};

  /// The JSON uploaded for [character].
  static Map<String, dynamic> toCloudJson(Character character) => {
    for (final entry in character.toJson().entries)
      if (!deviceOnlyFields.contains(entry.key)) entry.key: entry.value,
  };

  /// Builds the character from a downloaded payload, keeping what belongs
  /// to this device from [local] (the copy it replaces, if any).
  static Character fromCloudJson(
    Map<String, dynamic> data, {
    Character? local,
  }) {
    final character = Character.fromJson({
      ...data,
      'imagePath': null,
      'isPinned': local?.isPinned ?? false,
      'sortOrder': local?.sortOrder ?? 0,
    });
    return local?.imagePath == null
        ? character
        : character.copyWith(imagePath: local!.imagePath);
  }

  /// SHA-256 of the canonical cloud JSON without [hashIgnoredFields]. Equal
  /// hashes mean the character has not changed since it was last synced.
  static String contentHash(Character character) {
    final json = toCloudJson(character)
      ..removeWhere((key, _) => hashIgnoredFields.contains(key));
    return sha256.convert(utf8.encode(jsonEncode(_canonical(json)))).toString();
  }

  /// SHA-256 of image bytes, used in the storage path and `image_hash`.
  static String imageHash(List<int> bytes) => sha256.convert(bytes).toString();

  /// Sorts map keys recursively so equal data always encodes the same way.
  static Object? _canonical(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      return {for (final key in keys) key: _canonical(value[key])};
    }
    if (value is List) return [for (final item in value) _canonical(item)];
    return value;
  }
}
