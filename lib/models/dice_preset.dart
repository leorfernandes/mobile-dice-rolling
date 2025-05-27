class DiceSet {
  Map<int, int> dice;
  int modifier;

  DiceSet({
    required this.dice,
    required this.modifier,
  });
}

class DiceSetPreset {
  String id;
  String name;
  DiceSet diceSet;

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
      'sides': {
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