import 'dart:convert';
import 'dart:io';

import 'package:dnd_character_tool/data/datasources/local/local_backup_storage_native.dart';
import 'package:dnd_character_tool/data/models/local_backup.dart';
import 'package:dnd_character_tool/data/repositories/local_backup_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/memory_local_backup_storage.dart';

String payload(int version) => jsonEncode({
  'type': 'dnd-character-tool-backup',
  'characters': [
    {
      'character': {'name': 'Hero $version', 'dataVersion': version},
      'imageData': 'AQID',
    },
  ],
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'retains exactly the latest three complete snapshots across concurrent writes',
    () async {
      final storage = MemoryLocalBackupStorage();
      var tick = 0;
      final repository = LocalBackupRepository(
        storage: storage,
        now: () => DateTime.utc(2026, 11, 25, 0, 0, tick++),
      );
      final infos = await Future.wait([
        for (var i = 1; i <= 5; i++) repository.save(payload(i)),
      ]);
      expect(
        (await repository.list()).map((b) => b.id),
        infos.reversed.take(3).map((b) => b.id),
      );
      expect(storage.payloads, hasLength(3));
      expect(await repository.read(infos.last.id), payload(5));
      expect(
        (await repository.list()).every((b) => b.characterCount == 1),
        isTrue,
      );
    },
  );

  test(
    'failed new snapshot preserves all previous copies and does not poison later saves',
    () async {
      final storage = MemoryLocalBackupStorage();
      final repository = LocalBackupRepository(storage: storage);
      for (var i = 1; i <= 3; i++) {
        await repository.save(payload(i));
      }
      final previous = {...storage.payloads};
      storage.failWrites = true;
      await expectLater(repository.save(payload(4)), throwsStateError);
      expect(storage.payloads, previous);
      storage.failWrites = false;
      await repository.save(payload(5));
      expect(storage.payloads, hasLength(3));
      expect(storage.payloads.values, contains(payload(5)));
    },
  );

  test(
    'invalid backup payload cannot replace a valid recovery point',
    () async {
      final storage = MemoryLocalBackupStorage();
      final repository = LocalBackupRepository(storage: storage);
      await repository.save(payload(1));
      await expectLater(
        repository.save('{"characters":[]}'),
        throwsFormatException,
      );
      await expectLater(
        repository.save(
          '{"type":"dnd-character-tool-backup","characters":[{}]}',
        ),
        throwsFormatException,
      );
      expect(storage.payloads.values, [payload(1)]);
    },
  );

  test(
    'a backwards device clock cannot prune the just-created recovery point',
    () async {
      final storage = MemoryLocalBackupStorage();
      var clock = DateTime.utc(2026, 11, 25);
      final repository = LocalBackupRepository(
        storage: storage,
        now: () => clock,
      );
      for (var i = 1; i <= 3; i++) {
        await repository.save(payload(i));
        clock = clock.add(const Duration(days: 1));
      }
      clock = DateTime.utc(2020);
      final newest = await repository.save(payload(4));
      expect(await repository.read(newest.id), payload(4));
      expect(storage.payloads, hasLength(3));
      expect(
        await Future.wait(
          (await repository.list()).map((b) => repository.read(b.id)),
        ),
        [payload(4), payload(3), payload(2)],
      );
    },
  );

  group('native local backup storage', () {
    late Directory directory;
    setUp(() async {
      directory = await Directory.systemTemp.createTemp(
        'dnd_local_backup_test_',
      );
    });
    tearDown(() async {
      expect(
        directory.parent.absolute.path,
        Directory.systemTemp.absolute.path,
      );
      await directory.delete(recursive: true);
    });

    test(
      'metadata and full photo payload persist across repository instances',
      () async {
        final repository = LocalBackupRepository(
          storage: NativeLocalBackupStorage(directory: directory),
        );
        final info = await repository.save(payload(9));
        final reopened = LocalBackupRepository(
          storage: NativeLocalBackupStorage(directory: directory),
        );
        final listed = await reopened.list();
        expect(listed.single.id, info.id);
        expect(listed.single.createdAt, info.createdAt);
        expect(listed.single.characterCount, 1);
        expect(await reopened.read(info.id), payload(9));
        expect(
          (await directory.list().toList()).whereType<File>().map(
            (f) => f.path,
          ),
          everyElement(isNot(endsWith('.tmp'))),
        );
      },
    );

    test(
      'pruning deletes only older backups, retaining three readable payloads',
      () async {
        var tick = 0;
        final repository = LocalBackupRepository(
          storage: NativeLocalBackupStorage(directory: directory),
          now: () => DateTime.utc(2026, 11, 25, 0, 0, tick++),
        );
        for (var i = 1; i <= 4; i++) {
          await repository.save(payload(i));
        }
        final backups = await repository.list();
        expect(backups, hasLength(3));
        expect(await Future.wait(backups.map((b) => repository.read(b.id))), [
          payload(4),
          payload(3),
          payload(2),
        ]);
        expect(await directory.list().length, 6);
      },
    );

    test(
      'an incomplete publication is hidden without losing the previous backup',
      () async {
        final storage = NativeLocalBackupStorage(directory: directory);
        final old = LocalBackupInfo(
          id: 'old',
          createdAt: DateTime.utc(2026),
          characterCount: 1,
        );
        await storage.write(old, payload(1));
        await Directory('${directory.path}/new.meta.json.tmp').create();
        final fresh = LocalBackupInfo(
          id: 'new',
          createdAt: DateTime.utc(2026, 2),
          characterCount: 1,
        );
        await expectLater(
          storage.write(fresh, payload(2)),
          throwsA(isA<FileSystemException>()),
        );
        expect((await storage.list()).map((b) => b.id), ['old']);
        expect(await storage.read('old'), payload(1));
        expect(await File('${directory.path}/new.dndbackup').exists(), isFalse);
      },
    );

    test(
      'invalid IDs cannot read or delete files outside the backup directory',
      () async {
        final storage = NativeLocalBackupStorage(directory: directory);
        await expectLater(
          storage.read('../../character'),
          throwsFormatException,
        );
        await expectLater(
          storage.delete('../character'),
          throwsFormatException,
        );
      },
    );
  });
}
