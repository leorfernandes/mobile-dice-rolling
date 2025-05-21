class RollEntry {
  final int result;
  final int sides;
  final int modifier;
  final DateTime timestamp;

  const RollEntry({
    required this.result,
    required this.sides,
    required this.modifier,
    required this.timestamp,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'sides': sides,
      'modifier': modifier,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from JSON for retrieval
  factory RollEntry.fromJson(Map<String, dynamic> json) {
    return RollEntry(
      result: json['result'],
      sides: json['sides'],
      modifier: json['modifier'] ?? 0,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}