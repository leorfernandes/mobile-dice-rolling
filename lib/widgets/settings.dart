import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/sound_provider.dart';
import '../themes/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build (BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
            ),
            // Theme Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.dark_mode, color: Theme.of(context).colorScheme.primary),
                    const Divider(),
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        final isDark = themeProvider.isDarkMode;
                        final switchWidget = SwitchListTile(
                          title: const Text('Dark Mode'),
                          value: themeProvider.isDarkMode,
                          onChanged: (_) => themeProvider.toggleTheme(),
                          activeColor: Colors.white,
                          inactiveThumbColor: Theme.of(context).colorScheme.primary,
                        );

                        return switchWidget;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Color Preset Section
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.color_lens, color: Theme.of(context).colorScheme.primary),
                        const Divider(),
                        DropdownButton<int>(
                          value: themeProvider.presetIndex,
                          items: List.generate(
                            AppTheme.colorPresets.length,
                            (index) => DropdownMenuItem(
                              value: index,
                              child: Text(AppTheme.colorPresets[index].name),
                            ),
                          ),
                          onChanged: (index) {
                            if (index != null) {
                              themeProvider.setPreset(index);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Sound Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sound',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    Consumer<SoundProvider>(
                      builder: (context, soundProvider, child) {
                        return Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Enable Sound'),
                              subtitle: const Text('Play sounds when rolling dice'),
                              value: soundProvider.soundEnabled,
                              onChanged: (value) {
                                soundProvider.toggleSound();
                              },
                            ),
                            if (soundProvider.soundEnabled)
                              ListTile(
                                title: const Text('Volume'),
                                subtitle: Slider(
                                  value: soundProvider.volume,
                                  min: 0.0,
                                  max: 1.0,
                                  divisions: 10,
                                  label: '${(soundProvider.volume * 100).round()}%',
                                  onChanged: (value) {
                                    soundProvider.setVolume(value);
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // About Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const ListTile(
                      title: Text('Dice Roller App'),
                      subtitle: Text('Version 1.0.0'),
                    ),
                    ListTile(
                      title: const Text('View Source Code'),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () {
                        // You can use url_launcher to open the URL
                        // launchUrl(Uri.parse('https://github.com/leorfernandes/dice-rolling-app'));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}