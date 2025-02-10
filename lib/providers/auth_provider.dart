import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:zenflector/api/firebase_service.dart';
import 'package:zenflector/models/user.dart';

class AuthProvider with ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool _isInitialized = false; // Flag to track initialization
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    // UseauthStateChanges to listen for auth state.
    _auth.authStateChanges().listen((firebase_auth.User? firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
      } else {
        _currentUser = await _firebaseService.getUser(firebaseUser.uid);
        if (_currentUser == null) {
          _currentUser = User(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName,
            favorites: [],
          );
          await _firebaseService.createUser(firebaseUser.uid,
              firebaseUser.email ?? '', firebaseUser.displayName);
        }
      }
      _isInitialized = true; // Set flag after first load
      notifyListeners();
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Data loading now happens in the authStateChanges listener
    } catch (e) {
      print("Error during sign in: $e");
      rethrow; // Re-throw the exception so the UI can handle it
    }
  }

  // Modified signUpWithEmailAndPassword
  Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
    Uint8List? imageBytes, // Add imageBytes parameter
    String? imageName, //Add image name
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        String? photoURL;

        // Upload image if provided
        if (imageBytes != null) {
          photoURL = await _firebaseService.uploadProfileImage(
              user.uid, imageBytes, imageName!); // Upload and get URL
        }

        // Create user document in Firestore, including the photoURL
        await _firebaseService.createUser(
          user.uid,
          email,
          name,
          photoURL: photoURL, // Pass photoURL to createUser
        );

        // Update local user object (if needed, for immediate display)
        _currentUser = _currentUser?.copyWith(name: name, photoURL: photoURL) ??
            User(
              uid: user.uid,
              email: email,
              name: name,
              favorites: [],
              photoURL: photoURL, // Include in the local User object
            );
        notifyListeners(); // Notify after updating local user data
      }
    } catch (e) {
      print("Error during sign up: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
