import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/sound_provider.dart';
import 'providers/history_provider.dart';
import 'providers/preset_provider.dart';
import 'providers/dice_set_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create Providers
  final historyProvider = HistoryProvider();
  final soundProvider = SoundProvider();

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            ),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const MainScreen(),
          }
        );
      },
    );
  }
}