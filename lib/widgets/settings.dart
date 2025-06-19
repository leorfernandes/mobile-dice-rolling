import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../providers/sound_provider.dart';
import '../themes/app_theme.dart';

/// A screen that displays and allows modification of application settings.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Launches a URL in the external browser.
  /// 
  /// Takes a URL string and attempts to open it in the device's default browser.
  /// Shows a snackbar if the URL cannot be launched.
  Future<void> _launchUrl(String urlString, BuildContext context) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        _showErrorSnackBar(context, 'Could not launch $urlString');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Invalid URL or launch failed: $e');
    }
  }

  /// Shows an error message in a snackbar.
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Builds a section header with an icon and title.
  Widget _buildSectionHeader(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Icon(Icons.settings, size: 40),
            ),
            // Theme colors section
            _buildThemeColorsSection(context),
            const SizedBox(height: 16),
            // Dark mode section
            _buildDarkModeSection(context),
            const SizedBox(height: 16),
            // Sound settings section
            _buildSoundSection(context),
            const SizedBox(height: 16),
            // About app section
            _buildAboutSection(context),
          ],
        ),
      ),
    );
  }

  /// Builds the theme colors selection section.
  Widget _buildThemeColorsSection(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(context, Icons.color_lens, 'Theme Colors'),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Select color theme:'),
                ),
                Center(
                  child: DropdownButton<int>(
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the dark mode toggle section.
  Widget _buildDarkModeSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, Icons.dark_mode, 'Dark Mode'),
            const Divider(),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return SwitchListTile(
                  title: const Text('Enable Dark Mode'),
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  activeColor: Colors.white,
                  inactiveThumbColor: Theme.of(context).colorScheme.primary,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the sound settings section.
  Widget _buildSoundSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, Icons.volume_up, 'Sound'),
            const Divider(),
            Consumer<SoundProvider>(
              builder: (context, soundProvider, _) {
                return Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Sound'),
                      subtitle: const Text('Play sounds when rolling dice'),
                      value: soundProvider.soundEnabled,
                      onChanged: (_) => soundProvider.toggleSound(),
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
                          onChanged: soundProvider.setVolume,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the about app section.
  Widget _buildAboutSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, Icons.info_outline, 'About'),
            const Divider(),
            const ListTile(
              title: Text('Dice Roller App'),
              subtitle: Text('Version 1.0.0'),
            ),
            ListTile(
              title: const Text('View Source Code'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchUrl(
                'https://github.com/leorfernandes/dice-rolling-app', 
                context
              ),
            ),
          ],
        ),
      ),
    );
  }
}
