import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';

import '../models/dice_set.dart';
import '../providers/dice_set_provider.dart';
import '../providers/history_provider.dart';
import '../providers/sound_provider.dart';
import 'dice_roll_animation.dart';
import '../models/dice_icon.dart';

/// A widget that allows users to select, roll and save dice combinations
class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});

  @override
  State<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends State<DiceRoller> {
  //region Fields
  final List<int> _availableDice = [4, 6, 8, 10, 12, 20];
  Map<int, List<int>> _rollResults = {};
  bool _isRolling = false;
  bool _showingAnimation = false;
  final _modifierController = TextEditingController(text: '0');
  OverlayEntry? _overlayEntry;
  //endregion

  //region Lifecycle Methods
  @override
  void initState() {
    super.initState();
    _modifierController.addListener(_updateModifier);
  }

  @override
  void dispose() {
    _modifierController.removeListener(_updateModifier);
    _modifierController.dispose();
    _removeOverlay();
    super.dispose();
  }
  //endregion

  //region Modifier Management
  void _updateModifier() {
    try {
      final diceSet = Provider.of<DiceSetProvider>(context, listen: false).currentDiceSet;
      final value = int.tryParse(_modifierController.text) ?? 0;
      final newDiceSet = diceSet.copyWith(modifier: value);
      Provider.of<DiceSetProvider>(context, listen: false).loadDiceSet(newDiceSet);
    } catch (e) {
      debugPrint('Error updating modifier: $e');
      // Reset to 0 if there's an error
      _modifierController.text = '0';
    }
  }

  void _incrementModifier() {
    try {
      final diceSet = Provider.of<DiceSetProvider>(context, listen: false).currentDiceSet;
      final value = diceSet.modifier + 1;
      _modifierController.text = value.toString();
    } catch (e) {
      debugPrint('Error incrementing modifier: $e');
    }
  }

  void _decrementModifier() {
    try {
      final diceSet = Provider.of<DiceSetProvider>(context, listen: false).currentDiceSet;
      final value = diceSet.modifier - 1;
      _modifierController.text = value.toString();
    } catch (e) {
      debugPrint('Error decrementing modifier: $e');
    }
  }
  //endregion

  void _playRollSound() {
    try {
      final soundProvider = Provider.of<SoundProvider>(context, listen: false);
      if (soundProvider.soundEnabled) {
        soundProvider.playRollSound();
      }
    } catch (e) {
      debugPrint('Error playing roll sound: $e');
    }
  }
  //endregion

  //region Dice Management
  void _addDie(DiceSet diceSet, int sides) {
    try {
      final newDiceSet = diceSet.addDie(sides);
      Provider.of<DiceSetProvider>(context, listen: false).loadDiceSet(newDiceSet);
    } catch (e) {
      debugPrint('Error adding die: $e');
    }
  }

  void _removeDie(DiceSet diceSet, int sides) {
    try {
      final newDiceSet = diceSet.removeDie(sides);
      Provider.of<DiceSetProvider>(context, listen: false).loadDiceSet(newDiceSet);
    } catch (e) {
      debugPrint('Error removing die: $e');
    }
  }

  void _clearDie(DiceSet diceSet, int sides) {
    try {
      final newDiceSet = diceSet.clearDie(sides);
      Provider.of<DiceSetProvider>(context, listen: false).loadDiceSet(newDiceSet);
    } catch (e) {
      debugPrint('Error clearing die: $e');
    }
  }
  //endregion

  //region Overlay Management
  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }
  //endregion

  //region Dice Rolling Logic
  Future<void> _rollDice(DiceSet diceSet) async {
    if (diceSet.dice.isEmpty || _isRolling) return;

    try {
      setState(() {
        _isRolling = true;
      });

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

      // Play a random dice rolling sound
      _playRollSound();

      // Show the animation overlay
      setState(() {
        _showingAnimation = true;
      });

      // Calculate total result
      final totalResult = results.entries
          .map((e) => e.value.fold(0, (a, b) => a + b))
          .fold(0, (a, b) => a + b) + diceSet.modifier;

      // Remove any existing overlay
      _removeOverlay();

      _overlayEntry = OverlayEntry(
        builder: (context) => DiceRollAnimationPage(
          diceTypes: diceSet.dice,
          modifier: diceSet.modifier,
          result: totalResult,
          onComplete: () {
            try {
              // Save roll to history
              final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
              historyProvider.addCombinedRoll(results, diceSet.modifier);
            } catch (e) {
              debugPrint('Error saving roll to history: $e');
            } finally {
              // Remove overlay and reset state
              _removeOverlay();
              setState(() {
                _isRolling = false;
                _showingAnimation = false;
              });
            }
          },
        ),
      );

      Overlay.of(context).insert(_overlayEntry!);
    } catch (e) {
      debugPrint('Error during dice roll: $e');
      setState(() {
        _isRolling = false;
        _showingAnimation = false;
      });
    }
  }
  //endregion

  //region Build Methods
  Widget _buildDieButton(DiceSet diceSet, int sides, double dieSize, double spacing) {
    final count = diceSet.dice[sides] ?? 0;
    return SizedBox(
      width: dieSize,
      height: dieSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dice selection button
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => _addDie(diceSet, sides),
            onLongPress: () => _clearDie(diceSet, sides),
            child: Stack(
              alignment: Alignment.center,
              children: [
                DiceIcon(
                  sides: sides,
                  size: dieSize,
                  fillColor: Theme.of(context).colorScheme.primary,
                  strokeColor: Theme.of(context).colorScheme.background,
                ),
              ],
            ),
          ),
          // Dice type inform
          if (count == 0)
            IgnorePointer(
              child: Container(
                width: dieSize,
                height: dieSize,
                alignment: Alignment.center,
                child: Text(
                  'd$sides',
                  style: TextStyle(
                    fontSize: dieSize * 0.3,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          // Dice count indicator
          if (count > 0)
            IgnorePointer(
              child: Container(
                width: dieSize,
                height: dieSize,
                alignment: Alignment.center,
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: dieSize * 0.4,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      )
                    ],
                  ),
                ),
              ),
            ),
          if (count > 0)
            Positioned(
              right: 2,
              top: 2,
              child: GestureDetector(
                onTap: () => _removeDie(diceSet, sides),
                child: Container(
                  width: dieSize * 0.25,
                  height: dieSize * 0.25,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.remove_circle_outline,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModifierControl(double dieSize) {
    return Container(
      width: dieSize,
      height: dieSize,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          TextField(
            controller: _modifierController,
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            style: const TextStyle(color: Colors.transparent),
            cursorColor: Colors.transparent,
            decoration: const InputDecoration.collapsed(hintText: ''),
            textAlign: TextAlign.center,
          ),
          Center(
            child: Text(
              _modifierController.text,
              style: TextStyle(
                fontSize: dieSize * 0.5,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Plus button
          Positioned(
            right: 0,
            top: 0,
            bottom: dieSize * 0.5,
            child: GestureDetector(
              onTap: _incrementModifier,
              child: Container(
                width: dieSize * 0.25,
                height: dieSize * 0.25,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.add_circle_outline,
                  ),
                ),
              ),
            ),
          ),
          // Minus button
          Positioned(
            right: 0,
            top: dieSize * 0.5,
            bottom: 0,
            child: GestureDetector(
              onTap: _decrementModifier,
              child: Container(
                width: dieSize * 0.25,
                height: dieSize * 0.25,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.remove_circle_outline,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRollButton(DiceSet diceSet, double dieSize) {
    final canRoll = diceSet.dice.isNotEmpty && !_isRolling;
    return Container(
      width: dieSize,
      height: dieSize,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        onPressed: canRoll ? () => _rollDice(diceSet) : null,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Icon(
          Icons.casino,
          size: dieSize * 0.5,
          color: canRoll
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiceSetProvider>(
      builder: (context, diceSetProvider, child) {
        final diceSet = diceSetProvider.currentDiceSet;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_modifierController.text != diceSet.modifier.toString()) {
            _modifierController.text = diceSet.modifier.toString();
          }
        });

        return Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double totalWidth = constraints.maxWidth * 0.85;
              double spacing = totalWidth * 0.03;
              double dieSize = ((totalWidth - spacing * 2) / 3).clamp(32.0, 128.0);

              return Listener(
                onPointerSignal: (pointerSignal) {
                  if (pointerSignal is PointerScrollEvent) {
                    if (pointerSignal.scrollDelta.dy < 0) {
                      if (diceSet.dice.isNotEmpty && !_isRolling) {
                        _rollDice(diceSet);
                      }
                    }
                  }
                },
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    SizedBox(
                      width: totalWidth,
                      child: Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        alignment: WrapAlignment.center,
                        children: _availableDice.map((sides) => 
                          _buildDieButton(diceSet, sides, dieSize, spacing)
                        ).toList(),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: spacing,
                        children: [
                          // Modifier button
                          _buildModifierControl(dieSize),
                          
                          // Roll button
                          _buildRollButton(diceSet, dieSize),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
  //endregion
}