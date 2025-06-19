import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class DiceRollAnimationPage extends StatefulWidget {
  // Properties
  final Map<int, int> diceTypes; // Map<sides, count>
  final int modifier;
  final int result;
  final VoidCallback? onComplete;

  const DiceRollAnimationPage({
    super.key,
    required this.diceTypes,
    required this.modifier,
    required this.result,
    this.onComplete,
  });

  @override
  State<DiceRollAnimationPage> createState() => _DiceRollAnimationPageState();
}

class _DiceRollAnimationPageState extends State<DiceRollAnimationPage> with TickerProviderStateMixin {
  // Animation-related properties
  late AnimationController _scaleController;
  Timer? _numberTimer;
  int _animationStep = 0;
  int _animationInterval = 50; // milliseconds

  // State variables
  int _rollingNumber = 0;
  bool _showResult = false;

  // Lifecycle methods
  @override
  void initState() {
    super.initState();
    try {
      _initializeAnimation();
    } catch (e) {
      _handleError('Animation initialization failed: $e');
    }
  }

  @override
  void dispose() {
    _cleanupAnimation();
    super.dispose();
  }

  // Error handling
  void _handleError(String message) {
    debugPrint(message);
    // Show a subtle error in the UI if animation fails
    setState(() {
      _showResult = true;
      _rollingNumber = widget.result;
    });
  }

  // Animation initialization and cleanup
  void _initializeAnimation() {
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _startRollingAnimation();
  }

  void _cleanupAnimation() {
    _numberTimer?.cancel();
    if (_scaleController.isAnimating) {
      _scaleController.stop();
    }
    _scaleController.dispose();
  }

  // Animation logic
  void _startRollingAnimation() {
    try {
      final (minValue, maxValue) = _calculateValueRange();
      final random = Random();
      
      if (!mounted) return;
      
      setState(() {
        _rollingNumber = minValue + random.nextInt(maxValue - minValue + 1);
      });
      
      _numberTimer = Timer.periodic(Duration(milliseconds: _animationInterval), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        
        setState(() {
          _rollingNumber = minValue + random.nextInt(maxValue - minValue + 1);
          _updateAnimationSpeed();
          
          timer.cancel();
          if (_animationStep < 25) {
            _numberTimer = Timer(
              Duration(milliseconds: _animationInterval),
              _startRollingAnimation
            );
          } else {
            _finishAnimation();
          }
        });
      });
    } catch (e) {
      _handleError('Rolling animation failed: $e');
    }
  }

  // Helper methods
  (int, int) _calculateValueRange() {
    if (widget.diceTypes.isEmpty) {
      return (widget.modifier, widget.modifier);
    }
    
    final int totalDiceCount = widget.diceTypes.entries
        .fold(0, (sum, entry) => sum + entry.value);
    
    final int maxPossibleValue = widget.diceTypes.entries
        .fold(0, (sum, entry) => sum + (entry.key * entry.value)) + widget.modifier;
    
    final int minPossibleValue = totalDiceCount + widget.modifier;
    
    return (minPossibleValue, maxPossibleValue);
  }

  void _updateAnimationSpeed() {
    _animationStep++;
    if (_animationStep > 4) _animationInterval = 100;
    if (_animationStep > 8) _animationInterval = 200; 
    if (_animationStep > 12) _animationInterval = 300;
  }

  void _finishAnimation() {
    if (!mounted) return;
    
    setState(() {
      _rollingNumber = widget.result;
      _showResult = true;
    });
    
    try {
      _scaleController.forward();
    } catch (e) {
      _handleError('Scale animation failed: $e');
    }
  }

  String _getDiceDescription() {
    final buffer = StringBuffer();
    
    if (widget.diceTypes.isEmpty) {
      return widget.modifier.toString();
    }
    
    widget.diceTypes.forEach((sides, count) {
      if (buffer.isNotEmpty) buffer.write(' + ');
      buffer.write('${count}d$sides');
    });
    
    if (widget.modifier != 0) {
      buffer.write(' ${widget.modifier > 0 ? '+' : ''}${widget.modifier}');
    }
    
    return buffer.toString();
  }

  // Build method
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: _showResult ? () {
          widget.onComplete?.call();
        } : null,
        child: Container(
          color: Colors.black.withOpacity(0.8),
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(_showResult ? 40 : 30),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getDiceDescription(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedScale(
                    scale: _showResult ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _rollingNumber.toString(),
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: _showResult 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (widget.modifier != 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "(includes ${widget.modifier > 0 ? '+' : ''}${widget.modifier})",
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  if (_showResult)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text(
                        "Tap to dismiss",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}