import 'package:flutter/material.dart';
import 'package:zenflector/models/audio.dart';

class AudioPlayerProvider with ChangeNotifier {
  Audio? _currentAudio;
  bool _isPlaying = false; // Add this back

  Audio? get currentAudio => _currentAudio;
  bool get isPlaying => _isPlaying; // Add this back

  // We keep this method to update the _currentAudio
  void playAudio(Audio audio) {
    _currentAudio = audio;
    _isPlaying = true; // Set to true when playAudio is called
    notifyListeners();
  }

  // We also keep this to clear the selection
  void stopAudio() {
    _currentAudio = null;
    _isPlaying = false; // Set to false when stopped.
    notifyListeners();
  }
}
