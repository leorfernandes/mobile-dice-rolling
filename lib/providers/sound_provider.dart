import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class SoundProvider with ChangeNotifier {
  final _player = AudioPlayer();
  bool _isSoundEnabled = true;
  bool _isInitialized = false; // Debugging

  bool get isSoundEnabled => _isSoundEnabled;

  Future<void> initializeSound() async {
    if (!_isInitialized) {
      try {
        await _player.setAsset('sounds/dice_roll.mp3');
        _isInitialized = true; // Debugging
      } catch (e) {
        debugPrint('Error initalizing sound: $e'); // Debugging
        _isInitialized = false;
        }
    }
  }

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    notifyListeners();
  }

  Future<void> playRollSound() async {
    if (!_isSoundEnabled) return;

    try {
      if (!_isInitialized) {
        await initializeSound();
      }
      await _player.stop(); // Stop any currently playing sound
      await _player.seek(Duration.zero); // Seek to the beginning
      await _player.play(); // Play the sound
    } catch (e) {
      debugPrint('Error playing sound: $e'); // Debugging
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}