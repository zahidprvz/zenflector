// lib/models/playlist.dart
import 'package:equatable/equatable.dart';

class Playlist extends Equatable {
  final String id;
  final String name;
  final String userId;
  final List<String> audioIds; // List of audio IDs
  final String? imageUrl;

  const Playlist({
    required this.id,
    required this.name,
    required this.userId,
    required this.audioIds,
    this.imageUrl,
  });

  factory Playlist.fromFirestore(Map<String, dynamic> data, String id) {
    return Playlist(
      id: id,
      name: data['name'] ?? 'Unnamed Playlist',
      userId: data['userId'] ?? '',
      audioIds: List<String>.from(
          data['audioIds'] ?? []), // Handle null and convert to List<String>
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'userId': userId,
      'audioIds': audioIds,
      'imageUrl': imageUrl,
    };
  }

  Playlist copyWith({
    // Add copyWith method
    String? id,
    String? name,
    String? userId,
    List<String>? audioIds,
    String? imageUrl,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      audioIds: audioIds ?? this.audioIds,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, userId, audioIds, imageUrl];
}
