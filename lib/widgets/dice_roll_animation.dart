import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';

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
    d4: Color(0xFFD32F2F),     // Bright red
    d6: Color(0xFF1976D2),     // Bright blue
    d8: Color(0xFF388E3C),     // Bright green
    d10: Color(0xFFFFA000),    // Amber
    d12: Color(0xFF7B1FA2),    // Purple
    d20: Color(0xFF0097A7),    // Teal
    d100: Color(0xFFE64A19),   // Deep orange
    defaultDice: Color(0xFF616161), // Grey
  );

  // Dark theme
  static const DiceColorScheme dark = DiceColorScheme(
    d4: Color(0xFF8B0000),     // Dark red
    d6: Color(0xFF0D47A1),     // Dark blue
    d8: Color(0xFF1B5E20),     // Dark green
    d10: Color(0xFFFF6F00),    // Dark amber
    d12: Color(0xFF4A148C),    // Dark purple
    d20: Color(0xFF006064),    // Dark teal
    d100: Color(0xFFBF360C),   // Dark orange
    defaultDice: Color(0xFF424242), // Dark grey
  );

  // Light theme
  static const DiceColorScheme light = DiceColorScheme(
    d4: Color(0xFFFFCDD2),     // Light red
    d6: Color(0xFFBBDEFB),     // Light blue
    d8: Color(0xFFC8E6C9),     // Light green
    d10: Color(0xFFFFECB3),    // Light amber
    d12: Color(0xFFE1BEE7),    // Light purple
    d20: Color(0xFFB2EBF2),    // Light teal
    d100: Color(0xFFFFCCBC),   // Light orange
    defaultDice: Color(0xFFEEEEEE), // Light grey
  );
}

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

class _DiceRollAnimationState extends State<DiceRollAnimation>
  with TickerProviderStateMixin {
    late AnimationController _controller;
    late AnimationController _pulseController;
    late Animation<double> _pulseAnimation;
    late Random _random;
    int _displayNumber = 1;
    int _finalTotal = 0;

    late Map<int, List<DiceVisual>> _diceVisuals;

    @override
    void initState() {
      super.initState();
      _random = Random();
      _diceVisuals = {};

      //Calculate final total
      _finalTotal = 0;
      widget.results.forEach((sides, results) {
        _finalTotal += results.fold<int>(0, (sum, roll) => sum + roll);

        // Generate visual position for each die
        _diceVisuals[sides] = List.generate(
          results.length,
          (_) => DiceVisual(
            position: Offset(
              0.2 + _random.nextDouble() * 0.6,
              0.2 + _random.nextDouble() * 0.6,
            ),
            rotation: _random.nextDouble() * pi * 2,
            scale: 1 + _random.nextDouble() * 0.4,
            result: 1,
          ),
        );
      });

      _finalTotal += widget.modifier;

      // Setup animation controller
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1800),
      );

      // Update displayed number several times per second
      _controller.addListener(() {
        if (_controller.value < 0.8) {
          // During animation, show random numbers
          setState(() {
            _displayNumber = _random.nextInt(_finalTotal * 2) + 1;

            widget.results.forEach((sides, results) {
              for (int i = 0; i < results.length; i++) {
                if (i < _diceVisuals[sides]!.length) {
                  // Update position slightly for movement effect
                  final visual = _diceVisuals[sides]![i];

                  // Random movement within a small area
                  visual.moveAlongPath(_controller.value);

                  // Random scale for bouncing effect
                  visual.updateRotation(_controller.value);

                  // Scale bouncing effect - higer when the die is in the air
                  final pathProgress = _controller.value * 0.8;
                  final pathIndex = (visual.path.length * pathProgress).floor().clamp(0, visual.path.length - 1);
                  final nextIndex = min(pathIndex + 1, visual.path.length - 1);

                  // Calculate if die is going up or down (using y-coordinate)
                  final isGoingUp = pathIndex > 0 &&
                    visual.path[pathIndex].dy > visual.path[pathIndex - 1].dy;

                  // Make the scale larger when the die is higher in the air
                  final currentY = visual.position.dy;
                  final initialY = visual.path[0].dy;
                  final heightDiff = (initialY - currentY).abs();

                  // Scale effect is more pronounced when die is higher
                  visual.scale = 1.0 + heightDiff * 3.0;

                  // Show random number during animation
                  visual.result = _random.nextInt(sides) + 1;
                }
              }
            });
          });
        } else {
          // In the final 20% of animation, show the actual result
          setState(() {
            _displayNumber = _finalTotal;

            // Set final values
            widget.results.forEach((sides, results) {
              for (int i = 0; i < results.length; i++) {
                if (i < _diceVisuals[sides]!.length) {
                  _diceVisuals[sides]![i].result = results[i];
                }
              }
            });
          });
        }
      });

      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _animationComplete = true;
          });
        }
      });

      // Start the animation
      _controller.forward();

      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
      )..repeat(reverse: true);

      _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(_pulseController);
    }

    bool _animationComplete = false;

    @override
    void dispose() {
      _pulseController.dispose();
      _controller.dispose();
      super.dispose();
    }
    // Get icon for a specific die type
    Widget getDiceIcon(int sides, double size) {
      switch (sides) {
        case 4: return SvgPicture.asset(
          'assets/icons/dice-d4.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(_getDiceColor(6).withOpacity(0.9), BlendMode.srcIn),
        ); // d4 Icon
        case 6: return SvgPicture.asset(
          'assets/icons/dice-d6.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(_getDiceColor(6).withOpacity(0.9), BlendMode.srcIn),
        ); // d6 Icon
        case 8: return SvgPicture.asset(
          'assets/icons/dice-d8.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(_getDiceColor(6).withOpacity(0.9), BlendMode.srcIn),
        ); // d8 Icon
        case 10: return SvgPicture.asset(
          'assets/icons/dice-d10.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(_getDiceColor(6).withOpacity(0.9), BlendMode.srcIn),
        ); // d10 Icon
        case 12: return SvgPicture.asset(
          'assets/icons/dice-d12.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(_getDiceColor(6).withOpacity(0.9), BlendMode.srcIn),
        ); // d12 Icon
        case 20: return SvgPicture.asset(
          'assets/icons/dice-d20.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(_getDiceColor(6).withOpacity(0.9), BlendMode.srcIn),
        ); // d20 Icon
        case 100: return SvgPicture.asset(
          'assets/icons/dice-d20.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(_getDiceColor(6).withOpacity(0.9), BlendMode.srcIn),
        );
        default: return Icon(Icons.casino, size: size, color: _getDiceColor(0).withOpacity(0.9)); // Default dice icon for any other value
      }
    }

    @override
    Widget build(BuildContext context) {
      final Size screenSize = MediaQuery.of(context).size;

  
      return GestureDetector(
        onTap: () {
          if (_animationComplete) {
            widget.onComplete();
          }
        },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, childer) {
          return Stack(
            children: [
              // Background overlay
              Container(
                color: Colors.black.withOpacity(0.7 * _controller.value),
              ),
              
              // Dice for each type
              ...widget.results.entries.expand((entry) {
                final sides = entry.key;

                return _diceVisuals[sides]?.map((visual) {
                  return Positioned(
                    left: visual.position.dx * screenSize.width,
                    top: visual.position.dy * screenSize.height,
                    child: Transform.rotate(
                      angle: visual.rotation,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 70 + (visual.scale * 20),
                            height: 70 + (visual.scale * 20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10 + visual.scale * 5,
                                  offset: Offset(0, 5 + visual.scale * 2),
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          // The die icon
                          getDiceIcon(sides, 50 + (visual.scale * 20)),
                        ],
                      ),
                    ),
                  );
                }).toList() ?? [];
              }),

            // Main result display
            if (_controller.value > 0.3)
              Center(
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 3000),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: _controller.value < 0.8
                        ? 0.8 + _random.nextDouble() * 0.4
                        : 1.0 + (1.0 - _controller.value) * 2,
                      child: child,
                    );
                  },
                  child: Text(
                    _displayNumber.toString(),
                    style: TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Theme.of(context).primaryColor.withAlpha(204),
                          blurRadius: 12,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (_animationComplete)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedBuilder(
                    animation:_pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.touch_app, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Tap anywhere to continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                      ),
                    ),
                      ],
                  ),
                ),
              ),
                ),
              ),
            ],
            );
          },
        ),
      );
    }

  // Current color scheme
  final colorScheme = DiceColorScheme.vibrant;

  // Get color based on die type
    Color _getDiceColor(int sides) {
      switch(sides) {
        case 4: return colorScheme.d4;
        case 6: return colorScheme.d6;
        case 8: return colorScheme.d8;
        case 10: return colorScheme.d10;
        case 12: return colorScheme.d12;
        case 20: return colorScheme.d20;
        case 100: return colorScheme.d100;
        default: return colorScheme.defaultDice;
      }
    }
  } 

// Helper class to store visual properties for each die
class DiceVisual {
  Offset position;
  double rotation;
  double scale;
  int result;
  late List<Offset> path; // Path for the die to follow
  int pathIndex = 0; // Current position in the path
  late double initialSpeed;
  late double currentSpeed;
  late double decelaration;

  DiceVisual({
    required this.position,
    required this.rotation,
    required this.scale,
    required this.result,
  }) {
    // Generate a random path for this die
    path = _generateRandomPath();

    // Set initial physics properties
    final random = Random();
    initialSpeed = 0.3 + random.nextDouble() * 0.4;
    currentSpeed = initialSpeed;
    decelaration = 0.01 + random.nextDouble() * 0.02; 
  }

  // Generate a random path with multiple points
  List<Offset> _generateRandomPath() {
    final Random random = Random();
    final List<Offset> points = [];

    // Start at current position
    points.add(position);

    // Generate random points along the path
    final int numPoints = random.nextInt(3) + 4; // Between 4 and 6 points

    // Target destination
    final targetX = 0.1 + random.nextDouble() * 0.8;
    final targetY = 0.1 + random.nextDouble() * 0.8;
    
    for (int i=0; i < numPoints; i++) {
      // Distribute points along the path with some randomness
      final progress = (i + 1) / numPoints;

      // Higher in the first half, then gradually settling
      double bounceHeight;
      if (progress < 0.6) {
        // Higher bounces at the beginning
        bounceHeight = (1.0 - progress) * (0.2 + random.nextDouble() * 0.8);
      } else {
        // Smaller bounces at the end
        bounceHeight = (1.0 - progress) * (0.1 + random.nextDouble() * 0.4);
      }

      // Apply bounce using sine wave pattern
      final verticalOffset = -bounceHeight * sin(progress * 3 * pi);

      // Add some curves to make it look like it's bouncing/rolling
      final deviation = (1 - progress) * (random.nextDouble() * 0.2 - 0.1);
      
      points.add(Offset(
        position.dx + (targetX - position.dx) * progress + deviation,
        position.dy + (targetY - position.dy) * progress + verticalOffset,  
      ));
    }

    return points;
  }

  // Move along the path
  void moveAlongPath(double progress) {
    // Calculate which segment of the path we should be on
    final segmentLength = 1.0 / (path.length - 1);
    final segment = (progress / segmentLength).floor();

    // Clamp to valid range
    final currentSegment = segment.clamp(0, path.length - 2);

    // Calculate progress within this segment (0-1)
    final segmentProgress = (progress - (currentSegment * segmentLength)) / segmentLength;
  
    // Interpolate between current point and next point
    final start = path[currentSegment];
    final end = path[currentSegment + 1];

    position = Offset(
      start.dx + (end.dx - start.dx) * segmentProgress,
      start.dy + (end.dy - start.dy) * segmentProgress,
    );
  }

  void updateRotation(double progress) {
    // Fast at first, then gradually slow down
    if (progress < 0.1) {
      // Initial acceleration
      currentSpeed = initialSpeed * (1 + progress * 5);
    } else {
      // Gradual decelation
      currentSpeed = max(0.05, initialSpeed * (1.0 - (progress - 0.1) / 0.9));
    }

    // Add different rotation axes
    final random = Random();

    rotation += currentSpeed * (1 + random.nextDouble() * 0.5);
  }
}  