class RollEntry {
  final List<int> diceResults;
  final int sides;
  final int modifier;
  final DateTime timestamp;

  const RollEntry({
    required this.diceResults,
    required this.sides,
    required this.modifier,
    required this.timestamp,
  });

  // Total result including modificer
  int get total => diceResults.fold<int>(0, (sum, roll) => sum + roll) + modifier;

  // Number of dice rolled
  int get diceCount => diceResults.length;

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'diceResults': diceResults.toList(),
      'sides': sides,
      'modifier': modifier,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from JSON for retrieval
  factory RollEntry.fromJson(Map<String, dynamic> json) {
    var resultsData = json['diceResults'];
    List<int> results;
    
    // Handle different types of JSON data
    if (resultsData is List) {
      results = resultsData.map<int>((item) => item as int).toList();
    } else if (resultsData is int) {
      results = [resultsData];
    } else {
      results = [];
    }

    return RollEntry(
      diceResults: results,
      sides: json['sides'] as int,
      modifier: (json['modifier'] as int) ?? 0,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}