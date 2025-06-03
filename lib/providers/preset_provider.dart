import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dice_set.dart';

class DiceSetPreset {
  final String id;
  final String name;
  final DiceSet diceSet;

  DiceSetPreset({
    required this.id,
    required this.name,
    required this.diceSet,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'diceSet': diceSet.toMap()
    };
  }

  factory DiceSetPreset.fromMap(Map<String, dynamic> map) {
    return DiceSetPreset(
      id: map['id'],
      name: map['name'],
      diceSet: DiceSet.fromMap(map['diceSet']),
    );
  }
}

class PresetProvider with ChangeNotifier {
  List<DiceSetPreset> _presets = [];

  PresetProvider() {
    _loadPresets();
  }

  List<DiceSetPreset> get presets => [..._presets];

  // Load presets from storage
  Future<void> _loadPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = prefs.getStringList('presets') ?? [];

      _presets = presetsJson.map((json) {return DiceSetPreset.fromMap(jsonDecode(json));}).toList();

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
        .map((preset) {return jsonEncode(preset.toMap());})
        .toList();

      await prefs.setStringList('presets', presetsJson);
    } catch (e) {
      print('Error saving presets: $e');
    }
  }

  // Add a new preset
  void addPreset(String name, DiceSet diceSet) async {
    _presets.add(DiceSetPreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      diceSet: DiceSet(
        dice: diceSet.dice,
        modifier: diceSet.modifier,
      ),
    ));

    _savePresets();
    notifyListeners();
  }

  void updatePresetName(String id, String newName) {
    final index = _presets.indexWhere((preset) => preset.id == id);
    if (index >= 0) {
      final preset = _presets[index];
      _presets[index] = DiceSetPreset(
        id: preset.id,
        name: newName,
        diceSet: preset.diceSet,
      );

      _savePresets();
      notifyListeners();
    }
  }

  // Delete a preset
  void deletePreset(String id) {
    _presets.removeWhere((preset) => preset.id == id);

    _savePresets();
    notifyListeners();
  }
}