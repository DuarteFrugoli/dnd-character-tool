/// Persistence-contract constants shared across features, models, and providers.
///
/// These values are stored in saved character JSON, so they must not be changed
/// without a migration.
library;

/// Source key used when the user creates a custom class feature.
const kFeatureSourceCustom = 'Custom';

/// D&D 5e skill to ability mapping.
const skillAbility = <String, String>{
  'Acrobatics': 'Dexterity',
  'Animal Handling': 'Wisdom',
  'Arcana': 'Intelligence',
  'Athletics': 'Strength',
  'Deception': 'Charisma',
  'History': 'Intelligence',
  'Insight': 'Wisdom',
  'Intimidation': 'Charisma',
  'Investigation': 'Intelligence',
  'Medicine': 'Wisdom',
  'Nature': 'Intelligence',
  'Perception': 'Wisdom',
  'Performance': 'Charisma',
  'Persuasion': 'Charisma',
  'Religion': 'Intelligence',
  'Sleight of Hand': 'Dexterity',
  'Stealth': 'Dexterity',
  'Survival': 'Wisdom',
};
