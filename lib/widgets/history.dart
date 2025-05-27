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
          itemCount: history.length,
          itemBuilder: (context, index) {
            final entry = history[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              child: Text(entry.total.toString()),
            ),
            title: Row(
              children: [
                Text(
                  entry.diceDescription,
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
              subtitle: Wrap(
                spacing: 4,
                children: [
                  ...entry.diceResults.entries.map((e) {
                    return Chip(
                      label: Text(
                        'D${e.key}: [${e.value.join(', ')}]',
                        style: const TextStyle(fontSize: 12),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }),
                  if (entry.modifier != 0)
                    Chip(
                      label: Text('Mod: ${entry.modifier}'),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}