import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// -----------------------------------------------------------------------------
// MODELS & DATA CLASSES
// -----------------------------------------------------------------------------

/// Defines color schemes for different types of dice
class DiceColorScheme {
  final Color d4;
  final Color d6;
  final Color d8;
  final Color d10;
  final Color d12;
  final Color d20;
  final Color d100;
  final Color defaultDice;

  const DiceColorScheme({
    required this.d4,
    required this.d6,
    required this.d8,
    required this.d10,
    required this.d12,
    required this.d20,
    required this.d100,
    required this.defaultDice,
  });

  // Predefined themes
  static const DiceColorScheme vibrant = DiceColorScheme(
    d4: Color(0xFFD32F2F), // Bright red
    d6: Color(0xFF1976D2), // Bright blue
    d8: Color(0xFF388E3C), // Bright green
    d10: Color(0xFFFFA000), // Amber
    d12: Color(0xFF7B1FA2), // Purple
    d20: Color(0xFF0097A7), // Teal
    d100: Color(0xFFE64A19), // Deep orange
    defaultDice: Color(0xFF616161), // Grey
  );

  static const DiceColorScheme dark = DiceColorScheme(
    d4: Color(0xFF8B0000), // Dark red
    d6: Color(0xFF0D47A1), // Dark blue
    d8: Color(0xFF1B5E20), // Dark green
    d10: Color(0xFFFF6F00), // Dark amber
    d12: Color(0xFF4A148C), // Dark purple
    d20: Color(0xFF006064), // Dark teal
    d100: Color(0xFFBF360C), // Dark orange
    defaultDice: Color(0xFF424242), // Dark grey
  );

  static const DiceColorScheme light = DiceColorScheme(
    d4: Color(0xFFFFCDD2), // Light red
    d6: Color(0xFFBBDEFB), // Light blue
    d8: Color(0xFFC8E6C9), // Light green
    d10: Color(0xFFFFECB3), // Light amber
    d12: Color(0xFFE1BEE7), // Light purple
    d20: Color(0xFFB2EBF2), // Light teal
    d100: Color(0xFFFFCCBC), // Light orange
    defaultDice: Color(0xFFEEEEEE), // Light grey
  );
}

/// Helper class to store visual properties for each die
class DiceVisual {
  Offset position;
  double rotation;
  double scale;
  int result;

  late List<Offset> path;
  int pathIndex = 0;

  late double initialSpeed;
  late double currentSpeed;
  late double decelaration;

  DiceVisual({
    required this.position,
    required this.rotation,
    required this.scale,
    required this.result,
  }) {
    path = _generateRandomPath();
    final random = Random();
    initialSpeed = 0.3 + random.nextDouble() * 0.4;
    currentSpeed = initialSpeed;
    decelaration = 0.01 + random.nextDouble() * 0.02;
  }

  List<Offset> _generateRandomPath() {
    final Random random = Random();
    final List<Offset> points = [];
    points.add(position);

    final int numPoints = random.nextInt(3) + 4; // Between 4 and 6 points
    final targetX = 0.1 + random.nextDouble() * 0.8;
    final targetY = 0.1 + random.nextDouble() * 0.8;

    for (int i = 0; i < numPoints; i++) {
      final progress = (i + 1) / numPoints;
      double bounceHeight;
      if (progress < 0.6) {
        bounceHeight = (1.0 - progress) * (0.2 + random.nextDouble() * 0.8);
      } else {
        bounceHeight = (1.0 - progress) * (0.1 + random.nextDouble() * 0.4);
      }
      final verticalOffset = -bounceHeight * sin(progress * 3 * pi);
      final deviation = (1 - progress) * (random.nextDouble() * 0.2 - 0.1);

      points.add(Offset(
        position.dx + (targetX - position.dx) * progress + deviation,
        position.dy + (targetY - position.dy) * progress + verticalOffset,
      ));
    }
    return points;
  }
}

// -----------------------------------------------------------------------------
// MAIN WIDGET
// -----------------------------------------------------------------------------

class DiceRollAnimation extends StatefulWidget {
  final Map<int, List<int>> results;
  final int modifier;
  final VoidCallback onComplete;
  final bool showFinalResults;

  const DiceRollAnimation({
    super.key,
    required this.results,
    required this.modifier,
    required this.onComplete,
    this.showFinalResults = false,
  });

  @override
  State<DiceRollAnimation> createState() => _DiceRollAnimationState();
}

// -----------------------------------------------------------------------------
// WIDGET STATE IMPLEMENTATION
// -----------------------------------------------------------------------------

class _DiceRollAnimationState extends State<DiceRollAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Timer? _numberChangeTimer;
  int _currentNumber = 0;
  bool _animationComplete = false;
  int _finalTotal = 0;

  List<int> _currentDigits = [];
  List<Timer?> _digitTimers = [];

  final colorScheme = DiceColorScheme.vibrant;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  @override
  void dispose() {
    for (var timer in _digitTimers) {
      timer?.cancel();
    }
    _controller.dispose();
    super.dispose();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    // Calculate the final total and maximun possible value for each die type
    Map<int, int> maxPerDieType = {};
    _finalTotal = widget.results.entries.fold(0, (sum, entry) {
    // Calculate max possible value for each die type
    maxPerDieType[entry.key] = entry.key * entry.value.length; // die sides * number of dice
    return sum + entry.value.reduce((a, b) => a + b);
  }) + widget.modifier;

    int maxPossibleValue = maxPerDieType.values.fold(0, (sum, max) => sum + max) + widget.modifier;

    _currentDigits = _finalTotal.toString().split('').map(int.parse).toList();

    // Create timer for each digit
    for (int i = 0; i < _currentDigits.length; i++) {
      final digitTimer = Timer.periodic(
        Duration(milliseconds: 50 + (i * 20)),
        (timer) {
          if (_controller.value < 0.8) {
            setState(() {
              if (widget.results.length == 1 && widget.results.values.first.length == 1) {
                final dieSides = widget.results.keys.first;
                final maxValue = dieSides + widget.modifier;
                final maxForPosition = _getMaxValueForPosition(i, maxValue);           
              _currentDigits[i] = Random().nextInt(maxForPosition + 1);
            } else {
              final maxForPosition = _getMaxValueForPosition(i, maxPossibleValue);
              _currentDigits[i] = Random().nextInt(maxForPosition + 1);
            }
            });
          } else {
            timer.cancel();
            setState(() {
              _currentDigits[i] = int.parse(_finalTotal.toString()[i]);
            });
            if (i == _currentDigits.length - 1) {
              _animationComplete = true;
            }
          }
        }
      );
      _digitTimers.add(digitTimer);
    }

    _controller.forward();
  }

// Helper method
  int _getMaxValueForPosition(int position, int maxValue) {
    String maxValueStr = maxValue.toString();
    if (position >= maxValueStr.length) return 9;

    // for the leftmost digit, use the actual max value's digit
    if (position == 0) {
      return int.parse(maxValueStr[0]);
    }

    String currentPrefix = maxValueStr.substring(0, position);
    String finalPrefix = _finalTotal.toString().substring(0, position);

    if (currentPrefix == finalPrefix) {
      return int.parse(maxValueStr[position]);
    }

    return 9;
  }

  Color _getDiceColor(int sides) {
    switch (sides) {
      case 4:
        return colorScheme.d4;
      case 6:
        return colorScheme.d6;
      case 8:
        return colorScheme.d8;
      case 10:
        return colorScheme.d10;
      case 12:
        return colorScheme.d12;
      case 20:
        return colorScheme.d20;
      case 100:
        return colorScheme.d100;
      default:
        return colorScheme.defaultDice;
    }
  }

  Widget getDiceIcon(int sides, double size) {
    final color = _getDiceColor(6).withOpacity(0.9);
    switch (sides) {
      case 4:
        return SvgPicture.asset(
          'assets/icons/dice-d4.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
      case 6:
        return SvgPicture.asset(
          'assets/icons/dice-d6.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
      case 8:
        return SvgPicture.asset(
          'assets/icons/dice-d8.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
      case 10:
        return SvgPicture.asset(
          'assets/icons/dice-d10.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
      case 12:
        return SvgPicture.asset(
          'assets/icons/dice-d12.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
      case 20:
        return SvgPicture.asset(
          'assets/icons/dice-d20.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
      case 100:
        return SvgPicture.asset(
          'assets/icons/dice-d20.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
      default:
        return Icon(Icons.casino, size: size, color: _getDiceColor(0).withOpacity(0.9));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_animationComplete) {
          widget.onComplete();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              Container(
                color: Colors.black.withOpacity(0.9 * _controller.value),
              ),
              if (_controller.value > 0.3)
                Center(
                  child: _buildNumberDisplay(),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNumberDisplay() {
        return Container(
          width: 360,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _currentDigits.map((digit) {
                        return SizedBox(
                          width: 70,
                          child: Text(
                            digit.toString(),
                            style: const TextStyle(
                              fontSize: 120,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }
  }
