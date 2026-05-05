import 'package:flutter/material.dart';

/// Describes a named application theme.
class AppTheme {
  const AppTheme({
    required this.id,
    required this.name,
    required this.seedColor,
    this.brightness = Brightness.dark,
    this.contrastLevel = 0.0,
  });

  final String id;
  final String name;
  final Color seedColor;
  final Brightness brightness;
  final double contrastLevel;

  ThemeData toThemeData() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: brightness,
          contrastLevel: contrastLevel,
        ),
        useMaterial3: true,
      );
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
    seedColor: Color(0xFF2D6A4F), // verde musgo
    brightness: Brightness.dark,
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

  // ── Acessibilidade ─────────────────────────────────────────────────────────
  AppTheme(
    id: 'high_contrast',
    name: 'High Contrast',
    seedColor: Color(0xFFFFFFFF),
    brightness: Brightness.dark,
    contrastLevel: 1.0,
  ),
];
