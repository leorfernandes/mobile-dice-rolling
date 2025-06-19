/// Represents a single dice roll event with results for different dice types,
/// a modifier, and timestamp.
class RollEntry {
  /// Map of dice sides to roll results (key: number of sides, value: list of individual rolls)
  final Map<int, List<int>> diceResults;
  
  /// Numeric modifier added to the total roll
  final int modifier;
  
  /// When the roll was made
  final DateTime timestamp;

  /// Creates an immutable roll entry
  const RollEntry({
    required this.diceResults,
    required this.modifier,
    required this.timestamp,
  });

  /// Calculates the total result including modifier
  int get total {
    int sum = 0;
    diceResults.forEach((sides, result) {
      sum += result.fold<int>(0, (sum, roll) => sum + roll);
    });
    return sum + modifier;
  }
  
  /// Returns a formatted description of the dice rolled (e.g., "2d6 + 1d20")
  String get diceDescription {
    if (diceResults.isEmpty) {
      return "No dice";
    }
    
    List<String> parts = [];
    diceResults.forEach((sides, results) {
      if (results.isNotEmpty) {
        parts.add('${results.length}d$sides');
      }
    });
    return parts.join(' + ');
  }

  /// Returns the total number of individual dice rolled
  int get diceCount {
    int count = 0;
    diceResults.forEach((_, results) => count += results.length);
    return count;
  }

  /// Converts roll entry to JSON for storage
  Map<String, dynamic> toJson() {
    try {
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
    } catch (e) {
      // Log error and return a valid but empty structure
      print('Error serializing RollEntry: $e');
      return {
        'diceResults': <String, List<int>>{},
        'modifier': 0,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Creates a RollEntry from JSON data
  factory RollEntry.fromJson(Map<String, dynamic> json) {
    try {
      Map<int, List<int>> deserializedResults = {};

      // Handle different data formats
      final resultsData = json['diceResults'];
      if (resultsData is Map) {
        resultsData.forEach((key, value) {
          try {
            final sides = int.parse(key);
            if (value is List) {
              deserializedResults[sides] = List<int>.from(value.map((v) => 
                v is int ? v : int.parse(v.toString())));
            }
          } catch (e) {
            print('Error parsing dice data for key $key: $e');
          }
        });
      }

      return RollEntry(
        diceResults: deserializedResults,
        modifier: (json['modifier'] as num?)?.toInt() ?? 0,
        timestamp: json['timestamp'] != null 
            ? DateTime.parse(json['timestamp'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      print('Error deserializing RollEntry: $e');
      // Return a valid but empty roll entry on error
      return RollEntry(
        diceResults: {},
        modifier: 0,
        timestamp: DateTime.now(),
      );
    }
  }
}