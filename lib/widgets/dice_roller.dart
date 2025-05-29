import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/dice_set.dart';
import '../providers/sound_provider.dart';
import '../providers/history_provider.dart';
import '../providers/preset_provider.dart';
import 'dice_roll_animation.dart';

class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});

  @override
  State<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends State<DiceRoller>{
  final List<int> _availableDice = [4, 6, 8, 10, 12, 20, 100];
  DiceSet _diceSet = const DiceSet(dice: {});
  Map<int, List<int>> _rollResults = {};
  bool _isRolling = false;
  final _modifierController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _modifierController.addListener(_updateModifier);
  }

  @override
  void dispose() {
    _modifierController.dispose();
    super.dispose();
  }

  void _updateModifier() {
    final value = int.tryParse(_modifierController.text) ?? 0;
    setState(() {
      _diceSet = _diceSet.copyWith(modifier: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total from all dice + modifier
    int total = 0;
    _rollResults.forEach((sides, results) {
      total += results.fold<int>(0, (sum, roll) => sum + roll);
    });
    total += _diceSet.modifier;
    
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dice type buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _availableDice.map((sides) {
              final count = _diceSet.dice[sides] ?? 0;

              return InputChip(
                avatar: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  child: Text(count.toString()),
                ),
                label: Text('d$sides'),
                onPressed: () {
                  setState(() {
                    _diceSet = _diceSet.addDie(sides);
                  });
                },
                deleteIcon: const Icon(Icons.remove_circle_outline, size: 18),
                onDeleted: count > 0
                  ? () {
                      setState(() {
                        _diceSet = _diceSet.removeDie(sides);
                      });
                  }                
                : null,
              );
            }).toList(),
          ),

          const SizedBox(height: 16), 

          // Modifier input
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Modifier: '),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  final value = (_diceSet.modifier - 1);
                  _modifierController.text = value.toString();
                },
              ),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _modifierController,
                  keyboardType: TextInputType.numberWithOptions(signed: true),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  final value = (_diceSet.modifier + 1);
                  _modifierController.text = value.toString();
                },
              ),
            ],
          ),
              
          const SizedBox(height: 24),

          // Roll button
          ElevatedButton.icon(
            onPressed: _diceSet.dice.isEmpty || _isRolling ? null : _rollDice,
            icon: Icon(_isRolling ? Icons.hourglass_empty : Icons.casino),
            label: Text(_isRolling ? 'Rolling...' : 'Roll Dice'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),

          // Presets buttons
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Save preset button
              ElevatedButton.icon(
                onPressed: _diceSet.dice.isEmpty ? null : () {
                  final presetProvider = Provider.of<PresetProvider>(context, listen: false);
                  presetProvider.addPreset("Set", _diceSet);
                },
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
              const SizedBox(width: 8),

              // Load preset button
              Consumer<PresetProvider>(
                builder: (context, presetProvider, child) {
                  final presets = presetProvider.presets;

                  return PopupMenuButton<DiceSetPreset>(
                    enabled: presets.isNotEmpty,
                    tooltip: 'Load preset',
                    onSelected: (preset) {
                      setState(() {
                        _diceSet = preset.diceSet;
                        _modifierController.text = preset.diceSet.modifier.toString();
                      });
                    },
                    itemBuilder: (context) {
                      return [
                        ...presets.map((preset) {
                          return PopupMenuItem<DiceSetPreset>(
                            value: preset,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        preset.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        preset.diceSet.description,
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size:16),
                                  onPressed: () {
                                    presetProvider.deletePreset(preset.id);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ];
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.folder_open),
                          const SizedBox(width: 8),
                          const Text('Load'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
    );
  }

  bool _showingAnimation = false;

  Future<void> _rollDice() async {
    if (_diceSet.dice.isEmpty || _isRolling ) return;


    setState(() {
      _isRolling = true;
    });

    // Play sound
    final soundProvider = Provider.of<SoundProvider>(context, listen: false);
    await soundProvider.playRollSound();
  
    // Roll the dice
    final Map<int, List<int>> results = {};
    final random = Random();

    // Roll each type die
    _diceSet.dice.forEach((sides, count) {
      final List<int> rolls = [];
      for (int i = 0; i < count; i++) {
        rolls.add(random.nextInt(sides) + 1);
      }
      results[sides] = rolls;
    });
  
    // Show the animation overlay
    setState(() {
      _showingAnimation = true;
    });

    // Declare the entry variable before defining it
    late OverlayEntry entry;
    
    // The animation will call _finishRoll when complete
    entry = OverlayEntry(
      builder: (context) => DiceRollAnimation(
        results: results,
        modifier: _diceSet.modifier,
        onComplete: () {
          setState(() {
            _rollResults = results;
            _isRolling = false;
            _showingAnimation = false;
          });

          entry.remove();

          // Add to history
          if (mounted) {
            Provider.of<HistoryProvider>(context, listen: false)
              .addCombinedRoll(results, _diceSet.modifier);
          }
        },
      ),
    );

    Overlay.of(context).insert(entry);
  }
}