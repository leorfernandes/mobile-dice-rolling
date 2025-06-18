import 'dart:math';
import 'package:flutter/material.dart';
import '../models/dice_icon.dart';

class DiceRollAnimationPage extends StatefulWidget {
  // Updated to accept a map of dice sides and their counts
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
  // Track each die's position, rotation, and type
  late List<Offset> _dicePositions;
  late List<double> _diceRotations;
  late List<int> _diceSides; // Store the sides for each die
  
  // Track dragging state
  bool _isDragging = false;
  Offset _lastDragPosition = Offset.zero;
  
  // Animation controller for results
  late AnimationController _resultAnimController;
  bool _showResult = false;
  bool _initialized = false;

  int get _totalDiceCount => 
      widget.diceTypes.values.fold(0, (sum, count) => sum + count);

  @override
  void initState() {
    super.initState();
    print("DiceRollAnimationPage - initState with dice types: ${widget.diceTypes}");
    
    // Create lists with the correct total length
    final totalDice = _totalDiceCount;
    
    // Initialize with empty values
    _dicePositions = List.generate(totalDice, (_) => Offset.zero);
    _diceRotations = List.generate(totalDice, (_) => 0.0);
    
    // Initialize the sides for each die
    _diceSides = [];
    widget.diceTypes.forEach((sides, count) {
      for (int i = 0; i < count; i++) {
        _diceSides.add(sides);
      }
    });
    
    // Shuffle the dice sides for visual variety
    _diceSides.shuffle();
    
    // Initialize rotations
    final random = Random();
    for (int i = 0; i < _diceRotations.length; i++) {
      _diceRotations[i] = random.nextDouble() * 2 * pi;
    }
    
    _resultAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _resultAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showResult = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Now it's safe to access MediaQuery
    if (!_initialized) {
      final random = Random();
      final screenSize = MediaQuery.of(context).size;
      
      // Initialize dice positions in the center with some spread
      for (int i = 0; i < _dicePositions.length; i++) {
        _dicePositions[i] = Offset(
          screenSize.width / 2 + (random.nextDouble() * 120 - 60),
          screenSize.height / 2 + (random.nextDouble() * 120 - 60),
        );
      }
      
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _resultAnimController.dispose();
    super.dispose();
  }

  void _throwDice() {
    print("Throwing dice");
    _resultAnimController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        // Handle gestures at the container level to move all dice
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
            _lastDragPosition = details.localPosition;
          });
        },
        onPanUpdate: (details) {
          if (_isDragging && !_showResult) {
            final delta = details.localPosition - _lastDragPosition;
            setState(() {
              // Move all dice by the same amount
              for (int i = 0; i < _dicePositions.length; i++) {
                _dicePositions[i] += delta;
                // Add a bit of rotation based on horizontal movement
                _diceRotations[i] += delta.dx * 0.01;
              }
              _lastDragPosition = details.localPosition;
            });
          }
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
          });
          
          // If thrown upward with enough velocity
          if (details.velocity.pixelsPerSecond.dy < -500) {
            _throwDice();
          }
        },
        onTap: _showResult ? () {
          widget.onComplete?.call();
          Navigator.of(context).pop();
        } : null,
        child: Container(
          color: Colors.black.withOpacity(0.7),
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Dice layer
              if (!_showResult)
                ...List.generate(_dicePositions.length, (index) {
                  // Get the correct dice sides for this index
                  final sides = _diceSides[index];
                  
                  // Size variation based on sides (bigger dice for higher sides)
                  final dieSize = 60 + (sides / 20 * 20); // 60-80px based on sides
                  
                  return Positioned(
                    left: _dicePositions[index].dx - dieSize / 2,
                    top: _dicePositions[index].dy - dieSize / 2,
                    child: Transform.rotate(
                      angle: _diceRotations[index],
                      child: Container(
                        width: dieSize,
                        height: dieSize,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: DiceIcon(
                            sides: sides,
                            size: dieSize * 0.9,
                            fillColor: Theme.of(context).colorScheme.primary,
                            strokeColor: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              
              // Result box
              if (_showResult)
  Center(
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Result",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.result.toString(),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          if (widget.modifier != 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "(includes ${widget.modifier > 0 ? '+' : ''}${widget.modifier} modifier)",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Button to roll again
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showResult = false;
                    // Reset dice positions
                    // ...reset code here...
                  });
                },
                child: Text("Roll Again"),
              ),
              SizedBox(width: 16),
              // Button to dismiss
              OutlinedButton(
                onPressed: () {
                  widget.onComplete?.call();
                },
                child: Text("Dismiss"),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Get a color based on the die sides
  Color _getDiceColor(int sides) {
    switch (sides) {
      case 4:
        return Colors.blue;
      case 6:
        return Colors.red;
      case 8:
        return Colors.green;
      case 10:
        return Colors.purple;
      case 12:
        return Colors.orange;
      case 20:
        return Colors.teal;
      default:
        return Colors.red;
    }
  }
}