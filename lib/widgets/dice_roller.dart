import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../models/dice_set.dart';
import '../providers/dice_set_provider.dart';
import '../providers/history_provider.dart';
import '../providers/preset_provider.dart';
import '../providers/sound_provider.dart';
import 'dice_roll_animation.dart';

/// A widget that allows users to select, roll and save dice combinations
class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});

  @override
  State<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends State<DiceRoller> {
  //region Fields
  final List<int> _availableDice = [4, 6, 8, 10, 12, 20, 100];
  Map<int, List<int>> _rollResults = {};
  bool _isRolling = false;
  bool _showingAnimation = false;
  final _modifierController = TextEditingController(text: '0');
  OverlayEntry? entry;
  //endregion

  //region Lifecycle Methods
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
  //endregion

  //region Modifier Update
  void _updateModifier() {
    final diceSet = Provider.of<DiceSetProvider>(context, listen: false).currentDiceSet;
    final value = int.tryParse(_modifierController.text) ?? 0;
    final newDiceSet = diceSet.copyWith(modifier: value);
    Provider.of<DiceSetProvider>(context, listen: false).loadDiceSet(newDiceSet);
  }
  //endregion

  //region Build
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;

    return Consumer<DiceSetProvider>(
      builder: (context, diceSetProvider, child) {
        final diceSet = diceSetProvider.currentDiceSet;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _modifierController.text = diceSet.modifier.toString();
        });

        return Center(
          child: SizedBox(
            width: screenSize.width * 0.9,
            height: screenSize.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //region Main Content Layout - Dice Selection and Modifier
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Left Column - Dice Selection Grid
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: GridView.count(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  padding: const EdgeInsets.all(8),
                                  children: _availableDice.map((sides) {
                                    final count = diceSet.dice[sides] ?? 0;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Stack(
                                        children: [
                                          // Dice selection button
                                          TextButton(
                                            onPressed: () {
                                              final newDiceSet = diceSet.addDie(sides);
                                              Provider.of<DiceSetProvider>(context, listen: false).loadDiceSet(newDiceSet);
                                            },
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                _getDiceIcon(sides, 36)
                                              ],
                                            ),
                                          ),
                                          // Dice count indicator
                                          if (count > 0)
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).primaryColor,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Text(
                                                  count.toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Right Column - Modifier Controls
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Modifier Input with +/- buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    final value = (diceSet.modifier - 1);
                                    _modifierController.text = value.toString();
                                  },
                                ),
                                SizedBox(
                                  width: 60,
                                  child: TextField(
                                    controller: _modifierController,
                                    keyboardType: const TextInputType.numberWithOptions(signed: true),
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
                                    final value = (diceSet.modifier + 1);
                                    _modifierController.text = value.toString();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                //endregion

                const SizedBox(height: 16),

                //region Action Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Save Button
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: TextButton(
                          onPressed: diceSet.dice.isEmpty
                              ? null
                              : () {
                                  final presetProvider = Provider.of<PresetProvider>(context, listen: false);
                                  presetProvider.addPreset("Set", diceSet);
                                },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.save,
                                size: 32,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Roll Button
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextButton(
                          onPressed: diceSet.dice.isEmpty || _isRolling
                              ? null
                              : () => _rollDice(diceSet),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                _isRolling ? Icons.hourglass_empty : Icons.casino,
                                size: 32,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                //endregion
              ],
            ),
          ),
        );
      },
    );
  }
  //endregion

  //region Dice Rolling Logic
  Future<void> _rollDice(DiceSet diceSet) async {
    if (diceSet.dice.isEmpty || _isRolling) return;

    setState(() {
      _isRolling = true;
    });

    // Play sound effect
    final soundProvider = Provider.of<SoundProvider>(context, listen: false);
    await soundProvider.playRollSound();

    // Generate random dice results
    final Map<int, List<int>> results = {};
    final random = Random();

    diceSet.dice.forEach((sides, count) {
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

    entry = OverlayEntry(
      builder: (context) => DiceRollAnimation(
        results: results,
        modifier: diceSet.modifier,
        onComplete: () {
          setState(() {
            _rollResults = results;
            _isRolling = false;
            _showingAnimation = false;
          });

          entry?.remove();

          // Add result to history if widget is still mounted
          if (mounted) {
            Provider.of<HistoryProvider>(context, listen: false)
                .addCombinedRoll(results, diceSet.modifier);
          }
        },
      ),
    );

    Overlay.of(context).insert(entry!);
  }
  //endregion

  //region Dice Icon Helper
  Widget _getDiceIcon(int sides, double size) {
    switch (sides) {
      case 4:
        return SvgPicture.asset(
          'assets/icons/dice-d4.svg',
          width: size,
          height: size,
        );
      case 6:
        return SvgPicture.asset(
          'assets/icons/dice-d6.svg',
          width: size,
          height: size,
        );
      case 8:
        return SvgPicture.asset(
          'assets/icons/dice-d8.svg',
          width: size,
          height: size,
        );
      case 10:
        return SvgPicture.asset(
          'assets/icons/dice-d10.svg',
          width: size,
          height: size,
        );
      case 12:
        return SvgPicture.asset(
          'assets/icons/dice-d12.svg',
          width: size,
          height: size,
        );
      case 20:
        return SvgPicture.asset(
          'assets/icons/dice-d20.svg',
          width: size,
          height: size,
        );
      case 100:
        return SvgPicture.asset(
          'assets/icons/dice-d20.svg',
          width: size,
          height: size,
        );
      default:
        return Icon(Icons.casino, size: size);
    }
  }
  //endregion
}