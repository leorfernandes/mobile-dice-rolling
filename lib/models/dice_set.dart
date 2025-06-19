/// Represents a set of dice with different sides and a modifier
class DiceSet {
  /// Map of dice where key is number of sides and value is count of dice
  final Map<int, int> dice;
  
  /// Modifier to add to the total dice roll
  final int modifier;

  /// Creates a dice set with specified dice and optional modifier
  const DiceSet({
    required this.dice,
    this.modifier = 0,
  });

  /// Returns true if the dice set has no dice
  bool get isEmpty => dice.values.every((count) => count == 0);

  /// Creates a copy of this dice set with optional new values
  DiceSet copyWith({
    Map<int, int>? dice,
    int? modifier,
  }) {
    return DiceSet(
      dice: dice ?? Map<int, int>.from(this.dice),
      modifier: modifier ?? this.modifier,
    );
  }

  /// Adds a die with specified sides to the set
  /// 
  /// [sides] must be positive
  DiceSet addDie(int sides) {
    if (sides <= 0) {
      throw ArgumentError('Die sides must be positive: $sides');
    }
    
    final newDice = Map<int, int>.from(dice);
    newDice[sides] = (newDice[sides] ?? 0) + 1;
    return copyWith(dice: newDice);
  }

  /// Removes a single die with specified sides from the set
  /// 
  /// Returns the original set if no such die exists
  DiceSet removeDie(int sides) {
    if (!dice.containsKey(sides) || dice[sides] == 0) {
      return this;
    }
    
    final newDice = Map<int, int>.from(dice);
    newDice[sides] = newDice[sides]! - 1;
    if (newDice[sides] == 0) {
      newDice.remove(sides);
    }
    return copyWith(dice: newDice);
  }

  /// Removes all dice with specified sides from the set
  /// 
  /// Returns the original set if no such dice exist
  DiceSet clearDie(int sides) {
    if (!dice.containsKey(sides) || dice[sides] == 0) {
      return this;
    }
    
    final newDice = Map<int, int>.from(dice);
    newDice.remove(sides);
    return copyWith(dice: newDice);
  }

  /// Returns a formatted description of the dice set (e.g., "2d6 1d20 + 3")
  String get description {
    if (isEmpty && modifier == 0) {
      return "Empty dice set";
    }
    
    final parts = <String>[];
    
    // Add dice descriptions
    dice.forEach((sides, count) {
      if (count > 0) {
        parts.add('${count}d$sides');
      }
    });
    
    // Add modifier if present
    if (modifier > 0) {
      parts.add('+ $modifier');
    } else if (modifier < 0) {
      parts.add('- ${modifier.abs()}');
    }
    
    return parts.join(' ');
  }

  // Serialization and Deserialization

  /// Converts this dice set to a map for serialization
  Map<String, dynamic> toMap() {
    return {
      'dice': dice.map((key, value) => MapEntry(key.toString(), value)),
      'modifier': modifier,
    };
  }

  /// Creates a dice set from a serialized map
  /// 
  /// Throws FormatException if the map contains invalid data
  factory DiceSet.fromMap(Map<String, dynamic> map) {
    try {
      final diceMap = (map['dice'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(int.parse(key), value as int));
      
      return DiceSet(
        dice: diceMap,
        modifier: map['modifier'] as int,
      );
    } catch (e) {
      throw FormatException('Invalid dice set format: $e', map);
    }
  }

  /// Creates an empty dice set
  factory DiceSet.empty() {
    return const DiceSet(dice: {});
  }
}
