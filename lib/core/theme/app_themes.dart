import 'package:flutter/material.dart';

/// Describes a named application theme.
class AppTheme {
  const AppTheme({
    required this.id,
    required this.name,
    required this.seedColor,
    this.brightness = Brightness.dark,
    this.contrastLevel = 0.0,
    this.surfaceColor,
  });

  final String id;
  final String name;
  final Color seedColor;
  final Brightness brightness;
  final double contrastLevel;
  final Color? surfaceColor;

  ThemeData toThemeData() {
    var scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      contrastLevel: contrastLevel,
    );
    if (surfaceColor != null) {
      scheme = scheme.copyWith(
        surface: surfaceColor,
        surfaceContainerLowest: surfaceColor,
        surfaceContainerLow: Color.alphaBlend(
          Colors.brown.withValues(alpha: 0.06),
          surfaceColor!,
        ),
        surfaceContainer: Color.alphaBlend(
          Colors.brown.withValues(alpha: 0.10),
          surfaceColor!,
        ),
        surfaceContainerHigh: Color.alphaBlend(
          Colors.brown.withValues(alpha: 0.14),
          surfaceColor!,
        ),
        surfaceContainerHighest: Color.alphaBlend(
          Colors.brown.withValues(alpha: 0.18),
          surfaceColor!,
        ),
      );
    }
    return ThemeData(colorScheme: scheme, useMaterial3: true);
  }
}

/// All available themes, in display order.
const List<AppTheme> appThemes = [
  // ── Sistema / básicos ──────────────────────────────────────────────────────
  AppTheme(
    id: 'system_dark',
    name: 'Dark (default)',
    seedColor: Color(0xFF8B0000),
    brightness: Brightness.dark,
  ),
  AppTheme(
    id: 'system_light',
    name: 'Light',
    seedColor: Color(0xFF8B0000),
    brightness: Brightness.light,
  ),

  // ── Por classe ─────────────────────────────────────────────────────────────
  AppTheme(
    id: 'arcane',
    name: 'Arcane',
    seedColor: Color(0xFF6A0DAD), // roxo
    brightness: Brightness.dark,
  ),
  AppTheme(
    id: 'nature',
    name: 'Nature',
    seedColor: Color(0xFF388E3C), // verde vivo
    brightness: Brightness.light,
  ),
  AppTheme(
    id: 'sacred',
    name: 'Sacred',
    seedColor: Color(0xFFB8860B), // dourado
    brightness: Brightness.light,
  ),
  AppTheme(
    id: 'sea',
    name: 'Sea',
    seedColor: Color(0xFF006994), // azul profundo
    brightness: Brightness.dark,
  ),

  // ── Por ambiente ───────────────────────────────────────────────────────────
  AppTheme(
    id: 'elven_forest',
    name: 'Elven Forest',
    seedColor: Color(0xFF228B22), // verde esmeralda
    brightness: Brightness.dark,
  ),
  AppTheme(
    id: 'celestial',
    name: 'Celestial',
    seedColor: Color(0xFF4169E1), // azul real
    brightness: Brightness.light,
  ),
  AppTheme(
    id: 'parchment',
    name: 'Parchment',
    seedColor: Color(0xFF8B5E3C), // marrom couro
    brightness: Brightness.light,
    surfaceColor: Color(0xFFF5E6C8), // bege pergaminho
  ),
];
