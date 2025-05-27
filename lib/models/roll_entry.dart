class RollEntry {
  final Map<int, List<int>> diceResults;
  final int modifier;
  final DateTime timestamp;

  const RollEntry({
    required this.diceResults,
    required this.modifier,
    required this.timestamp,
  });

  // Total result including modificer
  int get total {
    int sum = 0;
    diceResults.forEach((sides, result) {
      sum += result.fold<int>(0, (sum, roll) => sum + roll);
    });
    return sum + modifier;
  }
  
  // Get a formatted description of the dice rolled
  String get diceDescription {
    List<String> parts = [];
    diceResults.forEach((sides, results) {
      if (results.isNotEmpty) {
        parts.add('${results.length}d$sides');
      }
    });
    return parts.join(' + ');
  }

  // Number of dice rolled
  int get diceCount => diceResults.length;

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    // Convert the map to a format that can be serialized
    Map<String, List<int>> serializedResults = {};
    diceResults.forEach((sides, results) {
      serializedResults[sides.toString()] = results;
    });

    return {
      'diceResults': serializedResults,
      'modifier': modifier,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from JSON for retrieval
  factory RollEntry.fromJson(Map<String, dynamic> json) {
    Map<int, List<int>> deserializedResults = {};

    // Handle different data formats
    final resultsData = json['diceResults'];
    if (resultsData is Map) {
      resultsData.forEach((key, value) {
        final sides = int.parse(key);
        if (value is List) {
          deserializedResults[sides] = List<int>.from(value);
        }
      });
    }

    return RollEntry(
      diceResults: deserializedResults,
      modifier: (json['modifier'] as int?) ?? 0,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}