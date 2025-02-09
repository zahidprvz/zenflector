import 'package:flutter/material.dart';
import 'package:zenflector/api/firebase_service.dart';
import 'package:zenflector/models/audio.dart';
// REMOVE AuthProvider import.  We don't need it here anymore.
//import 'package:zenflector/providers/auth_provider.dart'; //REMOVE THIS
import 'package:provider/provider.dart';

class FavoritesProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Audio>? _favoriteAudios =
      []; // Change to List<Audio>? and initialize to null.
  List<String> _favoriteAudioIds = [];

  List<Audio>? get favoriteAudios => _favoriteAudios; // Change to List<Audio>?

  Future<void> fetchFavorites(String? userId) async {
    print("fetchFavorites called with userId: $userId");
    if (userId == null) {
      print("fetchFavorites: userId is null, clearing favorites.");
      _favoriteAudios = null; // Set to null, not empty list, on logout/no user.
      _favoriteAudioIds = [];
      notifyListeners();
      return;
    }

    try {
      _favoriteAudioIds = await _firebaseService.getFavoriteAudioIds(userId);
      print("fetchFavorites: _favoriteAudioIds = $_favoriteAudioIds");

      _favoriteAudios =
          await _firebaseService.getFavoriteAudios(_favoriteAudioIds);
      print(
          "fetchFavorites: _favoriteAudios.length = ${_favoriteAudios?.length}"); // Use ?.length
      notifyListeners(); // Correct placement AFTER data is fetched
    } catch (e) {
      print("Error fetching favorites: $e");
      _favoriteAudios = null; // Set to null on error, to show error state.
      notifyListeners(); // Correct placement
    }
  }

  bool isFavorite(Audio audio) {
    print("isFavorite called for audio.id: ${audio.id}");
    print("Favorite Ids are :  $_favoriteAudioIds");
    return _favoriteAudioIds.contains(audio.id);
  }

  Future<void> toggleFavorite(Audio audio, String? userId) async {
    print("toggleFavorite called for audio: ${audio.title}, userId: $userId");

    if (userId == null) {
      print("Error: currentUser is null in toggleFavorite");
      return;
    }

    try {
      if (isFavorite(audio)) {
        print("Removing from favorites: ${audio.title}");
        _favoriteAudioIds.remove(audio.id);
      } else {
        print("Adding to favorites: ${audio.title}");
        _favoriteAudioIds.add(audio.id);
      }

      await _firebaseService.updateFavorites(userId, _favoriteAudioIds);
      print("Favorites updated in Firestore");
      await fetchFavorites(
          userId); // Re-fetch - keep this, but use the passed userId
    } catch (e) {
      print("Error toggling favorite: $e");
    }
  }
}
