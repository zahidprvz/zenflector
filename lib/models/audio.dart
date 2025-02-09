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

  const Audio({
    required this.id,
    required this.title,
    required this.artist,
    required this.fileUrl,
    required this.genreId,
    required this.duration,
    this.imageUrl,
    this.isPremium,
  });

  factory Audio.fromFirestore(Map<String, dynamic> data, String id) {
    // Handle isPremium correctly, allowing for String, bool, or null
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
      title: data['title'] ?? 'Unknown Title', // Fallback for null title
      artist: data['artist'] ?? 'Unknown Artist', // Fallback for null artist
      fileUrl: data['fileUrl'] ?? '', // Fallback for null fileUrl
      genreId: data['genreId'] ?? '', // Fallback for null genreId
      duration: (data['duration'] ?? 0).toInt(), // Fallback for null duration
      imageUrl: data['imageUrl'], // Nullable field
      isPremium: isPremiumValue, // Use the converted value
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
      'isPremium': isPremium, // Store as boolean
    };
  }

  @override
  List<Object?> get props =>
      [id, title, artist, fileUrl, genreId, duration, imageUrl, isPremium];
}
