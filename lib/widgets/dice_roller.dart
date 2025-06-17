import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';

import '../models/dice_set.dart';
import '../providers/dice_set_provider.dart';
import '../providers/history_provider.dart';
import '../providers/preset_provider.dart';
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
    final screenSize = MediaQuery.of(context).size;

    return Consumer<DiceSetProvider>(
      builder: (context, diceSetProvider, child) {
        final diceSet = diceSetProvider.currentDiceSet;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _modifierController.text = diceSet.modifier.toString();
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
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity! < 0) {
                      if (diceSet.dice.isNotEmpty && !_isRolling) {
                        _rollDice(diceSet);
                      }
                    }
                  },
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      Container(
                        width: totalWidth,
                        child: Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          alignment: WrapAlignment.center,
                          children: _availableDice.map((sides) {
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
                                    onPressed: () {
                                      final newDiceSet = diceSet.addDie(sides);
                                      Provider.of<DiceSetProvider>(context, listen: false).loadDiceSet(newDiceSet);
                                    },
                                    onLongPress: () {
                                      final newDiceSet = diceSet.clearDie(sides);
                                      Provider.of<DiceSetProvider>(context, listen: false).loadDiceSet(newDiceSet);
                                    },
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
                                        onTap: () {
                                          final newDiceSet = diceSet.removeDie(sides);
                                          Provider.of<DiceSetProvider>(context, listen: false).loadDiceSet(newDiceSet);
                                        },
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
                          }).toList(),
                        ),
                      ),
                      Provider.of<DiceSetProvider>(context).showModifier == true
                          ? Container(
                              width: dieSize,
                              height: dieSize,
                              child: Center(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final double textFieldSize = constraints.maxWidth;
                                    final double iconSize = constraints.maxWidth * 0.3;

                                    return Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 8,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Container(
                                          width: textFieldSize,
                                          height: textFieldSize,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.background,
                                          ),
                                          child: Stack(
                                            children: [
                                              TextField(
                                                controller: _modifierController,
                                                keyboardType: TextInputType.numberWithOptions(signed: true),
                                                style: const TextStyle(color: Colors.transparent),
                                                cursorColor: Colors.transparent,
                                                decoration: const InputDecoration.collapsed(hintText: ''),
                                                textAlign: TextAlign.center,
                                              ),
                                              Center(
                                                child: Text(
                                                  _modifierController.text,
                                                  style: TextStyle(
                                                    fontSize: textFieldSize * 0.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context).colorScheme.secondary,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                bottom: 0,                                                
                                                child: GestureDetector(
                                                  onTap: () {
                                                    final value = diceSet.modifier - 1;
                                                    _modifierController.text = value.toString();
                                                  },
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
                                              Positioned(
                                                right: 0,
                                                top: 0,
                                                bottom: 0,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    final value = diceSet.modifier + 1;
                                                    _modifierController.text = value.toString();
                                                  },
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
                                              Positioned(
                                                bottom: 0,
                                                left: 0,
                                                right: 0,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Provider.of<DiceSetProvider>(context, listen: false)
                                                        .toggleModifier(false);
                                                  },
                                                  child: Container(
                                                    width: dieSize * 0.25,
                                                    height: dieSize * 0.25,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).colorScheme.secondary,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.cancel_outlined,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            )
                          : SizedBox(
                              width: dieSize,
                              height: dieSize,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () {
                                      Provider.of<DiceSetProvider>(context, listen: false)
                                          .toggleModifier(true);
                                    },
                                    child: Icon(
                                      Icons.add_circle_outline,
                                      size: dieSize * 0.5,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              );
            },
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
    // final soundProvider = Provider.of<SoundProvider>(context, listen: false);
    // await soundProvider.playRollSound();

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

    final totalDiceCount = diceSet.dice.values.fold(0, (a, b) => a + b);
    final highestSides = diceSet.dice.keys.isNotEmpty ? diceSet.dice.keys.reduce(max) : 6;
    final totalResult = results.entries
      .map((e) => e.value.fold(0, (a, b) => a + b))
      .fold(0, (a, b) => a + b) + diceSet.modifier;

    entry = OverlayEntry(
      builder: (context) => DiceRollAnimationPage(
        diceCount: totalDiceCount,
        diceSides: highestSides,
        modifier: diceSet.modifier,
        result: totalResult,
        onComplete: () {
          entry?.remove();
          setState(() {
            _isRolling = false;
            _showingAnimation = false;
          });
        }
      ),
    );

    Overlay.of(context).insert(entry!);
  }
  //endregion
}