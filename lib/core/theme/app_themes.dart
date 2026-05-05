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
    name: 'Escuro (padrão)',
    seedColor: Color(0xFF8B0000),
    brightness: Brightness.dark,
  ),
  AppTheme(
    id: 'system_light',
    name: 'Claro',
    seedColor: Color(0xFF8B0000),
    brightness: Brightness.light,
  ),

  // ── Por classe ─────────────────────────────────────────────────────────────
  AppTheme(
    id: 'arcano',
    name: 'Arcano',
    seedColor: Color(0xFF6A0DAD), // roxo
    brightness: Brightness.dark,
  ),
  AppTheme(
    id: 'natureza',
    name: 'Natureza',
    seedColor: Color(0xFF2D6A4F), // verde musgo
    brightness: Brightness.dark,
  ),
  AppTheme(
    id: 'sagrado',
    name: 'Sagrado',
    seedColor: Color(0xFFB8860B), // dourado
    brightness: Brightness.light,
  ),
  AppTheme(
    id: 'sombras',
    name: 'Sombras',
    seedColor: Color(0xFF8B0000), // vermelho escuro
    brightness: Brightness.dark,
  ),
  AppTheme(
    id: 'ferreiro',
    name: 'Ferreiro',
    seedColor: Color(0xFFBF5700), // laranja ferrugem
    brightness: Brightness.dark,
  ),
  AppTheme(
    id: 'mar',
    name: 'Mar',
    seedColor: Color(0xFF006994), // azul profundo
    brightness: Brightness.dark,
  ),

  // ── Por ambiente ───────────────────────────────────────────────────────────
  AppTheme(
    id: 'dungeon',
    name: 'Dungeon',
    seedColor: Color(0xFF4A3728), // pedra marrom
    brightness: Brightness.dark,
  ),
  AppTheme(
    id: 'floresta_elfica',
    name: 'Floresta Élfica',
    seedColor: Color(0xFF228B22), // verde esmeralda
    brightness: Brightness.dark,
  ),
  AppTheme(
    id: 'inferno',
    name: 'Inferno',
    seedColor: Color(0xFFCC2200), // vermelho brasa
    brightness: Brightness.dark,
  ),
  AppTheme(
    id: 'celeste',
    name: 'Celeste',
    seedColor: Color(0xFF4169E1), // azul real
    brightness: Brightness.light,
  ),
];
