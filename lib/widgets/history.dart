import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import 'package:intl/intl.dart';

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
          shrinkWrap: true,
          itemCount: history.length,
          itemBuilder: (context, index) {
            final entry = history[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  child: Text(entry.total.toString()),
                ),
                title: Row( 
                  children: [
                    Text(entry.diceCount > 1
                      ? '${entry.diceCount}d${entry.sides}'
                      : 'd${entry.sides}',
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  const Spacer(),
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
                entry.diceCount > 1
                  ? 'Rolls: ${entry.diceResults.join(', ')}' +
                    (entry.modifier != 0 ? ' + Mod: ${entry.modifier}' : '')
                  : (entry.modifier != 0 
                    ? 'Roll: ${entry.diceResults.isNotEmpty 
                      ? entry.diceResults[0] 
                      : 0
                      } + Mod: ${entry.modifier}'
                    : 'Roll: ${entry.diceResults.isNotEmpty 
                      ? entry.diceResults[0] 
                      : 0
                      }'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            );
          },
        );
      },
    );
  }
}