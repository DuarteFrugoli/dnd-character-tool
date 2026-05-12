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

  /// Import error: not valid JSON.
  ///
  /// In en, this message translates to:
  /// **'The pasted text is not valid JSON.'**
  String get importErrorInvalidJson;

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

  /// Status label when HP reaches 0.
  ///
  /// In en, this message translates to:
  /// **'Unconscious / Dying'**
  String get statUnconsciousDying;

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
