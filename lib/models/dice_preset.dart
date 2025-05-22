class DicePreset {
  final String id;
  final String name;
  final int sides;
  final int count;
  final int modifier;

  const DicePreset({
    required this.id,
    required this.name,
    required this.sides,
    required this.count,
    this.modifier = 0,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sides': sides,
      'count': count,
      'modifier': modifier,
    };
  }

  // Create from JSON for retrieval
  factory DicePreset.fromJson(Map<String, dynamic> json) {
    return DicePreset(
      id: json['id'] as String,
      name: json['name'] as String,
      sides: json['sides'] as int,
      count: json['count'] as int,
      modifier: (json['modifier'] as int?) ?? 0,
    );
  }
}