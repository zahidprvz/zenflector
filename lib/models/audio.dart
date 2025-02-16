import 'package:equatable/equatable.dart';

class Audio extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String fileUrl;
  final String genreId;
  final int duration;
  final String? imageUrl;
  final bool? isPremium;
  final String? description; // New description field

  const Audio({
    required this.id,
    required this.title,
    required this.artist,
    required this.fileUrl,
    required this.genreId,
    required this.duration,
    this.imageUrl,
    this.isPremium,
    this.description, // Initialize description
  });

  factory Audio.fromFirestore(Map<String, dynamic> data, String id) {
    dynamic premium = data['isPremium'];
    bool? isPremiumValue;

    if (premium is bool) {
      isPremiumValue = premium;
    } else if (premium is String) {
      isPremiumValue = premium.toLowerCase() == 'true';
    } else {
      isPremiumValue = false; // Default to false if null or unexpected type
    }

    return Audio(
      id: id,
      title: data['title'] ?? 'Unknown Title',
      artist: data['artist'] ?? 'Unknown Artist',
      fileUrl: data['fileUrl'] ?? '',
      genreId: data['genreId'] ?? '',
      duration: (data['duration'] ?? 0).toInt(),
      imageUrl: data['imageUrl'],
      isPremium: isPremiumValue,
      description: data['description'], // Get description from Firestore
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'artist': artist,
      'fileUrl': fileUrl,
      'genreId': genreId,
      'duration': duration,
      'imageUrl': imageUrl,
      'isPremium': isPremium,
      'description': description, // Add description to Firestore data
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        fileUrl,
        genreId,
        duration,
        imageUrl,
        isPremium,
        description, // Include description in props
      ];
}
