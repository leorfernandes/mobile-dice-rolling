import 'package:flutter/material.dart';
import '../models/dice_set.dart';

/// Provides state management for dice sets throughout the application.
/// Uses ChangeNotifier to inform listeners when dice set data changes.
class DiceSetProvider with ChangeNotifier {
  // Current active dice set
  DiceSet _currentDiceSet = DiceSet(dice: {});
  
  // Whether to show the modifier UI element
  bool _showModifier = false;

  /// Getters
  DiceSet get currentDiceSet => _currentDiceSet;
  bool get showModifier => _showModifier;

  /// Updates the count of dice with specific sides.
  /// 
  /// [sides] - The number of sides on the die
  /// [count] - How many of this die type to include
  void updateDiceCount(int sides, int count) {
    if (sides <= 0) {
      throw ArgumentError('Dice sides must be a positive number');
    }
    
    if (count < 0) {
      throw ArgumentError('Dice count cannot be negative');
    }
    
    final newDice = Map<int, int>.from(_currentDiceSet.dice);
    
    if (count == 0) {
      // Remove the entry if count is zero
      newDice.remove(sides);
    } else {
      newDice[sides] = count;
    }
    
    _currentDiceSet = _currentDiceSet.copyWith(dice: newDice);
    notifyListeners();
  }

  /// Updates the modifier value for the current dice set.
  void updateModifier(int modifier) {
    _currentDiceSet = _currentDiceSet.copyWith(modifier: modifier);
    notifyListeners();
  }

  /// Loads a new dice set, replacing the current one.
  /// 
  /// Creates a deep copy to avoid reference issues.
  void loadDiceSet(DiceSet diceSet) {
    if (diceSet == null) {
      throw ArgumentError('Cannot load a null dice set');
    }
    
    _currentDiceSet = DiceSet(
      dice: Map<int, int>.from(diceSet.dice),
      modifier: diceSet.modifier,
    );
    notifyListeners();
  }

  /// Clears the current dice set by replacing it with an empty one.
  void clearDiceSet() {
    _currentDiceSet = DiceSet(dice: {});
    notifyListeners();
  }

  /// Controls the visibility of the modifier UI element.
  void toggleModifier(bool value) {
    _showModifier = value;
    notifyListeners();
  }
}
