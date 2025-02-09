import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String uid; // User ID from Firebase Authentication
  final String email;
  final String? name; // Optional name
  final List<String> favorites; // List of favorite audio IDs
  final Map<String, dynamic>? preferences; // User preferences (optional)

  const User({
    required this.uid,
    required this.email,
    this.name,
    required this.favorites,
    this.preferences,
  });

  factory User.fromFirestore(Map<String, dynamic> data, String uid) {
    return User(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'],
      favorites: List<String>.from(data['favorites'] ?? []),
      preferences: data['preferences'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'favorites': favorites,
      'preferences': preferences,
    };
  }

  @override
  List<Object?> get props => [uid, email, name, favorites, preferences];
}
