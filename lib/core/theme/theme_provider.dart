import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_themes.dart';

const _kThemeKey = 'selected_theme_id';

/// Provides the currently selected [AppTheme].
final themeProvider = NotifierProvider<ThemeNotifier, AppTheme>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<AppTheme> {
  static final _defaultTheme = appThemes[0]; // 'system_dark'

  @override
  AppTheme build() {
    _loadFromPrefs();
    return _defaultTheme;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kThemeKey);
    if (id == null) return;
    final theme = appThemes.where((t) => t.id == id).firstOrNull;
    if (theme != null) state = theme;
  }

  Future<void> setTheme(AppTheme theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, theme.id);
  }
}
