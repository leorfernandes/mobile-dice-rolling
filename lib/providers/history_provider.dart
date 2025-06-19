import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/roll_entry.dart';

/// A provider class that manages dice roll history with persistence
/// using SharedPreferences.
class HistoryProvider with ChangeNotifier {
  // Private fields
  final List<RollEntry> _history = [];
  static const int _maxHistory = 20;
  static const String _storageKey = 'dice_roll_history';

  /// Constructor initializes by loading history from storage
  HistoryProvider() {
    _loadHistory();
  }

  /// Public getter for history that prevents modification
  List<RollEntry> get history => List.unmodifiable(_history);

  /// Loads roll history from SharedPreferences
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_storageKey) ?? [];

      _history.clear();
      for (var item in historyJson) {
        try {
          final entry = RollEntry.fromJson(jsonDecode(item));
          _history.add(entry);
        } catch (e) {
          debugPrint('Error decoding history entry: $e');
          // Continue with other entries even if one fails
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading history: $e');
      _history.clear();
      // In a production app, you might want to show a user-facing error
    }
  }

  /// Saves roll history to SharedPreferences
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _history
          .map((entry) => jsonEncode(entry.toJson()))
          .toList();

      await prefs.setStringList(_storageKey, historyJson);
    } catch (e) {
      debugPrint('Error saving history: $e');
      // Consider implementing retry logic or notifying the user
    }
  }

  /// Adds a new dice roll to the history
  /// 
  /// [results] - Map of number of dice to their roll results
  /// [sides] - Number of sides on the dice
  /// [modifier] - Optional modifier added to the roll total
  void addCombinedRoll(Map<int, List<int>> results, int sides, [int modifier = 0]) {
    if (results.isEmpty) {
      debugPrint('Warning: Attempted to add empty roll results');
      return; // Don't add empty rolls
    }

    _history.insert(0, RollEntry(
      diceResults: Map<int, List<int>>.from(results),
      modifier: modifier,
      timestamp: DateTime.now(),
    ));

    // Maintain maximum history size
    if(_history.length > _maxHistory) {
      _history.removeLast();
    }

    _saveHistory();
    notifyListeners();
  }

  /// Clears all roll history
  void clearHistory() {
    _history.clear();
    _saveHistory();
    notifyListeners();
  }
}