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
}
