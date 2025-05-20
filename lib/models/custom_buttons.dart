import 'package:flutter/material.dart';

class DiceButton extends StatefulWidget {
  final int sides;
  final VoidCallback onPressed;
  final bool isRolling;

  const DiceButton({
    super.key,
    required this.sides,
    required this.onPressed,
    this.isRolling = false,
  });

  @override
  State<DiceButton> createState() => _DiceButtonState();
}

class _DiceButtonState extends State<DiceButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  IconData _getDiceIcon() {
    // Basic icon mapping
    switch(widget.sides) {
      case 6:
        return Icons.casino;
      case 20:
        return Icons.icecream;
      default:
        return Icons.change_history;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: widget.isRolling
          ? Colors.white.withOpacity(0.7)
          : Colors.white,
        ),
        onPressed: widget.isRolling ? null : widget.onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(
              turns: _animation,
              child: Icon(
                _getDiceIcon(), 
                size: 24,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}