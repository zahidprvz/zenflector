import 'package:equatable/equatable.dart';

class Genre extends Equatable {
  final String id;
  final String name;
  final String? imageUrl; // Optional image URL

  const Genre({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory Genre.fromFirestore(Map<String, dynamic> data, String id) {
    return Genre(
      id: id,
      name: data['name'] ?? 'Unknown Genre',
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [id, name, imageUrl];
}
