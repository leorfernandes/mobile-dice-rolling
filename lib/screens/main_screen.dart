import 'package:flutter/material.dart';
import '../widgets/dice_roller.dart';
import '../widgets/history.dart';
import '../widgets/settings.dart';
import '../screens/presets_screen.dart';
import '../widgets/help_overlay.dart';

/// Main screen of the dice rolling application.
/// Handles navigation between various screens with a page view approach.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // ---- Controllers and state variables ----
  final PageController _horizontalController = PageController(initialPage: 1);
  final PageController _verticalController = PageController(initialPage: 0);
  int _horizontalPage = 1; // 0: Settings, 1: Dice Roller, 2: History
  int _verticalPage = 0;   // 0: Main screens, 1: Presets
  bool _showHelp = false;  // Controls help overlay visibility

  // ---- Lifecycle methods ----
  @override
  void initState() {
    super.initState();
    // Show help overlay on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _showHelp = true);
      }
    });
  }

  @override
  void dispose() {
    // Clean up controllers
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  // ---- Build methods ----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main interface stack
          Stack(
            children: [
              _buildMainPageView(),
              ..._buildEdgeTapAreas(context),
              _buildHelpButton(),
            ],
          ),
          // Conditionally show help overlay
          if (_showHelp)
            HelpOverlay(
              onDismiss: () => setState(() => _showHelp = false),
              horizontalPage: _horizontalPage,
              verticalPage: _verticalPage,
            ),
        ]
      )
    );
  }

  /// Builds the main navigation button that shows the help overlay
  Widget _buildHelpButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      right: 8,
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () => setState(() => _showHelp = true),
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  /// Builds the main page view with vertical navigation between
  /// the horizontal screens and the presets screen
  Widget _buildMainPageView() {
    return PageView(
      scrollDirection: Axis.vertical,
      controller: _verticalController,
      // Disable vertical scrolling if not on the dice roller page
      physics: _horizontalPage == 1 
          ? const AlwaysScrollableScrollPhysics() 
          : const NeverScrollableScrollPhysics(),
      onPageChanged: (index) {
        if (mounted) {
          setState(() {
            _verticalPage = index;
          });
        }
      },
      children: [
        // Main horizontal PageView (Settings, Roller, History)
        PageView(
          controller: _horizontalController,
          onPageChanged: (index) {
            if (mounted) {
              setState(() {
                _horizontalPage = index;
              });
            }
          },
          children: const [
            SettingsScreen(),
            DiceRoller(),
            RollHistory(),
          ],
        ),
        // Presets Screen
        PresetsScreen(
          onNavigateToRoller: _navigateToRoller,
        ),
      ],
    );
  }

  /// Navigate from presets back to the dice roller
  void _navigateToRoller() {
    try {
      _verticalController
        .animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) {
          if (mounted) {
            _horizontalController.animateToPage(
              1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
    } catch (e) {
      debugPrint('Error navigating to roller: $e');
    }
  }

  /// Builds tap areas at the edges of the screen for navigation
  List<Widget> _buildEdgeTapAreas(BuildContext context) {
    final List<Widget> areas = [];

    // Settings page: right edge to roller
    if (_verticalPage == 0 && _horizontalPage == 0) {
      areas.add(_buildEdgeTapArea(
        context: context,
        alignment: Alignment.centerRight,
        onTap: () => _animateToHorizontalPage(1),
      ));
    }

    // Dice roller page: left to settings, right to history, bottom to presets
    if (_verticalPage == 0 && _horizontalPage == 1) {
      areas.addAll([
        _buildEdgeTapArea(
          context: context,
          alignment: Alignment.centerLeft,
          onTap: () => _animateToHorizontalPage(0),
        ),
        _buildEdgeTapArea(
          context: context,
          alignment: Alignment.centerRight,
          onTap: () => _animateToHorizontalPage(2),
        ),
        _buildEdgeTapArea(
          context: context,
          alignment: Alignment.bottomCenter,
          onTap: () => _animateToVerticalPage(1),
          isHorizontal: true,
        ),
      ]);
    }

    // History page: left to roller
    if (_verticalPage == 0 && _horizontalPage == 2) {
      areas.add(_buildEdgeTapArea(
        context: context,
        alignment: Alignment.centerLeft,
        onTap: () => _animateToHorizontalPage(1),
      ));
    }

    // Presets page: top to roller
    if (_verticalPage == 1) {
      areas.add(_buildEdgeTapArea(
        context: context,
        alignment: Alignment.topCenter,
        onTap: () => _animateToVerticalPage(0),
        isHorizontal: true,
      ));
    }

    return areas;
  }

  /// Helper method to animate to a horizontal page with error handling
  void _animateToHorizontalPage(int page) {
    try {
      _horizontalController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      debugPrint('Error navigating to horizontal page $page: $e');
    }
  }

  /// Helper method to animate to a vertical page with error handling
  void _animateToVerticalPage(int page) {
    try {
      _verticalController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      debugPrint('Error navigating to vertical page $page: $e');
    }
  }

  /// Builds a single edge tap area for navigation
  Widget _buildEdgeTapArea({
    required BuildContext context,
    required Alignment alignment,
    required VoidCallback onTap,
    bool isHorizontal = false,
  }) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: isHorizontal ? double.infinity : 48,
            height: isHorizontal ? 48 : double.infinity,
            color: Colors.transparent,
            child: Center(
              child: Container( 
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIcon(alignment),
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                      size: 36,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }

  /// Determines the appropriate icon for navigation based on current page and alignment
  IconData _getIcon(Alignment alignment) {
    if (_verticalPage == 0) {
      // On the horizontal pages
      switch (_horizontalPage) {
        case 0: // Settings page
          if (alignment == Alignment.centerRight) return Icons.casino;
          break;
        case 1: // Dice Roller Page
          if (alignment == Alignment.centerLeft) return Icons.settings;
          if (alignment == Alignment.centerRight) return Icons.history;
          if (alignment == Alignment.topCenter) return Icons.casino;
          if (alignment == Alignment.bottomCenter) return Icons.save; 
          break;
        case 2: // History page
          if (alignment == Alignment.centerLeft) return Icons.casino;
          break;
      }
    } else {
      // On the presets page
      if (alignment == Alignment.topCenter) return Icons.casino;
    }
    // Default icon if no match found
    return Icons.help_outlined;
  }
}
