import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/roll_entry.dart';

class HistoryProvider with ChangeNotifier {
  final List<RollEntry> _history = [];
  static const int _maxHistory = 20;
  static const String _storageKey = 'dice_roll_history';

  HistoryProvider() {
    _loadHistory();
  }

  List<RollEntry> get history => List.unmodifiable(_history);

  // Load history from storage
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_storageKey) ?? [];

    _history.clear();
    _history.addAll(historyJson
      .map((item) => RollEntry.fromJson(jsonDecode(item)))
      .toList());

    notifyListeners();
  }

  // Save history to storage
  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _history
      .map((entry) => jsonEncode(entry.toJson()))
      .toList();

    await prefs.setStringList(_storageKey, historyJson);
  }

  // Add a new roll entry
  void addRoll (int result, int sides, [int modifier = 0]) {
    _history.insert(0, RollEntry(
      result: result,
      sides: sides,
      modifier: modifier,
      timestamp: DateTime.now(),
    ));

    if(_history.length > _maxHistory) {
      _history.removeLast();
    }

    _saveHistory();
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    _saveHistory();
    notifyListeners();
  }
}