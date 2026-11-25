import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';

/// Singleton service that listens for `.dndchar` and `.dndbackup` files opened from other apps
/// via Android Intent / iOS URL handling.
///
/// - [initialize] must be called once (in main.dart) before using.
/// - [checkPendingFile] should be called after the UI is ready to handle an
///   import that arrived during a cold start (Android and iOS).
/// - [fileStream] emits the raw JSON string of any received file.
class IncomingFileService {
  static final IncomingFileService instance = IncomingFileService();
  IncomingFileService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('dnd.character/file_import') {
    _controller = StreamController<String>.broadcast(
      onListen: () => scheduleMicrotask(_flushPending),
    );
  }

  final MethodChannel _channel;
  late final StreamController<String> _controller;
  final _pending = Queue<String>();
  bool _initialized = false;

  Stream<String> get fileStream => _controller.stream;

  void initialize() {
    if (_initialized) return;
    _initialized = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onFileReceived' && call.arguments is String) {
        _receive(call.arguments as String);
      }
    });
  }

  /// Checks for a file that was received before Flutter was fully ready
  /// (Android/iOS cold start). Emits it on [fileStream] if present.
  Future<void> checkPendingFile() async {
    try {
      final content = await _channel.invokeMethod<String>('getPendingFile');
      if (content != null && content.isNotEmpty) {
        _receive(content);
      }
    } catch (_) {
      // Unsupported platform or channel not set up — ignore.
    }
  }

  void _receive(String content) {
    if (content.isEmpty || _controller.isClosed) return;
    _pending.addLast(content);
    _flushPending();
  }

  void _flushPending() {
    while (_controller.hasListener && _pending.isNotEmpty) {
      _controller.add(_pending.removeFirst());
    }
  }

  Future<void> dispose() async {
    _channel.setMethodCallHandler(null);
    _pending.clear();
    await _controller.close();
  }
}
