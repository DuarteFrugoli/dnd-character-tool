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
