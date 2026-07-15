import 'dart:async';

import 'package:flutter/services.dart';

/// Singleton service that listens for `.dndchar` and `.dndbackup` files opened from other apps
/// via Android Intent / iOS URL handling.
///
/// - [initialize] must be called once (in main.dart) before using.
/// - [checkPendingFile] should be called after the UI is ready to handle an
///   import that arrived during a cold start (Android only).
/// - [fileStream] emits the raw JSON string of any received file.
class IncomingFileService {
  static const _channel = MethodChannel('dnd.character/file_import');
  static final IncomingFileService instance = IncomingFileService._();
  IncomingFileService._();

  final _controller = StreamController<String>.broadcast();

  Stream<String> get fileStream => _controller.stream;

  void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onFileReceived' && call.arguments is String) {
        _controller.add(call.arguments as String);
      }
    });
  }

  /// Checks for a file that was received before Flutter was fully ready
  /// (Android cold-start scenario). Emits it on [fileStream] if present.
  Future<void> checkPendingFile() async {
    try {
      final content = await _channel.invokeMethod<String>('getPendingFile');
      if (content != null && content.isNotEmpty) {
        _controller.add(content);
      }
    } catch (_) {
      // Not on Android or channel not set up — ignore.
    }
  }
}
