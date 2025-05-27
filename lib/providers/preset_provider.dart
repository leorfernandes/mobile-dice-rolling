import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/dice_set.dart';

class PresetProvider with ChangeNotifier {
  List<DiceSetPreset> _presets = [];
  static const String _storageKey = 'dice_presets';

  PresetProvider() {
    _loadPresets();
  }

  List<DiceSetPreset> get presets => List.unmodifiable(_presets);

  // Load presets from storage
  Future<void> _loadPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = prefs.getStringList(_storageKey) ?? [];

      _presets = presetsJson
        .map((item) => DiceSetPreset.fromJson(jsonDecode(item)))
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
  Future<void> addPreset(String name, DiceSet diceSet) async {
    final preset = DiceSetPreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      diceSet: DiceSet(
        dice: diceSet.dice,
        modifier: diceSet.modifier,
      ),
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


class DiceSetPreset {
  final String id;
  final String name;
  final DiceSet diceSet;

  DiceSetPreset({
    required this.id,
    required this.name,
    required this.diceSet,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'diceSet': {
        'dice': diceSet.dice.map((key, value) => MapEntry(key.toString(), value)),
        'modifier': diceSet.modifier,
      },
    };
  }

  // Create from JSON for retrieval
  factory DiceSetPreset.fromJson(Map<String, dynamic> json) {
    final diceSetData = json['diceSet'] as Map<String, dynamic>;
    final diceData = diceSetData['dice'] as Map<String, dynamic>;

    final dice = diceData.map((key, value) =>
        MapEntry(int.parse(key), value as int));
        
    return DiceSetPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      diceSet: DiceSet(
        dice: dice,
        modifier: diceSetData['modifier'] as int,
      ),
    );
  }
}
