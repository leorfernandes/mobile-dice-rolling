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

  // Override toString for debugging
  @override
  String toString() => 'Dice(sides: $sides)';
}