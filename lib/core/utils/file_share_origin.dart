import 'package:flutter/widgets.dart';

/// A nonempty, visible anchor required by the native iPad share popover.
Rect fileShareOrigin(BuildContext context) {
  if (!context.mounted) {
    throw StateError('The share source is no longer mounted.');
  }
  final view = View.of(context);
  final viewport = Offset.zero & (view.physicalSize / view.devicePixelRatio);
  final renderObject = context.findRenderObject();
  if (renderObject is RenderBox &&
      renderObject.attached &&
      renderObject.hasSize) {
    final visible =
        (renderObject.localToGlobal(Offset.zero) & renderObject.size).intersect(
          viewport,
        );
    if (!visible.isEmpty && visible.isFinite) {
      return Rect.fromCenter(center: visible.center, width: 1, height: 1);
    }
  }
  return Rect.fromCenter(center: viewport.center, width: 1, height: 1);
}
