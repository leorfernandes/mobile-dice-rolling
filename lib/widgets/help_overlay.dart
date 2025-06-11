import 'package:flutter/material.dart';

class HelpOverlay extends StatelessWidget {
  final VoidCallback onDismiss;
  final int horizontalPage;
  final int verticalPage;

  const HelpOverlay({
    super.key,
    required this.onDismiss,
    required this.horizontalPage,
    required this.verticalPage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent background
        GestureDetector(
          onTap: onDismiss,
          child: Container(
            color: Colors.black54,
          ),
        ),
        // Arrows and text
        Center (
          child: Stack(
            children: 
              _buildArrows(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildArrows() {
    final List<Widget> arrows = [];

    if (verticalPage == 0) {
      // On the horizontal pages
      switch (horizontalPage) {
        case 0: // Settings page
          arrows.add(_buildArrow(
            alignment: Alignment.centerRight,
            icon: Icons.arrow_forward,
            label: 'Roller',
          ));
          break;
        case 1: // Dice Roller Page
          arrows.addAll([
            _buildArrow(
              alignment: Alignment.topCenter,
              icon: Icons.arrow_upward,
              label: 'Roll',
            ),
            _buildArrow(
              alignment: Alignment.centerLeft,
              icon: Icons.arrow_back,
              label: 'Settings',
            ),
            _buildArrow(
              alignment: Alignment.centerRight,
              icon: Icons.arrow_forward,
              label: 'History',
            ),
            _buildArrow(
              alignment: Alignment.bottomCenter,
              icon: Icons.arrow_downward,
              label: 'Presets',
            ),
          ]);
          break;
        case 2: // History page
          arrows.add(_buildArrow(
            alignment: Alignment.centerLeft,
            icon: Icons.arrow_back,
            label: 'Roller',
          ));
          break;
      }
    } else {
      // On the presets page
      arrows.add(_buildArrow(
        alignment: Alignment.topCenter,
        icon: Icons.arrow_upward,
        label: 'Roller',
      ));
    }

    return arrows;
  }

  Widget _buildArrow({
    required Alignment alignment,
    required IconData icon,
    required String label,
  }) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column (
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}