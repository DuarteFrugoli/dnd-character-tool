/// Persistence-contract constants shared across features, models, and providers.
///
/// These values are stored in saved character JSON, so they must not be changed
/// without a migration.
library;

/// Source key used when the user creates a custom class feature.
const kFeatureSourceCustom = 'Custom';

/// Item type keys stored in [Item.type] and used for category filtering.
const kItemTypeWeapon = 'weapon';
const kItemTypeArmor = 'armor';
const kItemTypeAdventuringGear = 'adventuring gear';
const kItemTypeAmmunition = 'ammunition';
