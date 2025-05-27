class DiceSet {
  final Map<int, int> dice;
  final int modifier;

  //Constructor
  const DiceSet({
    required this.dice,
    this.modifier = 0,
  });

  DiceSet copyWith({
    Map<int, int>? dice,
    int? modifier,
  }) {
    return DiceSet(
      dice: dice ?? Map.from(this.dice),
      modifier: modifier ?? this.modifier,
    );
  }

  // Add a die type to the set
  DiceSet addDie(int sides) {
    final newDice = Map<int, int>.from(dice);
    newDice[sides] = (newDice[sides] ?? 0) + 1;
    return copyWith(dice: newDice);
  }

  // Remove a die type from the set
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

  // Get a formatted description of the dice set
  String get description {
    List<String> parts = [];

    dice.forEach((sides, count) {
      if (count > 0) {
        parts.add('${count}d$sides');
      }
    });

    if (modifier > 0) {
      parts.add('+ $modifier');
    } else if (modifier < 0) {
      parts.add('- ${modifier.abs()}');
    }

    return parts.join(' ');
  }
}