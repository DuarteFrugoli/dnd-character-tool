import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_themes.dart';

const _kThemeKey = 'selected_theme_id';

/// Provides the currently selected [AppTheme].
final themeProvider = NotifierProvider<ThemeNotifier, AppTheme>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<AppTheme> {
  static final _defaultTheme = appThemes[0]; // 'system_dark'

  ThemeNotifier([this._initial]);
  final AppTheme? _initial;

  /// Named constructor used by main() to pass the pre-loaded value.
  static ThemeNotifier withInitial(AppTheme theme) => ThemeNotifier(theme);

  @override
  AppTheme build() => _initial ?? _defaultTheme;

  Future<void> setTheme(AppTheme theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, theme.id);
  }
}
