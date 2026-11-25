import 'package:dnd_character_tool/core/whats_new/whats_new_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'users who read 3.0.0 see 3.0.1 once, with the installed version',
    () async {
      SharedPreferences.setMockInitialValues({
        'whats_new_last_seen_announcement': '3.0.0-whats-new',
      });
      final service = WhatsNewService(
        sharedPreferences: await SharedPreferences.getInstance(),
        packageInfo: () async => PackageInfo(
          appName: 'D&D Character Tool',
          packageName: 'test',
          version: '3.0.1',
          buildNumber: '36',
        ),
      );
      final pending = await service.pendingInfo();
      expect(pending!.id, '3.0.1-whats-new');
      expect(pending.version, '3.0.1');
      await service.markSeen(pending.id);
      expect(await service.pendingInfo(), isNull);
      expect((await service.currentInfo()).id, pending.id);
    },
  );
}
