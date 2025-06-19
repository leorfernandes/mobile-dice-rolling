import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app's theme settings and persistence
class ThemeProvider with ChangeNotifier {
  // Theme state variables
  bool _isDarkMode = false;
  int _presetIndex = 0;
  
  // Keys for shared preferences
  static const String _darkModeKey = 'isDarkMode';
  static const String _presetIndexKey = 'presetIndex';

  /// Constructor - loads saved preferences
  ThemeProvider() {
    _loadThemePreference();
  }

  /// Getters
  bool get isDarkMode => _isDarkMode;
  int get presetIndex => _presetIndex;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Toggles between light and dark mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveThemePreference();
    notifyListeners();
  }

  /// Changes the color preset index
  Future<void> setPreset(int index) async {
    _presetIndex = index;
    await _savePresetPreference();
    notifyListeners();
  }

  /// Loads theme preferences from storage
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
      _presetIndex = prefs.getInt(_presetIndexKey) ?? 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preferences: $e');
      // Use defaults if loading fails
    }
  }
  
  /// Saves dark mode preference
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, _isDarkMode);
    } catch (e) {
      debugPrint('Error saving dark mode preference: $e');
    }
  }
  
  /// Saves preset preference
  Future<void> _savePresetPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_presetIndexKey, _presetIndex);
    } catch (e) {
      debugPrint('Error saving preset preference: $e');
    }
  }
}