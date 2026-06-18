// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DnD Character Tool';

  @override
  String get charListTitle => 'DnD Characters';

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
  String get importErrorInvalidJson => 'The pasted JSON is not valid.';

  @override
  String get importErrorInvalidToken =>
      'Invalid token. It may be corrupted or from an incompatible version.';

  @override
  String get importFieldLockedHint => 'Clear the other field to use this one.';

  @override
  String get importErrorNotObject => 'Invalid format: expected a JSON object.';

  @override
  String get importErrorMissingCharacter =>
      'Invalid JSON: \'character\' field not found.';

  @override
  String get importErrorCorruptedCharacter =>
      'Could not read character. The JSON may be incomplete or from an incompatible version.';

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
  String get dialogDone => 'Done';

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
  String get detailTabIdentity => 'Identity';

  @override
  String get detailEditButton => 'Edit';

  @override
  String get skillsEditHint => 'Hold to toggle: none → proficient → expert';

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
  String get restPickerTitle => 'Rest';

  @override
  String get restPickerShort => 'Short Rest';

  @override
  String get restPickerShortCaption => 'Spend Hit Dice to recover HP';

  @override
  String get restPickerLong => 'Long Rest';

  @override
  String get restPickerLongCaption => 'Full HP and spell slot recovery';

  @override
  String get shortRestTitle => 'Short Rest';

  @override
  String get shortRestAvailableDice => 'Available Hit Dice';

  @override
  String get shortRestSpend => 'Spend';

  @override
  String get shortRestRolled => 'HP recovered';

  @override
  String get shortRestRollButton => 'Roll';

  @override
  String get shortRestButton => 'Rest';

  @override
  String get shortRestNoDice => 'No Hit Dice remaining';

  @override
  String get concentrationBannerLabel => 'Concentrating on:';

  @override
  String get concentrationBreakButton => 'End';

  @override
  String get concentrationReplaceTitle => 'Replace Concentration?';

  @override
  String concentrationReplaceBody(String current, String next) {
    return 'You are concentrating on $current. Starting $next will end your concentration.';
  }

  @override
  String get concentrationReplaceConfirm => 'Replace';

  @override
  String get concentrationTooltip => 'Set concentration';

  @override
  String get sectionIdentity => 'Identity';

  @override
  String get sectionHitPoints => 'Hit Points';

  @override
  String get sectionCombat => 'Combat';

  @override
  String get sectionProgression => 'Progression';

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
  String get levelManualChangeWarning =>
      'Only features and spell slots are updated automatically. For a full level up (HP, ability scores, feats, spell choices), use the Level Up button in the top bar.';

  @override
  String get tooltipLevelUp => 'Level Up';

  @override
  String get levelUpTitle => 'Level Up';

  @override
  String get levelUpConfirm => 'Confirm Level Up';

  @override
  String get levelUpCancel => 'Cancel';

  @override
  String get levelUpStepFeatures => 'New Features';

  @override
  String levelUpStepSubclass(String feature) {
    return 'Choose $feature';
  }

  @override
  String get levelUpStepAsi => 'Ability Score Improvement';

  @override
  String get levelUpStepHp => 'Hit Points';

  @override
  String get levelUpStepCantrips => 'New Cantrips';

  @override
  String get levelUpStepSpells => 'New Spells';

  @override
  String get levelUpStepSummary => 'Summary';

  @override
  String get levelUpNoNewFeatures => 'No new class features at this level.';

  @override
  String get levelUpHpRoll => 'Roll';

  @override
  String get levelUpHpAverage => 'Average';

  @override
  String levelUpHpGained(int n) {
    return '+$n HP';
  }

  @override
  String levelUpHpFormula(int die, String mod) {
    return 'd$die + CON ($mod)';
  }

  @override
  String get levelUpAsiOption => 'Ability Score Improvement';

  @override
  String get levelUpFeatOption => 'Choose a Feat';

  @override
  String levelUpAsiPointsLeft(int n) {
    return '$n point(s) remaining';
  }

  @override
  String levelUpSpellsToLearn(int n) {
    return 'Choose $n spell(s) to learn';
  }

  @override
  String levelUpCantripsToLearn(int n) {
    return 'Choose $n cantrip(s)';
  }

  @override
  String get levelUpSpellSwap => 'Replace a known spell (optional)';

  @override
  String levelUpSpellSwapCurrent(String name) {
    return 'Currently: $name';
  }

  @override
  String levelUpSummaryLevel(int level) {
    return '→ Level $level';
  }

  @override
  String levelUpSummaryHp(int n) {
    return 'Max HP +$n';
  }

  @override
  String levelUpSummaryAsi(String changes) {
    return 'ASI: $changes';
  }

  @override
  String levelUpSummaryFeat(String name) {
    return 'Feat: $name';
  }

  @override
  String levelUpSummarySubclass(String name) {
    return 'Subclass: $name';
  }

  @override
  String levelUpSummarySpellsLearned(int count) {
    return 'Spells learned: $count';
  }

  @override
  String levelUpSummaryCantripsLearned(int count) {
    return 'Cantrips learned: $count';
  }

  @override
  String levelUpSubclassAlreadyHas(String name) {
    return 'Current subclass: $name';
  }

  @override
  String get levelUpMaxLevel => 'Already at maximum level (20).';

  @override
  String get levelUpHpReroll => 'Reroll / change';

  @override
  String get levelUpSpellSwapPickReplacement =>
      'Now choose a replacement spell';

  @override
  String get levelUpSpellSwapReplaceWith => 'Replace with';

  @override
  String get levelUpSpellSwapNone => 'None';

  @override
  String get levelUpSpellAlreadyKnown => 'Already known';

  @override
  String levelUpSpellCantripSubtitle(String school) {
    return '$school cantrip';
  }

  @override
  String levelUpSpellSubtitle(int level, String school) {
    return 'Lv $level $school';
  }

  @override
  String get labelSubclass => 'Subclass';

  @override
  String get labelLanguages => 'Languages';

  @override
  String get hintAddLanguage => 'Add language…';

  @override
  String get labelChoose => 'Choose';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get labelAge => 'Age';

  @override
  String get labelHeight => 'Height';

  @override
  String get labelWeight => 'Weight';

  @override
  String get labelEyes => 'Eyes';

  @override
  String get labelSkin => 'Skin';

  @override
  String get labelHair => 'Hair';

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
  String statsTempHpChip(int n) {
    return '+$n temp';
  }

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
  String get featuresTooltipEnable => 'Enable';

  @override
  String get featuresTooltipDisable => 'Disable';

  @override
  String get featuresTabFeats => 'Feats';

  @override
  String featPrerequisite(String req) {
    return 'Prerequisite: $req';
  }

  @override
  String get featuresSectionFeats => 'Feats';

  @override
  String get featuresTabClass => 'Class';

  @override
  String get featuresTabRacial => 'Racial';

  @override
  String get featuresTabCustom => 'Custom';

  @override
  String get featuresTabTools => 'Tools';

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
  String get notesEmptyTitle => 'No notes yet';

  @override
  String get notesEmptyHint => 'Tap + to create your first note.';

  @override
  String get notesUntitled => 'Untitled';

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
  String get sectionPersonality => 'Personality';

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
  String get inventoryLabelWeight => 'Weight';

  @override
  String get weightCarried => 'Carried';

  @override
  String get weightCapacity => 'Capacity';

  @override
  String get weightEncumbered => 'Encumbered';

  @override
  String get weightHeavilyEncumbered => 'Heavily Encumbered';

  @override
  String get weightEnableTooltip => 'Enable weight tracking';

  @override
  String get weightDisableTooltip => 'Disable weight tracking';

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
  String get inventoryTabTools => 'Tools';

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

  @override
  String get statAC => 'AC';

  @override
  String get statArmor => 'Armor';

  @override
  String get statNoArmor => 'No armor';

  @override
  String get statNoArmorShield => 'No armor + Shield';

  @override
  String get statShieldSuffix => ' + Shield';

  @override
  String get statSpeed => 'Speed';

  @override
  String get statInitiative => 'Initiative';

  @override
  String get statProfBonus => 'Prof Bonus';

  @override
  String get statPassivePerc => 'Passive Perc';

  @override
  String get statInspiration => 'Inspiration';

  @override
  String get statXP => 'XP';

  @override
  String get inspirationGranted => 'Granted';

  @override
  String get inspirationNotGranted => 'Not granted';

  @override
  String statLevel(int level) {
    return 'Level $level';
  }

  @override
  String get tooltipAddXp => 'Add XP';

  @override
  String get labelLevelTable => 'Level Table';

  @override
  String get statUnconsciousDying => 'Unconscious / Dying';

  @override
  String get deathSavesTitle => 'Death Saves';

  @override
  String get deathSavesSuccesses => 'Successes';

  @override
  String get deathSavesFailures => 'Failures';

  @override
  String get deathSavesStabilized => 'Stabilized';

  @override
  String get deathSavesDead => 'Dead';

  @override
  String get sectionActiveConditions => 'Active Conditions';

  @override
  String get conditionsNone => 'None active';

  @override
  String get conditionsAdd => 'Add condition';

  @override
  String get conditionsPickTitle => 'Apply Condition';

  @override
  String get conditionsRemove => 'Remove condition';

  @override
  String get tooltipAddTempHp => 'Add temp HP';

  @override
  String get tooltipChangeTempHp => 'Change temp HP';

  @override
  String get abilityStr => 'STR';

  @override
  String get abilityDex => 'DEX';

  @override
  String get abilityCon => 'CON';

  @override
  String get abilityInt => 'INT';

  @override
  String get abilityWis => 'WIS';

  @override
  String get abilityCha => 'CHA';

  @override
  String featuresSectionRacialTraits(String name) {
    return 'Racial Traits — $name';
  }

  @override
  String featuresSectionBackground(String name) {
    return 'Background Feature — $name';
  }

  @override
  String featuresSectionClass(String name) {
    return 'Class Features — $name';
  }

  @override
  String featuresSectionSubclass(String name) {
    return 'Subclass Features — $name';
  }

  @override
  String get featuresSectionTools => 'Tool Proficiencies';

  @override
  String get featuresSectionExtra => 'Extra Features';

  @override
  String get spellsNoSpellcasting => 'No Spellcasting';

  @override
  String get spellsNoSpellcastingDesc =>
      'This class has no spellcasting features.';

  @override
  String get spellsSlots => 'Spell Slots';

  @override
  String get spellsSpellcasting => 'Spellcasting';

  @override
  String get spellsAttack => 'Attack';

  @override
  String get spellsSaveDC => 'Save DC';

  @override
  String get spellsCantrips => 'Cantrips';

  @override
  String get spellsPrepared => 'Prepared';

  @override
  String get spellsKnown => 'Known';

  @override
  String get spellsEmpty => 'No spells added yet.\nTap + to browse spells.';

  @override
  String spellsSlotLevel(int level) {
    return 'Lvl $level';
  }

  @override
  String spellsLevelN(int level) {
    return 'Level $level';
  }

  @override
  String get spellsInnateHeader => 'Racial Spells';

  @override
  String get spellsDisableTitle => 'Disable spell?';

  @override
  String get spellsEnableTitle => 'Enable spell?';

  @override
  String spellsDisableContent(String name) {
    return 'Disable \"$name\"? It will be grayed out and cannot be prepared.';
  }

  @override
  String spellsEnableContent(String name) {
    return 'Enable \"$name\"? It will appear normally again.';
  }

  @override
  String get spellsDisable => 'Disable';

  @override
  String get spellsEnable => 'Enable';

  @override
  String get spellsExtrasHeader => 'Extra Spells';

  @override
  String get spellFilterTitle => 'Filters';

  @override
  String get spellFilterReset => 'Reset';

  @override
  String get spellFilterApply => 'Apply Filters';

  @override
  String get spellFilterSectionClasses => 'Classes';

  @override
  String get spellFilterClassesHint => 'No class selected = show all classes';

  @override
  String get spellFilterSectionLevel => 'Spell Level';

  @override
  String get spellFilterShowAllLevels => 'Show all spell levels';

  @override
  String spellFilterShowAllLevelsHint(int max) {
    return 'Include spells above your current max (Lvl $max)';
  }

  @override
  String get spellFilterCantrip => 'Cantrip';

  @override
  String spellFilterLvl(int n) {
    return 'Lvl $n';
  }

  @override
  String get spellFilterSectionCastingTime => 'Casting Time';

  @override
  String get spellFilterCastAction => 'Action';

  @override
  String get spellFilterCastBonus => 'Bonus action';

  @override
  String get spellFilterCastReaction => 'Reaction';

  @override
  String get spellFilterCastLonger => 'Longer cast (1 min+)';

  @override
  String get spellFilterSectionProperties => 'Properties';

  @override
  String get spellFilterConcentration => 'Concentration';

  @override
  String get spellFilterConcentrationHint =>
      'Only spells that require concentration';

  @override
  String get spellFilterRitual => 'Ritual';

  @override
  String get spellFilterRitualHint => 'Only spells that can be cast as rituals';

  @override
  String get spellFilterSectionSchool => 'School of Magic';

  @override
  String get spellRemoveTitle => 'Remove spell';

  @override
  String spellRemoveContent(String name) {
    return 'Remove \"$name\" from your spell list?';
  }

  @override
  String get spellActionPrepared => 'Prepared — tap to unprepare';

  @override
  String get spellActionPrepare => 'Prepare for today';

  @override
  String get spellActionAdd => 'Add to character';

  @override
  String get spellActionInList => 'In your spell list — tap to remove';

  @override
  String get spellActionAlreadyInList => 'Already in your spell list';

  @override
  String get spellActionClassSpellInfo =>
      'This spell is already part of your class list and doesn\'t need to be learned.';

  @override
  String get inventoryCurrency => 'Currency';

  @override
  String inventoryCarriedSection(int count) {
    return 'Carried ($count)';
  }

  @override
  String inventoryEquippableSection(int count) {
    return 'Equippable ($count)';
  }

  @override
  String get inventoryEquipHint =>
      'Tap the circle icon on the left to equip or unequip';

  @override
  String get inventoryInventory => 'Inventory';

  @override
  String get inventoryEmpty => 'No items yet. Tap + to add.';

  @override
  String get inventoryAmmunition => 'Ammunition';

  @override
  String get coinCopper => 'Copper';

  @override
  String get coinSilver => 'Silver';

  @override
  String get coinElectrum => 'Electrum';

  @override
  String get coinGold => 'Gold';

  @override
  String get coinPlatinum => 'Platinum';

  @override
  String get inventoryGroupSimpleMelee => 'Simple Melee';

  @override
  String get inventoryGroupSimpleRanged => 'Simple Ranged';

  @override
  String get inventoryGroupMartialMelee => 'Martial Melee';

  @override
  String get inventoryGroupMartialRanged => 'Martial Ranged';

  @override
  String get inventoryGroupLightArmor => 'Light Armor';

  @override
  String get inventoryGroupMediumArmor => 'Medium Armor';

  @override
  String get inventoryGroupHeavyArmor => 'Heavy Armor';

  @override
  String get inventoryGroupShields => 'Shields';

  @override
  String get inventoryGroupAdventuringGear => 'Adventuring Gear';

  @override
  String get inventoryGroupAmmunition => 'Ammunition';

  @override
  String get inventoryGroupArcaneFocus => 'Arcane Focus';

  @override
  String get inventoryGroupClothing => 'Clothing';

  @override
  String get inventoryGroupContainer => 'Container';

  @override
  String get inventoryGroupPoison => 'Poison';

  @override
  String get inventoryGroupPotions => 'Potions';

  @override
  String get inventoryGroupRings => 'Rings';

  @override
  String get inventoryGroupWands => 'Wands';

  @override
  String get inventoryGroupWeapons => 'Weapons';

  @override
  String get inventoryGroupArmor => 'Armor';

  @override
  String get inventoryGroupWondrousItems => 'Wondrous Items';

  @override
  String get inventoryGroupArtisansTools => 'Artisan\'s Tools';

  @override
  String get inventoryGroupGamingSets => 'Gaming Sets';

  @override
  String get inventoryGroupMusicalInstruments => 'Musical Instruments';

  @override
  String get inventoryGroupOtherTools => 'Other Tools';

  @override
  String get armorStealthDisadvantage => 'Stealth disadvantage';

  @override
  String get spellDetailCastingTime => 'Casting time';

  @override
  String get spellDetailRange => 'Range';

  @override
  String get spellRangeSelf => 'Self';

  @override
  String get spellRangeTouch => 'Touch';

  @override
  String get spellRangeSight => 'Sight';

  @override
  String get spellRangeSpecial => 'Special';

  @override
  String get spellRangeUnlimited => 'Unlimited';

  @override
  String get spellAreaSphere => 'sphere';

  @override
  String get spellAreaCone => 'cone';

  @override
  String get spellAreaCube => 'cube';

  @override
  String get spellAreaCylinder => 'cylinder';

  @override
  String get spellAreaLine => 'line';

  @override
  String get spellAreaWall => 'wall';

  @override
  String get spellAreaCircle => 'circle';

  @override
  String get spellDetailDuration => 'Duration';

  @override
  String get spellDetailComponents => 'Components';

  @override
  String get spellDetailConcentration => 'Requires concentration';

  @override
  String get spellDetailRitual => 'Can be cast as a ritual';

  @override
  String get spellDetailAtHigherLevels => 'At Higher Levels. ';

  @override
  String spellDetailClasses(String classes) {
    return 'Classes: $classes';
  }

  @override
  String spellDetailLevelSchool(String ordinal, String school) {
    return '$ordinal-level $school';
  }

  @override
  String spellDetailCantrip(String school) {
    return '$school cantrip';
  }

  @override
  String armorSwapCurrent(String name) {
    return 'Current: $name';
  }

  @override
  String armorSwapAcNow(int ac) {
    return 'AC now: $ac';
  }

  @override
  String armorSwapAcAfter(int ac) {
    return 'AC after: $ac';
  }

  @override
  String get armorSwapButton => 'Swap armor';

  @override
  String get reviewRowName => 'Name';

  @override
  String get reviewUnnamedHero => 'Unnamed Hero';

  @override
  String get reviewRowPlayer => 'Player';

  @override
  String get reviewRowSubclass => 'Subclass';

  @override
  String get reviewRowHitDie => 'Hit Die';

  @override
  String get reviewRowSavingThrows => 'Saving Throws';

  @override
  String get reviewRowSubrace => 'Subrace';

  @override
  String get reviewRowSpeed => 'Speed';

  @override
  String get reviewRowLanguages => 'Languages';

  @override
  String get reviewRowFeature => 'Feature';

  @override
  String get reviewRowFromBackground => 'From background';

  @override
  String get reviewRowClassChoices => 'Class choices';

  @override
  String get reviewRowMaxHp => 'Max HP';

  @override
  String get reviewRowAcUnarmored => 'AC (Unarmored)';

  @override
  String reviewRowAcWith(String name) {
    return 'AC with $name';
  }

  @override
  String get reviewRowProficiencyBonus => 'Proficiency Bonus';

  @override
  String get reviewStartingGold => 'Starting Gold';

  @override
  String get reviewStartingEquipment => 'Starting Equipment';

  @override
  String get reviewDeselectAll => 'Deselect all';

  @override
  String get reviewSelectAll => 'Select all';

  @override
  String get reviewUncheckHint =>
      'Uncheck items you don\'t want to add to your inventory.';

  @override
  String get reviewEquipmentChoices => 'Equipment Choices';

  @override
  String get reviewEquipmentChoicesHint =>
      'Pick the specific item for each slot.';

  @override
  String get reviewToolProficiencies => 'Tool Proficiencies';

  @override
  String get reviewChooseToolProficiency => 'Choose your tool proficiency:';

  @override
  String reviewChooseLanguages(int count) {
    return 'Choose $count language(s) granted by your race or background.';
  }

  @override
  String get reviewChooseOne => 'Choose one:';

  @override
  String get stepTashaRule =>
      'Tasha\'s optional rule — assign ASI points to any attribute';

  @override
  String get stepRollDice => 'Roll dice';

  @override
  String get stepReroll => 'Reroll';

  @override
  String get stepRollHint => 'Roll to generate 6 values (4d6, drop lowest)';

  @override
  String get stepPrimaryAbilities => 'primary abilities: ';

  @override
  String get stepNameTitle => 'Give your character a name.';

  @override
  String get stepNameHint => 'You can always change this later.';

  @override
  String get stepNameCharLabel => 'Character name';

  @override
  String get stepNamePlayerLabel => 'Player name (optional)';

  @override
  String get stepHitDieLabel => 'Hit die';

  @override
  String get stepSavesLabel => 'Saves';

  @override
  String get stepSpellcastingLabel => 'Spellcasting';

  @override
  String get stepOptionsLabel => 'options';

  @override
  String stepChooseSubclassPrompt(String feature, int level) {
    return 'Choose a $feature (Lv $level):';
  }

  @override
  String get stepRaceSpeedLabel => 'Speed';

  @override
  String get stepRaceASILabel => 'ASI';

  @override
  String stepRaceSubracesAvailable(int count) {
    return '$count subraces available';
  }

  @override
  String stepChooseSkillsHint(int count) {
    return 'Choose $count skills from your class list.';
  }

  @override
  String get abilityStrength => 'Strength';

  @override
  String get abilityDexterity => 'Dexterity';

  @override
  String get abilityConstitution => 'Constitution';

  @override
  String get abilityIntelligence => 'Intelligence';

  @override
  String get abilityWisdom => 'Wisdom';

  @override
  String get abilityCharisma => 'Charisma';

  @override
  String stepFreeAsiRemaining(int remaining) {
    return 'Distribute racial ASI points freely ($remaining remaining):';
  }

  @override
  String stepFreePicksRemaining(int total, int remaining) {
    return 'Racial free ASI: assign +1 to $total attributes ($remaining remaining):';
  }

  @override
  String get stepFreePicksNoStack =>
      'Cannot assign to attributes already receiving a racial bonus.';

  @override
  String reviewClassEquipmentTitle(String name) {
    return 'Class Equipment — $name';
  }

  @override
  String get reviewEquipmentIncluded => 'Included:';

  @override
  String get stepToolCategoryGamingSet => 'Gaming set';

  @override
  String get stepToolCategoryInstrument => 'Musical instrument';

  @override
  String get stepToolCategoryArtisanTool => 'Artisan\'s tool';

  @override
  String get stepToolCategoryArtisanOrInstrument =>
      'Artisan\'s tool or instrument';

  @override
  String exportCopied(String label) {
    return '$label copied!';
  }

  @override
  String exportDialogTitle(String name) {
    return 'Export $name';
  }

  @override
  String get exportLabelToken => 'Token';

  @override
  String get exportCopyToken => 'Copy token';

  @override
  String get exportHideQr => 'Hide QR Code';

  @override
  String get exportShowQr => 'Show QR Code';

  @override
  String get exportQrTooLarge =>
      'Character too large for QR code.\nUse the token or JSON to share.';

  @override
  String get exportShowJson => 'Show JSON';

  @override
  String get exportCopyJson => 'Copy JSON';

  @override
  String get exportSectionQuick => 'Quick share';

  @override
  String get exportSectionQuickCaption => 'No image — for sharing stats';

  @override
  String get exportSectionFile => 'Complete file';

  @override
  String get exportSectionFileCaption => 'Includes the character photo';

  @override
  String get exportShareFile => 'Share .dndchar';

  @override
  String get dialogClose => 'Close';

  @override
  String get importDialogTitle => 'Import Character';

  @override
  String get importTokenHint => 'Paste token here…';

  @override
  String get importScanQr => 'Scan QR Code';

  @override
  String get importUseJson => 'Use JSON directly';

  @override
  String get importJsonHint => 'Paste JSON here…';

  @override
  String get importPickFile => 'Pick .dndchar file';

  @override
  String get importFileError => 'Invalid or corrupted .dndchar file';

  @override
  String get importFileIncoming => 'Import character from file?';

  @override
  String get dialogImport => 'Import';

  @override
  String get spellBrowserTitle => 'Browse Spells';

  @override
  String get spellBrowserFilters => 'Filters';

  @override
  String get spellBrowserSearchHint => 'Search spells...';

  @override
  String get filterClearAll => 'Clear all';

  @override
  String get loadingLabel => 'Loading...';

  @override
  String spellBrowserCount(int count, String s) {
    return '$count spell$s';
  }

  @override
  String get spellBrowserEmpty => 'No spells match the current filters.';

  @override
  String get spellCantrip => 'Cantrip';

  @override
  String spellLevelN(int n) {
    return 'Lvl $n';
  }

  @override
  String get castingTimeAction => 'Action';

  @override
  String get castingTimeBonusAction => 'Bonus action';

  @override
  String get castingTimeReaction => 'Reaction';

  @override
  String get castingTimeLonger => 'Longer cast';

  @override
  String get filterConcentration => 'Concentration';

  @override
  String get filterRitual => 'Ritual';

  @override
  String get filterAllLevels => 'All levels';

  @override
  String get avatarChoosePhoto => 'Choose photo';

  @override
  String get avatarRemovePhoto => 'Remove photo';

  @override
  String get avatarCropPhoto => 'Crop photo';

  @override
  String get avatarChangePhoto => 'Change photo';

  @override
  String get avatarSavePhoto => 'Save photo';

  @override
  String get avatarSaveSuccess => 'Photo saved to gallery';

  @override
  String get avatarSaveError => 'Could not save photo';

  @override
  String featureAddedSnackbar(String name) {
    return '$name added!';
  }

  @override
  String get featureAddButton => 'Add Feature';

  @override
  String get reviewLanguageChoices => 'Language Choices';

  @override
  String get reviewLanguageTypeHint => 'Type a language…';

  @override
  String get avatarRemoveConfirmTitle => 'Remove photo?';

  @override
  String get avatarRemoveConfirmBody => 'This action cannot be undone.';

  @override
  String get editModeBanner => 'Editing';

  @override
  String get detailSheetInfoTooltip => 'Details';

  @override
  String get detailSheetProficiencies => 'Proficiencies';

  @override
  String get detailSheetTraits => 'Traits';

  @override
  String get detailSheetSubclassFeaturePlaceholder => 'Subclass Feature';

  @override
  String detailSheetAvailableSubclasses(String feature) {
    return 'Available $feature';
  }

  @override
  String get detailSheetAvailableSubraces => 'Subraces';

  @override
  String get xpTrackingLabel => 'Track XP';

  @override
  String get xpReadyToLevelUp => 'Ready to level up!';

  @override
  String get xpLevelUpNowTitle => 'Level Up?';

  @override
  String xpLevelUpNowMessage(int level) {
    return 'You have enough XP to reach Level $level. Level up now?';
  }

  @override
  String get xpLevelUpLater => 'Later';

  @override
  String get settingsSectionUnits => 'Units';

  @override
  String get settingsUnitSystem => 'Unit system';

  @override
  String get settingsUnitImperial => 'Imperial (ft / lb)';

  @override
  String get settingsUnitMetric => 'Metric (m / kg)';

  @override
  String get settingsUnitSquares => 'Squares (sq / kg)';

  @override
  String get settingsChooseUnitSystem => 'Choose Unit System';
}
