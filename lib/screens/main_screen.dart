import 'package:flutter/material.dart';
import '../widgets/dice_roller.dart';
import '../widgets/history.dart';
import '../widgets/settings.dart';
import '../screens/presets_screen.dart';
import '../widgets/help_overlay.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Controllers and page indices
  final PageController _horizontalController = PageController(initialPage: 1);
  final PageController _verticalController = PageController(initialPage: 0);
  int _horizontalPage = 1;
  int _verticalPage = 0;
  bool _showHelp = false;

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Stack(
            children: [
          _buildMainPageView(),
          ..._buildEdgeTapAreas(context),
          _buildHelpButton(),
            ],
          ),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _showHelp = true);
    });
  }

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

  Widget _buildMainPageView() {
    return PageView(
      scrollDirection: Axis.vertical,
      controller: _verticalController,
      onPageChanged: (index) {
        setState(() {
          _verticalPage = index;
        });
      },
      children: [
        // Main horizontal PageView
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
        // Presets Screen
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
    );
  }

  List<Widget> _buildEdgeTapAreas(BuildContext context) {
    final List<Widget> areas = [];

    // Settings page: right edge to roller
    if (_verticalPage == 0 && _horizontalPage == 0) {
      areas.add(_buildEdgeTapArea(
        context: context,
        alignment: Alignment.centerRight,
        onTap: () => _horizontalController.animateToPage(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
        quarterTurns: 1,
      ));
    }

    // Dice roller page: left to settings, right to history, bottom to presets
    if (_verticalPage == 0 && _horizontalPage == 1) {
      areas.addAll([
        _buildEdgeTapArea(
          context: context,
          alignment: Alignment.centerLeft,
          onTap: () => _horizontalController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
          quarterTurns: 3,
        ),
        _buildEdgeTapArea(
          context: context,
          alignment: Alignment.centerRight,
          onTap: () => _horizontalController.animateToPage(
            2,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
          quarterTurns: 1,
        ),
        _buildEdgeTapArea(
          context: context,
          alignment: Alignment.bottomCenter,
          onTap: () => _verticalController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
          quarterTurns: 0,
          isHorizontal: true,
        ),
      ]);
    }

    // History page: left to roller
    if (_verticalPage == 0 && _horizontalPage == 2) {
      areas.add(_buildEdgeTapArea(
        context: context,
        alignment: Alignment.centerLeft,
        onTap: () => _horizontalController.animateToPage(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
        quarterTurns: 3,
      ));
    }

    // Presets page: top to roller
    if (_verticalPage == 1) {
      areas.add(_buildEdgeTapArea(
        context: context,
        alignment: Alignment.topCenter,
        onTap: () => _verticalController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
        quarterTurns: 0,
        isHorizontal: true,
      ));
    }

    return areas;
  }

  Widget _buildEdgeTapArea({
    required BuildContext context,
    required Alignment alignment,
    required VoidCallback onTap,
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
              child: Container( 
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: RotatedBox(
                quarterTurns: quarterTurns,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIcon(alignment, _verticalPage, _horizontalPage),
                      color: Theme.of(context).primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      )
    );
  }

  IconData _getIcon(Alignment alignment, int horizontalPage, int verticalPage) {
    if (verticalPage == 0) {
      // On the horizontal pages
      switch (horizontalPage) {
        case 0: // Settings page
          if (alignment == Alignment.centerRight) return Icons.casino;
          break;
        case 1: // Dice Roller Page
          if (alignment == Alignment.centerLeft) return Icons.settings;
          if (alignment == Alignment.centerRight) return Icons.history;
          if (alignment == Alignment.topCenter) return Icons.save;
          if (alignment == Alignment.bottomCenter) return Icons.casino; 
          break;
        case 2: // History page
          if (alignment == Alignment.centerLeft) return Icons.casino;
          break;
      }
    } else {
      // On the presets page
      if (alignment == Alignment.bottomCenter) return Icons.casino;
    }
    return Icons.help_outlined;
  }
}
