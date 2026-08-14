import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class KeepScreenOn {
  static const _channel = MethodChannel('dnd.character/screen');

  static Future<void> setEnabled(bool enabled) async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod<void>('setKeepScreenOn', {
        'enabled': enabled,
      });
    } on MissingPluginException {
      // Unsupported desktop/iOS builds can ignore this Android-only helper.
    }
  }
}
