import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:zenflector/models/audio.dart';
import 'package:zenflector/models/genre.dart';
import 'package:zenflector/models/playlist.dart';
import 'package:zenflector/models/user.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseStorage _storage =
      FirebaseStorage.instance; // Add Storage instance
  final _uuid = Uuid();

  // Fetch genres
  Future<List<Genre>> getGenres() async {
    QuerySnapshot snapshot = await _firestore.collection('genres').get();
    return snapshot.docs
        .map((doc) =>
            Genre.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Add a New Genre
  Future<void> addGenre(String name, String? imageUrl) async {
    Genre newGenre = Genre(id: _uuid.v4(), name: name, imageUrl: imageUrl);
    await _firestore
        .collection('genres')
        .doc(newGenre.id)
        .set(newGenre.toFirestore());
  }

  // Upload Genre Image
  Future<String?> uploadGenreImage(Uint8List fileBytes, String fileName) async {
    try {
      final ref = _storage
          .ref('audio/genre_images/${_uuid.v4()}_$fileName'); // Unique path
      final uploadTask = ref.putData(fileBytes); // Use putData for Uint8List
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null; // Or rethrow, depending on how you want to handle errors
    }
  }

  // Fetch audio by genre
  Future<List<Audio>> getAudioByGenre(String genreId) async {
    print("getAudioByGenre called with genreId: $genreId"); // Debug print

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('audio')
          .where('genreId', isEqualTo: genreId)
          .get();

      print(
          "getAudioByGenre: snapshot.docs.length = ${snapshot.docs.length}"); // Debug print

      final List<Audio> audioList = [];
      for (final doc in snapshot.docs) {
        try {
          final audio =
              Audio.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          audioList.add(audio);
        } catch (e) {
          print(
              "Error creating Audio object from Firestore: $e"); // PRINT Error if any
        }
      }
      return audioList;
    } catch (e) {
      print(
          "Error in getAudioByGenre: $e"); // Catch and log any Firestore errors
      rethrow; // Re-throw so the provider can handle it
    }
  }

  // Fetch All audios
  Future<List<Audio>> getAllAudio() async {
    QuerySnapshot snapshot = await _firestore.collection('audio').get();
    final List<Audio> audioList = [];
    for (final doc in snapshot.docs) {
      try {
        final audio =
            Audio.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        audioList.add(audio);
      } catch (e) {
        print(
            "Error creating Audio object from Firestore: $e"); // PRINT Error if any
      }
    }
    return audioList;
  }

  // Upload Audio File and Metadata (UPDATED)
  Future<void> uploadAudio(
    String title,
    String artist,
    String genreId,
    int duration,
    Uint8List fileBytes,
    String fileName,
    String? imageUrl,
    String? description, // Add description parameter
  ) async {
    try {
      // 1. Upload the audio file to Firebase Storage
      final audioRef = _storage.ref('audio/${_uuid.v4()}_$fileName');
      final uploadTask = audioRef.putData(fileBytes);
      final snapshot = await uploadTask.whenComplete(() {});
      final fileUrl = await snapshot.ref.getDownloadURL();

      // 2. Create the Audio object
      Audio newAudio = Audio(
        id: _uuid.v4(),
        title: title,
        artist: artist,
        fileUrl: fileUrl,
        genreId: genreId,
        duration: duration,
        imageUrl: imageUrl,
        isPremium: false,
        description: description, // Set the description
      );

      // 3. Add the Audio document to Firestore
      await _firestore
          .collection('audio')
          .doc(newAudio.id)
          .set(newAudio.toFirestore());
    } catch (e) {
      print("Error uploading audio: $e");
      rethrow;
    }
  }

  Future<String?> uploadAudioFile(
      Uint8List fileBytes, String fileName, String genreId) async {
    try {
      final audioRef = _storage.ref('audio/$genreId/${_uuid.v4()}_$fileName');
      final uploadTask = audioRef.putData(fileBytes);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading audio file: $e");
      return null;
    }
  }

  // Get user data (Modified to include photoURL)
  Future<User?> getUser(String uid) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(uid).get();
    if (snapshot.exists) {
      return User.fromFirestore(
          snapshot.data() as Map<String, dynamic>, snapshot.id);
    } else {
      return null;
    }
  }

  // Create new user (Modified to include photoURL)
  Future<void> createUser(String uid, String email, String? name,
      {String? photoURL}) async {
    // Add optional photoURL
    User newUser = User(
      uid: uid,
      email: email,
      name: name,
      favorites: [],
      photoURL: photoURL, // Add to the User object
    );
    await _firestore.collection('users').doc(uid).set(newUser.toFirestore());
  }

  // Update user data (New method!)
  Future<void> updateUser(User user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(user.toFirestore());
      print("Firestore: User data updated successfully.");
    } catch (e) {
      print("Error updating user: $e");
      rethrow; // Re-throw the error so calling functions can handle it
    }
  }

  // Upload User Profile Image (New method!)
  Future<String?> uploadProfileImage(
      String userId, Uint8List fileBytes, String fileName) async {
    try {
      final ref = _storage
          .ref('user_profiles/$userId/${_uuid.v4()}_$fileName'); // Unique path
      final uploadTask = ref.putData(fileBytes); // Use putData for Uint8List
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading profile image: $e");
      return null; // Or rethrow, depending on how you want to handle errors
    }
  }

  // Get favorite audio IDs for a user
  Future<List<String>> getFavoriteAudioIds(String userId) async {
    print("getFavoriteAudioIds called: $userId"); //Added

    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      User user = User.fromFirestore(
          userDoc.data() as Map<String, dynamic>, userDoc.id);
      print("User data from firestore is: ${user.favorites}"); //Added
      return user.favorites;
    } else {
      print("getFavoriteAudioIds called: returning empty");
      return []; // Return empty list if user not found
    }
  }

  // Get favorite Audio objects based on a list of IDs
  Future<List<Audio>> getFavoriteAudios(List<String> audioIds) async {
    print("getFavoriteAudios called: $audioIds");
    if (audioIds.isEmpty) {
      return []; // Return an empty list if there are no favorite IDs
    }

    List<Audio> favoriteAudios = [];
    for (int i = 0; i < audioIds.length; i += 10) {
      final end = (i + 10 < audioIds.length) ? i + 10 : audioIds.length;
      final batchIds = audioIds.sublist(i, end);

      QuerySnapshot snapshot = await _firestore
          .collection('audio')
          .where(FieldPath.documentId,
              whereIn: batchIds) // Efficiently fetch by ID
          .get();
      print("getFavoriteAudioIds snapshot length is: ${snapshot.docs.length}");

      favoriteAudios.addAll(snapshot.docs
          .map((doc) =>
              Audio.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList());
    }

    return favoriteAudios;
  }

  // Update favorites for a user
  Future<void> updateFavorites(String userId, List<String> audioIds) async {
    print(
        "updateFavorites called for userId: $userId, audioIds: $audioIds"); // Debug print
    try {
      // Add a try-catch block
      await _firestore.collection('users').doc(userId).update({
        'favorites': audioIds,
      });
      print("updateFavorites: Firestore update successful"); // Debug print
    } catch (e) {
      print("Error updating favorites in Firestore: $e"); // Debug print
      rethrow; // Re-throw the error
    }
  }

  //Playlist related functions.
  Future<List<Playlist>> getPlaylistsForUser(String userId) async {
    print(
        "FirebaseService: getPlaylistsForUser called with userId: $userId"); // PRINT 5
    QuerySnapshot snapshot = await _firestore
        .collection('playlists')
        .where('userId', isEqualTo: userId)
        .get();
    print(
        "FirebaseService: getPlaylistsForUser snapshot.docs.length = ${snapshot.docs.length}"); // PRINT 6
    return snapshot.docs
        .map((doc) =>
            Playlist.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> createPlaylist(String userId, String name) async {
    print(
        "FirebaseService: createPlaylist called with userId: $userId, name: $name"); // PRINT 7
    Playlist newPlaylist = Playlist(
      id: '', // Firestore will auto-generate the ID
      name: name,
      userId: userId,
      audioIds: [],
    );

    try {
      // Add the playlist and get the document reference to update the ID
      DocumentReference docRef = await _firestore
          .collection('playlists')
          .add(newPlaylist.toFirestore());
      print(
          "FirebaseService: createPlaylist - Playlist added with ID: ${docRef.id}"); // PRINT 8

      // Update the playlist object with the auto-generated ID
      newPlaylist = Playlist(
          id: docRef.id,
          name: newPlaylist.name,
          userId: newPlaylist.userId,
          audioIds: newPlaylist.audioIds);
      // Update the document to store the correct ID
      await docRef.set(newPlaylist.toFirestore()); // Set data.
    } catch (e) {
      print("Error creating playlist in Firestore: $e");
      rethrow;
    }
  }

  Future<void> addAudioToPlaylist(String playlistId, String audioId) async {
    DocumentReference playlistRef =
        _firestore.collection('playlists').doc(playlistId);

    // Use FieldValue.arrayUnion to add the audio ID to the array
    await playlistRef.update({
      'audioIds': FieldValue.arrayUnion([audioId]),
    });
  }

  Future<void> removeAudioFromPlaylist(
      String playlistId, String audioId) async {
    try {
      DocumentReference playlistRef =
          _firestore.collection('playlists').doc(playlistId);

      await playlistRef.update({
        'audioIds': FieldValue.arrayRemove([audioId]), // Remove from the array
      });
      print("Removed the audio from the playlsit");
    } catch (e) {
      print("Error removing audio from playlist in Firestore: $e");
      rethrow;
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _firestore.collection('playlists').doc(playlistId).delete();
  }
}
