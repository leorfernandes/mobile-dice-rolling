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
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleText()),
      ),
      body: Stack(
        children: [ PageView(
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
              // Left: Setting screen
              SettingsScreen(),

              // Middle: Dice roller screen (home)
              DiceRoller(),

              // Right: Your history screen
              RollHistory(),
            ],
          ),

          // Bottom: Presets Screen
          PresetsScreen(
            onNavigateToRoller: () {
              _verticalController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ).then((_) {
                _horizontalController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              });
            }
          ),
        ],
        ),
          
          // Right edge tap area to navigate to dice roller (visible on history page)
            if (_verticalPage == 0 && _horizontalPage == 0)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    _horizontalController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 40,
                    color: Colors.transparent,
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Text(
                          'ROLLER',
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


          // Left edge tap area to navigate to history (visible on dice roller page)
          if (_verticalPage == 0 && _horizontalPage == 1)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  _horizontalController.animateToPage(
                    0, // Navigate to settings page
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: 40,
                  color: Colors.transparent,
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'SETTINGS',
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

            // Right edge tap area (visible on dice roller page)
            if (_verticalPage == 0 && _horizontalPage == 1)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    _horizontalController.animateToPage(
                      2, // Navigate to history page
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 40,
                    color: Colors.transparent,
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Text(
                          'HISTORY',
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

          // Bottom edge tap area (visible on dice roller page)
           if (_verticalPage == 0 && _horizontalPage == 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
               onTap: () {
                    _verticalController.animateToPage(
                      1, // Navigate to preset page
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                child: Container(
                  width: 40,
                  color: Colors.transparent,
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: 0,
                      child: Text(
                        'PRESETS',
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

          // Right side tap area (only visible on history page)
            if (_verticalPage == 0 && _horizontalPage == 2)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    _horizontalController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 40,
                    color: Colors.transparent,
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          'ROLLER',
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

            if (_verticalPage == 1)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: GestureDetector(
               onTap: () {
                    _verticalController.animateToPage(
                      0, // Navigate to roller page
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                child: Container(
                  width: 40,
                  color: Colors.transparent,
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: 0,
                      child: Text(
                        'ROLLER',
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
        ],
      ),
      // bottom navigation for even easier navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _verticalPage == 1 ? 3 : _horizontalPage,
        onTap: (index) {
          if (index == 3) {
          // Navigate to presets (vertical swipe)
          _verticalController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves. easeInOut,
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
        ]
      )
      );
    }
      
    // Helper methods for dynamic UI elements
    String _getTitleText() {
      if (_verticalPage == 1) return 'Saved Presets';
  
      switch (_horizontalPage) {
        case 0: return 'Settings';
        case 1: return 'Dice Roller';
        case 2: return 'Roll History';
        case 3: return 'Saved Presets';
        default: return 'Dice Roller';
      }
    }
  
    IconData _getActionIcon() {
      if (_verticalPage == 1) return Icons.save;
  
      switch (_horizontalPage) {
        case 0: return Icons.casino;
        case 1: return Icons.history;
        case 2: return Icons.settings;
        default: return Icons.casino;
      }
    }
  }