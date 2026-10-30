import 'package:flutter/material.dart';

import '../../data/migrations/character_migration.dart';
import '../../data/migrations/character_migration_runner.dart';
import '../../l10n/app_localizations.dart';

String formatCharacterMaintenanceReport(
  BuildContext context,
  CharacterMigrationBatchReport report,
) {
  final l10n = AppLocalizations.of(context)!;
  final buffer = StringBuffer();

  buffer.writeln(l10n.settingsMaintenanceReportChecked(report.checkedCount));
  buffer.writeln(l10n.settingsMaintenanceReportUpdated(report.outdatedCount));
  buffer.writeln(
    l10n.settingsMaintenanceReportDataChanged(report.dataChangedCount),
  );
  if (report.hasReadIssues) {
    buffer.writeln();
    buffer.writeln(l10n.settingsMaintenanceError);
    for (final issue in report.readIssues) {
      final id = issue.id == null ? '' : ' (${issue.id})';
      buffer.writeln(
        '- ${issue.source}$id: ${_formatReadIssue(context, issue)}',
      );
    }
  }

  final updated = report.characters.where((entry) => entry.needsMigration);
  for (final entry in updated) {
    buffer.writeln();
    buffer.writeln(entry.original.name);
    if (entry.changes.isEmpty) {
      buffer.writeln('- ${l10n.settingsMaintenanceReportVersionUpdated}');
      continue;
    }

    for (final change in entry.changes) {
      buffer.writeln('- ${_formatChange(context, change)}');
    }
  }

  return buffer.toString().trimRight();
}

String _formatReadIssue(
  BuildContext context,
  CharacterMigrationReadIssue issue,
) {
  final l10n = AppLocalizations.of(context)!;
  return switch (issue.message) {
    'invalid_json' => l10n.importErrorInvalidJson,
    'not_object' => l10n.importErrorNotObject,
    _ => l10n.importErrorCorruptedCharacter,
  };
}

String _formatChange(BuildContext context, CharacterMigrationChange change) {
  final l10n = AppLocalizations.of(context)!;
  if (change.code == 'equipment_weights_backfilled') {
    return l10n.settingsMaintenanceChangeEquipmentWeights(change.count);
  }
  if (change.code == 'equipment_items_normalized') {
    return l10n.settingsMaintenanceChangeEquipmentNormalized(change.count);
  }
  if (change.code == 'equipment_packs_expanded') {
    return l10n.settingsMaintenanceChangeEquipmentPacksExpanded(change.count);
  }
  if (change.code == 'equipment_order_normalized') {
    return l10n.settingsMaintenanceChangeEquipmentOrder(change.count);
  }
  if (change.code == 'multiclass_structure_prepared') {
    return l10n.settingsMaintenanceChangeMulticlassStructure;
  }
  if (change.code == 'spell_slots_synced' ||
      change.code == 'standard_spell_slots_synced') {
    return l10n.settingsMaintenanceChangeSpellSlots;
  }
  if (change.code == 'pact_magic_slots_synced') {
    return l10n.settingsMaintenanceChangePactMagicSlots;
  }
  if (change.code == 'armor_class_recalculated') {
    return l10n.settingsMaintenanceChangeArmorClass;
  }
  if (change.code == 'ruleset_2014_assigned') {
    return l10n.settingsMaintenanceChangeRuleset2014;
  }
  if (change.code == 'level_history_recorded') {
    return l10n.settingsMaintenanceChangeLevelHistory;
  }
  if (change.code == 'class_skills_recorded') {
    return l10n.settingsMaintenanceChangeClassSkills;
  }

  return l10n.settingsMaintenanceChangeGeneric(change.count);
}
