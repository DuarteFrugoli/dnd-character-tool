import 'dart:async';

import 'package:dnd_character_tool/core/services/incoming_file_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/dnd-file-import');
  const codec = StandardMethodCodec();
  late IncomingFileService service;

  Future<void> send(
    Object? arguments, {
    String method = 'onFileReceived',
  }) async {
    final response = Completer<void>();
    await binding.defaultBinaryMessenger.handlePlatformMessage(
      channel.name,
      codec.encodeMethodCall(MethodCall(method, arguments)),
      (_) => response.complete(),
    );
    await response.future;
    await Future<void>.delayed(Duration.zero);
  }

  setUp(() {
    service = IncomingFileService(channel: channel)..initialize();
  });
  tearDown(() async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    await service.dispose();
  });

  test(
    'files arriving before the list subscribes are delivered once in order',
    () async {
      await send('character');
      await send('backup');
      final received = <String>[];
      final subscription = service.fileStream.listen(received.add);
      await Future<void>.delayed(Duration.zero);
      expect(received, ['character', 'backup']);
      await subscription.cancel();
    },
  );

  test(
    'files received while the list is absent survive its next subscription',
    () async {
      final first = service.fileStream.listen((_) {});
      await first.cancel();
      await send('backup');
      final received = <String>[];
      final second = service.fileStream.listen(received.add);
      await Future<void>.delayed(Duration.zero);
      expect(received, ['backup']);
      await second.cancel();
    },
  );

  test(
    'cold pending result and later native notification are each delivered once',
    () async {
      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        expect(call.method, 'getPendingFile');
        return 'cold character';
      });
      final received = <String>[];
      final subscription = service.fileStream.listen(received.add);
      await service.checkPendingFile();
      await send('later backup');
      expect(received, ['cold character', 'later backup']);
      await subscription.cancel();
    },
  );

  test('empty messages and unrelated calls are ignored', () async {
    final received = <String>[];
    final subscription = service.fileStream.listen(received.add);
    await send('');
    await send(42);
    await send('not a file', method: 'anotherMethod');
    expect(received, isEmpty);
    await subscription.cancel();
  });

  test(
    'missing native import channel is tolerated on other platforms',
    () async {
      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        _,
      ) async {
        throw MissingPluginException();
      });
      await service.checkPendingFile();
    },
  );
}
