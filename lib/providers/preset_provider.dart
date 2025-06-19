import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dice_set.dart';

/// Represents a saved dice set configuration with a unique identifier and name
class DiceSetPreset {
  final String id;
  final String name;
  final DiceSet diceSet;

  DiceSetPreset({
    required this.id,
    required this.name,
    required this.diceSet,
  });

  /// Converts the preset to a map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'diceSet': diceSet.toMap()
    };
  }

  /// Creates a preset from a map
  factory DiceSetPreset.fromMap(Map<String, dynamic> map) {
    if (map['id'] == null || map['name'] == null || map['diceSet'] == null) {
      throw FormatException('Invalid preset data structure');
    }
    
    return DiceSetPreset(
      id: map['id'],
      name: map['name'],
      diceSet: DiceSet.fromMap(map['diceSet']),
    );
  }
}

/// Manages the creation, storage, and retrieval of dice set presets
class PresetProvider with ChangeNotifier {
  List<DiceSetPreset> _presets = [];
  static const String _storageKey = 'saved_presets';
  bool _isLoading = true;

  PresetProvider() {
    _loadPresets();
  }

  /// Returns a copy of the presets list
  List<DiceSetPreset> get presets => [..._presets];
  
  /// Returns whether presets are currently loading
  bool get isLoading => _isLoading;

  /// Loads presets from SharedPreferences
  Future<void> _loadPresets() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = prefs.getStringList(_storageKey) ?? [];

      _presets = presetsJson.map((json) {
        try {
          final map = jsonDecode(json);
          return DiceSetPreset.fromMap(map);
        } catch (e) {
          debugPrint('Error parsing preset: $e');
          return null;
        }
      })
      .whereType<DiceSetPreset>() // Filter out null values
      .toList();

    } catch (e) {
      debugPrint('Error loading presets: $e');
      _presets = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves presets to SharedPreferences
  Future<bool> _savePresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = _presets
        .map((preset) => jsonEncode(preset.toMap()))
        .toList();

      return await prefs.setStringList(_storageKey, presetsJson);
    } catch (e) {
      debugPrint('Error saving presets: $e');
      return false;
    }
  }

  /// Adds a new preset with the given name and dice set
  Future<bool> addPreset(String name, DiceSet diceSet) async {
    if (name.isEmpty) {
      return false;
    }
    
    _presets.add(DiceSetPreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      diceSet: DiceSet(
        dice: Map<int, int>.from(diceSet.dice),
        modifier: diceSet.modifier,
      ),
    ));

    final success = await _savePresets();
    notifyListeners();
    return success;
  }

  /// Updates the name of a preset with the given ID
  Future<bool> updatePresetName(String id, String newName) async {
    if (newName.isEmpty) {
      return false;
    }
    
    final index = _presets.indexWhere((preset) => preset.id == id);
    if (index < 0) {
      return false;
    }
    
    final preset = _presets[index];
    _presets[index] = DiceSetPreset(
      id: preset.id,
      name: newName,
      diceSet: preset.diceSet,
    );

    final success = await _savePresets();
    notifyListeners();
    return success;
  }

  /// Deletes a preset with the given ID
  Future<bool> deletePreset(String id) async {
    final initialLength = _presets.length;
    _presets.removeWhere((preset) => preset.id == id);
    
    if (_presets.length == initialLength) {
      return false; // No preset was removed
    }

    final success = await _savePresets();
    notifyListeners();
    return success;
  }
}