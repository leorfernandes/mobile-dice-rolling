import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dice.dart';
import '../models/custom_buttons.dart';
import '../providers/sound_provider.dart';

class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});

  @override
  State<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends State<DiceRoller>{
  final List<int> _availableDice = [4, 6, 8, 10, 12, 20, 100];
  int _selectedDiceSides = 6;
  int _currentValue = 1;
  bool _isRolling = false;

  Future<void> _rollDice() async {
    setState(() {
      _isRolling = true;
    });

    // Play sound
    final soundProvider = Provider.of<SoundProvider>(context, listen: false);
    await soundProvider.playRollSound();

    // Small delay to simulate rolling
    await Future.delayed(const Duration(milliseconds: 1000));
  
    final dice = Dice(sides: _selectedDiceSides);
    setState(() {
      _currentValue = dice.roll();
      _isRolling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              const Text(
                'Select Dice:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _selectedDiceSides,
                items: _availableDice.map((sides) {
                  return DropdownMenuItem<int>(
                    value: sides,
                    child: Text('d$sides'),
                  );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDiceSides = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _currentValue.toString(),
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isRolling ? null : _rollDice,
            icon: Icon(_isRolling ? Icons.hourglass_empty : Icons.casino),
            label: Text(_isRolling ? 'Rolling...' : 'Roll Dice'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      );
    }
}