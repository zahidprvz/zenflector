import 'package:flutter/material.dart';
import 'package:zenflector/api/firebase_service.dart';
import 'package:zenflector/models/audio.dart';
import 'package:zenflector/models/genre.dart';

class GenreProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Genre> _genres = [];
  List<Audio> _audioFiles = [];
  bool _isLoading = false; // ✅ Added loading state

  List<Genre> get genres => _genres;
  List<Audio> get audioFiles => _audioFiles;
  bool get isLoading => _isLoading; // ✅ Getter for loading state

  Future<void> fetchGenres() async {
    _isLoading = true; // ✅ Start loading
    notifyListeners();

    try {
      _genres = await _firebaseService.getGenres();
    } catch (e) {
      print("Error fetching genres: $e");
      rethrow;
    } finally {
      _isLoading = false; // ✅ Stop loading
      notifyListeners();
    }
  }

  Future<void> fetchAudioByGenre(String genreId) async {
    print("fetchAudioByGenre called with genreId: $genreId");
    _isLoading = true; // ✅ Start loading
    notifyListeners();

    try {
      _audioFiles = await _firebaseService.getAudioByGenre(genreId);
      print("fetchAudioByGenre: _audioFiles.length = ${_audioFiles.length}");
    } catch (e) {
      print("Error fetching audio by genre: $e");
      _audioFiles = []; // Clear data on error
      rethrow;
    } finally {
      _isLoading = false; // ✅ Stop loading
      notifyListeners();
    }
  }

  Future<void> fetchAllAudio() async {
    _isLoading = true; // ✅ Start loading
    notifyListeners();

    try {
      _audioFiles = await _firebaseService.getAllAudio();
    } catch (e) {
      print("Error fetching all audio: $e");
      _audioFiles = [];
      rethrow;
    } finally {
      _isLoading = false; // ✅ Stop loading
      notifyListeners();
    }
  }
}
