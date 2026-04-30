import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'storage_backend_stub.dart';

StorageBackend createStorageBackend() => WebStorageBackend();

/// Backend de storage para a web usando shared_preferences (localStorage).
/// Imagens não são suportadas nesta plataforma (retorna null).
class WebStorageBackend implements StorageBackend {
  static const _prefix = 'dnd_char_';
  static const _idsKey = 'dnd_char_ids';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ---- Personagens ----

  @override
  Future<List<Map<String, dynamic>>> loadAllCharacters() async {
    final prefs = await _prefs;
    final ids = _getIds(prefs);
    final result = <Map<String, dynamic>>[];
    for (final id in ids) {
      final str = prefs.getString('$_prefix$id');
      if (str != null) {
        try {
          result.add(jsonDecode(str) as Map<String, dynamic>);
        } catch (_) {
          // entrada corrompida — ignora
        }
      }
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>?> loadCharacter(String id) async {
    final prefs = await _prefs;
    final str = prefs.getString('$_prefix$id');
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveCharacter(String id, Map<String, dynamic> json) async {
    final prefs = await _prefs;
    await prefs.setString('$_prefix$id', jsonEncode(json));
    final ids = _getIds(prefs);
    if (!ids.contains(id)) {
      ids.add(id);
      await prefs.setString(_idsKey, jsonEncode(ids));
    }
  }

  @override
  Future<void> deleteCharacter(String id) async {
    final prefs = await _prefs;
    await prefs.remove('$_prefix$id');
    final ids = _getIds(prefs)..remove(id);
    await prefs.setString(_idsKey, jsonEncode(ids));
  }

  @override
  Future<bool> characterExists(String id) async {
    final prefs = await _prefs;
    return prefs.containsKey('$_prefix$id');
  }

  // ---- Imagens (não suportado na web por ora) ----

  @override
  Future<String?> saveImage(String characterId, String sourcePath) async =>
      null;

  @override
  Future<String?> resolveImagePath(String? fileName) async => null;

  @override
  Future<void> deleteImage(String? fileName) async {}

  // ---- Helpers ----

  List<String> _getIds(SharedPreferences prefs) {
    final str = prefs.getString(_idsKey);
    if (str == null) return [];
    try {
      return (jsonDecode(str) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }
}
