import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/roll_entry.dart';

class RollDetailScreen extends StatelessWidget {
  final RollEntry rollEntry;

  const RollDetailScreen({
    super.key,
    required this.rollEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Roll Details'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with total and timestamp
                Row(
                  children: [
                    Transform.rotate(
                      angle: 45 * (3.14159 / 180), // 45 degrees in radians
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).primaryColor.withOpacity(0.8),
                              Theme.of(context).primaryColor,
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Transform.rotate(
                            angle: -45 * (3.14159 / 180), // Counter-rotate the text
                            child: Text(
                              rollEntry.total.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox (width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rollEntry.diceDescription,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            DateFormat('MMM d, yyyy - h:mm a').format(rollEntry.timestamp),
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                
                // Detailed results for each die type
                const Text(
                  'Roll Results',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),

                ...rollEntry.diceResults.entries.map((e) {
                  final sides = e.key;
                  final results = e.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'D$sides (${results.length} dice)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: results.map((result) {
                            return Transform.rotate(
                              angle: 45 * (3.14159 / 180),
                              child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context).primaryColor.withOpacity(0.8),
                                    Theme.of(context).primaryColor,
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Transform.rotate(
                                  angle: -45 * (3.14159 / 180),
                                  child: Text(
                                    result.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                // Modifier
                if (rollEntry.modifier != 0) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Text(
                          'Modifier:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          rollEntry.modifier > 0
                            ? ' +${rollEntry.modifier}'
                            : '${rollEntry.modifier}',
                          style: TextStyle(
                            color: rollEntry.modifier > 0
                              ? Colors.green
                              : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}