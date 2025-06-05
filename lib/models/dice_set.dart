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
      dice: dice ?? Map<int, int>.from(this.dice),
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

  Map<String, dynamic> toMap() {
    return {
      'dice': dice.map((key, value) => MapEntry(key.toString(), value)),
      'modifier': modifier,
    };
  }

  factory DiceSet.fromMap(Map<String, dynamic> map) {
    final diceMap = (map['dice'] as Map<String, dynamic>).map((key, value) => 
      MapEntry(int.parse(key), value as int));
    
    return DiceSet(
      dice: diceMap,
      modifier: map['modifier'] as int,
    );
  }
}