import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';
import '../screens/roll_detail_screen.dart';

/// A widget that displays the history of dice rolls.
/// Shows a list of previous rolls with their results and timestamps.
class RollHistory extends StatelessWidget {
  const RollHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, child) {
        final history = historyProvider.history;

        // Show message when no rolls are available
        if (history.isEmpty) {
          return const Center(
            child: Text('No rolls yet'),
          );
        }

        // Display list of roll history entries
        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            // Safety check to prevent index out of range errors
            if (index >= history.length) {
              return null;
            }

            final entry = history[index];
            
            // Create dismissible entry with swipe action
            return Dismissible(
              key: ValueKey(entry.timestamp.millisecondsSinceEpoch),
              direction: DismissDirection.startToEnd,
              background: Container(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                ),
              ),
              // Handle swipe confirmation if needed
              confirmDismiss: (direction) async {
                // Currently just showing details on swipe, return false to prevent dismissal
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RollDetailScreen(rollEntry: entry),
                  )
                );
                return false;
              },
              child: _buildRollEntryTile(context, entry),
            );
          },
        );
      },
    );
  }

  /// Builds a ListTile for a single roll history entry
  Widget _buildRollEntryTile(BuildContext context, dynamic entry) {
    // Format the timestamp for display
    final formattedTime = DateFormat.jm().format(entry.timestamp);
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: Text(entry.total.toString()),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              entry.diceDescription,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      subtitle: Text(
        'Tap for details',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      ),
      onTap: () {
        // Navigate to detail screen on tap
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RollDetailScreen(rollEntry: entry),
          )
        );
      },
    );
  }
}