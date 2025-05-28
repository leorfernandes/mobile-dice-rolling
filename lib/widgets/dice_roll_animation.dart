import 'package:flutter/material.dart';
import 'dart:math';

class DiceRollAnimation extends StatefulWidget {
  final Map<int, List<int>> results;
  final int modifier;
  final VoidCallback onComplete;

  const DiceRollAnimation({
    super.key,
    required this.results,
    required this.modifier,
    required this.onComplete,
  });

  @override
  State<DiceRollAnimation> createState() => _DiceRollAnimationState();
}

class _DiceRollAnimationState extends State<DiceRollAnimation>
  with SingleTickerProviderStateMixin {
    late AnimationController _controller;
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
                  visual.scale = 1 + _random.nextDouble() * 0.4;

                  if (_controller.value > 0.5) {
                    visual.speed = visual.speed * (1.0 - (_controller.value - 0.5) * 0.5);
                    visual.rotation += visual.speed;
                  } else {
                    visual.speed = 0.2 + _random.nextDouble() * 0.3;
                    visual.rotation += visual.speed;
                  }

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
          Future.delayed(const Duration(milliseconds: 500), () {
            widget.onComplete();
          });
        }
      });

      // Start the animation
      _controller.forward();
    }

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

    // Get icon for a specific die type
    IconData getDiceIcon(int sides) {
      switch (sides) {
        case 4: return Icons.change_history; // Triangle for d4
        case 6: return Icons.square; // Square for d6
        case 8: return Icons.hexagon; // Hexagon for d8
        case 10: return Icons.pentagon; // Pentagon for d10
        case 12: return Icons.dangerous; // Hexagon for d12
        case 20: return Icons.diamond_rounded; // Comples shape for d220
        case 100: return Icons.circle; // Circle for d100
        default: return Icons.casino; // Default dice icon for any other value
      }
    }

    @override
    Widget build(BuildContext context) {
      final Size screenSize = MediaQuery.of(context).size;

      return AnimatedBuilder(
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
                          // The die icon
                          Icon (
                            getDiceIcon(sides),
                            size: 50 + (visual.scale * 20),
                            color: _getDiceColor(sides).withOpacity(0.9),
                          ),

                          // The result number shown inside the die
                          Text(
                            visual.result.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 2,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            )
                          ),
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
          ],
          );
        },
      );
    }

  // Get color based on die type
    Color _getDiceColor(int sides) {
      switch(sides) {
        case 4: return Colors.red.shade800;
        case 6: return Colors.blue.shade800;
        case 8: return Colors.green.shade800;
        case 10: return Colors.amber.shade800;
        case 12: return Colors.purple.shade800;
        case 20: return Colors.teal.shade800;
        case 100: return Colors.deepOrange.shade800;
        default: return Colors.grey.shade800;
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
  double speed = 0.0; // Current speed
  double deceleration = 0.01; // How quickly it slows down

  DiceVisual({
    required this.position,
    required this.rotation,
    required this.scale,
    required this.result,
  }) {
    // Generate a random path for this die
    path = _generateRandomPath();
  }
  
  // Generate a random path with multiple points
  List<Offset> _generateRandomPath() {
    final Random random = Random();
    final List<Offset> points = [];

    // Start at current position
    points.add(position);

    // Add6-10 random waypoints
    final int numPoints = random.nextInt(5) + 6;
    for (int i=0; i < numPoints; i++) {
      points.add(Offset(
        0.1 + random.nextDouble() * 0.8,
        0.1 + random.nextDouble() * 0.8, 
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
}  