import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

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
            child: Text(l10n.dialogKeepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
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
