import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'selected_locale';

/// Supported locales for the app.
/// `null` means "follow the system".
const supportedLocales = [
  Locale('en'),
  Locale('pt'),
  Locale('es'),
  Locale('fr'),
  Locale('de'),
  Locale('it'),
  Locale('ja'),
  Locale('ko'),
  Locale('ru'),
  Locale('zh'),
];

class LocaleNotifier extends Notifier<Locale?> {
  LocaleNotifier([this._initial]);
  final Locale? _initial;

  /// Named constructor used by main() to pass the pre-loaded value.
  static LocaleNotifier withInitial(Locale? locale) => LocaleNotifier(locale);

  @override
  Locale? build() => _initial; // null means "follow system"

  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_kLocaleKey);
    } else {
      await prefs.setString(_kLocaleKey, locale.languageCode);
    }
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);
