import 'dart:convert';
import 'dart:io';

import 'package:dnd_character_tool/core/platform/picked_file_reader_io.dart';
import 'package:dnd_character_tool/core/utils/file_exporter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  const shareChannel = MethodChannel('dev.fluttercommunity.plus/share');
  const origin = Rect.fromLTWH(12, 34, 1, 1);
  late Directory temporary;
  late List<Map<dynamic, dynamic>> shares;
  String shareResult = 'test.activity';

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('dnd_export_test_');
    shares = [];
    shareResult = 'test.activity';
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      pathChannel,
      (_) async => temporary.path,
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(shareChannel, (
      call,
    ) async {
      expect(call.method, 'shareFiles');
      shares.add(call.arguments as Map<dynamic, dynamic>);
      return shareResult;
    });
  });
  tearDown(() async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(pathChannel, null);
    binding.defaultBinaryMessenger.setMockMethodCallHandler(shareChannel, null);
    await temporary.delete(recursive: true);
  });

  test(
    'character and backup exports preserve UTF-8 and embedded photo data',
    () async {
      final payload = jsonEncode({
        'character': {'name': 'Mágico'},
        'imageData': 'AQID',
      });
      final backup = jsonEncode({
        'type': 'dnd-character-tool-backup',
        'characters': [jsonDecode(payload)],
      });
      await exportDndCharFile('Mágico', payload, sharePositionOrigin: origin);
      await exportDndBackupFile(backup, sharePositionOrigin: origin);
      expect(shares, hasLength(2));
      for (final (index, expected, extension) in [
        (0, payload, '.dndchar'),
        (1, backup, '.dndbackup'),
      ]) {
        final share = shares[index];
        final path = (share['paths'] as List).single as String;
        expect(path, endsWith(extension));
        expect(await File(path).readAsString(), expected);
        expect(
          await readPickedFileAsString(
            PlatformFile(
              name: File(path).uri.pathSegments.last,
              size: await File(path).length(),
              path: path,
            ),
          ),
          expected,
        );
        expect(share['originX'], origin.left);
        expect(share['originY'], origin.top);
        expect(share['originWidth'], greaterThan(0));
        expect(share['originHeight'], greaterThan(0));
        expect(share['mimeTypes'], ['application/octet-stream']);
      }
    },
  );

  test(
    'sharing the same character twice does not overwrite an earlier file',
    () async {
      await exportDndCharFile('Hero', 'first', sharePositionOrigin: origin);
      await exportDndCharFile('Hero', 'second', sharePositionOrigin: origin);
      final first = (shares[0]['paths'] as List).single as String;
      final second = (shares[1]['paths'] as List).single as String;
      expect(first, isNot(second));
      expect(await File(first).readAsString(), 'first');
      expect(await File(second).readAsString(), 'second');
    },
  );

  test(
    'a dismissed share is cancellation rather than a completed backup',
    () async {
      shareResult = '';
      await expectLater(
        exportDndBackupFile('{}', sharePositionOrigin: origin),
        throwsA(isA<FileExportCancelled>()),
      );
    },
  );

  test('empty names still create a visible character file', () async {
    await exportDndCharFile('', '{}', sharePositionOrigin: origin);
    final path = (shares.single['paths'] as List).single as String;
    expect(File(path).uri.pathSegments.last, 'character.dndchar');
  });

  test(
    'native file picker accepts bytes when a provider has no usable path',
    () async {
      const payload = '{"character":{"name":"Mágico"}}';
      final picked = PlatformFile(
        name: 'hero.dndchar',
        size: payload.length,
        bytes: Uint8List.fromList(utf8.encode(payload)),
      );
      expect(await readPickedFileAsString(picked), payload);
    },
  );

  testWidgets('share anchor stays inside the visible iPad viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    late BuildContext source;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Builder(
              builder: (context) {
                source = context;
                return const SizedBox(height: 2000, width: 800);
              },
            ),
          ),
        ),
      ),
    );
    final anchor = fileShareOrigin(source);
    expect(anchor.isEmpty, isFalse);
    expect(
      (Offset.zero & const Size(1024, 768)).contains(anchor.center),
      isTrue,
    );
  });
}
