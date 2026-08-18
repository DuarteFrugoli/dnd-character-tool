import 'package:flutter/material.dart';

/// Describes a named application theme.
class AppTheme {
  const AppTheme({
    required this.id,
    required this.name,
    required this.brightness,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.surface,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    this.primaryContainer,
    this.secondaryContainer,
    this.tertiaryContainer,
    this.outline,
    this.outlineVariant,
    this.error,
  });

  final String id;
  final String name;
  final Brightness brightness;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color surface;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color? primaryContainer;
  final Color? secondaryContainer;
  final Color? tertiaryContainer;
  final Color? outline;
  final Color? outlineVariant;
  final Color? error;

  ThemeData toThemeData() {
    final effectivePrimaryContainer =
        primaryContainer ?? _containerFor(primary);
    final effectiveSecondaryContainer =
        secondaryContainer ?? _containerFor(secondary);
    final effectiveTertiaryContainer =
        tertiaryContainer ?? _containerFor(tertiary);
    final effectiveError =
        error ??
        (brightness == Brightness.dark
            ? const Color(0xFFFFB4AB)
            : const Color(0xFFBA1A1A));
    final errorContainer = _blend(
      effectiveError,
      surfaceContainerHighest,
      brightness == Brightness.dark ? 0.32 : 0.16,
    );

    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: _foregroundFor(primary),
      primaryContainer: effectivePrimaryContainer,
      onPrimaryContainer: _foregroundFor(effectivePrimaryContainer),
      secondary: secondary,
      onSecondary: _foregroundFor(secondary),
      secondaryContainer: effectiveSecondaryContainer,
      onSecondaryContainer: _foregroundFor(effectiveSecondaryContainer),
      tertiary: tertiary,
      onTertiary: _foregroundFor(tertiary),
      tertiaryContainer: effectiveTertiaryContainer,
      onTertiaryContainer: _foregroundFor(effectiveTertiaryContainer),
      error: effectiveError,
      onError: _foregroundFor(effectiveError),
      errorContainer: errorContainer,
      onErrorContainer: _foregroundFor(errorContainer),
      surface: surface,
      onSurface: _foregroundFor(surface),
      surfaceDim: brightness == Brightness.dark
          ? surfaceContainerLowest
          : _blend(Colors.black, surface, 0.08),
      surfaceBright: brightness == Brightness.dark
          ? surfaceContainerHigh
          : _blend(Colors.white, surface, 0.55),
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurfaceVariant: _mutedForegroundFor(surface),
      outline: outline ?? _blend(_foregroundFor(surface), surface, 0.42),
      outlineVariant:
          outlineVariant ?? _blend(_foregroundFor(surface), surface, 0.18),
      inverseSurface: _foregroundFor(surface),
      onInverseSurface: surface,
      inversePrimary: effectivePrimaryContainer,
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceTint: primary,
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      useMaterial3: true,
    );
  }

  Color _containerFor(Color color) => _blend(
    color,
    surfaceContainerHighest,
    brightness == Brightness.dark ? 0.34 : 0.18,
  );
}

Color _foregroundFor(Color color) =>
    color.computeLuminance() > 0.45 ? Colors.black : Colors.white;

Color _mutedForegroundFor(Color surface) =>
    _blend(_foregroundFor(surface), surface, 0.68);

Color _blend(Color overlay, Color base, double alpha) =>
    Color.alphaBlend(overlay.withValues(alpha: alpha), base);

AppTheme get defaultAppTheme => appThemes.first;

AppTheme appThemeByIdOrDefault(String? id) {
  if (id == null) return defaultAppTheme;
  for (final theme in appThemes) {
    if (theme.id == id) return theme;
  }
  return defaultAppTheme;
}

/// All available themes, in display order.
const List<AppTheme> appThemes = [
  AppTheme(
    id: 'crimson',
    name: 'Crimson',
    brightness: Brightness.dark,
    primary: Color(0xFFE05263),
    secondary: Color(0xFFD8A85E),
    tertiary: Color(0xFFFFB1A7),
    surface: Color(0xFF120B0D),
    surfaceContainerLowest: Color(0xFF0B0708),
    surfaceContainerLow: Color(0xFF181012),
    surfaceContainer: Color(0xFF211619),
    surfaceContainerHigh: Color(0xFF2B1D21),
    surfaceContainerHighest: Color(0xFF37262B),
    primaryContainer: Color(0xFF671B26),
    secondaryContainer: Color(0xFF4D351A),
    tertiaryContainer: Color(0xFF5B2A31),
  ),
  AppTheme(
    id: 'light',
    name: 'Light',
    brightness: Brightness.light,
    primary: Color(0xFF8F1D2C),
    secondary: Color(0xFF76512B),
    tertiary: Color(0xFF5D5A85),
    surface: Color(0xFFFFF8F5),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFFF0EA),
    surfaceContainer: Color(0xFFF8E8E0),
    surfaceContainerHigh: Color(0xFFF0DED5),
    surfaceContainerHighest: Color(0xFFE7D4CB),
    primaryContainer: Color(0xFFFFDAD9),
    secondaryContainer: Color(0xFFFFDDB8),
    tertiaryContainer: Color(0xFFE4DFFF),
  ),
  AppTheme(
    id: 'parchment',
    name: 'Parchment',
    brightness: Brightness.light,
    primary: Color(0xFF7B4A24),
    secondary: Color(0xFF9A2F24),
    tertiary: Color(0xFF5C6542),
    surface: Color(0xFFF5E6C8),
    surfaceContainerLowest: Color(0xFFFFF4D9),
    surfaceContainerLow: Color(0xFFEEDDBF),
    surfaceContainer: Color(0xFFE5D2B1),
    surfaceContainerHigh: Color(0xFFD9C49F),
    surfaceContainerHighest: Color(0xFFCDB58D),
    primaryContainer: Color(0xFFFFDCC2),
    secondaryContainer: Color(0xFFFFDAD3),
    tertiaryContainer: Color(0xFFE1E8BF),
  ),
  AppTheme(
    id: 'arcane',
    name: 'Arcane',
    brightness: Brightness.dark,
    primary: Color(0xFFCFA7FF),
    secondary: Color(0xFF86B6FF),
    tertiary: Color(0xFF7DE7D1),
    surface: Color(0xFF0D0A1A),
    surfaceContainerLowest: Color(0xFF07050F),
    surfaceContainerLow: Color(0xFF151025),
    surfaceContainer: Color(0xFF1D1730),
    surfaceContainerHigh: Color(0xFF281F3E),
    surfaceContainerHighest: Color(0xFF34294D),
    primaryContainer: Color(0xFF4A277A),
    secondaryContainer: Color(0xFF193C6D),
    tertiaryContainer: Color(0xFF164D46),
  ),
  AppTheme(
    id: 'forest',
    name: 'Forest',
    brightness: Brightness.light,
    primary: Color(0xFF326B35),
    secondary: Color(0xFF80622D),
    tertiary: Color(0xFF4F6F65),
    surface: Color(0xFFF5F5E8),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFEFF0DB),
    surfaceContainer: Color(0xFFE6E8D1),
    surfaceContainerHigh: Color(0xFFDDE0C6),
    surfaceContainerHighest: Color(0xFFD3D7BA),
    primaryContainer: Color(0xFFCDEDC5),
    secondaryContainer: Color(0xFFF4DEB3),
    tertiaryContainer: Color(0xFFD2E7DE),
  ),
  AppTheme(
    id: 'elven_forest',
    name: 'Elven Forest',
    brightness: Brightness.dark,
    primary: Color(0xFFA3D977),
    secondary: Color(0xFFE0B86C),
    tertiary: Color(0xFF78D0B2),
    surface: Color(0xFF07120B),
    surfaceContainerLowest: Color(0xFF030805),
    surfaceContainerLow: Color(0xFF0D1A10),
    surfaceContainer: Color(0xFF142317),
    surfaceContainerHigh: Color(0xFF1D2F20),
    surfaceContainerHighest: Color(0xFF283B2A),
    primaryContainer: Color(0xFF28511D),
    secondaryContainer: Color(0xFF4A3714),
    tertiaryContainer: Color(0xFF1F4C40),
  ),
  AppTheme(
    id: 'sea',
    name: 'Sea',
    brightness: Brightness.dark,
    primary: Color(0xFF4FD5E7),
    secondary: Color(0xFF8BC6FF),
    tertiary: Color(0xFFB8E0D2),
    surface: Color(0xFF06141D),
    surfaceContainerLowest: Color(0xFF020A0F),
    surfaceContainerLow: Color(0xFF0B1C28),
    surfaceContainer: Color(0xFF112737),
    surfaceContainerHigh: Color(0xFF193346),
    surfaceContainerHighest: Color(0xFF234157),
    primaryContainer: Color(0xFF00505B),
    secondaryContainer: Color(0xFF173F63),
    tertiaryContainer: Color(0xFF294C43),
  ),
  AppTheme(
    id: 'celestial',
    name: 'Celestial',
    brightness: Brightness.light,
    primary: Color(0xFF315CA8),
    secondary: Color(0xFFC08B18),
    tertiary: Color(0xFF7B65C7),
    surface: Color(0xFFF7FAFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFEEF4FF),
    surfaceContainer: Color(0xFFE5EDFA),
    surfaceContainerHigh: Color(0xFFDCE5F2),
    surfaceContainerHighest: Color(0xFFD2DCEB),
    primaryContainer: Color(0xFFD8E2FF),
    secondaryContainer: Color(0xFFFFE0A1),
    tertiaryContainer: Color(0xFFE8DDFF),
  ),
  AppTheme(
    id: 'sacred',
    name: 'Sacred',
    brightness: Brightness.light,
    primary: Color(0xFF7B5A00),
    secondary: Color(0xFF3E5F96),
    tertiary: Color(0xFF8354A3),
    surface: Color(0xFFFFFBF0),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF7F0DD),
    surfaceContainer: Color(0xFFEEE5D0),
    surfaceContainerHigh: Color(0xFFE4DAC4),
    surfaceContainerHighest: Color(0xFFD9CFB8),
    primaryContainer: Color(0xFFFFE08A),
    secondaryContainer: Color(0xFFD8E3FF),
    tertiaryContainer: Color(0xFFF0D8FF),
  ),
  AppTheme(
    id: 'shadow',
    name: 'Shadow',
    brightness: Brightness.dark,
    primary: Color(0xFFC8C3FF),
    secondary: Color(0xFFB9C6D6),
    tertiary: Color(0xFF98D5C7),
    surface: Color(0xFF0A0D14),
    surfaceContainerLowest: Color(0xFF05070C),
    surfaceContainerLow: Color(0xFF111622),
    surfaceContainer: Color(0xFF171D2B),
    surfaceContainerHigh: Color(0xFF20283A),
    surfaceContainerHighest: Color(0xFF2B3449),
    primaryContainer: Color(0xFF39356C),
    secondaryContainer: Color(0xFF344150),
    tertiaryContainer: Color(0xFF244D45),
  ),
];
