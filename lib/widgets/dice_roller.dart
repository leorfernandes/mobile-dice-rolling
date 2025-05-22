import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dice.dart';
import '../models/custom_buttons.dart';
import '../providers/sound_provider.dart';
import '../providers/history_provider.dart';
import '../providers/preset_provider.dart';
import '../models/dice_preset.dart';
import '../widgets/save_preset_dialog.dart';

class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});

  @override
  State<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends State<DiceRoller>{
  final List<int> _availableDice = [4, 6, 8, 10, 12, 20, 100];
  int _selectedDiceSides = 6;
  int _diceCount = 1;
  List<int> _rollResults = [1];
  int _modifier = 0;
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
    final results = dice.rollMultiple(_diceCount);
    final total = results.fold<int>(0, (sum, roll) => sum + roll) + _modifier;

    setState(() {
      _rollResults = results;
      _isRolling = false;
    });

    // Add to history
    Provider.of<HistoryProvider>(context, listen: false).addMultiRoll(results, _selectedDiceSides, _modifier);
  }

  @override
  void dispose() {
    _modifierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total from all dice + modifier
    final total = _rollResults.fold<int>(0, (sum, roll) => sum + roll) + _modifier;
    
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              const Text('Dice:', style: TextStyle(fontSize: 18)),
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

          // Dice count selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Number of Dice: ', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _diceCount > 1
                  ? () {
                    setState(() {
                      _diceCount--;
                      _rollResults = List.generate(_diceCount, (_) => 1);
                    });
                  }
                : null,
              ),
              Text(
                '$_diceCount',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _diceCount < 100
                  ? () {
                    setState(() {
                      _diceCount++;
                      _rollResults = List.generate(_diceCount, (_) => 1); 
                    });
                  }
                : null,
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

          // Save Preset Button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Save current preset button
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => SavePresetDialog(
                      sides: _selectedDiceSides,
                      count: _diceCount,
                      modifier: _modifier,
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),

              // Load presets button
              Consumer<PresetProvider>(
                builder: (context, presetProvider, child) {
                  final presets = presetProvider.presets;

                  return PopupMenuButton<DicePreset>(
                    icon: const Icon(Icons.folder_open),
                    tooltip: 'Load',
                    enabled: presets.isNotEmpty,
                    onSelected: (preset) {
                      setState(() {
                        _selectedDiceSides = preset.sides;
                        _diceCount = preset.count;
                        _modifier = preset.modifier;
                        _modifierController.text = preset.modifier.toString();
                        _rollResults = List.generate(_diceCount, (_) => 1);
                      });
                    },
                    itemBuilder: (context) {
                      return presets.map((preset) {
                        return PopupMenuItem<DicePreset>(
                          value: preset,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(preset.name),
                              Text(
                                '${preset.count}d${preset.sides}' +
                                (preset.modifier != 0
                                  ? ' + ${preset.modifier}'
                                  : ''),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 16),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    presetProvider.deletePreset(preset.id);
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList();
                      },
                      );
                    },
                  )
            ],
          ),

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
                // Display total result
                Text(
                total.toString(),
                style: Theme.of(context).textTheme.displayLarge,
              ),

              // Show formula if needed
              if (_diceCount > 1 || _modifier != 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _buildResultString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),

              if (_diceCount > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _rollResults.map((result) {
                      return Chip(
                        label: Text(result.toString()),
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),          
        ],
      );
    }

    // Helper function to build result string
    String _buildResultString() {
      final parts = <String>[];

      if (_diceCount > 1) {
        parts.add('${_diceCount}d$_selectedDiceSides');
        parts.add('${_rollResults.join(', ')}');
      } else {
        parts.add('1d$_selectedDiceSides');
      }

      if (_modifier > 0) {
        parts.add('+ Mod: $_modifier');
      } else if (_modifier < 0) {
        parts.add('- Mod: ${_modifier.abs()}');
      }

      return parts.join(' ');
    }
}