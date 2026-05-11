// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'D&D Character Tool';

  @override
  String get charListTitle => 'D&D Characters';

  @override
  String get charListImportTooltip => 'Import JSON';

  @override
  String get charListSettingsTooltip => 'Settings';

  @override
  String get charListNewCharacter => 'New Character';

  @override
  String get charListEmpty => 'No characters yet';

  @override
  String get charListEmptyHint => 'Tap + to create your first character';

  @override
  String charListImportedSuccess(String name) {
    return '$name imported successfully!';
  }

  @override
  String get charListImportError =>
      'Unexpected error while importing. Please try again.';

  @override
  String charCardLevel(int level) {
    return 'Level $level';
  }

  @override
  String get charCardPin => 'Pin to top';

  @override
  String get charCardUnpin => 'Unpin';

  @override
  String get charCardChangePhoto => 'Change photo';

  @override
  String get charCardRename => 'Rename';

  @override
  String get charCardExport => 'Export';

  @override
  String get charCardDelete => 'Delete';

  @override
  String get renameDialogTitle => 'Rename character';

  @override
  String get renameDialogLabel => 'Name';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogSave => 'Save';

  @override
  String get deleteDialogTitle => 'Delete character?';

  @override
  String deleteDialogContent(String name) {
    return 'Are you sure you want to delete $name? This cannot be undone.';
  }

  @override
  String get dialogConfirm => 'Confirm';

  @override
  String get dialogDiscard => 'Discard';

  @override
  String get dialogContinue => 'Continue';

  @override
  String get dialogKeepEditing => 'Keep editing';

  @override
  String get dialogRemove => 'Remove';

  @override
  String get dialogAdd => 'Add';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionTheme => 'Visual Theme';

  @override
  String get settingsDark => 'Dark';

  @override
  String get settingsLight => 'Light';

  @override
  String get settingsChooseTheme => 'Choose a Theme';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsAppLanguage => 'App language';

  @override
  String get settingsChooseLanguage => 'Choose a Language';

  @override
  String get settingsSystemDefault => 'System default';

  @override
  String get modeSelectionTitle => 'New Character';

  @override
  String get modeSelectionQuestion =>
      'How do you want to create your character?';

  @override
  String get modeGuidedTitle => 'Guided';

  @override
  String get modeGuidedSubtitle =>
      'Step-by-step wizard. Choose class, race, background, skills and attributes one at a time. Recommended for new players.';

  @override
  String get modeManualTitle => 'Manual';

  @override
  String get modeManualSubtitle =>
      'Fill in everything yourself. All fields are free and no values are calculated for you. Best for experienced players.';

  @override
  String get modeRandomTitle => 'Random';

  @override
  String get modeRandomSubtitle =>
      'Everything is rolled for you — race, class, background and attributes. Great for a challenge or one-shots.';

  @override
  String get modeSemiRandomTitle => 'Semi-random';

  @override
  String get modeSemiRandomSubtitle =>
      'You pick the important choices; everything else is rolled. Good for when you have a concept but want surprises.';

  @override
  String get modeComingSoon => 'Soon';

  @override
  String get creationStepClass => 'Class';

  @override
  String get creationStepRace => 'Race';

  @override
  String get creationStepBackground => 'Background';

  @override
  String get creationStepSkills => 'Skills';

  @override
  String get creationStepAttributes => 'Attributes';

  @override
  String get creationStepName => 'Name';

  @override
  String get creationStepReview => 'Review';

  @override
  String get creationDiscardTitle => 'Discard character?';

  @override
  String get creationDiscardContent =>
      'All progress will be lost. Are you sure?';

  @override
  String get creationTooltipCancel => 'Cancel';

  @override
  String get creationBack => 'Back';

  @override
  String get creationCreateCharacter => 'Create Character';

  @override
  String get detailLeaveWithoutSaving => 'Leave without saving?';

  @override
  String get detailChangesWillBeDiscarded =>
      'Changes will be discarded. To save, use the ✓ button at the top right.';

  @override
  String get detailLeaveAndDiscard => 'Leave and discard';

  @override
  String detailErrorLoading(String error) {
    return 'Error loading character: $error';
  }

  @override
  String get detailTooltipLongRest => 'Long Rest';

  @override
  String get detailTooltipCancelEdit => 'Cancel editing';

  @override
  String get detailTooltipDoneEditing => 'Done editing';

  @override
  String get detailTooltipEditCharacter => 'Edit character';

  @override
  String get detailCancelEditTitle => 'Cancel editing?';

  @override
  String get detailCancelEditContent => 'All changes will be discarded.';

  @override
  String get detailFinishEditTitle => 'Finish editing?';

  @override
  String get detailFinishEditContent => 'Changes will be saved.';

  @override
  String get detailTabStats => 'Stats';

  @override
  String get detailTabSkills => 'Skills';

  @override
  String get detailTabFeatures => 'Features';

  @override
  String get detailTabSpells => 'Spells';

  @override
  String get detailTabInventory => 'Inventory';

  @override
  String get detailTabNotes => 'Notes';

  @override
  String get longRestTitle => 'Long Rest';

  @override
  String get longRestContent =>
      'Restore HP to maximum and recover all spell slots?';

  @override
  String get longRestButton => 'Rest';

  @override
  String get sectionIdentity => 'Identity';

  @override
  String get sectionHitPoints => 'Hit Points';

  @override
  String get sectionCombat => 'Combat';

  @override
  String get sectionAbilityScores => 'Ability Scores';

  @override
  String get sectionSavingThrows => 'Saving Throw Proficiencies';

  @override
  String get labelName => 'Name';

  @override
  String get labelBackground => 'Background';

  @override
  String get labelChange => 'Change';

  @override
  String get labelAlignment => 'Alignment';

  @override
  String get labelPlayer => 'Player';

  @override
  String get labelLevel => 'Level';

  @override
  String get labelSubclass => 'Subclass';

  @override
  String get labelLanguages => 'Languages';

  @override
  String get hintAddLanguage => 'Add language…';

  @override
  String get labelChoose => 'Choose';

  @override
  String get labelMaxHP => 'Max HP';

  @override
  String get labelTempHP => 'Temp HP';

  @override
  String get labelAmount => 'Amount';

  @override
  String get labelSpeed => 'Speed (ft)';

  @override
  String get detailDamage => 'Damage';

  @override
  String get detailHeal => 'Heal';

  @override
  String get detailNone => 'None';

  @override
  String get tempHpDialogTitle => 'Add Temporary HP';

  @override
  String get tempHpDialogTitleReplace => 'Temporary HP';

  @override
  String tempHpCurrent(int n) {
    return 'Current: +$n temp HP';
  }

  @override
  String get tempHpNoStack =>
      'Temp HP doesn\'t stack — only higher values replace the current.';

  @override
  String get tempHpReplace => 'Replace';

  @override
  String subclassConfirmTitle(String feature) {
    return 'Confirm $feature';
  }

  @override
  String subclassChooseTitle(String feature) {
    return 'Choose $feature';
  }

  @override
  String subclassConfirmBody(int level, String feature) {
    return 'You reached level $level. Confirm or change your $feature.';
  }

  @override
  String subclassChooseBody(int level, String feature) {
    return 'You reached level $level! Choose your $feature.';
  }

  @override
  String get subclassKeepCurrent => 'Keep current';

  @override
  String get subclassChangeTitle => 'Change subclass';

  @override
  String get subclassChangeWarning =>
      'Warning: spells and proficiencies granted by the previous subclass are not removed automatically. You will need to adjust them manually.';

  @override
  String get backgroundChooseTitle => 'Choose Background';

  @override
  String get featuresTooltipAdd => 'Add feature';

  @override
  String get featuresTooltipRemove => 'Remove';

  @override
  String get featuresRemoveTitle => 'Remove feature?';

  @override
  String featuresRemoveContent(String name) {
    return '\"$name\" will be removed.';
  }

  @override
  String get featuresNoneAvailable => 'No features available.';

  @override
  String get featuresAddLabel => 'Add Feature';

  @override
  String get featuresLoadError => 'Error loading features.';

  @override
  String get hintSearch => 'Search...';

  @override
  String get labelFeatureName => 'Name';

  @override
  String get labelFeatureDescription => 'Description (optional)';

  @override
  String get labelFeatureType => 'Type:';

  @override
  String get labelPassive => 'Passive';

  @override
  String get labelActive => 'Active';

  @override
  String get spellsTooltipAdd => 'Add spell';

  @override
  String get spellsRemoveTitle => 'Remove spell?';

  @override
  String spellsRemoveContent(String name) {
    return 'Remove \"$name\" from your spell list?';
  }

  @override
  String get spellsAtWill => 'At will';

  @override
  String get notesTooltipAdd => 'Add note';

  @override
  String get notesTooltipEdit => 'Edit note';

  @override
  String get notesTooltipDelete => 'Delete note';

  @override
  String get notesDeleteTitle => 'Delete note?';

  @override
  String notesDeleteContentNamed(String title) {
    return '\"$title\" will be permanently deleted.';
  }

  @override
  String get notesDeleteContent => 'This note will be permanently deleted.';

  @override
  String get notesLabelTitle => 'Title';

  @override
  String get notesLabelContent => 'Content';

  @override
  String get sectionPersonalityTraits => 'Personality Traits';

  @override
  String get sectionIdeals => 'Ideals';

  @override
  String get sectionBonds => 'Bonds';

  @override
  String get sectionFlaws => 'Flaws';

  @override
  String get sectionBackstory => 'Backstory';

  @override
  String inventoryEquippedSection(int count, int ac) {
    return 'Equipped ($count)  ·  AC $ac';
  }

  @override
  String get inventoryTooltipAdd => 'Add item';

  @override
  String get inventoryTooltipRemove => 'Remove';

  @override
  String get inventoryRemoveTitle => 'Remove item?';

  @override
  String inventoryRemoveContent(String name) {
    return 'Remove $name from inventory?';
  }

  @override
  String inventoryRemovePartial(int count, int total) {
    return 'Will remove: $count of $total';
  }

  @override
  String get inventoryLabelQuantity => 'Quantity:';

  @override
  String get inventoryLabelQuantityToRemove => 'Quantity to remove';

  @override
  String get inventoryAddCustomItem => 'Add Custom Item';

  @override
  String get inventoryAddItem => 'Add Item';

  @override
  String get inventoryLabelItemName => 'Name *';

  @override
  String get inventoryLabelType => 'Type';

  @override
  String get inventoryLabelCategory => 'Category';

  @override
  String get inventoryLabelItemQuantity => 'Quantity';

  @override
  String get inventoryLabelDescription => 'Description (optional)';

  @override
  String get inventoryTypeWeapon => 'Weapon';

  @override
  String get inventoryTypeArmor => 'Armor';

  @override
  String get inventoryTypeConsumable => 'Consumable';

  @override
  String get inventoryTypeGear => 'Gear';

  @override
  String get inventoryReplaceArmorTitle => 'Replace equipped armor?';

  @override
  String get inventoryTabWeapons => 'Weapons';

  @override
  String get inventoryTabArmor => 'Armor';

  @override
  String get inventoryTabGear => 'Gear';

  @override
  String get inventoryTabMagic => 'Magic';

  @override
  String get inventoryTabCustom => 'Custom';

  @override
  String hintSearchCategory(String category) {
    return 'Search $category...';
  }

  @override
  String get stepChooseMethod => 'Choose your method:';

  @override
  String get stepStandardArray => 'Standard Array';

  @override
  String get stepPointBuy => 'Point Buy';

  @override
  String get stepRoll4d6 => 'Roll 4d6';

  @override
  String get stepDistributeRacialBonuses => 'Distribute racial bonuses freely';

  @override
  String get stepAssignRolls => 'Assign each roll to an attribute:';

  @override
  String get stepAssignValues => 'Assign each value to one attribute:';

  @override
  String get stepPointsRemaining => 'Points remaining: ';

  @override
  String stepRaceBonus(int n) {
    return '+$n race';
  }

  @override
  String get stepChooseSubrace => 'Choose a subrace:';

  @override
  String get stepGrantedByBackground => 'Granted by background:';

  @override
  String stepClassSkillChoices(int count) {
    return 'Class skill choices ($count):';
  }

  @override
  String get stepChooseOne => 'Choose one';

  @override
  String get stepSelectTool => 'Select a tool…';
}
