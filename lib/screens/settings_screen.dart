import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/sound_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer2<ThemeProvider, SoundProvider>(
        builder: (context, themeProvider, soundProvider, child){
          return ListView(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.color_lens),
                title: const Text('Theme'),
                value: themeProvider.isDarkMode,
                onChanged: (_) {
                  themeProvider.toggleTheme();
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.volume_up),
                title: Text('Sound Effects'),
                value: soundProvider.isSoundEnabled,
                onChanged: (_) => soundProvider.toggleSound(),
              ),
            ],
          );
        },
      ),
    );
  }
}