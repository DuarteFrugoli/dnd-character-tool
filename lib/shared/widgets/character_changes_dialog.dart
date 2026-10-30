import 'package:flutter/material.dart';

import '../../data/character_change_summary.dart';
import '../../data/datasources/srd/srd_i18n_service.dart';
import '../../data/models/models.dart';
import '../../l10n/ability_l10n.dart';
import '../../l10n/app_localizations.dart';
import 'confirmation_dialog_styles.dart';

/// Lists what an operation changes on a sheet and asks to save it.
/// [notes] explain what the operation could not change.
Future<bool> showCharacterChangesDialog(
  BuildContext context, {
  required Character before,
  required Character after,
  required SrdI18nService i18n,
  List<String> notes = const [],
}) async {
  final changes = CharacterChangeSummary.compare(before, after);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext)!;
      final theme = Theme.of(dialogContext);
      return AlertDialog(
        title: Text(l10n.changesReviewTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(changes.isEmpty ? l10n.changesReviewNone : l10n.changesReviewIntro),
              for (final change in changes)
                _ChangeTile(change: change, i18n: i18n),
              if (notes.isNotEmpty) ...[
                const Divider(height: 24),
                Text(l10n.changesKeptTitle, style: theme.textTheme.titleSmall),
                for (final note in notes)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      note,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: neutralDialogTextButtonStyle(dialogContext),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.changesReviewApply),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

class _ChangeTile extends StatelessWidget {
  const _ChangeTile({required this.change, required this.i18n});

  final CharacterChange change;
  final SrdI18nService i18n;

  String _title(AppLocalizations l10n) => switch (change.kind) {
    CharacterChangeKind.level => l10n.labelLevel,
    CharacterChangeKind.classes => l10n.changesKindClasses,
    CharacterChangeKind.maxHp => l10n.labelMaxHP,
    CharacterChangeKind.ability => abilityName(l10n, change.ability!),
    CharacterChangeKind.savingThrows => l10n.reviewRowSavingThrows,
    CharacterChangeKind.skills => l10n.creationStepSkills,
    CharacterChangeKind.expertise => l10n.changesKindExpertise,
    CharacterChangeKind.proficiencies => l10n.changesKindProficiencies,
    CharacterChangeKind.languages => l10n.labelLanguages,
    CharacterChangeKind.feats => l10n.featuresSectionFeats,
    CharacterChangeKind.spells => l10n.detailTabSpells,
    CharacterChangeKind.experience => l10n.changesKindExperience,
    CharacterChangeKind.wildShapeKnownForms => l10n.changesKindWildShapeForms,
    CharacterChangeKind.wildShapeEnds => l10n.wildShapeTitle,
  };

  String _name(AppLocalizations l10n, String value) => switch (change.kind) {
    CharacterChangeKind.savingThrows => abilityName(l10n, value.toLowerCase()),
    CharacterChangeKind.skills || CharacterChangeKind.expertise => i18n.skillName(value),
    CharacterChangeKind.languages => i18n.languageName(value),
    CharacterChangeKind.feats => i18n.featName(value) ?? value,
    CharacterChangeKind.spells => i18n.spellName(value),
    CharacterChangeKind.proficiencies => value.startsWith('Tool Proficiency: ')
        ? i18n.toolName(value.substring('Tool Proficiency: '.length))
        : value,
    _ => value,
  };

  String _classes(String value) => value
      .split(' / ')
      .map((part) {
        final words = part.split(' ');
        return [i18n.className(words.first), ...words.skip(1)].join(' ');
      })
      .join(' / ');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final valueChange = change.before != null || change.after != null;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_title(l10n), style: theme.textTheme.titleSmall),
          if (change.kind == CharacterChangeKind.wildShapeEnds)
            Text(l10n.changesWildShapeEnds),
          if (valueChange)
            Text(
              change.kind == CharacterChangeKind.classes
                  ? '${_classes(change.before!)} → ${_classes(change.after!)}'
                  : '${change.before} → ${change.after}',
            ),
          if (change.removed.isNotEmpty)
            Text(
              '${l10n.changesRemoved}: ${change.removed.map((v) => _name(l10n, v)).join(', ')}',
              style: TextStyle(color: scheme.error),
            ),
          if (change.added.isNotEmpty)
            Text(
              '${l10n.changesAdded}: ${change.added.map((v) => _name(l10n, v)).join(', ')}',
              style: TextStyle(color: scheme.primary),
            ),
        ],
      ),
    );
  }
}
