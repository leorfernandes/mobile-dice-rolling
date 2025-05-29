import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import 'package:intl/intl.dart';
import '../screens/roll_detail_screen.dart';

class RollHistory extends StatelessWidget {
  const RollHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, child) {
        final history = historyProvider.history;

        if (history.isEmpty) {
          return const Center(
            child: Text('No rolls yet'),
          );
        }
        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final entry = history[index];

            // Swipe action
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
              confirmDismiss: (direction) async {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RollDetailScreen(rollEntry: entry),
                  ),
                );
                return false;
              },
              child: ListTile(
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
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                ),
                Text(
                  DateFormat.jm().format(entry.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            subtitle: Text(
              'Swipe right for details',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            onTap: () {
              // Tap to view details
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RollDetailScreen(rollEntry: entry),
                )
              );
            }
  
              ),
            );
          },
        );
      },
    );
  }
}