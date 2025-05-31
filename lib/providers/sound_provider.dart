
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';

class SoundProvider with ChangeNotifier {
  bool _soundEnabled = true;
  double _volume = 0.7;
  final AudioPlayer _audioPlayer = AudioPlayer();

  SoundProvider() {
    _loadPreferences();
  }

  bool get soundEnabled => _soundEnabled;
  double get volume => _volume;

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    _savePreferences();
    notifyListeners();
  }

  void setVolume(double value) {
    _volume = value;
    _audioPlayer.setVolume(value);
    _savePreferences();
    notifyListeners();
  }

  Future<void> playRollSound() async {
    if (!_soundEnabled) return;

    try {
      await _audioPlayer.setAsset('assets/sounds/roll_sound.mp3');
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _volume = prefs.getDouble('volume') ?? 0.7;
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('soundEnabled', _soundEnabled);
    prefs.setDouble('soundVolume', _volume);
  }

  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}