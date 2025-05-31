import 'package:flutter/material.dart';
import '../widgets/dice_roller.dart';
import '../widgets/history.dart';
import '../widgets/settings.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController(initialPage: 1);
  int _currentPage = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleText()),
        actions: [
          // Add a button to manually naigate between screens
          IconButton(
            icon: Icon(_currentPage == 0 ? Icons.history : Icons.casino),
            onPressed: () {
              // Cycle through screens
              int nextPage = (_currentPage + 1) % 3;
              _pageController.animateToPage(
                nextPage,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: const [
              // Left: Setting screen
              SettingsScreen(),

              // Middle: Dice roller screen (home)
              DiceRoller(),

              // Your history screen
              RollHistory(),
            ],
          ),
          
          // Right edge tap area to navigate to dice roller (visible on history page)
            if (_currentPage == 0)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
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
          if (_currentPage == 1)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
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
            if (_currentPage == 1)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
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

          // Right side tap area (only visible on history page)
            if (_currentPage == 2)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
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
        ],
      ),
      // bottom navigation for even easier navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
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
        ]
      )
    );
  }

  // Helper methods for dynamic UI elements
  String _getTitleText() {
    switch (_currentPage) {
      case 0: return 'Settings';
      case 1: return 'Dice Roller';
      case 2: return 'Roll History';
      default: return 'Dice Roller';
    }
  }

  IconData _getActionIcon() {
    switch (_currentPage) {
      case 0: return Icons.casino;
      case 1: return Icons.history;
      case 2: return Icons.settings;
      default: return Icons.casino;
    }
  }
}