import 'package:flutter/material.dart';
import '../widgets/dice_roller.dart';
import '../widgets/history.dart';
import '../widgets/settings.dart';
import '../screens/presets_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Horizontal navigation (Settings <> Roller <> History)
  final PageController _horizontalController = PageController(initialPage: 1);
  int _horizontalPage = 1;

  // Vertical navigation (Main screens <> Presets)
  final PageController _verticalController = PageController(initialPage: 0);
  int _verticalPage = 0;

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleText()),
      ),
      body: Stack(
        children: [
          PageView(
            scrollDirection: Axis.vertical,
            controller: _verticalController,
            onPageChanged: (index) {
              setState(() {
                _verticalPage = index;
              });
            },
            children: [
              // Top: Main horizontal PageView
              PageView(
                controller: _horizontalController,
                onPageChanged: (index) {
                  setState(() {
                    _horizontalPage = index;
                  });
                },
                children: const [
                  SettingsScreen(),
                  DiceRoller(),
                  RollHistory(),
                ],
              ),
              // Bottom: Presets Screen
              PresetsScreen(
                onNavigateToRoller: () {
                  _verticalController
                      .animateToPage(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                      .then((_) {
                    _horizontalController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                },
              ),
            ],
          ),

          // Edge tap areas for navigation
          // Right edge tap area to navigate to dice roller (visible on settings page)
          if (_verticalPage == 0 && _horizontalPage == 0)
            _buildEdgeTapArea(
              context: context,
              alignment: Alignment.centerRight,
              onTap: () => _horizontalController.animateToPage(
                1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              label: 'ROLLER',
              quarterTurns: 1,
            ),

          // Left edge tap area to navigate to settings (visible on dice roller page)
          if (_verticalPage == 0 && _horizontalPage == 1)
            _buildEdgeTapArea(
              context: context,
              alignment: Alignment.centerLeft,
              onTap: () => _horizontalController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              label: 'SETTINGS',
              quarterTurns: 3,
            ),

          // Right edge tap area to navigate to history (visible on dice roller page)
          if (_verticalPage == 0 && _horizontalPage == 1)
            _buildEdgeTapArea(
              context: context,
              alignment: Alignment.centerRight,
              onTap: () => _horizontalController.animateToPage(
                2,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              label: 'HISTORY',
              quarterTurns: 1,
            ),

          // Bottom edge tap area to navigate to presets (visible on dice roller page)
          if (_verticalPage == 0 && _horizontalPage == 1)
            _buildEdgeTapArea(
              context: context,
              alignment: Alignment.bottomCenter,
              onTap: () => _verticalController.animateToPage(
                1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              label: 'PRESETS',
              quarterTurns: 0,
              isHorizontal: true,
            ),

          // Left edge tap area to navigate to roller (visible on history page)
          if (_verticalPage == 0 && _horizontalPage == 2)
            _buildEdgeTapArea(
              context: context,
              alignment: Alignment.centerLeft,
              onTap: () => _horizontalController.animateToPage(
                1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              label: 'ROLLER',
              quarterTurns: 3,
            ),

          // Top edge tap area to navigate to roller (visible on presets page)
          if (_verticalPage == 1)
            _buildEdgeTapArea(
              context: context,
              alignment: Alignment.topCenter,
              onTap: () => _verticalController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              label: 'ROLLER',
              quarterTurns: 0,
              isHorizontal: true,
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _verticalPage == 1 ? 3 : _horizontalPage,
        onTap: (index) {
          if (index == 3) {
            // Navigate to presets (vertical swipe)
            _verticalController.animateToPage(
              1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            // First ensure we're on the main screen
            if (_verticalPage == 1) {
              _verticalController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
            // Then navigate horizontally
            _horizontalController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: 'Roller',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: 'Presets',
          ),
        ],
      ),
    );
  }

  // Helper widget for edge tap areas
  Widget _buildEdgeTapArea({
    required BuildContext context,
    required Alignment alignment,
    required VoidCallback onTap,
    required String label,
    required int quarterTurns,
    bool isHorizontal = false,
  }) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: isHorizontal ? double.infinity : 40,
            height: isHorizontal ? 40 : double.infinity,
            color: Colors.transparent,
            child: Center(
              child: RotatedBox(
                quarterTurns: quarterTurns,
                child: Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for dynamic UI elements
  String _getTitleText() {
    if (_verticalPage == 1) return 'Saved Presets';

    switch (_horizontalPage) {
      case 0:
        return 'Settings';
      case 1:
        return 'Dice Roller';
      case 2:
        return 'Roll History';
      case 3:
        return 'Saved Presets';
      default:
        return 'Dice Roller';
    }
  }

  IconData _getTitleIcon() {
    if (_verticalPage == 1) return Icons.save;

    switch (_horizontalPage) {
      case 0:
        return Icons.casino;
      case 1:
        return Icons.history;
      case 2:
        return Icons.settings;
      default:
        return Icons.casino;
    }
  }
}
