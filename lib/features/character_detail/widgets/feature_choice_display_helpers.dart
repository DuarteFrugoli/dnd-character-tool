import 'package:dnd_character_tool/l10n/ability_l10n.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../data/datasources/srd/srd_i18n_service.dart';
import '../../../data/datasources/srd/srd_models.dart';
import '../../../data/feature_choice_engine.dart';

String? featureChoiceOptionSubtitle({
  required BuildContext context,
  required FeatureChoiceRequest request,
  required SrdFeatureChoiceOption option,
  required SrdI18nService i18n,
}) {
  final description = option.description?.trim();
  if (description == null || description.isEmpty) return null;

  final type = request.requirement.type;
  if (_isSkillOption(type, option.id)) {
    return _abilitySubtitle(context, description);
  }
  if (_isToolOption(type, option.id) || type == 'weapon') {
    return _categorySubtitle(context, description, i18n);
  }
  return description.contains('_')
      ? _humanizeIdentifier(description)
      : description;
}

bool _isSkillOption(String type, String optionId) {
  return type == 'skill' ||
      type == 'skill_expertise' ||
      ((type == 'skill_or_tool' || type == 'skill_or_tool_expertise') &&
          optionId.startsWith('skill:'));
}

bool _isToolOption(String type, String optionId) {
  return type == 'tool' ||
      ((type == 'skill_or_tool' || type == 'skill_or_tool_expertise') &&
          optionId.startsWith('tool:'));
}

String _abilitySubtitle(BuildContext context, String ability) {
  final normalized = _humanizeIdentifier(ability);
  return abilityName(AppLocalizations.of(context)!, normalized);
}

String _categorySubtitle(
  BuildContext context,
  String category,
  SrdI18nService i18n,
) {
  final l10n = AppLocalizations.of(context)!;
  switch (category.trim().toLowerCase()) {
    case 'simple melee':
      return l10n.inventoryGroupSimpleMelee;
    case 'simple ranged':
      return l10n.inventoryGroupSimpleRanged;
    case 'martial melee':
      return l10n.inventoryGroupMartialMelee;
    case 'martial ranged':
      return l10n.inventoryGroupMartialRanged;
    case 'artisans_tools':
      return l10n.inventoryGroupArtisansTools;
    case 'gaming_sets':
      return l10n.inventoryGroupGamingSets;
    case 'musical_instruments':
      return l10n.inventoryGroupMusicalInstruments;
    case 'other_tools':
      return l10n.inventoryGroupOtherTools;
    default:
      final translated = i18n.term(category.trim());
      return translated == category
          ? _humanizeIdentifier(category)
          : translated;
  }
}

String _humanizeIdentifier(String value) {
  final normalized = value
      .trim()
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ');
  if (normalized.isEmpty) return value;
  final lower = normalized.toLowerCase();
  return lower[0].toUpperCase() + lower.substring(1);
}
