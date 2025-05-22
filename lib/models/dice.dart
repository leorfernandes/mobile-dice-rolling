import 'dart:math';

class Dice {
  final int sides;

  //Constructor
  const Dice({required this.sides});

  //Method to roll the dice
  int roll() {
    final random = Random();
    return random.nextInt(sides) + 1;
  }
  
  // Roll multiple dice and return individual results
  List<int> rollMultiple(int count) {
    final results = <int>[];
    final random = Random();

    for (int i = 0; i < count; i++) {
      results.add(random.nextInt(sides) + 1);
    }

    return results;
  }

  // Override toString for debugging
  @override
  String toString() => 'Dice(sides: $sides)';
}