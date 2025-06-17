import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  int _presetIndex = 0;
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadThemePreference();
  }

  bool get isDarkMode => _isDarkMode;
  int get presetIndex => _presetIndex;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setPreset(int index) {
    _presetIndex = index;
    _savePresetPreference();
    notifyListeners();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _presetIndex = prefs.getInt('presetIndex') ?? 0;
    notifyListeners();
  }
  
  Future<void> _savePresetPreference() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('presetIndex', _presetIndex);
  }
}