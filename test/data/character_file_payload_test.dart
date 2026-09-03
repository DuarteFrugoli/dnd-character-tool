import 'dart:convert';

import 'package:dnd_character_tool/data/character_file_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('looksLikeDndBackupFileJson', () {
    test('detects backup payloads by their characters list', () {
      final payload = jsonEncode({
        'type': 'dnd-character-tool-backup',
        'characters': [
          {'character': <String, dynamic>{}},
        ],
      });

      expect(looksLikeDndBackupFileJson(payload), isTrue);
    });

    test('does not treat single-character files as backups', () {
      final payload = jsonEncode({
        'version': '1.0',
        'character': <String, dynamic>{},
      });

      expect(looksLikeDndBackupFileJson(payload), isFalse);
    });

    test('returns false for invalid JSON and non-object payloads', () {
      expect(looksLikeDndBackupFileJson('not json'), isFalse);
      expect(looksLikeDndBackupFileJson(jsonEncode([])), isFalse);
    });
  });
}
