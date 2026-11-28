import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/sync/character_sync_payload.dart';
import 'package:dnd_character_tool/data/sync/character_sync_state.dart';
import 'package:dnd_character_tool/data/sync/character_sync_status.dart';
import 'package:dnd_character_tool/data/sync/remote_character.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Character _hero({String name = 'Hero'}) => Character(
  id: '0b8f0f1e-6a5e-4c32-9a51-3f3c2b7a1d10',
  name: name,
  race: 'Human',
  characterClass: 'Fighter',
  abilityScores: const AbilityScores(strength: 16),
  hitPoints: const HitPoints(maximum: 12, current: 12),
  imagePath: '/data/user/0/app/images/hero.jpg',
  isPinned: true,
  sortOrder: 3,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 2),
);

RemoteCharacterSummary _remote({int revision = 4, bool deleted = false, int dataVersion = 11}) =>
    RemoteCharacterSummary.fromRow({
      'id': _hero().id,
      'revision': revision,
      'name': 'Hero',
      'ruleset_id': 'dnd_2014',
      'data_version': dataVersion,
      'image_hash': null,
      'deleted_at': deleted ? '2026-02-01T10:00:00Z' : null,
      'updated_at': '2026-02-01T10:00:00Z',
    });

void main() {
  group('CharacterSyncPayload', () {
    test('device-only fields stay on the device', () {
      final json = CharacterSyncPayload.toCloudJson(_hero());
      expect(json.keys, isNot(contains('imagePath')));
      expect(json.keys, isNot(contains('isPinned')));
      expect(json.keys, isNot(contains('sortOrder')));
      expect(json['name'], 'Hero');
      expect(json['rulesetId'], 'dnd_2014');
    });

    test('a download keeps this device photo, pin and order', () {
      final local = _hero();
      final cloud = CharacterSyncPayload.toCloudJson(_hero(name: 'Renamed'));
      final restored = CharacterSyncPayload.fromCloudJson(cloud, local: local);
      expect(restored.name, 'Renamed');
      expect(restored.imagePath, local.imagePath);
      expect(restored.isPinned, isTrue);
      expect(restored.sortOrder, 3);

      final fresh = CharacterSyncPayload.fromCloudJson(cloud);
      expect(fresh.imagePath, isNull);
      expect(fresh.isPinned, isFalse);
      expect(fresh.sortOrder, 0);
    });

    test('the hash changes with content only', () {
      final hero = _hero();
      final hash = CharacterSyncPayload.contentHash(hero);
      expect(hash, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(
        CharacterSyncPayload.contentHash(hero.copyWith(
          updatedAt: DateTime.utc(2027),
          isPinned: false,
          sortOrder: 9,
          clearImagePath: true,
        )),
        hash,
      );
      expect(CharacterSyncPayload.contentHash(hero.copyWith(name: 'Other')), isNot(hash));
      // Map key order does not matter.
      final reordered = Character.fromJson(
        Map.fromEntries(hero.toJson().entries.toList().reversed),
      );
      expect(CharacterSyncPayload.contentHash(reordered), hash);
    });
  });

  group('CharacterSyncStatusRules', () {
    final hash = CharacterSyncPayload.contentHash(_hero());
    final synced = CharacterSyncState(baseRevision: 4, baseHash: hash);

    CharacterSyncStatus status({
      String? localHash,
      CharacterSyncState state = const CharacterSyncState(),
      RemoteCharacterSummary? remote,
    }) => CharacterSyncStatusRules.compute(
      localHash: localHash,
      state: state,
      remote: remote,
      appDataVersion: 11,
    );

    test('covers the states of the sync specification', () {
      expect(status(localHash: hash, state: synced, remote: _remote()), CharacterSyncStatus.inSync);
      expect(status(localHash: 'changed', state: synced, remote: _remote()), CharacterSyncStatus.localAhead);
      expect(status(localHash: hash, state: synced, remote: _remote(revision: 5)), CharacterSyncStatus.cloudAhead);
      expect(status(localHash: 'changed', state: synced, remote: _remote(revision: 5)), CharacterSyncStatus.diverged);
      expect(status(remote: _remote()), CharacterSyncStatus.cloudOnly);
      expect(status(localHash: hash), CharacterSyncStatus.localOnly);
      expect(status(localHash: hash, state: synced, remote: _remote(deleted: true)), CharacterSyncStatus.deletedInCloud);
      expect(
        status(localHash: hash, state: synced.copyWith(excluded: true), remote: _remote()),
        CharacterSyncStatus.excluded,
      );
    });

    test('a never-synced copy with a cloud row has diverged', () {
      // Same id in the cloud but no local record of it, e.g. after signing
      // out and back in: the player decides instead of an overwrite.
      expect(status(localHash: hash, remote: _remote()), CharacterSyncStatus.diverged);
    });

    test('a newer cloud schema waits for an app update', () {
      expect(status(remote: _remote(dataVersion: 12)), CharacterSyncStatus.needsAppUpdate);
      expect(
        status(localHash: hash, state: synced, remote: _remote(revision: 5, dataVersion: 12)),
        CharacterSyncStatus.needsAppUpdate,
      );
      // Unchanged in the cloud: nothing to download, so no update needed.
      expect(
        status(localHash: hash, state: synced, remote: _remote(dataVersion: 12)),
        CharacterSyncStatus.inSync,
      );
    });

    test('a character must exist somewhere', () {
      expect(() => status(), throwsArgumentError);
      expect(() => status(remote: _remote(deleted: true)), throwsArgumentError);
    });
  });

  group('SyncWriteResult', () {
    test('parses the RPC responses', () {
      expect((SyncWriteResult.fromJson({'status': 'pushed', 'revision': 2}) as SyncPushed).revision, 2);
      expect((SyncWriteResult.fromJson({'status': 'conflict', 'revision': 7}) as SyncConflict).revision, 7);
      expect(SyncWriteResult.fromJson({'status': 'no_entitlement'}), isA<SyncNoEntitlement>());
      expect(() => SyncWriteResult.fromJson({'status': 'other'}), throwsFormatException);
    });
  });

  group('CharacterSyncStateStore', () {
    test('saves, reads, removes and clears state per character', () async {
      SharedPreferences.setMockInitialValues({});
      final store = CharacterSyncStateStore(await SharedPreferences.getInstance());
      expect(store.read('a'), const CharacterSyncState());

      await store.write('a', const CharacterSyncState(baseRevision: 3, baseHash: 'h'));
      await store.write('b', const CharacterSyncState(excluded: true));
      expect(store.read('a'), const CharacterSyncState(baseRevision: 3, baseHash: 'h'));
      expect(store.readAll().keys, unorderedEquals(['a', 'b']));

      await store.remove('a');
      expect(store.read('a').isSynced, isFalse);
      await store.clear();
      expect(store.readAll(), isEmpty);
    });

    test('a corrupted value is treated as no state', () async {
      SharedPreferences.setMockInitialValues({CharacterSyncStateStore.storageKey: 'not json'});
      final store = CharacterSyncStateStore(await SharedPreferences.getInstance());
      expect(store.readAll(), isEmpty);
    });
  });
}
