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
            arrow: Icons.arrow_forward,
            icon: Icons.casino,
          ));
          break;
        case 1: // Dice Roller Page
          arrows.addAll([
            _buildArrow(
              alignment: Alignment.topCenter,
              arrow: Icons.arrow_upward,
              icon: Icons.casino,
            ),
            _buildArrow(
              alignment: Alignment.centerLeft,
              arrow: Icons.arrow_back,
              icon: Icons.settings,
            ),
            _buildArrow(
              alignment: Alignment.centerRight,
              arrow: Icons.arrow_forward,
              icon: Icons.history,
            ),
            _buildArrow(
              alignment: Alignment.bottomCenter,
              arrow: Icons.arrow_downward,
              icon: Icons.save,
            ),
          ]);
          break;
        case 2: // History page
          arrows.add(_buildArrow(
            alignment: Alignment.centerLeft,
            arrow: Icons.arrow_back,
            icon: Icons.casino,
          ));
          break;
      }
    } else {
      // On the presets page
      arrows.add(_buildArrow(
        alignment: Alignment.topCenter,
        arrow: Icons.arrow_upward,
        icon: Icons.casino,
      ));
    }

    return arrows;
  }

  Widget _buildArrow({
    required Alignment alignment,
    required IconData icon,
    required IconData arrow,
  }) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column (
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              arrow,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 8),
            Icon(
              icon,
              color: Colors.white,
              size: 48,
            ),
          ],
        ),
      ),
    );
  }
}