import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/src/source.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages dice rolling sound effects and related settings
class SoundProvider with ChangeNotifier {
  // Constants
  static const String _soundEnabledKey = 'soundEnabled';
  static const String _volumeKey = 'volume';
  static const double _defaultVolume = 0.7;
  
  // Sound assets
  final List<String> _rollSounds = [
    'dice_roll_E_minor__bpm_85.mp3',
    'dice_roll_Db_minor__bpm_85.mp3',
    'dice_roll_G_minor__bpm_85.mp3',
  ];

  // State variables
  bool _soundEnabled = true;
  double _volume = _defaultVolume;
  bool _initialized = false;
  final _random = Random();

  // Getters
  bool get soundEnabled => _soundEnabled;
  double get volume => _volume;
  bool get isInitialized => _initialized;

  /// Constructor initializes by loading saved preferences
  SoundProvider() {
    _loadPreferences();
  }

  /// Initialize the sound provider
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      _initialized = true;
      notifyListeners();
      debugPrint('Sound provider initialized');
    } catch (e) {
      debugPrint('Error initializing sound: $e');
      // Still mark as initialized to avoid blocking the app
      _initialized = true;
    }
  }

  /// Loads user preferences from local storage
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
      _volume = prefs.getDouble(_volumeKey) ?? _defaultVolume;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load sound preferences: $e');
      // Keep default values if loading fails
    }
  }

  /// Saves current settings to local storage
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundEnabledKey, _soundEnabled);
      await prefs.setDouble(_volumeKey, _volume);
    } catch (e) {
      debugPrint('Failed to save sound preferences: $e');
    }
  }

  /// Toggles sound on/off
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    _savePreferences();
    notifyListeners();
  }

  /// Updates volume level
  void setVolume(double value) {
    if (value < 0 || value > 1) {
      debugPrint('Invalid volume value: $value. Must be between 0 and 1.');
      return;
    }
    
    _volume = value;
    _savePreferences();
    notifyListeners();
  }

  /// Plays a random dice rolling sound
  Future<void> playRollSound() async {
    if (!_soundEnabled || !_initialized) return;
    
    try {
      final player = AudioPlayer();
      await player.setVolume(_volume);
      
      // Select random sound from available options
      final soundFile = _rollSounds[_random.nextInt(_rollSounds.length)];
      await player.play(AssetSource('sounds/$soundFile'));
      
      // Clean up resources when sound completes
      player.onPlayerComplete.listen((event) {
        player.dispose();
      });
      
      // Add timeout to ensure player gets disposed even if onComplete fails
      Future.delayed(const Duration(seconds: 10), () {
        player.dispose();
      });
    } catch (e) {
      debugPrint('Error playing dice roll sound: $e');
    }
  }
}