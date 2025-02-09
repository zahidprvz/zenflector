import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenflector/components/audio_card.dart'; // Import AudioCard
import 'package:zenflector/models/genre.dart';
import 'package:zenflector/providers/audio_player_provider.dart';
import 'package:zenflector/providers/auth_provider.dart'; // Import AuthProvider
import 'package:zenflector/providers/favorites_provider.dart';
import 'package:zenflector/providers/genre_provider.dart';
import 'package:zenflector/screens/audio_player_screen.dart';

class GenreScreen extends StatefulWidget {
  final Genre genre;

  const GenreScreen({super.key, required this.genre});

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  late Future<void> _audioFuture;

  @override
  void initState() {
    super.initState();
    _audioFuture = Provider.of<GenreProvider>(context, listen: false)
        .fetchAudioByGenre(widget.genre.id);

    // Fetch favorites, but only *after* the user is authenticated
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      Provider.of<FavoritesProvider>(context, listen: false)
          .fetchFavorites(authProvider.currentUser!.uid); // Pass UID
    }
  }

  @override
  Widget build(BuildContext context) {
    final genreProvider = Provider.of<GenreProvider>(context);
    final audioPlayerProvider = Provider.of<AudioPlayerProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context,
        listen: false); // Get AuthProvider for currentUser, Don't rebuild here.

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.genre.name),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _audioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (genreProvider.audioFiles.isEmpty) {
            return const Center(
              child: Text("No music available in this section currently."),
            );
          } else {
            return _buildResponsiveGrid(
                genreProvider, audioPlayerProvider, authProvider);
          }
        },
      ),
    );
  }

  Widget _buildResponsiveGrid(GenreProvider genreProvider,
      AudioPlayerProvider audioPlayerProvider, AuthProvider authProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        double childAspectRatio = constraints.maxWidth > 600 ? 0.9 : 0.75;

        return Consumer<FavoritesProvider>(
          // Use Consumer for Favorites
          builder: (context, favoritesProvider, child) {
            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: genreProvider.audioFiles.length,
              itemBuilder: (context, index) {
                final audio = genreProvider.audioFiles[index];
                return AudioCard(
                  audio: audio,
                  onTap: () {
                    audioPlayerProvider.playAudio(audio);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AudioPlayerScreen(),
                      ),
                    );
                  },
                  isFavorite: favoritesProvider.isFavorite(audio),
                  onFavoritePressed: () {
                    // Pass currentUser to toggleFavorite
                    favoritesProvider.toggleFavorite(
                        audio, authProvider.currentUser?.uid);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
