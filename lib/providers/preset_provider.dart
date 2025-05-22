import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/dice_preset.dart';

class PresetProvider with ChangeNotifier {
  List<DicePreset> _presets = [];
  static const String _storageKey = 'dice_presets';

  PresetProvider() {
    _loadPresets();
  }

  List<DicePreset> get presets => List.unmodifiable(_presets);

  // Load presets from storage
  Future<void> _loadPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = prefs.getStringList(_storageKey) ?? [];

      _presets = presetsJson
        .map((item) => DicePreset.fromJson(jsonDecode(item)))
        .toList();

      notifyListeners();
    } catch (e) {
      print('Error loading presets: $e');
      _presets = [];
    }
  }

  // Save presets to storage
  Future<void> _savePresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = _presets
        .map((preset) => jsonEncode(preset.toJson()))
        .toList();

      await prefs.setStringList(_storageKey, presetsJson);
    } catch (e) {
      print('Error saving presets: $e');
    }
  }

  // Add a new preset
  Future<void> addPreset(String name, int sides, int count, int modifier) async {
    final preset = DicePreset(
      id: const Uuid().v4(),
      name: name,
      sides: sides,
      count: count,
      modifier: modifier,
    );

    _presets.add(preset);
    await _savePresets();
    notifyListeners();
  }

  // Delete a preset
  Future<void> deletePreset(String id) async {
    _presets.removeWhere((preset) => preset.id == id);
    await _savePresets();
    notifyListeners();
  }
}