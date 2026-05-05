import 'package:flutter/material.dart';

/// Describes a named application theme.
class AppTheme {
  const AppTheme({
    required this.id,
    required this.name,
    required this.seedColor,
    this.brightness = Brightness.dark,
  });

  final String id;
  final String name;
  final Color seedColor;
  final Brightness brightness;

  ThemeData toThemeData() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: brightness,
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
    id: 'shadows',
    name: 'Shadows',
    seedColor: Color(0xFF1A0A2E), // roxo quase preto
    brightness: Brightness.dark,
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
    id: 'inferno',
    name: 'Inferno',
    seedColor: Color(0xFFFF1A00), // vermelho vivo
    brightness: Brightness.dark,
  ),
  AppTheme(
    id: 'celestial',
    name: 'Celestial',
    seedColor: Color(0xFF4169E1), // azul real
    brightness: Brightness.light,
  ),
];
