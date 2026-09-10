import 'package:flutter/material.dart';

ButtonStyle neutralDialogTextButtonStyle(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return TextButton.styleFrom(foregroundColor: scheme.onSurfaceVariant);
}

ButtonStyle destructiveDialogTextButtonStyle(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return TextButton.styleFrom(foregroundColor: scheme.error);
}

ButtonStyle destructiveDialogFilledButtonStyle(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return FilledButton.styleFrom(
    backgroundColor: scheme.error,
    foregroundColor: scheme.onError,
  );
}
