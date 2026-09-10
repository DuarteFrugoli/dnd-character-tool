import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/confirmation_dialog_styles.dart';

class EditGuard {
  bool get isEditing => _discardFn != null;

  Future<void> Function()? _discardFn;

  void register(Future<void> Function() discardFn) {
    _discardFn = discardFn;
  }

  void unregister() {
    _discardFn = null;
  }

  Future<bool> requestCancel(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final fn = _discardFn;
    if (fn == null) return true;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.detailCancelEditTitle),
        content: Text(l10n.detailCancelEditContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: neutralDialogTextButtonStyle(ctx),
            child: Text(l10n.dialogKeepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: destructiveDialogFilledButtonStyle(ctx),
            child: Text(l10n.dialogDiscard),
          ),
        ],
      ),
    );
    if (confirm != true) return false;
    await fn();
    return true;
  }
}
