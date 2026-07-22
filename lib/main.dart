import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/locale/locale_provider.dart';
import 'core/platform/url_strategy.dart';
import 'core/router/app_router.dart';
import 'core/services/incoming_file_service.dart';
import 'core/theme/app_themes.dart';
import 'core/theme/theme_provider.dart';
import 'core/units/unit_system_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureAppUrlStrategy();
  IncomingFileService.instance.initialize();

  // Load persisted theme, locale and unit system before first frame — no flash.
  final prefs = await SharedPreferences.getInstance();

  final savedThemeId = prefs.getString('selected_theme_id');
  final initialTheme = savedThemeId != null
      ? appThemes.where((t) => t.id == savedThemeId).firstOrNull ?? appThemes[0]
      : appThemes[0];

  final savedLocaleCode = prefs.getString('selected_locale');
  final initialLocale =
      savedLocaleCode != null ? Locale(savedLocaleCode) : null;

  final savedUnitSystem = prefs.getString('unit_system');
  final initialUnitSystem = savedUnitSystem != null
      ? UnitSystem.values.firstWhere(
          (v) => v.name == savedUnitSystem,
          orElse: () => defaultUnitSystem(initialLocale),
        )
      : defaultUnitSystem(initialLocale);

  runApp(ProviderScope(
    overrides: [
      themeProvider.overrideWith(() => ThemeNotifier.withInitial(initialTheme)),
      localeProvider.overrideWith(
          () => LocaleNotifier.withInitial(initialLocale)),
      unitSystemProvider.overrideWith(
          () => UnitSystemNotifier.withInitial(initialUnitSystem)),
    ],
    child: const MainApp(),
  ));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'DnD Character Tool',
      routerConfig: appRouter,
      theme: appTheme.toThemeData(),
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
