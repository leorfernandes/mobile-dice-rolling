import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/sound_provider.dart';

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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'App Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Appearance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return SwitchListTile(
                          title: const Text('Dark Mode'),
                          subtitle: const Text('Enable dark theme'),
                          value: themeProvider.isDarkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

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
                        const url = 'https://github.com/leorfernandes/dice-rolling-app';
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