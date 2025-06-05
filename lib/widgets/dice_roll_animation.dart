import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'dart:ui' as ui;

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

/// Helper class to store visual properties for each die
class DiceVisual {
  // Position and appearance properties
  Offset position;
  double rotation;
  double scale;
  int result;
  
  // Animation path properties
  late List<Offset> path;
  int pathIndex = 0;
  
  // Physics properties
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

  /// Generate a random path with multiple points
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
}

// -----------------------------------------------------------------------------
// MAIN WIDGET
// -----------------------------------------------------------------------------

/// Widget that animates dice rolls and displays results
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
    // Animation controllers
    late AnimationController _controller;
    late Random _random;

    late AnimationController _shakeController;
    late Animation<double> _shakeAnimation;

    int _displayNumber = 0;
    Timer? _numberChangeTimer;
    
    // Display values
    int _finalTotal = 0;
    bool _animationComplete = false;

    // Current color scheme
    final colorScheme = DiceColorScheme.vibrant;

    @override
    void initState() {
      super.initState();
      _setupAnimation();
      _setupShakeAnimation();
      _setupNumberAnimation();
    }

    @override
    void dispose() {
      _controller.dispose();
      _shakeController.dispose();
      _numberChangeTimer?.cancel();
      super.dispose();
    }

    // -----------------------------------------------------------------------------
    // ANIMATION SETUP AND CONTROL
    // -----------------------------------------------------------------------------

    void _setupAnimation() {
      _random = Random();

      // Setup main animation controller
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1800),
      );

      // Calculate final total
      _finalTotal = widget.results.entries
          .fold(0, (sum, entry) => sum + entry.value.reduce((a, b) => a + b)) + 
          widget.modifier;

      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _animationComplete = true;
          });
        }
      });

      // Start the animation
      _controller.forward();
    }

    void _setupShakeAnimation() {
      _shakeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 50),
      );

      _shakeAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 50.0)
            .chain(CurveTween(curve: Curves.easeOut)),
          weight: 25,
        ),
        TweenSequenceItem(
          tween: Tween(begin: -50.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
          weight: 25,
        ),
      ]).animate(_shakeController);

      // Repeat the shake animation while the main animation is running
      _shakeController.repeat();

      _controller.addListener(() {
        if (_controller.value > 0.8 && _shakeController.isAnimating) {
          _shakeController.stop();
          _shakeController.value = 0.0;
        }
      });
    }

    void _setupNumberAnimation() {
      _displayNumber = _finalTotal;
      _numberChangeTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (_controller.value < 0.8) {
          setState(() {
            //Generate a random number around the final total
            _displayNumber = _finalTotal + _random.nextInt(_finalTotal) - (_finalTotal ~/2);
            // Ensure number is positive
            _displayNumber = _displayNumber.abs();
          });
        } else {
          _numberChangeTimer?.cancel();
          setState(() {
            _displayNumber = _finalTotal;
          });
        }
      });
    }

    // -----------------------------------------------------------------------------
    // DICE APPEARANCE HELPERS
    // -----------------------------------------------------------------------------

    /// Get color based on die type
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

    /// Get icon for a specific die type
    Widget getDiceIcon(int sides, double size) {
      switch (sides) {
        case 4: return SvgPicture.asset(
          'assets/icons/dice-d4.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(_getDiceColor(6).withOpacity(0.9), BlendMode.srcIn),
        );
        case 6: return SvgPicture.asset(
          'assets/icons/dice-d6.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(_getDiceColor(6).withOpacity(0.9), BlendMode.srcIn),
        );
        case 8: return SvgPicture.asset(
          'assets/icons/dice-d8.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(_getDiceColor(6).withOpacity(0.9), BlendMode.srcIn),
        );
        case 10: return SvgPicture.asset(
          'assets/icons/dice-d10.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(_getDiceColor(6).withOpacity(0.9), BlendMode.srcIn),
        );
        case 12: return SvgPicture.asset(
          'assets/icons/dice-d12.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(_getDiceColor(6).withOpacity(0.9), BlendMode.srcIn),
        );
        case 20: return SvgPicture.asset(
          'assets/icons/dice-d20.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(_getDiceColor(6).withOpacity(0.9), BlendMode.srcIn),
        );
        case 100: return SvgPicture.asset(
          'assets/icons/dice-d20.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(_getDiceColor(6).withOpacity(0.9), BlendMode.srcIn),
        );
        default: return Icon(Icons.casino, size: size, color: _getDiceColor(0).withOpacity(0.9));
      }
    }

    // -----------------------------------------------------------------------------
    // WIDGET BUILD METHOD
    // -----------------------------------------------------------------------------

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
                // Background darkening overlay
                Container(
                  color: Colors.black.withOpacity(0.7 * _controller.value),
                ),

                // Main result display (animated number)
                if (_controller.value > 0.3)
                  Center(
                    child: _buildNumberDisplay(),
                  ),
              ]
            );
          },
        ),
      );
    }
    
    Widget _buildNumberDisplay() {
  return AnimatedOpacity(
    opacity: _controller.value,
    duration: const Duration(milliseconds: 300),
    child: AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.3),
                Colors.white,
                Colors.white,
                Colors.white.withOpacity(0.3),
                Colors.transparent,
              ],
              stops: const [0.0, 0.1, 0.3, 0.7, 0.9, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: 3.0,
              sigmaY: 8.0, // More vertical blur for motion effect
            ),
            child: Transform.translate(
              offset: Offset(0, _shakeAnimation.value),
              child: Text(
                _displayNumber.toString(),
                style: TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
}