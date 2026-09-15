import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final whatsNewServiceProvider = Provider<WhatsNewService>(
  (ref) => WhatsNewService(),
);

class WhatsNewInfo {
  const WhatsNewInfo({required this.id, required this.version});

  final String id;
  final String version;
}

class WhatsNewService {
  WhatsNewService({
    SharedPreferences? sharedPreferences,
    Future<PackageInfo> Function()? packageInfo,
  }) : _sharedPreferences = sharedPreferences,
       _packageInfo = packageInfo ?? PackageInfo.fromPlatform;

  final SharedPreferences? _sharedPreferences;
  final Future<PackageInfo> Function() _packageInfo;

  static const currentAnnouncementId = '2.1.1-whats-new';
  static const _lastSeenAnnouncementKey = 'whats_new_last_seen_announcement';

  Future<WhatsNewInfo?> pendingInfo() async {
    final prefs = await _prefs();
    if (prefs.getString(_lastSeenAnnouncementKey) == currentAnnouncementId) {
      return null;
    }

    final info = await _packageInfo();
    final version = info.version.trim();
    return WhatsNewInfo(
      id: currentAnnouncementId,
      version: version.isEmpty ? info.buildNumber : version,
    );
  }

  Future<void> markSeen(String announcementId) async {
    final prefs = await _prefs();
    await prefs.setString(_lastSeenAnnouncementKey, announcementId);
  }

  Future<SharedPreferences> _prefs() {
    return _sharedPreferences == null
        ? SharedPreferences.getInstance()
        : Future.value(_sharedPreferences);
  }
}
