import 'package:flutter/material.dart';
import 'package:zenflector/api/firebase_service.dart';
import 'package:zenflector/models/playlist.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:zenflector/providers/auth_provider.dart'; // Import AuthProvider

class PlaylistProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Playlist> _playlists = [];

  List<Playlist> get playlists => _playlists;

  Future<void> fetchPlaylists(String userId) async {
    // Add userId parameter
    if (userId == null) {
      // Added null check.
      _playlists = [];
      notifyListeners();
      return;
    }
    try {
      _playlists =
          await _firebaseService.getPlaylistsForUser(userId); // Pass userId
      notifyListeners();
    } catch (e) {
      print("Error $e");
      rethrow;
    }
  }

  Future<void> createPlaylist(String userId, String name) async {
    if (userId == null) {
      // Added null check
      print("Error: userId is null in createPlaylist"); // Debug print
      return; // Or throw an exception if you prefer
    }
    try {
      await _firebaseService.createPlaylist(userId, name); // Pass userId
      await fetchPlaylists(
          userId); // Pass userId. Refetch playlists , this is important
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }

  Future<void> addAudioToPlaylist(
      String playlistId, String audioId, String userId) async {
    try {
      await _firebaseService.addAudioToPlaylist(playlistId, audioId);
      await fetchPlaylists(userId);
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }

  Future<void> removeAudioFromPlaylist(
      String playlistId, String audioId, String userId) async {
    // Add userId
    try {
      await _firebaseService.removeAudioFromPlaylist(playlistId, audioId);
      await fetchPlaylists(
          userId); // Pass userId, and Refetch.  THIS IS THE KEY FIX.
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    try {
      await _firebaseService.deletePlaylist(playlistId);
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }
}
