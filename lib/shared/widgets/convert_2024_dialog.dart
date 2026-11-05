import 'package:flutter/material.dart';

import '../../data/datasources/srd/srd_i18n_service.dart';
import '../../data/models/models.dart';
import '../../l10n/app_localizations.dart';

/// Says what the conversion of a 2014 sheet keeps and what is chosen again.
/// Returns true when the player starts it.
Future<bool> confirmConvert2024(
  BuildContext context,
  Character character,
  SrdI18nService? i18n,
) async {
  final l10n = AppLocalizations.of(context)!;
  final classes = character.classEntries
      .map((entry) => '${i18n?.className(entry.className) ?? entry.className} ${entry.level}')
      .join(' / ');
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.convert2024Title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.convert2024Intro(character.name)),
            const SizedBox(height: 12),
            Text('• ${l10n.convert2024Kept}'),
            const SizedBox(height: 8),
            Text('• ${l10n.convert2024Chosen(classes)}'),
            const SizedBox(height: 8),
            Text('• ${l10n.convert2024Reset}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.convert2024Start),
        ),
      ],
    ),
  );
  return confirmed == true;
}
