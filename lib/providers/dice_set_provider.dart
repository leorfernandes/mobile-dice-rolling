import 'package:flutter/material.dart';
import '../models/dice_set.dart';

class DiceSetProvider with ChangeNotifier {
  DiceSet _currentDiceSet = DiceSet(dice: {});
  bool _showModifier = false;

  DiceSet get currentDiceSet => _currentDiceSet;
  bool get showModifier => _showModifier;

  void updateDiceCount(int sides, int count) {
    final newDice = Map<int, int>.from(_currentDiceSet.dice);
    newDice[sides] = count;
    _currentDiceSet = _currentDiceSet.copyWith(dice: newDice);
    notifyListeners();
  }

  void updateModifier(int modifier) {
    _currentDiceSet = _currentDiceSet.copyWith(modifier: modifier);
    notifyListeners();
  }

  void loadDiceSet(DiceSet diceSet) {
    _currentDiceSet = DiceSet(
      dice: Map<int, int>.from(diceSet.dice),
      modifier: diceSet.modifier,
    );
    notifyListeners();
  }

  void clearDiceSet() {
    _currentDiceSet = DiceSet(dice: {});
    notifyListeners();
  }

  void toggleModifier(bool value) {
    _showModifier = value;
    notifyListeners();
  }
}
