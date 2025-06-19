import 'package:flutter/material.dart';

/// A widget that displays navigation help as an overlay with directional arrows and labels
class HelpOverlay extends StatelessWidget {
  /// Callback function when the overlay is dismissed
  final VoidCallback onDismiss;
  
  /// Current horizontal page index (0: Settings, 1: Dice Roller, 2: History)
  final int horizontalPage;
  
  /// Current vertical page index (0: Main pages, 1: Presets page)
  final int verticalPage;

  const HelpOverlay({
    super.key,
    required this.onDismiss,
    required this.horizontalPage,
    required this.verticalPage,
  });

  @override
  Widget build(BuildContext context) {
    // Validate page indices
    if (horizontalPage < 0 || horizontalPage > 2) {
      debugPrint('Warning: Invalid horizontalPage value: $horizontalPage');
    }
    if (verticalPage < 0 || verticalPage > 1) {
      debugPrint('Warning: Invalid verticalPage value: $verticalPage');
    }

    return Stack(
      children: [
        // Semi-transparent background that dismisses overlay when tapped
        GestureDetector(
          onTap: onDismiss,
          child: Container(
            color: Colors.black54,
          ),
        ),
        // Centered stack of directional indicators
        Center(
          child: Stack(
            children: _buildNavigationGuides(),
          ),
        ),
      ],
    );
  }

  /// Builds the appropriate navigation guides based on current page position
  List<Widget> _buildNavigationGuides() {
    final List<Widget> guides = [];

    if (verticalPage == 0) {
      // Main horizontal pages
      switch (horizontalPage) {
        case 0: // Settings page
          guides.add(_buildDirectionalGuide(
            alignment: Alignment.centerRight,
            arrowIcon: Icons.arrow_forward,
            direction: 'Swipe Left',
            destination: 'Dice Roller',
          ));
          break;
        case 1: // Dice Roller Page
          guides.addAll([
            _buildDirectionalGuide(
              alignment: Alignment.centerLeft,
              arrowIcon: Icons.arrow_back,
              direction: 'Swipe Right',
              destination: 'Settings',
            ),
            _buildDirectionalGuide(
              alignment: Alignment.centerRight,
              arrowIcon: Icons.arrow_forward,
              direction: 'Swipe Left',
              destination: 'History',
            ),
            _buildDirectionalGuide(
              alignment: Alignment.bottomCenter,
              arrowIcon: Icons.arrow_downward,
              direction: 'Swipe Up',
              destination: 'Presets',
            ),
          ]);
          break;
        case 2: // History page
          guides.add(_buildDirectionalGuide(
            alignment: Alignment.centerLeft,
            arrowIcon: Icons.arrow_back,
            direction: 'Swipe Right',
            destination: 'Dice Roller',
          ));
          break;
        default:
          // Handle unexpected page index
          guides.add(_buildErrorMessage('Unknown page: $horizontalPage'));
          break;
      }
    } else if (verticalPage == 1) {
      // Presets page
      guides.add(_buildDirectionalGuide(
        alignment: Alignment.topCenter,
        arrowIcon: Icons.arrow_upward,
        direction: 'Swipe Down',
        destination: 'Dice Roller',
      ));
    } else {
      // Handle unexpected vertical page index
      guides.add(_buildErrorMessage('Unknown vertical page: $verticalPage'));
    }

    return guides;
  }

  /// Builds a directional guide with an arrow icon and descriptive text
  Widget _buildDirectionalGuide({
    required Alignment alignment,
    required String destination,
    required String direction,
    required IconData arrowIcon,
  }) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Arrow icon
            Icon(
              arrowIcon,
              color: Colors.white,
              size: 36,
            ),
            const SizedBox(height: 8),
            // Direction text
            Text(
              direction,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            // Destination text
            Text(
              'to $destination',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates an error message widget for unexpected states
  Widget _buildErrorMessage(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.red.withOpacity(0.7),
        child: Text(
          'Error: $message',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}