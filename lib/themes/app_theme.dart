import 'package:flutter/material.dart';

class ColorPreset {
  final String name;
  final Color primary;
  final Color background;
  final Color accent;
  final Color text;

  const ColorPreset({
    required this.name,
    required this.primary,
    required this.background,
    required this.accent,
    required this.text,
  });
}

class AppTheme {
  static const colorPresets = [
    ColorPreset(
      name: 'Fantasy Classic',
      primary: Color(0xFF8B5E3C),
      background: Color(0xFFF3E6C2),
      accent: Color(0xFFC49A6C),
      text: Color(0xFF2E1B0B),
    ),
    ColorPreset(
      name: 'Dark Classic',
      primary: Color(0xFF4B1D3F),
      background: Color(0xFF1A1A1D),
      accent: Color(0xFFB00020),
      text: Color(0xFFEDEDED),
    ),
    ColorPreset(
      name: 'Dark Mystery',
      primary: Color(0xFF1C3C3E),
      background: Color(0xFF0F1A1C),
      accent: Color(0xFF6D9886),
      text: Color(0xFFD9D9D6),
    ),
    ColorPreset(
      name: 'Cyberpunk',
      primary: Color(0xFF00FFF7),
      background: Color(0xFF0C0C0C),
      accent: Color(0xFFFF006F),
      text: Color(0xFFFFFFFF),
    ),
    ColorPreset(
      name: 'Whimsical',
      primary: Color(0xFFFFB5E8),
      background: Color(0xFFFFF6F0),
      accent: Color(0xFFB28DFF),
      text: Color(0xFF44355B),
    ),
  ];
  
  static ThemeData createTheme(ColorPreset preset, {bool isDark = false}) {
    if (isDark) {
      // Joke dark mode:
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Colors.black,
          onPrimary: Colors.black,
          secondary: Colors.black,
          onSecondary: Colors.black,
          background: Colors.black,
          onBackground: Colors.black,
          surface: Colors.black,
          onSurface: Colors.black,
          error: Colors.black,
          onError: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          titleLarge: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      );
    }
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: preset.primary,
        onPrimary: preset.text,
        primaryContainer: preset.primary.withOpacity(0.8),
        onPrimaryContainer: preset.text,
        secondary: preset.accent,
        onSecondary: preset.text,
        secondaryContainer: preset.accent.withOpacity(0.8),
        onSecondaryContainer: preset.text,
        background: preset.background,
        onBackground: preset.text,
        surface: preset.background,
        onSurface: preset.text,
        error: Colors.red,
        onError: Colors.white,
        outline: preset.accent.withOpacity(0.5),
        outlineVariant: preset.accent.withOpacity(0.3),
        // Add any other required ColorScheme fields if needed
      ),
      scaffoldBackgroundColor: preset.background,
    );
  }

  static ThemeData get lightTheme => createTheme(colorPresets[0], isDark: false);
  static ThemeData get darkTheme => createTheme(colorPresets[0], isDark: true);
}