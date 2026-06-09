import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
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

  /// Import error: pasted JSON is not valid.
  ///
  /// In en, this message translates to:
  /// **'The pasted JSON is not valid.'**
  String get importErrorInvalidJson;

  /// Import error: the token is not valid.
  ///
  /// In en, this message translates to:
  /// **'Invalid token. It may be corrupted or from an incompatible version.'**
  String get importErrorInvalidToken;

  /// Hint shown when tapping a disabled input field during import.
  ///
  /// In en, this message translates to:
  /// **'Clear the other field to use this one.'**
  String get importFieldLockedHint;

  /// Import error: expected object.
  ///
  /// In en, this message translates to:
  /// **'Invalid format: expected a JSON object.'**
  String get importErrorNotObject;

  /// Import error: missing character field.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON: \'character\' field not found.'**
  String get importErrorMissingCharacter;

  /// Import error: character field corrupted.
  ///
  /// In en, this message translates to:
  /// **'Could not read character. The JSON may be incomplete or from an incompatible version.'**
  String get importErrorCorruptedCharacter;

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

  /// Generic done button.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get dialogDone;

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

  /// Identity tab label.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get detailTabIdentity;

  /// Edit mode toggle button label.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get detailEditButton;

  /// Skills long-press hint text.
  ///
  /// In en, this message translates to:
  /// **'Hold to toggle: none → proficient → expert'**
  String get skillsEditHint;

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

  /// Rest type picker title.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get restPickerTitle;

  /// Short rest option label.
  ///
  /// In en, this message translates to:
  /// **'Short Rest'**
  String get restPickerShort;

  /// Short rest option caption.
  ///
  /// In en, this message translates to:
  /// **'Spend Hit Dice to recover HP'**
  String get restPickerShortCaption;

  /// Long rest option label.
  ///
  /// In en, this message translates to:
  /// **'Long Rest'**
  String get restPickerLong;

  /// Long rest option caption.
  ///
  /// In en, this message translates to:
  /// **'Full HP and spell slot recovery'**
  String get restPickerLongCaption;

  /// Short rest dialog title.
  ///
  /// In en, this message translates to:
  /// **'Short Rest'**
  String get shortRestTitle;

  /// Short rest dialog available HD label.
  ///
  /// In en, this message translates to:
  /// **'Available Hit Dice'**
  String get shortRestAvailableDice;

  /// Short rest dialog spend label.
  ///
  /// In en, this message translates to:
  /// **'Spend'**
  String get shortRestSpend;

  /// Short rest dialog HP result label.
  ///
  /// In en, this message translates to:
  /// **'HP recovered'**
  String get shortRestRolled;

  /// Short rest roll dice button.
  ///
  /// In en, this message translates to:
  /// **'Roll'**
  String get shortRestRollButton;

  /// Short rest confirm button.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get shortRestButton;

  /// Short rest: no HD available message.
  ///
  /// In en, this message translates to:
  /// **'No Hit Dice remaining'**
  String get shortRestNoDice;

  /// Concentration banner prefix label.
  ///
  /// In en, this message translates to:
  /// **'Concentrating on:'**
  String get concentrationBannerLabel;

  /// Button to break concentration.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get concentrationBreakButton;

  /// Dialog title when replacing active concentration.
  ///
  /// In en, this message translates to:
  /// **'Replace Concentration?'**
  String get concentrationReplaceTitle;

  /// Dialog body when replacing concentration.
  ///
  /// In en, this message translates to:
  /// **'You are concentrating on {current}. Starting {next} will end your concentration.'**
  String concentrationReplaceBody(String current, String next);

  /// Confirm button to replace concentration.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get concentrationReplaceConfirm;

  /// Tooltip for the concentration icon button on a spell card.
  ///
  /// In en, this message translates to:
  /// **'Set concentration'**
  String get concentrationTooltip;

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

  /// Stats tab XP/progression section title.
  ///
  /// In en, this message translates to:
  /// **'Progression'**
  String get sectionProgression;

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

  /// Warning shown near the manual level control in edit mode.
  ///
  /// In en, this message translates to:
  /// **'Only features and spell slots are updated automatically. For a full level up (HP, ability scores, feats, spell choices), use the Level Up button in the top bar.'**
  String get levelManualChangeWarning;

  /// Tooltip for the Level Up button in the AppBar.
  ///
  /// In en, this message translates to:
  /// **'Level Up'**
  String get tooltipLevelUp;

  /// Level Up wizard bottom sheet title.
  ///
  /// In en, this message translates to:
  /// **'Level Up'**
  String get levelUpTitle;

  /// Level Up wizard confirm button.
  ///
  /// In en, this message translates to:
  /// **'Confirm Level Up'**
  String get levelUpConfirm;

  /// Level Up wizard cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get levelUpCancel;

  /// Level Up wizard step: new features.
  ///
  /// In en, this message translates to:
  /// **'New Features'**
  String get levelUpStepFeatures;

  /// Level Up wizard step: subclass.
  ///
  /// In en, this message translates to:
  /// **'Choose {feature}'**
  String levelUpStepSubclass(String feature);

  /// Level Up wizard step: ASI.
  ///
  /// In en, this message translates to:
  /// **'Ability Score Improvement'**
  String get levelUpStepAsi;

  /// Level Up wizard step: HP.
  ///
  /// In en, this message translates to:
  /// **'Hit Points'**
  String get levelUpStepHp;

  /// Level Up wizard step: cantrips.
  ///
  /// In en, this message translates to:
  /// **'New Cantrips'**
  String get levelUpStepCantrips;

  /// Level Up wizard step: spells.
  ///
  /// In en, this message translates to:
  /// **'New Spells'**
  String get levelUpStepSpells;

  /// Level Up wizard step: summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get levelUpStepSummary;

  /// Level Up wizard: no features message.
  ///
  /// In en, this message translates to:
  /// **'No new class features at this level.'**
  String get levelUpNoNewFeatures;

  /// Level Up wizard HP: roll button.
  ///
  /// In en, this message translates to:
  /// **'Roll'**
  String get levelUpHpRoll;

  /// Level Up wizard HP: average button.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get levelUpHpAverage;

  /// Level Up wizard HP gained label.
  ///
  /// In en, this message translates to:
  /// **'+{n} HP'**
  String levelUpHpGained(int n);

  /// Level Up wizard HP formula hint.
  ///
  /// In en, this message translates to:
  /// **'d{die} + CON ({mod})'**
  String levelUpHpFormula(int die, String mod);

  /// Level Up wizard ASI: ASI option label.
  ///
  /// In en, this message translates to:
  /// **'Ability Score Improvement'**
  String get levelUpAsiOption;

  /// Level Up wizard ASI: feat option label.
  ///
  /// In en, this message translates to:
  /// **'Choose a Feat'**
  String get levelUpFeatOption;

  /// Level Up wizard ASI: points remaining.
  ///
  /// In en, this message translates to:
  /// **'{n} point(s) remaining'**
  String levelUpAsiPointsLeft(int n);

  /// Level Up wizard spells: how many to pick.
  ///
  /// In en, this message translates to:
  /// **'Choose {n} spell(s) to learn'**
  String levelUpSpellsToLearn(int n);

  /// Level Up wizard cantrips: how many to pick.
  ///
  /// In en, this message translates to:
  /// **'Choose {n} cantrip(s)'**
  String levelUpCantripsToLearn(int n);

  /// Level Up wizard: Warlock spell swap section.
  ///
  /// In en, this message translates to:
  /// **'Replace a known spell (optional)'**
  String get levelUpSpellSwap;

  /// Level Up wizard: currently swapped spell label.
  ///
  /// In en, this message translates to:
  /// **'Currently: {name}'**
  String levelUpSpellSwapCurrent(String name);

  /// Level Up summary: new level.
  ///
  /// In en, this message translates to:
  /// **'→ Level {level}'**
  String levelUpSummaryLevel(int level);

  /// Level Up summary: HP gained.
  ///
  /// In en, this message translates to:
  /// **'Max HP +{n}'**
  String levelUpSummaryHp(int n);

  /// Level Up summary: ASI changes.
  ///
  /// In en, this message translates to:
  /// **'ASI: {changes}'**
  String levelUpSummaryAsi(String changes);

  /// Level Up summary: feat chosen.
  ///
  /// In en, this message translates to:
  /// **'Feat: {name}'**
  String levelUpSummaryFeat(String name);

  /// Level Up summary: subclass chosen.
  ///
  /// In en, this message translates to:
  /// **'Subclass: {name}'**
  String levelUpSummarySubclass(String name);

  /// Level Up summary: spells learned.
  ///
  /// In en, this message translates to:
  /// **'Spells learned: {count}'**
  String levelUpSummarySpellsLearned(int count);

  /// Level Up summary: cantrips learned.
  ///
  /// In en, this message translates to:
  /// **'Cantrips learned: {count}'**
  String levelUpSummaryCantripsLearned(int count);

  /// Level Up subclass step: warning when character already has a subclass.
  ///
  /// In en, this message translates to:
  /// **'Current subclass: {name}'**
  String levelUpSubclassAlreadyHas(String name);

  /// Level Up: shown when character is already level 20.
  ///
  /// In en, this message translates to:
  /// **'Already at maximum level (20).'**
  String get levelUpMaxLevel;

  /// Level Up HP step: reroll button label.
  ///
  /// In en, this message translates to:
  /// **'Reroll / change'**
  String get levelUpHpReroll;

  /// Level Up spell swap: no swap option.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get levelUpSpellSwapNone;

  /// Level Up spell pick: tooltip for already-known spells.
  ///
  /// In en, this message translates to:
  /// **'Already known'**
  String get levelUpSpellAlreadyKnown;

  /// Level Up cantrip subtitle.
  ///
  /// In en, this message translates to:
  /// **'{school} cantrip'**
  String levelUpSpellCantripSubtitle(String school);

  /// Level Up spell subtitle.
  ///
  /// In en, this message translates to:
  /// **'Lv {level} {school}'**
  String levelUpSpellSubtitle(int level, String school);

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

  /// Identity tab appearance section title.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// Appearance age field label.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get labelAge;

  /// Appearance height field label.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get labelHeight;

  /// Appearance weight field label.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get labelWeight;

  /// Appearance eye color field label.
  ///
  /// In en, this message translates to:
  /// **'Eyes'**
  String get labelEyes;

  /// Appearance skin color field label.
  ///
  /// In en, this message translates to:
  /// **'Skin'**
  String get labelSkin;

  /// Appearance hair color field label.
  ///
  /// In en, this message translates to:
  /// **'Hair'**
  String get labelHair;

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

  /// Temporary HP chip label in HP row.
  ///
  /// In en, this message translates to:
  /// **'+{n} temp'**
  String statsTempHpChip(int n);

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

  /// Enable feature tooltip.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get featuresTooltipEnable;

  /// Disable feature tooltip.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get featuresTooltipDisable;

  /// Add feature sheet: Feats tab label.
  ///
  /// In en, this message translates to:
  /// **'Feats'**
  String get featuresTabFeats;

  /// Feat prerequisite label.
  ///
  /// In en, this message translates to:
  /// **'Prerequisite: {req}'**
  String featPrerequisite(String req);

  /// Feats section header in Features tab.
  ///
  /// In en, this message translates to:
  /// **'Feats'**
  String get featuresSectionFeats;

  /// Add feature sheet: Class tab label.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get featuresTabClass;

  /// Add feature sheet: Racial tab label.
  ///
  /// In en, this message translates to:
  /// **'Racial'**
  String get featuresTabRacial;

  /// Add feature sheet: Custom tab label.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get featuresTabCustom;

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

  /// Notes tab empty state title.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get notesEmptyTitle;

  /// Notes tab empty state subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first note.'**
  String get notesEmptyHint;

  /// Default title for a note with no title.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get notesUntitled;

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

  /// Personality section header.
  ///
  /// In en, this message translates to:
  /// **'Personality'**
  String get sectionPersonality;

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

  /// Custom item weight field label (in lb).
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get inventoryLabelWeight;

  /// Weight tracking: label for current carried weight.
  ///
  /// In en, this message translates to:
  /// **'Carried'**
  String get weightCarried;

  /// Weight tracking: label for max carry capacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get weightCapacity;

  /// Weight tracking: encumbered status label.
  ///
  /// In en, this message translates to:
  /// **'Encumbered'**
  String get weightEncumbered;

  /// Weight tracking: heavily encumbered status label.
  ///
  /// In en, this message translates to:
  /// **'Heavily Encumbered'**
  String get weightHeavilyEncumbered;

  /// Tooltip for the weight tracking toggle button.
  ///
  /// In en, this message translates to:
  /// **'Enable weight tracking'**
  String get weightEnableTooltip;

  /// Tooltip for the weight tracking disable button.
  ///
  /// In en, this message translates to:
  /// **'Disable weight tracking'**
  String get weightDisableTooltip;

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

  /// Inventory browser tools tab.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get inventoryTabTools;

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

  /// Armor Class stat chip label.
  ///
  /// In en, this message translates to:
  /// **'AC'**
  String get statAC;

  /// Armor stat chip label.
  ///
  /// In en, this message translates to:
  /// **'Armor'**
  String get statArmor;

  /// Armor summary when no armor equipped.
  ///
  /// In en, this message translates to:
  /// **'No armor'**
  String get statNoArmor;

  /// Armor summary when only shield equipped.
  ///
  /// In en, this message translates to:
  /// **'No armor + Shield'**
  String get statNoArmorShield;

  /// Shield suffix appended to armor name.
  ///
  /// In en, this message translates to:
  /// **' + Shield'**
  String get statShieldSuffix;

  /// Speed stat chip label.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get statSpeed;

  /// Initiative stat chip label.
  ///
  /// In en, this message translates to:
  /// **'Initiative'**
  String get statInitiative;

  /// Proficiency bonus stat chip label.
  ///
  /// In en, this message translates to:
  /// **'Prof Bonus'**
  String get statProfBonus;

  /// Passive perception stat chip label.
  ///
  /// In en, this message translates to:
  /// **'Passive Perc'**
  String get statPassivePerc;

  /// Inspiration toggle label.
  ///
  /// In en, this message translates to:
  /// **'Inspiration'**
  String get statInspiration;

  /// Experience points label.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get statXP;

  /// Inspiration active subtitle.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get inspirationGranted;

  /// Inspiration inactive subtitle.
  ///
  /// In en, this message translates to:
  /// **'Not granted'**
  String get inspirationNotGranted;

  /// Level label with number.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String statLevel(int level);

  /// Add XP quick-action button.
  ///
  /// In en, this message translates to:
  /// **'Add XP'**
  String get tooltipAddXp;

  /// Level/XP table toggle label.
  ///
  /// In en, this message translates to:
  /// **'Level Table'**
  String get labelLevelTable;

  /// Status label when HP reaches 0.
  ///
  /// In en, this message translates to:
  /// **'Unconscious / Dying'**
  String get statUnconsciousDying;

  /// Death saves section header in Stats tab.
  ///
  /// In en, this message translates to:
  /// **'Death Saves'**
  String get deathSavesTitle;

  /// Death save successes label.
  ///
  /// In en, this message translates to:
  /// **'Successes'**
  String get deathSavesSuccesses;

  /// Death save failures label.
  ///
  /// In en, this message translates to:
  /// **'Failures'**
  String get deathSavesFailures;

  /// Message when 3 death save successes are reached.
  ///
  /// In en, this message translates to:
  /// **'Stabilized'**
  String get deathSavesStabilized;

  /// Message when 3 death save failures are reached.
  ///
  /// In en, this message translates to:
  /// **'Dead'**
  String get deathSavesDead;

  /// Stats tab active conditions section title.
  ///
  /// In en, this message translates to:
  /// **'Active Conditions'**
  String get sectionActiveConditions;

  /// Shown when no conditions are active.
  ///
  /// In en, this message translates to:
  /// **'None active'**
  String get conditionsNone;

  /// Tooltip/button to open condition picker.
  ///
  /// In en, this message translates to:
  /// **'Add condition'**
  String get conditionsAdd;

  /// Title of the condition picker bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Apply Condition'**
  String get conditionsPickTitle;

  /// Button to remove an active condition.
  ///
  /// In en, this message translates to:
  /// **'Remove condition'**
  String get conditionsRemove;

  /// Temp HP button tooltip when none.
  ///
  /// In en, this message translates to:
  /// **'Add temp HP'**
  String get tooltipAddTempHp;

  /// Temp HP button tooltip when some exists.
  ///
  /// In en, this message translates to:
  /// **'Change temp HP'**
  String get tooltipChangeTempHp;

  /// Strength abbreviation.
  ///
  /// In en, this message translates to:
  /// **'STR'**
  String get abilityStr;

  /// Dexterity abbreviation.
  ///
  /// In en, this message translates to:
  /// **'DEX'**
  String get abilityDex;

  /// Constitution abbreviation.
  ///
  /// In en, this message translates to:
  /// **'CON'**
  String get abilityCon;

  /// Intelligence abbreviation.
  ///
  /// In en, this message translates to:
  /// **'INT'**
  String get abilityInt;

  /// Wisdom abbreviation.
  ///
  /// In en, this message translates to:
  /// **'WIS'**
  String get abilityWis;

  /// Charisma abbreviation.
  ///
  /// In en, this message translates to:
  /// **'CHA'**
  String get abilityCha;

  /// Features tab racial traits section header.
  ///
  /// In en, this message translates to:
  /// **'Racial Traits — {name}'**
  String featuresSectionRacialTraits(String name);

  /// Features tab background feature section header.
  ///
  /// In en, this message translates to:
  /// **'Background Feature — {name}'**
  String featuresSectionBackground(String name);

  /// Features tab class features section header.
  ///
  /// In en, this message translates to:
  /// **'Class Features — {name}'**
  String featuresSectionClass(String name);

  /// Features tab subclass features section header.
  ///
  /// In en, this message translates to:
  /// **'Subclass Features — {name}'**
  String featuresSectionSubclass(String name);

  /// Features tab tool proficiencies section header.
  ///
  /// In en, this message translates to:
  /// **'Tool Proficiencies'**
  String get featuresSectionTools;

  /// Features tab extra features section header.
  ///
  /// In en, this message translates to:
  /// **'Extra Features'**
  String get featuresSectionExtra;

  /// Empty state headline when class has no spellcasting.
  ///
  /// In en, this message translates to:
  /// **'No Spellcasting'**
  String get spellsNoSpellcasting;

  /// Empty state body when class has no spellcasting.
  ///
  /// In en, this message translates to:
  /// **'This class has no spellcasting features.'**
  String get spellsNoSpellcastingDesc;

  /// Spell slots section header.
  ///
  /// In en, this message translates to:
  /// **'Spell Slots'**
  String get spellsSlots;

  /// Spellcasting banner title word.
  ///
  /// In en, this message translates to:
  /// **'Spellcasting'**
  String get spellsSpellcasting;

  /// Spell attack banner stat label.
  ///
  /// In en, this message translates to:
  /// **'Attack'**
  String get spellsAttack;

  /// Save DC banner stat label.
  ///
  /// In en, this message translates to:
  /// **'Save DC'**
  String get spellsSaveDC;

  /// Cantrips label (banner + level header).
  ///
  /// In en, this message translates to:
  /// **'Cantrips'**
  String get spellsCantrips;

  /// Prepared spells banner stat label.
  ///
  /// In en, this message translates to:
  /// **'Prepared'**
  String get spellsPrepared;

  /// Known spells banner stat label.
  ///
  /// In en, this message translates to:
  /// **'Known'**
  String get spellsKnown;

  /// Empty state when no spells added and not prepare-all.
  ///
  /// In en, this message translates to:
  /// **'No spells added yet.\nTap + to browse spells.'**
  String get spellsEmpty;

  /// Spell slot row level label.
  ///
  /// In en, this message translates to:
  /// **'Lvl {level}'**
  String spellsSlotLevel(int level);

  /// Spell list level group header.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String spellsLevelN(int level);

  /// Innate/racial spells section header.
  ///
  /// In en, this message translates to:
  /// **'Racial Spells'**
  String get spellsInnateHeader;

  /// Dialog title when disabling a spell.
  ///
  /// In en, this message translates to:
  /// **'Disable spell?'**
  String get spellsDisableTitle;

  /// Dialog title when re-enabling a spell.
  ///
  /// In en, this message translates to:
  /// **'Enable spell?'**
  String get spellsEnableTitle;

  /// Dialog body when disabling a spell.
  ///
  /// In en, this message translates to:
  /// **'Disable \"{name}\"? It will be grayed out and cannot be prepared.'**
  String spellsDisableContent(String name);

  /// Dialog body when re-enabling a spell.
  ///
  /// In en, this message translates to:
  /// **'Enable \"{name}\"? It will appear normally again.'**
  String spellsEnableContent(String name);

  /// Disable button in spell disable dialog.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get spellsDisable;

  /// Enable button in spell re-enable dialog.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get spellsEnable;

  /// Header for extra spells added to a prepare-all caster.
  ///
  /// In en, this message translates to:
  /// **'Extra Spells'**
  String get spellsExtrasHeader;

  /// Spell filter sheet title.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get spellFilterTitle;

  /// Reset filters button.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get spellFilterReset;

  /// Apply filters button.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get spellFilterApply;

  /// Filter section: classes.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get spellFilterSectionClasses;

  /// Hint below class filter chips.
  ///
  /// In en, this message translates to:
  /// **'No class selected = show all classes'**
  String get spellFilterClassesHint;

  /// Filter section: spell level.
  ///
  /// In en, this message translates to:
  /// **'Spell Level'**
  String get spellFilterSectionLevel;

  /// Switch label to show all spell levels.
  ///
  /// In en, this message translates to:
  /// **'Show all spell levels'**
  String get spellFilterShowAllLevels;

  /// Subtitle for show-all-levels switch.
  ///
  /// In en, this message translates to:
  /// **'Include spells above your current max (Lvl {max})'**
  String spellFilterShowAllLevelsHint(int max);

  /// Cantrip chip label in level filter.
  ///
  /// In en, this message translates to:
  /// **'Cantrip'**
  String get spellFilterCantrip;

  /// Spell level chip label.
  ///
  /// In en, this message translates to:
  /// **'Lvl {n}'**
  String spellFilterLvl(int n);

  /// Filter section: casting time.
  ///
  /// In en, this message translates to:
  /// **'Casting Time'**
  String get spellFilterSectionCastingTime;

  /// Casting time filter: action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get spellFilterCastAction;

  /// Casting time filter: bonus action.
  ///
  /// In en, this message translates to:
  /// **'Bonus action'**
  String get spellFilterCastBonus;

  /// Casting time filter: reaction.
  ///
  /// In en, this message translates to:
  /// **'Reaction'**
  String get spellFilterCastReaction;

  /// Casting time filter: 1+ min.
  ///
  /// In en, this message translates to:
  /// **'Longer cast (1 min+)'**
  String get spellFilterCastLonger;

  /// Filter section: spell properties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get spellFilterSectionProperties;

  /// Concentration checkbox label.
  ///
  /// In en, this message translates to:
  /// **'Concentration'**
  String get spellFilterConcentration;

  /// Concentration checkbox subtitle.
  ///
  /// In en, this message translates to:
  /// **'Only spells that require concentration'**
  String get spellFilterConcentrationHint;

  /// Ritual checkbox label.
  ///
  /// In en, this message translates to:
  /// **'Ritual'**
  String get spellFilterRitual;

  /// Ritual checkbox subtitle.
  ///
  /// In en, this message translates to:
  /// **'Only spells that can be cast as rituals'**
  String get spellFilterRitualHint;

  /// Filter section: school of magic.
  ///
  /// In en, this message translates to:
  /// **'School of Magic'**
  String get spellFilterSectionSchool;

  /// Remove spell dialog title.
  ///
  /// In en, this message translates to:
  /// **'Remove spell'**
  String get spellRemoveTitle;

  /// Remove spell dialog content.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from your spell list?'**
  String spellRemoveContent(String name);

  /// Button label: spell is prepared, tap to unprepare.
  ///
  /// In en, this message translates to:
  /// **'Prepared — tap to unprepare'**
  String get spellActionPrepared;

  /// Button label: prepare spell for today.
  ///
  /// In en, this message translates to:
  /// **'Prepare for today'**
  String get spellActionPrepare;

  /// Button label: add spell to character.
  ///
  /// In en, this message translates to:
  /// **'Add to character'**
  String get spellActionAdd;

  /// Button label: spell already in list, tap to remove.
  ///
  /// In en, this message translates to:
  /// **'In your spell list — tap to remove'**
  String get spellActionInList;

  /// Button label: spell already in list, no remove action.
  ///
  /// In en, this message translates to:
  /// **'Already in your spell list'**
  String get spellActionAlreadyInList;

  /// Info text for prepare-all class spells.
  ///
  /// In en, this message translates to:
  /// **'This spell is already part of your class list and doesn\'t need to be learned.'**
  String get spellActionClassSpellInfo;

  /// Currency card section header.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get inventoryCurrency;

  /// Carried items section title.
  ///
  /// In en, this message translates to:
  /// **'Carried ({count})'**
  String inventoryCarriedSection(int count);

  /// Equippable items (weapons/armor not yet equipped) section title.
  ///
  /// In en, this message translates to:
  /// **'Equippable ({count})'**
  String inventoryEquippableSection(int count);

  /// Hint below the equippable items section.
  ///
  /// In en, this message translates to:
  /// **'Tap the circle icon on the left to equip or unequip'**
  String get inventoryEquipHint;

  /// Inventory section title when all sections empty.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventoryInventory;

  /// Inventory empty state text.
  ///
  /// In en, this message translates to:
  /// **'No items yet. Tap + to add.'**
  String get inventoryEmpty;

  /// Ammunition section header.
  ///
  /// In en, this message translates to:
  /// **'Ammunition'**
  String get inventoryAmmunition;

  /// Copper coin label.
  ///
  /// In en, this message translates to:
  /// **'Copper'**
  String get coinCopper;

  /// Silver coin label.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get coinSilver;

  /// Electrum coin label.
  ///
  /// In en, this message translates to:
  /// **'Electrum'**
  String get coinElectrum;

  /// Gold coin label.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get coinGold;

  /// Platinum coin label.
  ///
  /// In en, this message translates to:
  /// **'Platinum'**
  String get coinPlatinum;

  /// Weapon browser group: simple melee.
  ///
  /// In en, this message translates to:
  /// **'Simple Melee'**
  String get inventoryGroupSimpleMelee;

  /// Weapon browser group: simple ranged.
  ///
  /// In en, this message translates to:
  /// **'Simple Ranged'**
  String get inventoryGroupSimpleRanged;

  /// Weapon browser group: martial melee.
  ///
  /// In en, this message translates to:
  /// **'Martial Melee'**
  String get inventoryGroupMartialMelee;

  /// Weapon browser group: martial ranged.
  ///
  /// In en, this message translates to:
  /// **'Martial Ranged'**
  String get inventoryGroupMartialRanged;

  /// Armor browser group: light armor.
  ///
  /// In en, this message translates to:
  /// **'Light Armor'**
  String get inventoryGroupLightArmor;

  /// Armor browser group: medium armor.
  ///
  /// In en, this message translates to:
  /// **'Medium Armor'**
  String get inventoryGroupMediumArmor;

  /// Armor browser group: heavy armor.
  ///
  /// In en, this message translates to:
  /// **'Heavy Armor'**
  String get inventoryGroupHeavyArmor;

  /// Armor browser group: shields.
  ///
  /// In en, this message translates to:
  /// **'Shields'**
  String get inventoryGroupShields;

  /// Gear browser group: adventuring gear.
  ///
  /// In en, this message translates to:
  /// **'Adventuring Gear'**
  String get inventoryGroupAdventuringGear;

  /// Gear browser group: ammunition.
  ///
  /// In en, this message translates to:
  /// **'Ammunition'**
  String get inventoryGroupAmmunition;

  /// Gear browser group: arcane focus.
  ///
  /// In en, this message translates to:
  /// **'Arcane Focus'**
  String get inventoryGroupArcaneFocus;

  /// Gear browser group: clothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get inventoryGroupClothing;

  /// Gear browser group: container.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get inventoryGroupContainer;

  /// Gear browser group: poison.
  ///
  /// In en, this message translates to:
  /// **'Poison'**
  String get inventoryGroupPoison;

  /// Magic item browser group: potions.
  ///
  /// In en, this message translates to:
  /// **'Potions'**
  String get inventoryGroupPotions;

  /// Magic item browser group: rings.
  ///
  /// In en, this message translates to:
  /// **'Rings'**
  String get inventoryGroupRings;

  /// Magic item browser group: wands.
  ///
  /// In en, this message translates to:
  /// **'Wands'**
  String get inventoryGroupWands;

  /// Magic item browser group: weapons.
  ///
  /// In en, this message translates to:
  /// **'Weapons'**
  String get inventoryGroupWeapons;

  /// Magic item browser group: armor.
  ///
  /// In en, this message translates to:
  /// **'Armor'**
  String get inventoryGroupArmor;

  /// Magic item browser group: wondrous items.
  ///
  /// In en, this message translates to:
  /// **'Wondrous Items'**
  String get inventoryGroupWondrousItems;

  /// Tools browser group: artisan's tools.
  ///
  /// In en, this message translates to:
  /// **'Artisan\'s Tools'**
  String get inventoryGroupArtisansTools;

  /// Tools browser group: gaming sets.
  ///
  /// In en, this message translates to:
  /// **'Gaming Sets'**
  String get inventoryGroupGamingSets;

  /// Tools browser group: musical instruments.
  ///
  /// In en, this message translates to:
  /// **'Musical Instruments'**
  String get inventoryGroupMusicalInstruments;

  /// Tools browser group: other tools.
  ///
  /// In en, this message translates to:
  /// **'Other Tools'**
  String get inventoryGroupOtherTools;

  /// Label shown when armor imposes stealth disadvantage.
  ///
  /// In en, this message translates to:
  /// **'Stealth disadvantage'**
  String get armorStealthDisadvantage;

  /// Spell detail label: casting time.
  ///
  /// In en, this message translates to:
  /// **'Casting time'**
  String get spellDetailCastingTime;

  /// Spell detail label: range.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get spellDetailRange;

  /// Spell detail label: duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get spellDetailDuration;

  /// Spell detail label: components.
  ///
  /// In en, this message translates to:
  /// **'Components'**
  String get spellDetailComponents;

  /// Spell detail badge: requires concentration.
  ///
  /// In en, this message translates to:
  /// **'Requires concentration'**
  String get spellDetailConcentration;

  /// Spell detail badge: can be cast as a ritual.
  ///
  /// In en, this message translates to:
  /// **'Can be cast as a ritual'**
  String get spellDetailRitual;

  /// Spell detail section heading: at higher levels.
  ///
  /// In en, this message translates to:
  /// **'At Higher Levels. '**
  String get spellDetailAtHigherLevels;

  /// Spell detail classes line.
  ///
  /// In en, this message translates to:
  /// **'Classes: {classes}'**
  String spellDetailClasses(String classes);

  /// Spell level + school descriptor.
  ///
  /// In en, this message translates to:
  /// **'{ordinal}-level {school}'**
  String spellDetailLevelSchool(String ordinal, String school);

  /// Cantrip school descriptor.
  ///
  /// In en, this message translates to:
  /// **'{school} cantrip'**
  String spellDetailCantrip(String school);

  /// Armor swap dialog: current armor name.
  ///
  /// In en, this message translates to:
  /// **'Current: {name}'**
  String armorSwapCurrent(String name);

  /// Armor swap dialog: current AC value.
  ///
  /// In en, this message translates to:
  /// **'AC now: {ac}'**
  String armorSwapAcNow(int ac);

  /// Armor swap dialog: AC after swap.
  ///
  /// In en, this message translates to:
  /// **'AC after: {ac}'**
  String armorSwapAcAfter(int ac);

  /// Armor swap confirm button.
  ///
  /// In en, this message translates to:
  /// **'Swap armor'**
  String get armorSwapButton;

  /// Review step: name row label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get reviewRowName;

  /// Review step: placeholder when character has no name.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Hero'**
  String get reviewUnnamedHero;

  /// Review step: player row label.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get reviewRowPlayer;

  /// Review step: subclass row label fallback.
  ///
  /// In en, this message translates to:
  /// **'Subclass'**
  String get reviewRowSubclass;

  /// Review step: hit die row label.
  ///
  /// In en, this message translates to:
  /// **'Hit Die'**
  String get reviewRowHitDie;

  /// Review step: saving throws row label.
  ///
  /// In en, this message translates to:
  /// **'Saving Throws'**
  String get reviewRowSavingThrows;

  /// Review step: subrace row label.
  ///
  /// In en, this message translates to:
  /// **'Subrace'**
  String get reviewRowSubrace;

  /// Review step: speed row label.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get reviewRowSpeed;

  /// Review step: languages row label.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get reviewRowLanguages;

  /// Review step: background feature row label.
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get reviewRowFeature;

  /// Review step: skills from background row label.
  ///
  /// In en, this message translates to:
  /// **'From background'**
  String get reviewRowFromBackground;

  /// Review step: class skill choices row label.
  ///
  /// In en, this message translates to:
  /// **'Class choices'**
  String get reviewRowClassChoices;

  /// Review step: max HP row label.
  ///
  /// In en, this message translates to:
  /// **'Max HP'**
  String get reviewRowMaxHp;

  /// Review step: AC unarmored row label.
  ///
  /// In en, this message translates to:
  /// **'AC (Unarmored)'**
  String get reviewRowAcUnarmored;

  /// Review step: AC with armor row label.
  ///
  /// In en, this message translates to:
  /// **'AC with {name}'**
  String reviewRowAcWith(String name);

  /// Review step: proficiency bonus row label.
  ///
  /// In en, this message translates to:
  /// **'Proficiency Bonus'**
  String get reviewRowProficiencyBonus;

  /// Review step: starting gold row label.
  ///
  /// In en, this message translates to:
  /// **'Starting Gold'**
  String get reviewStartingGold;

  /// Review step: starting equipment section title.
  ///
  /// In en, this message translates to:
  /// **'Starting Equipment'**
  String get reviewStartingEquipment;

  /// Review step: deselect all button.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get reviewDeselectAll;

  /// Review step: select all button.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get reviewSelectAll;

  /// Review step: hint below starting equipment list.
  ///
  /// In en, this message translates to:
  /// **'Uncheck items you don\'t want to add to your inventory.'**
  String get reviewUncheckHint;

  /// Review step: equipment choices subsection title.
  ///
  /// In en, this message translates to:
  /// **'Equipment Choices'**
  String get reviewEquipmentChoices;

  /// Review step: equipment choices hint.
  ///
  /// In en, this message translates to:
  /// **'Pick the specific item for each slot.'**
  String get reviewEquipmentChoicesHint;

  /// Review step: tool proficiencies section title.
  ///
  /// In en, this message translates to:
  /// **'Tool Proficiencies'**
  String get reviewToolProficiencies;

  /// Review step: choose tool proficiency label.
  ///
  /// In en, this message translates to:
  /// **'Choose your tool proficiency:'**
  String get reviewChooseToolProficiency;

  /// Review step: choose languages hint.
  ///
  /// In en, this message translates to:
  /// **'Choose {count} language(s) granted by your race or background.'**
  String reviewChooseLanguages(int count);

  /// Review step: choose one option label.
  ///
  /// In en, this message translates to:
  /// **'Choose one:'**
  String get reviewChooseOne;

  /// Attributes step: Tasha's optional rule subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tasha\'s optional rule — assign ASI points to any attribute'**
  String get stepTashaRule;

  /// Attributes step: roll dice button label.
  ///
  /// In en, this message translates to:
  /// **'Roll dice'**
  String get stepRollDice;

  /// Attributes step: reroll button label.
  ///
  /// In en, this message translates to:
  /// **'Reroll'**
  String get stepReroll;

  /// Attributes step: roll hint when no values rolled yet.
  ///
  /// In en, this message translates to:
  /// **'Roll to generate 6 values (4d6, drop lowest)'**
  String get stepRollHint;

  /// Attributes step: class reminder primary abilities label.
  ///
  /// In en, this message translates to:
  /// **'primary abilities: '**
  String get stepPrimaryAbilities;

  /// Name step: page title.
  ///
  /// In en, this message translates to:
  /// **'Give your character a name.'**
  String get stepNameTitle;

  /// Name step: subtitle hint.
  ///
  /// In en, this message translates to:
  /// **'You can always change this later.'**
  String get stepNameHint;

  /// Name step: character name field label.
  ///
  /// In en, this message translates to:
  /// **'Character name'**
  String get stepNameCharLabel;

  /// Name step: player name field label.
  ///
  /// In en, this message translates to:
  /// **'Player name (optional)'**
  String get stepNamePlayerLabel;

  /// Class card: hit die label.
  ///
  /// In en, this message translates to:
  /// **'Hit die'**
  String get stepHitDieLabel;

  /// Class card: saving throws label.
  ///
  /// In en, this message translates to:
  /// **'Saves'**
  String get stepSavesLabel;

  /// Class card: spellcasting ability label.
  ///
  /// In en, this message translates to:
  /// **'Spellcasting'**
  String get stepSpellcastingLabel;

  /// Class card: subclass options count suffix.
  ///
  /// In en, this message translates to:
  /// **'options'**
  String get stepOptionsLabel;

  /// Class step: subclass selector prompt.
  ///
  /// In en, this message translates to:
  /// **'Choose a {feature} (Lv {level}):'**
  String stepChooseSubclassPrompt(String feature, int level);

  /// Race card: speed label.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get stepRaceSpeedLabel;

  /// Race card: ability score increase label.
  ///
  /// In en, this message translates to:
  /// **'ASI'**
  String get stepRaceASILabel;

  /// Race card: subraces count.
  ///
  /// In en, this message translates to:
  /// **'{count} subraces available'**
  String stepRaceSubracesAvailable(int count);

  /// Skills step: prompt to choose skills.
  ///
  /// In en, this message translates to:
  /// **'Choose {count} skills from your class list.'**
  String stepChooseSkillsHint(int count);

  /// Full name of the Strength ability score.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get abilityStrength;

  /// Full name of the Dexterity ability score.
  ///
  /// In en, this message translates to:
  /// **'Dexterity'**
  String get abilityDexterity;

  /// Full name of the Constitution ability score.
  ///
  /// In en, this message translates to:
  /// **'Constitution'**
  String get abilityConstitution;

  /// Full name of the Intelligence ability score.
  ///
  /// In en, this message translates to:
  /// **'Intelligence'**
  String get abilityIntelligence;

  /// Full name of the Wisdom ability score.
  ///
  /// In en, this message translates to:
  /// **'Wisdom'**
  String get abilityWisdom;

  /// Full name of the Charisma ability score.
  ///
  /// In en, this message translates to:
  /// **'Charisma'**
  String get abilityCharisma;

  /// Attributes step: Tasha free ASI distribution label.
  ///
  /// In en, this message translates to:
  /// **'Distribute racial ASI points freely ({remaining} remaining):'**
  String stepFreeAsiRemaining(int remaining);

  /// Attributes step: Half-Elf style free picks label.
  ///
  /// In en, this message translates to:
  /// **'Racial free ASI: assign +1 to {total} attributes ({remaining} remaining):'**
  String stepFreePicksRemaining(int total, int remaining);

  /// Attributes step: free picks constraint hint.
  ///
  /// In en, this message translates to:
  /// **'Cannot assign to attributes already receiving a racial bonus.'**
  String get stepFreePicksNoStack;

  /// No description provided for @reviewClassEquipmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Class Equipment — {name}'**
  String reviewClassEquipmentTitle(String name);

  /// No description provided for @reviewEquipmentIncluded.
  ///
  /// In en, this message translates to:
  /// **'Included:'**
  String get reviewEquipmentIncluded;

  /// No description provided for @stepToolCategoryGamingSet.
  ///
  /// In en, this message translates to:
  /// **'Gaming set'**
  String get stepToolCategoryGamingSet;

  /// No description provided for @stepToolCategoryInstrument.
  ///
  /// In en, this message translates to:
  /// **'Musical instrument'**
  String get stepToolCategoryInstrument;

  /// No description provided for @stepToolCategoryArtisanTool.
  ///
  /// In en, this message translates to:
  /// **'Artisan\'s tool'**
  String get stepToolCategoryArtisanTool;

  /// No description provided for @stepToolCategoryArtisanOrInstrument.
  ///
  /// In en, this message translates to:
  /// **'Artisan\'s tool or instrument'**
  String get stepToolCategoryArtisanOrInstrument;

  /// Snackbar shown after copying to clipboard.
  ///
  /// In en, this message translates to:
  /// **'{label} copied!'**
  String exportCopied(String label);

  /// Export dialog title.
  ///
  /// In en, this message translates to:
  /// **'Export {name}'**
  String exportDialogTitle(String name);

  /// Export dialog: token section label.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get exportLabelToken;

  /// Export dialog: copy token button.
  ///
  /// In en, this message translates to:
  /// **'Copy token'**
  String get exportCopyToken;

  /// Export dialog: hide QR code button.
  ///
  /// In en, this message translates to:
  /// **'Hide QR Code'**
  String get exportHideQr;

  /// Export dialog: show QR code button.
  ///
  /// In en, this message translates to:
  /// **'Show QR Code'**
  String get exportShowQr;

  /// Export dialog: character too large for QR code warning.
  ///
  /// In en, this message translates to:
  /// **'Character too large for QR code.\nUse the token or JSON to share.'**
  String get exportQrTooLarge;

  /// Export dialog: expand JSON section label.
  ///
  /// In en, this message translates to:
  /// **'Show JSON'**
  String get exportShowJson;

  /// Export dialog: copy JSON button.
  ///
  /// In en, this message translates to:
  /// **'Copy JSON'**
  String get exportCopyJson;

  /// Export dialog: quick share section heading.
  ///
  /// In en, this message translates to:
  /// **'Quick share'**
  String get exportSectionQuick;

  /// Export dialog: quick share section caption.
  ///
  /// In en, this message translates to:
  /// **'No image — for sharing stats'**
  String get exportSectionQuickCaption;

  /// Export dialog: complete file section heading.
  ///
  /// In en, this message translates to:
  /// **'Complete file'**
  String get exportSectionFile;

  /// Export dialog: complete file section caption.
  ///
  /// In en, this message translates to:
  /// **'Includes the character photo'**
  String get exportSectionFileCaption;

  /// Export dialog: share .dndchar file button.
  ///
  /// In en, this message translates to:
  /// **'Share .dndchar'**
  String get exportShareFile;

  /// Generic dialog close button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dialogClose;

  /// Import dialog title.
  ///
  /// In en, this message translates to:
  /// **'Import Character'**
  String get importDialogTitle;

  /// Import dialog: token text field hint.
  ///
  /// In en, this message translates to:
  /// **'Paste token here…'**
  String get importTokenHint;

  /// Import dialog: scan QR code button / AppBar title.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get importScanQr;

  /// Import dialog: expand JSON section label.
  ///
  /// In en, this message translates to:
  /// **'Use JSON directly'**
  String get importUseJson;

  /// Import dialog: JSON text field hint.
  ///
  /// In en, this message translates to:
  /// **'Paste JSON here…'**
  String get importJsonHint;

  /// Import dialog: button to open a .dndchar file from storage.
  ///
  /// In en, this message translates to:
  /// **'Pick .dndchar file'**
  String get importPickFile;

  /// Import dialog: error shown when picked file is invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid or corrupted .dndchar file'**
  String get importFileError;

  /// Confirmation dialog title when app is opened with a .dndchar file.
  ///
  /// In en, this message translates to:
  /// **'Import character from file?'**
  String get importFileIncoming;

  /// Import dialog: import button.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get dialogImport;

  /// Spell browser sheet title.
  ///
  /// In en, this message translates to:
  /// **'Browse Spells'**
  String get spellBrowserTitle;

  /// Spell browser: filter icon button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get spellBrowserFilters;

  /// Spell browser: search field hint.
  ///
  /// In en, this message translates to:
  /// **'Search spells...'**
  String get spellBrowserSearchHint;

  /// Filter panel: clear all filters button.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get filterClearAll;

  /// Generic loading label.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingLabel;

  /// Spell browser: result count.
  ///
  /// In en, this message translates to:
  /// **'{count} spell{s}'**
  String spellBrowserCount(int count, String s);

  /// Spell browser: empty state message.
  ///
  /// In en, this message translates to:
  /// **'No spells match the current filters.'**
  String get spellBrowserEmpty;

  /// Spell level 0 label.
  ///
  /// In en, this message translates to:
  /// **'Cantrip'**
  String get spellCantrip;

  /// Spell level N label.
  ///
  /// In en, this message translates to:
  /// **'Lvl {n}'**
  String spellLevelN(int n);

  /// Casting time: action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get castingTimeAction;

  /// Casting time: bonus action.
  ///
  /// In en, this message translates to:
  /// **'Bonus action'**
  String get castingTimeBonusAction;

  /// Casting time: reaction.
  ///
  /// In en, this message translates to:
  /// **'Reaction'**
  String get castingTimeReaction;

  /// Casting time: longer than one round.
  ///
  /// In en, this message translates to:
  /// **'Longer cast'**
  String get castingTimeLonger;

  /// Filter label: concentration.
  ///
  /// In en, this message translates to:
  /// **'Concentration'**
  String get filterConcentration;

  /// Filter label: ritual.
  ///
  /// In en, this message translates to:
  /// **'Ritual'**
  String get filterRitual;

  /// Filter label: show all spell levels.
  ///
  /// In en, this message translates to:
  /// **'All levels'**
  String get filterAllLevels;

  /// Character avatar: choose photo option.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get avatarChoosePhoto;

  /// Character avatar: remove photo option.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get avatarRemovePhoto;

  /// Character avatar: crop photo toolbar title.
  ///
  /// In en, this message translates to:
  /// **'Crop photo'**
  String get avatarCropPhoto;

  /// Character avatar: change photo action in full-screen viewer.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get avatarChangePhoto;

  /// Features tab: snackbar shown after adding a custom feature.
  ///
  /// In en, this message translates to:
  /// **'{name} added!'**
  String featureAddedSnackbar(String name);

  /// Features tab: add custom feature button label.
  ///
  /// In en, this message translates to:
  /// **'Add Feature'**
  String get featureAddButton;

  /// Review step: language choices section title.
  ///
  /// In en, this message translates to:
  /// **'Language Choices'**
  String get reviewLanguageChoices;

  /// Review step: language text field hint.
  ///
  /// In en, this message translates to:
  /// **'Type a language…'**
  String get reviewLanguageTypeHint;

  /// Avatar: confirmation dialog title when removing photo.
  ///
  /// In en, this message translates to:
  /// **'Remove photo?'**
  String get avatarRemoveConfirmTitle;

  /// Avatar: confirmation dialog body when removing photo.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get avatarRemoveConfirmBody;

  /// Banner shown at the top of the stats tab when in edit mode.
  ///
  /// In en, this message translates to:
  /// **'Editing'**
  String get editModeBanner;

  /// Tooltip for the info button on class/race cards in character creation.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailSheetInfoTooltip;

  /// Detail sheet: proficiencies section label.
  ///
  /// In en, this message translates to:
  /// **'Proficiencies'**
  String get detailSheetProficiencies;

  /// Detail sheet: racial traits section label.
  ///
  /// In en, this message translates to:
  /// **'Traits'**
  String get detailSheetTraits;

  /// Detail sheet: placeholder label shown at the level where a subclass feature is gained.
  ///
  /// In en, this message translates to:
  /// **'Subclass Feature'**
  String get detailSheetSubclassFeaturePlaceholder;

  /// Detail sheet: available subclasses section label.
  ///
  /// In en, this message translates to:
  /// **'Available {feature}'**
  String detailSheetAvailableSubclasses(String feature);

  /// Detail sheet: available subraces section label.
  ///
  /// In en, this message translates to:
  /// **'Subraces'**
  String get detailSheetAvailableSubraces;

  /// Label for the XP tracking toggle switch.
  ///
  /// In en, this message translates to:
  /// **'Track XP'**
  String get xpTrackingLabel;

  /// CTA button shown when XP reaches the next level threshold.
  ///
  /// In en, this message translates to:
  /// **'Ready to level up!'**
  String get xpReadyToLevelUp;

  /// Dialog title shown when XP reaches a new level threshold.
  ///
  /// In en, this message translates to:
  /// **'Level Up?'**
  String get xpLevelUpNowTitle;

  /// Dialog message shown when XP reaches a new level threshold.
  ///
  /// In en, this message translates to:
  /// **'You have enough XP to reach Level {level}. Level up now?'**
  String xpLevelUpNowMessage(int level);

  /// Dialog button to postpone leveling up.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get xpLevelUpLater;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
