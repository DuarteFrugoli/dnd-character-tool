import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// The application title.
  ///
  /// In en, this message translates to:
  /// **'D&D Character Tool'**
  String get appTitle;

  /// AppBar title on the character list screen.
  ///
  /// In en, this message translates to:
  /// **'D&D Characters'**
  String get charListTitle;

  /// Tooltip for import button.
  ///
  /// In en, this message translates to:
  /// **'Import JSON'**
  String get charListImportTooltip;

  /// Tooltip for settings button.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get charListSettingsTooltip;

  /// FAB label.
  ///
  /// In en, this message translates to:
  /// **'New Character'**
  String get charListNewCharacter;

  /// Empty state headline.
  ///
  /// In en, this message translates to:
  /// **'No characters yet'**
  String get charListEmpty;

  /// Empty state subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first character'**
  String get charListEmptyHint;

  /// Snackbar after successful import.
  ///
  /// In en, this message translates to:
  /// **'{name} imported successfully!'**
  String charListImportedSuccess(String name);

  /// Generic import error snackbar.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error while importing. Please try again.'**
  String get charListImportError;

  /// Level label on character card subtitle.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String charCardLevel(int level);

  /// Popup menu item.
  ///
  /// In en, this message translates to:
  /// **'Pin to top'**
  String get charCardPin;

  /// Popup menu item.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get charCardUnpin;

  /// Popup menu item.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get charCardChangePhoto;

  /// Popup menu item.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get charCardRename;

  /// Popup menu item.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get charCardExport;

  /// Popup menu item.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get charCardDelete;

  /// Rename dialog title.
  ///
  /// In en, this message translates to:
  /// **'Rename character'**
  String get renameDialogTitle;

  /// Text field label in rename dialog.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get renameDialogLabel;

  /// Generic cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// Generic save button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get dialogSave;

  /// Delete confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete character?'**
  String get deleteDialogTitle;

  /// Delete confirmation dialog body.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}? This cannot be undone.'**
  String deleteDialogContent(String name);

  /// Generic confirm button.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dialogConfirm;

  /// Generic discard button.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get dialogDiscard;

  /// Generic continue button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get dialogContinue;

  /// Generic keep editing button.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get dialogKeepEditing;

  /// Generic remove button.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get dialogRemove;

  /// Generic add button.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get dialogAdd;

  /// Settings screen AppBar title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings section header for themes.
  ///
  /// In en, this message translates to:
  /// **'Visual Theme'**
  String get settingsSectionTheme;

  /// Dark brightness label.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsDark;

  /// Light brightness label.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsLight;

  /// Theme picker bottom sheet title.
  ///
  /// In en, this message translates to:
  /// **'Choose a Theme'**
  String get settingsChooseTheme;

  /// Settings section header for language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsSectionLanguage;

  /// Language tile title.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsAppLanguage;

  /// Language picker bottom sheet title.
  ///
  /// In en, this message translates to:
  /// **'Choose a Language'**
  String get settingsChooseLanguage;

  /// System default locale option.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsSystemDefault;

  /// Mode selection screen AppBar title.
  ///
  /// In en, this message translates to:
  /// **'New Character'**
  String get modeSelectionTitle;

  /// Mode selection prompt.
  ///
  /// In en, this message translates to:
  /// **'How do you want to create your character?'**
  String get modeSelectionQuestion;

  /// Guided creation mode title.
  ///
  /// In en, this message translates to:
  /// **'Guided'**
  String get modeGuidedTitle;

  /// Guided creation mode description.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step wizard. Choose class, race, background, skills and attributes one at a time. Recommended for new players.'**
  String get modeGuidedSubtitle;

  /// Manual creation mode title.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get modeManualTitle;

  /// Manual creation mode description.
  ///
  /// In en, this message translates to:
  /// **'Fill in everything yourself. All fields are free and no values are calculated for you. Best for experienced players.'**
  String get modeManualSubtitle;

  /// Random creation mode title.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get modeRandomTitle;

  /// Random creation mode description.
  ///
  /// In en, this message translates to:
  /// **'Everything is rolled for you — race, class, background and attributes. Great for a challenge or one-shots.'**
  String get modeRandomSubtitle;

  /// Semi-random creation mode title.
  ///
  /// In en, this message translates to:
  /// **'Semi-random'**
  String get modeSemiRandomTitle;

  /// Semi-random creation mode description.
  ///
  /// In en, this message translates to:
  /// **'You pick the important choices; everything else is rolled. Good for when you have a concept but want surprises.'**
  String get modeSemiRandomSubtitle;

  /// Coming soon chip label.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get modeComingSoon;

  /// Step title for class selection.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get creationStepClass;

  /// Step title for race selection.
  ///
  /// In en, this message translates to:
  /// **'Race'**
  String get creationStepRace;

  /// Step title for background selection.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get creationStepBackground;

  /// Step title for skill selection.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get creationStepSkills;

  /// Step title for attribute assignment.
  ///
  /// In en, this message translates to:
  /// **'Attributes'**
  String get creationStepAttributes;

  /// Step title for naming the character.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get creationStepName;

  /// Step title for review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get creationStepReview;

  /// Discard creation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Discard character?'**
  String get creationDiscardTitle;

  /// Discard creation dialog body.
  ///
  /// In en, this message translates to:
  /// **'All progress will be lost. Are you sure?'**
  String get creationDiscardContent;

  /// Cancel creation tooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get creationTooltipCancel;

  /// Back button in creation wizard.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get creationBack;

  /// Final step button.
  ///
  /// In en, this message translates to:
  /// **'Create Character'**
  String get creationCreateCharacter;

  /// Dialog title when leaving edit mode with unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'Leave without saving?'**
  String get detailLeaveWithoutSaving;

  /// Dialog body when leaving with unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'Changes will be discarded. To save, use the ✓ button at the top right.'**
  String get detailChangesWillBeDiscarded;

  /// Button to leave and discard changes.
  ///
  /// In en, this message translates to:
  /// **'Leave and discard'**
  String get detailLeaveAndDiscard;

  /// Error state body.
  ///
  /// In en, this message translates to:
  /// **'Error loading character: {error}'**
  String detailErrorLoading(String error);

  /// Long rest icon button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Long Rest'**
  String get detailTooltipLongRest;

  /// Cancel edit icon button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel editing'**
  String get detailTooltipCancelEdit;

  /// Done editing icon button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Done editing'**
  String get detailTooltipDoneEditing;

  /// Edit character icon button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit character'**
  String get detailTooltipEditCharacter;

  /// Cancel edit dialog title.
  ///
  /// In en, this message translates to:
  /// **'Cancel editing?'**
  String get detailCancelEditTitle;

  /// Cancel edit dialog body.
  ///
  /// In en, this message translates to:
  /// **'All changes will be discarded.'**
  String get detailCancelEditContent;

  /// Finish edit dialog title.
  ///
  /// In en, this message translates to:
  /// **'Finish editing?'**
  String get detailFinishEditTitle;

  /// Finish edit dialog body.
  ///
  /// In en, this message translates to:
  /// **'Changes will be saved.'**
  String get detailFinishEditContent;

  /// Stats tab label.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get detailTabStats;

  /// Skills tab label.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get detailTabSkills;

  /// Features tab label.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get detailTabFeatures;

  /// Spells tab label.
  ///
  /// In en, this message translates to:
  /// **'Spells'**
  String get detailTabSpells;

  /// Inventory tab label.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get detailTabInventory;

  /// Notes tab label.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get detailTabNotes;

  /// Long rest dialog title.
  ///
  /// In en, this message translates to:
  /// **'Long Rest'**
  String get longRestTitle;

  /// Long rest dialog body.
  ///
  /// In en, this message translates to:
  /// **'Restore HP to maximum and recover all spell slots?'**
  String get longRestContent;

  /// Long rest confirm button.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get longRestButton;

  /// Stats tab identity section title.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get sectionIdentity;

  /// Stats tab hit points section title.
  ///
  /// In en, this message translates to:
  /// **'Hit Points'**
  String get sectionHitPoints;

  /// Stats tab combat section title.
  ///
  /// In en, this message translates to:
  /// **'Combat'**
  String get sectionCombat;

  /// Stats tab ability scores section title.
  ///
  /// In en, this message translates to:
  /// **'Ability Scores'**
  String get sectionAbilityScores;

  /// Stats tab saving throws section title.
  ///
  /// In en, this message translates to:
  /// **'Saving Throw Proficiencies'**
  String get sectionSavingThrows;

  /// Name field label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get labelName;

  /// Background field label.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get labelBackground;

  /// Change button label.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get labelChange;

  /// Alignment field label.
  ///
  /// In en, this message translates to:
  /// **'Alignment'**
  String get labelAlignment;

  /// Player name field label.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get labelPlayer;

  /// Level field label.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get labelLevel;

  /// Subclass field label.
  ///
  /// In en, this message translates to:
  /// **'Subclass'**
  String get labelSubclass;

  /// Languages field label.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get labelLanguages;

  /// Language input hint.
  ///
  /// In en, this message translates to:
  /// **'Add language…'**
  String get hintAddLanguage;

  /// Choose button label.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get labelChoose;

  /// Max HP inline field label.
  ///
  /// In en, this message translates to:
  /// **'Max HP'**
  String get labelMaxHP;

  /// Temporary HP field label.
  ///
  /// In en, this message translates to:
  /// **'Temp HP'**
  String get labelTempHP;

  /// Amount field label for HP tracker.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get labelAmount;

  /// Speed inline field label.
  ///
  /// In en, this message translates to:
  /// **'Speed (ft)'**
  String get labelSpeed;

  /// Damage button in HP tracker.
  ///
  /// In en, this message translates to:
  /// **'Damage'**
  String get detailDamage;

  /// Heal button in HP tracker.
  ///
  /// In en, this message translates to:
  /// **'Heal'**
  String get detailHeal;

  /// None placeholder (e.g. no concentration spell).
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get detailNone;

  /// Temp HP dialog title when no temp HP.
  ///
  /// In en, this message translates to:
  /// **'Add Temporary HP'**
  String get tempHpDialogTitle;

  /// Temp HP dialog title when temp HP exists.
  ///
  /// In en, this message translates to:
  /// **'Temporary HP'**
  String get tempHpDialogTitleReplace;

  /// Current temp HP display.
  ///
  /// In en, this message translates to:
  /// **'Current: +{n} temp HP'**
  String tempHpCurrent(int n);

  /// Temp HP stacking note.
  ///
  /// In en, this message translates to:
  /// **'Temp HP doesn\'t stack — only higher values replace the current.'**
  String get tempHpNoStack;

  /// Replace temp HP button.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get tempHpReplace;

  /// Subclass dialog title when confirming existing choice.
  ///
  /// In en, this message translates to:
  /// **'Confirm {feature}'**
  String subclassConfirmTitle(String feature);

  /// Subclass dialog title when choosing for the first time.
  ///
  /// In en, this message translates to:
  /// **'Choose {feature}'**
  String subclassChooseTitle(String feature);

  /// Subclass confirm dialog body.
  ///
  /// In en, this message translates to:
  /// **'You reached level {level}. Confirm or change your {feature}.'**
  String subclassConfirmBody(int level, String feature);

  /// Subclass choose dialog body.
  ///
  /// In en, this message translates to:
  /// **'You reached level {level}! Choose your {feature}.'**
  String subclassChooseBody(int level, String feature);

  /// Keep current subclass button.
  ///
  /// In en, this message translates to:
  /// **'Keep current'**
  String get subclassKeepCurrent;

  /// Change subclass warning dialog title.
  ///
  /// In en, this message translates to:
  /// **'Change subclass'**
  String get subclassChangeTitle;

  /// Change subclass warning dialog body.
  ///
  /// In en, this message translates to:
  /// **'Warning: spells and proficiencies granted by the previous subclass are not removed automatically. You will need to adjust them manually.'**
  String get subclassChangeWarning;

  /// Background picker dialog title.
  ///
  /// In en, this message translates to:
  /// **'Choose Background'**
  String get backgroundChooseTitle;

  /// Add feature FAB tooltip.
  ///
  /// In en, this message translates to:
  /// **'Add feature'**
  String get featuresTooltipAdd;

  /// Remove feature tooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get featuresTooltipRemove;

  /// Remove feature dialog title.
  ///
  /// In en, this message translates to:
  /// **'Remove feature?'**
  String get featuresRemoveTitle;

  /// Remove feature dialog body.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be removed.'**
  String featuresRemoveContent(String name);

  /// Empty state for features.
  ///
  /// In en, this message translates to:
  /// **'No features available.'**
  String get featuresNoneAvailable;

  /// Add feature FAB label.
  ///
  /// In en, this message translates to:
  /// **'Add Feature'**
  String get featuresAddLabel;

  /// Features tab error state.
  ///
  /// In en, this message translates to:
  /// **'Error loading features.'**
  String get featuresLoadError;

  /// Generic search hint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get hintSearch;

  /// Feature name field label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get labelFeatureName;

  /// Feature description field label.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get labelFeatureDescription;

  /// Feature type label.
  ///
  /// In en, this message translates to:
  /// **'Type:'**
  String get labelFeatureType;

  /// Passive feature type.
  ///
  /// In en, this message translates to:
  /// **'Passive'**
  String get labelPassive;

  /// Active feature type.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get labelActive;

  /// Add spell button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Add spell'**
  String get spellsTooltipAdd;

  /// Remove spell dialog title.
  ///
  /// In en, this message translates to:
  /// **'Remove spell?'**
  String get spellsRemoveTitle;

  /// Remove spell dialog body.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from your spell list?'**
  String spellsRemoveContent(String name);

  /// At-will spell slot label.
  ///
  /// In en, this message translates to:
  /// **'At will'**
  String get spellsAtWill;

  /// Add note FAB tooltip.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get notesTooltipAdd;

  /// Edit note tooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get notesTooltipEdit;

  /// Delete note tooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get notesTooltipDelete;

  /// Delete note dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete note?'**
  String get notesDeleteTitle;

  /// Delete note dialog body when note has a title.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be permanently deleted.'**
  String notesDeleteContentNamed(String title);

  /// Delete note dialog body when note has no title.
  ///
  /// In en, this message translates to:
  /// **'This note will be permanently deleted.'**
  String get notesDeleteContent;

  /// Note title field label.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get notesLabelTitle;

  /// Note content field label.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get notesLabelContent;

  /// Notes tab personality traits section.
  ///
  /// In en, this message translates to:
  /// **'Personality Traits'**
  String get sectionPersonalityTraits;

  /// Notes tab ideals section.
  ///
  /// In en, this message translates to:
  /// **'Ideals'**
  String get sectionIdeals;

  /// Notes tab bonds section.
  ///
  /// In en, this message translates to:
  /// **'Bonds'**
  String get sectionBonds;

  /// Notes tab flaws section.
  ///
  /// In en, this message translates to:
  /// **'Flaws'**
  String get sectionFlaws;

  /// Notes tab backstory section.
  ///
  /// In en, this message translates to:
  /// **'Backstory'**
  String get sectionBackstory;

  /// Equipped items section title.
  ///
  /// In en, this message translates to:
  /// **'Equipped ({count})  ·  AC {ac}'**
  String inventoryEquippedSection(int count, int ac);

  /// Add item FAB tooltip.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get inventoryTooltipAdd;

  /// Remove item tooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get inventoryTooltipRemove;

  /// Remove item dialog title.
  ///
  /// In en, this message translates to:
  /// **'Remove item?'**
  String get inventoryRemoveTitle;

  /// Remove item dialog body (single).
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from inventory?'**
  String inventoryRemoveContent(String name);

  /// Partial removal display.
  ///
  /// In en, this message translates to:
  /// **'Will remove: {count} of {total}'**
  String inventoryRemovePartial(int count, int total);

  /// Quantity label in item dialog.
  ///
  /// In en, this message translates to:
  /// **'Quantity:'**
  String get inventoryLabelQuantity;

  /// Quantity to remove field label.
  ///
  /// In en, this message translates to:
  /// **'Quantity to remove'**
  String get inventoryLabelQuantityToRemove;

  /// Add custom item button.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Item'**
  String get inventoryAddCustomItem;

  /// Add item browser title.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get inventoryAddItem;

  /// Custom item name field label.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get inventoryLabelItemName;

  /// Custom item type field label.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get inventoryLabelType;

  /// Custom item category field label.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get inventoryLabelCategory;

  /// Custom item quantity field label.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get inventoryLabelItemQuantity;

  /// Custom item description field label.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get inventoryLabelDescription;

  /// Item type: weapon.
  ///
  /// In en, this message translates to:
  /// **'Weapon'**
  String get inventoryTypeWeapon;

  /// Item type: armor.
  ///
  /// In en, this message translates to:
  /// **'Armor'**
  String get inventoryTypeArmor;

  /// Item type: consumable.
  ///
  /// In en, this message translates to:
  /// **'Consumable'**
  String get inventoryTypeConsumable;

  /// Item type: gear.
  ///
  /// In en, this message translates to:
  /// **'Gear'**
  String get inventoryTypeGear;

  /// Replace armor confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Replace equipped armor?'**
  String get inventoryReplaceArmorTitle;

  /// Inventory browser weapons tab.
  ///
  /// In en, this message translates to:
  /// **'Weapons'**
  String get inventoryTabWeapons;

  /// Inventory browser armor tab.
  ///
  /// In en, this message translates to:
  /// **'Armor'**
  String get inventoryTabArmor;

  /// Inventory browser gear tab.
  ///
  /// In en, this message translates to:
  /// **'Gear'**
  String get inventoryTabGear;

  /// Inventory browser magic tab.
  ///
  /// In en, this message translates to:
  /// **'Magic'**
  String get inventoryTabMagic;

  /// Inventory browser custom tab.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get inventoryTabCustom;

  /// Search hint with category name.
  ///
  /// In en, this message translates to:
  /// **'Search {category}...'**
  String hintSearchCategory(String category);

  /// Attributes step method selector label.
  ///
  /// In en, this message translates to:
  /// **'Choose your method:'**
  String get stepChooseMethod;

  /// Standard Array method chip.
  ///
  /// In en, this message translates to:
  /// **'Standard Array'**
  String get stepStandardArray;

  /// Point Buy method chip.
  ///
  /// In en, this message translates to:
  /// **'Point Buy'**
  String get stepPointBuy;

  /// Roll 4d6 method chip.
  ///
  /// In en, this message translates to:
  /// **'Roll 4d6'**
  String get stepRoll4d6;

  /// Tasha's optional rule switch label.
  ///
  /// In en, this message translates to:
  /// **'Distribute racial bonuses freely'**
  String get stepDistributeRacialBonuses;

  /// Rolled dice assignment label.
  ///
  /// In en, this message translates to:
  /// **'Assign each roll to an attribute:'**
  String get stepAssignRolls;

  /// Standard array assignment label.
  ///
  /// In en, this message translates to:
  /// **'Assign each value to one attribute:'**
  String get stepAssignValues;

  /// Point buy remaining points label.
  ///
  /// In en, this message translates to:
  /// **'Points remaining: '**
  String get stepPointsRemaining;

  /// Race ASI bonus label.
  ///
  /// In en, this message translates to:
  /// **'+{n} race'**
  String stepRaceBonus(int n);

  /// Subrace selector label.
  ///
  /// In en, this message translates to:
  /// **'Choose a subrace:'**
  String get stepChooseSubrace;

  /// Background skill grant label.
  ///
  /// In en, this message translates to:
  /// **'Granted by background:'**
  String get stepGrantedByBackground;

  /// Class skill choices label.
  ///
  /// In en, this message translates to:
  /// **'Class skill choices ({count}):'**
  String stepClassSkillChoices(int count);

  /// Generic choose one dropdown hint.
  ///
  /// In en, this message translates to:
  /// **'Choose one'**
  String get stepChooseOne;

  /// Tool proficiency dropdown hint.
  ///
  /// In en, this message translates to:
  /// **'Select a tool…'**
  String get stepSelectTool;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
