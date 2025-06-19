import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/sound_provider.dart';
import 'providers/history_provider.dart';
import 'providers/preset_provider.dart';
import 'providers/dice_set_provider.dart';
import 'themes/app_theme.dart';

/// The entry point of the application
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (optional)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize providers that require async setup
  final historyProvider = HistoryProvider();
  final soundProvider = SoundProvider();
  
  try {
    // Initialize sound provider with error handling
    await soundProvider.initialize();
  } catch (e) {
    debugPrint('Error initializing sound provider: $e');
    // Continue app initialization even if sound fails
  }

  // Launch the application with all required providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => soundProvider),
        ChangeNotifierProvider(create: (_) => historyProvider),
        ChangeNotifierProvider(create: (_) => PresetProvider()),
        ChangeNotifierProvider(create: (_) => DiceSetProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// Main application widget that configures the theme and initial route
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Get the current color preset from the theme provider
        final preset = AppTheme.colorPresets[themeProvider.presetIndex];
        
        return MaterialApp(
          title: 'Dice Roller',
          // Configure light theme using selected preset
          theme: AppTheme.createTheme(preset, isDark: false),
          // Configure dark theme using selected preset
          darkTheme: AppTheme.createTheme(preset, isDark: true),
          // Use the theme mode from provider (system, light, or dark)
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const MainScreen(),
          },
          // Add error handling for widget errors
          builder: (context, widget) {
            // Add error handling widget wrapper if needed
            ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
              return Material(
                child: Center(
                  child: Text(
                    'Something went wrong!',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              );
            };
            return widget!;
          },
        );
      },
    );
  }
}