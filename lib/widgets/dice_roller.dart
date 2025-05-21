import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dice.dart';
import '../models/custom_buttons.dart';
import '../providers/sound_provider.dart';
import '../providers/history_provider.dart';

class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});

  @override
  State<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends State<DiceRoller>{
  final List<int> _availableDice = [4, 6, 8, 10, 12, 20, 100];
  int _selectedDiceSides = 6;
  int _currentValue = 1;
  int _modifier = 0;
  int _rollResult = 1;
  bool _isRolling = false;
  final _modifierController = TextEditingController(text: '0');

  Future<void> _rollDice() async {
    setState(() {
      _isRolling = true;
    });

    // Play sound
    final soundProvider = Provider.of<SoundProvider>(context, listen: false);
    await soundProvider.playRollSound();

    // Small delay to simulate rolling
    await Future.delayed(const Duration(milliseconds: 1000));
  
    // Roll the dice
    final dice = Dice(sides: _selectedDiceSides);
    _rollResult = dice.roll();
    final totalResult = _rollResult + _modifier;

    setState(() {
      _currentValue = totalResult;
      _isRolling = false;
    });

    // Add to history
    Provider.of<HistoryProvider>(context, listen: false).addRoll(_rollResult, _selectedDiceSides, _modifier);
  }

  @override
  void dispose() {
    _modifierController.dispose();
    super.dispose();
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

          // Modifier input
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Modifier: ', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // TextField for modifier input
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _modifierController,
                      keyboardType: TextInputType.numberWithOptions(signed: true),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _modifier = int.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                  Column(
                    children: [

                      // Increment button
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() {
                            _modifier++;
                            _modifierController.text = _modifier.toString();
                          });
                        },
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        padding: EdgeInsets.zero,
                      ),

                      // Decrement button
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() {
                            _modifier--;
                            _modifierController.text = _modifier.toString();
                          });
                        },
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Roll button
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

          const SizedBox(height: 10),

          // Display the result
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                _currentValue.toString(),
                style: Theme.of(context).textTheme.displayLarge,
              ),
              if (_modifier != 0)
                Text(
                  '${_rollResult} + $_modifier',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),          
        ],
      );
    }
}