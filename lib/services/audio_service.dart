import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  late AudioPlayer _audioPlayer;
  bool _isInitialized = false;
  bool _isMusicEnabled = true;

  // Singleton pattern
  factory AudioService() {
    return _instance;
  }

  AudioService._internal() {
    _audioPlayer = AudioPlayer();
  }

  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        // Set volume to make sure it's audible
        await _audioPlayer.setVolume(1.0);

        // Set to loop mode
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);

        // Load the audio source
        await _audioPlayer.setSource(
          AssetSource('music/Isaac DaBom - Crosswalk Bounce.mp3'),
        );

        _isInitialized = true;
        if (kDebugMode) {
          print('Audio initialized successfully');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error initializing audio: $e');
        }
      }
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_isInitialized) await initialize();
    if (_isMusicEnabled) {
      try {
        // Use play instead of resume for initial playback
        await _audioPlayer.play(
          AssetSource('music/Isaac DaBom - Crosswalk Bounce.mp3'),
        );
        if (kDebugMode) {
          print('Playing background music');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error playing audio: $e');
        }
      }
    }
  }

  Future<void> pauseBackgroundMusic() async {
    if (_isInitialized) {
      await _audioPlayer.pause();
      if (kDebugMode) {
        print('Paused background music');
      }
    }
  }

  Future<void> toggleBackgroundMusic() async {
    _isMusicEnabled = !_isMusicEnabled;
    if (_isMusicEnabled) {
      await playBackgroundMusic();
    } else {
      await pauseBackgroundMusic();
    }
  }

  bool get isMusicEnabled => _isMusicEnabled;

  void dispose() {
    _audioPlayer.dispose();
  }
}
