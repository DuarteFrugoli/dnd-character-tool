import 'app_localizations.dart';

/// Returns the localized full name for a D&D ability score.
/// Falls back to the English name if the key is unrecognized.
String abilityName(AppLocalizations l10n, String en) {
  // Normalize: SRD data may store ability names in lowercase.
  final key = en.isEmpty ? en : en[0].toUpperCase() + en.substring(1);
  switch (key) {
    case 'Strength':
      return l10n.abilityStrength;
    case 'Dexterity':
      return l10n.abilityDexterity;
    case 'Constitution':
      return l10n.abilityConstitution;
    case 'Intelligence':
      return l10n.abilityIntelligence;
    case 'Wisdom':
      return l10n.abilityWisdom;
    case 'Charisma':
      return l10n.abilityCharisma;
    default:
      return en;

  }
}
