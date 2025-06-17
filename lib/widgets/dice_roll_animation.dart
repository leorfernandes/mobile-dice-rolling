import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/dice_icon.dart';

class DiceRollAnimationPage extends StatefulWidget {  
  final int diceCount;
  final int diceSides;
  final int modifier;
  final int result;
  final VoidCallback? onComplete;

  const DiceRollAnimationPage({
    super.key,
    required this.diceCount,
    required this.diceSides,
    required this.modifier,
    required this.result,
    this.onComplete,
  });

  @override
  State<DiceRollAnimationPage> createState() => _DiceRollAnimationPageState();
}

class _DiceRollAnimationPageState extends State<DiceRollAnimationPage> with TickerProviderStateMixin {
  // Animation controllers and state variables
  late AnimationController _moveController;
  late AnimationController _scaleController;
  late AnimationController _throwController;
  late AnimationController _spinController;

  Offset _fingerPosition = Offset.zero;
  bool _isHolding = false;
  bool _isThrown = false;
  bool _showNumbers = false;
  double _lastDx = 0.0;
  double _angularVelocity = 0.0;

  // Dice state
  late List<double> _diceRotations;
  late List<double> _diceOffsets;

  // Number rolling
  int _rollingNumber = 0;
  Timer? _numberTimer;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..forward();

    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _throwController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _throwController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showNumbers = true;
        });
        _startNumberRolling();
      }
    });

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
      setState(() {
        for (int i = 0; i < _diceRotations.length; i++) {
          _diceRotations[i] += _angularVelocity;
        }
        _angularVelocity *= 0.96; // Friction
        if (_angularVelocity.abs() < 0.001) {
          _spinController.stop();
        }
      });
    });

    // Initialize dice rotations and offsets
    final rand = Random();
    _diceRotations = List.generate(widget.diceCount, (_) => rand.nextDouble() * pi * 2);
    _diceOffsets = List.generate(widget.diceCount, (i) {
      // Spread dice horizontally, centered
      double spread = (i - (widget.diceCount - 1) / 2) * 60.0;
      return spread + rand.nextDouble() * 10 - 5;
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _moveController.dispose();
    _throwController.dispose();
    _numberTimer?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isHolding = true;
      _fingerPosition = details.localPosition;
    });
    _moveController.forward(from: 0.0);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isHolding && !_isThrown) {
      setState(() {
        _fingerPosition = details.localPosition;
        _lastDx = details.delta.dx;
        for (int i = 0; i < _diceRotations.length; i++) {
          _diceRotations[i] += details.delta.dx * 0.01;
        }      
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isHolding && !_isThrown) {
      final velocity = details.velocity.pixelsPerSecond;
      // Calculate angular velocity based on last drag
      _angularVelocity = _lastDx * 0.02;
      if (_angularVelocity.abs() > 0.001) {
        _spinController.repeat();
      }
      if (velocity.dy < -300) {
        // Upward throw detected
        _spinController.stop();
        setState(() {
          _isThrown = true;
        });
        _throwController.forward(from: 0.0);
      }
      setState(() {
        _isHolding = false;
      });
    }
  }

  void _startNumberRolling() {
    final max = widget.diceCount * widget.diceSides + widget.modifier;
    final min = widget.diceCount + widget.modifier;
    int interval = 40;
    int slowdownStep = 0;
    _rollingNumber = Random().nextInt(max - min + 1) + min;

    _numberTimer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      setState(() {
        _rollingNumber = Random().nextInt(max - min + 1) + min;
      });
      slowdownStep++;
      if (slowdownStep > 20) interval = 80;
      if (slowdownStep > 35) interval = 160;
      if (slowdownStep > 45) interval = 320;
      if (slowdownStep > 50) {
        timer.cancel();
        setState(() {
          _rollingNumber = widget.result;
        });
      }
    });
  }

  void _onTap() {
    widget.onComplete?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final Offset center = Offset(screenSize.width / 2, screenSize.height / 2);

    // Dice position logic
    Offset dicePos = center;
    if (_isHolding && !_isThrown) {
      dicePos = _fingerPosition;
    } else if (_isThrown) {
      // Animate dice moving up and shrinking
      dicePos = Offset(center.dx, center.dy - _throwController.value * screenSize.height * 0.7);
    }

    double diceScale = _scaleController.value;
    if (_isThrown) {
      diceScale = 1.0 - _throwController.value;
    }

    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: _showNumbers ? () => _onTap : null,
      child: Stack(
        children: [
          // Dice animation
          AnimatedBuilder(
            animation: Listenable.merge([_scaleController, _throwController]),
            builder: (context, child) {
              if (_showNumbers) return const SizedBox.shrink();
              return Stack(
                children: List.generate(widget.diceCount, (i) {
                  // Dice position logic
                  Offset dicePos = center + Offset(_diceOffsets[i], 0);
                  if (_isHolding && !_isThrown) {
                    dicePos = _fingerPosition + Offset(_diceOffsets[i], 0);
                  } else if (_isThrown) {
                    // Animate dice moving up and shrinking, with a little horizontal spread
                    dicePos = Offset(
                      center.dx + _diceOffsets[i] * (1 - _throwController.value),
                      center.dy - _throwController.value * screenSize.height * 0.7,
                    );
                  }

                  return Positioned(
                    left: dicePos.dx - 40 * diceScale,
                    top: dicePos.dy - 40 * diceScale,
                    child: Transform.rotate(
                      angle: _diceRotations[i],
                      child: Transform.scale(
                        scale: diceScale,
                        child: DiceIcon(
                          sides: widget.diceSides,
                          size: 80,
                          fillColor: Theme.of(context).colorScheme.primary,
                          strokeColor: Theme.of(context).colorScheme.background,
                        ),
                      ),
                    ),
                  );
            }),
          );
            },
          ),
          // Numbers box
          if (_showNumbers)
          Center(
            child: AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  '$_rollingNumber',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}