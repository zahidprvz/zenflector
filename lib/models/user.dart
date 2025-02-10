import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String uid;
  final String email;
  final String? name;
  final List<String> favorites;
  final Map<String, dynamic>? preferences;
  final String? photoURL; // Add photoURL

  const User({
    required this.uid,
    required this.email,
    this.name,
    required this.favorites,
    this.preferences,
    this.photoURL, // Add to constructor
  });

  factory User.fromFirestore(Map<String, dynamic> data, String uid) {
    return User(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'],
      favorites: List<String>.from(data['favorites'] ?? []),
      preferences: data['preferences'],
      photoURL: data['photoURL'], // Add fromFirestore
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'favorites': favorites,
      'preferences': preferences,
      'photoURL': photoURL, // Add toFirestore
    };
  }

  User copyWith({
    String? uid,
    String? email,
    String? name,
    List<String>? favorites,
    Map<String, dynamic>? preferences,
    String? photoURL,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      favorites: favorites ?? this.favorites,
      preferences: preferences ?? this.preferences,
      photoURL: photoURL ?? this.photoURL,
    );
  }

  @override
  List<Object?> get props =>
      [uid, email, name, favorites, preferences, photoURL];
}
