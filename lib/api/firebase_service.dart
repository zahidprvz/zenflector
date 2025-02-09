import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth; // Import FirebaseAuth with prefix
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zenflector/models/audio.dart';
import 'package:zenflector/models/genre.dart';
import 'package:zenflector/models/playlist.dart';
import 'package:zenflector/models/user.dart';

import '../models/user.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth auth =
      firebase_auth.FirebaseAuth.instance; // Add FirebaseAuth instance

  // Fetch genres
  Future<List<Genre>> getGenres() async {
    QuerySnapshot snapshot = await _firestore.collection('genres').get();
    return snapshot.docs
        .map((doc) =>
            Genre.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
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
          print("Error creating Audio object from Firestore: $e");
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

  // Get user data
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

  // Create new user
  Future<void> createUser(String uid, String email, String? name) async {
    User newUser = User(
      uid: uid,
      email: email,
      name: name,
      favorites: [],
    );
    await _firestore.collection('users').doc(uid).set(newUser.toFirestore());
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

// Corrected _DummyContext implementation
class _DummyContext extends BuildContext {
  @override
  bool get debugDoingBuild => false;

  @override
  InheritedWidget dependOnInheritedElement(InheritedElement ancestor,
      {Object? aspect}) {
    throw UnimplementedError();
  }

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>(
      {Object? aspect}) {
    return null;
  }

  @override
  DiagnosticsNode describeElement(String name,
      {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  List<DiagnosticsNode> describeMissingAncestor(
      {required Type expectedAncestorType}) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeOwnershipChain(String name) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeWidget(String name,
      {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  T? findAncestorRenderObjectOfType<T extends RenderObject>() {
    return null;
  }

  @override
  T? findAncestorStateOfType<T extends State>() {
    return null;
  }

  @override
  T? findAncestorWidgetOfExactType<T extends Widget>() {
    return null;
  }

  @override
  RenderObject? findRenderObject() {
    return null;
  }

  @override
  T? findRootAncestorStateOfType<T extends State>() {
    return null;
  }

  @override
  InheritedElement?
      getElementForInheritedWidgetOfExactType<T extends InheritedWidget>() {
    return null;
  }

  @override
  BuildOwner? get owner => null;

  @override
  T? getInheritedWidgetOfExactType<T extends InheritedWidget>() {
    return null;
  }

  @override
  bool get mounted => false;

  @override
  void visitAncestorElements(bool Function(Element element) visitor) {}

  @override
  void visitChildElements(ElementVisitor visitor) {}

  @override
  Widget get widget => throw UnimplementedError();

  @override
  void dispatchNotification(Notification notification) {}

  @override
  Size? get size => null;
}
