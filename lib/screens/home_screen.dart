import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/dice_roller.dart';
import '../widgets/history.dart';
import '../providers/history_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dice Roller'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),

      // Drawer for roll history
      drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: const Center(
                  child: Text(
                    'Roll History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lastest Rolls',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 24,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        Provider.of<HistoryProvider>(context, listen: false).clearHistory();
                      },
                      tooltip: 'Clear History',
                    ),
                  ],
                ),
              ),
              const Divider(),
              // History list takes remaining space
              const Expanded(child: RollHistory()),
            ],
          ),
        ),
      
      // Main content
      
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: Card(
                    elevation: 4,
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      child: DiceRoller(),
                    ),
                  ),
                ),
              ]
            )
          )
        )
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          child: const Icon(Icons.history),
          tooltip: 'Show History',
        ),
      ),
    );
  }
}