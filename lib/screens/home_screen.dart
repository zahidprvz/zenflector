import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenflector/components/audio_card.dart';
import 'package:zenflector/components/section_header.dart';
import 'package:zenflector/providers/audio_player_provider.dart';
import 'package:zenflector/providers/auth_provider.dart';
import 'package:zenflector/providers/favorites_provider.dart';
import 'package:zenflector/providers/genre_provider.dart';
import 'package:zenflector/screens/audio_player_screen.dart';
import 'package:zenflector/screens/genre_screen.dart';
import 'package:zenflector/utils/constants.dart';
import 'package:zenflector/components/genre_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _genresFuture;
  late Future<void> _audioFuture;

  @override
  void initState() {
    super.initState();
    final genreProvider = Provider.of<GenreProvider>(context, listen: false);
    _genresFuture =
        genreProvider.fetchGenres(); // Use Future for loading and error states
    _audioFuture =
        genreProvider.fetchAllAudio(); // Use Future for loading/error
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      // Only fetch if logged in
      Provider.of<FavoritesProvider>(context, listen: false)
          .fetchFavorites(authProvider.currentUser!.uid); // Pass UID
    }
  }

  @override
  Widget build(BuildContext context) {
    final genreProvider = Provider.of<GenreProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final audioPlayerProvider = Provider.of<AudioPlayerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZenFlector'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        // Added pull-to-refresh
        onRefresh: () async {
          // Re-fetch data.  Await to ensure UI updates.
          await Provider.of<GenreProvider>(context, listen: false)
              .fetchGenres();
          await Provider.of<GenreProvider>(context, listen: false)
              .fetchAllAudio();
          if (authProvider.currentUser != null) {
            await Provider.of<FavoritesProvider>(context, listen: false)
                .fetchFavorites(authProvider.currentUser!.uid);
          }
        },
        child: ListView(
          // Use ListView for scrollability
          children: [
            _buildGenresSection(genreProvider),
            const SizedBox(height: 16),
            _buildAudioSection(
                genreProvider, audioPlayerProvider, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildGenresSection(GenreProvider genreProvider) {
    return FutureBuilder(
      future: _genresFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (genreProvider.genres.isEmpty) {
          return const Center(child: Text("No genres available."));
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: "Categories de meditation"),
              SizedBox(
                height: 170, // Increased height slightly
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.85),
                  // Use PageView
                  itemCount: genreProvider.genres.length,
                  itemBuilder: (context, index) {
                    final genre = genreProvider.genres[index];
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: GenreCard(
                        genre: genre,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GenreScreen(genre: genre),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildAudioSection(
    GenreProvider genreProvider,
    AudioPlayerProvider audioPlayerProvider,
    AuthProvider authProvider,
  ) {
    return FutureBuilder(
      future: _audioFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (genreProvider.audioFiles.isEmpty) {
          return const Center(child: Text("No audio files available."));
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: "Categories de sons"),
              Consumer<FavoritesProvider>(
                // Wrap with Consumer
                builder: (context, favoritesProvider, child) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(), // Important for nested lists
                    itemCount: genreProvider.audioFiles.length,
                    itemBuilder: (context, index) {
                      final audio = genreProvider.audioFiles[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.defaultPadding,
                            vertical: AppConstants.defaultPadding / 2),
                        child: AudioCard(
                          audio: audio,
                          isFavorite: favoritesProvider.isFavorite(audio),
                          onFavoritePressed: () {
                            favoritesProvider.toggleFavorite(audio,
                                authProvider.currentUser?.uid); // Pass UID
                          },
                          onTap: () {
                            audioPlayerProvider.playAudio(audio);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AudioPlayerScreen(),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              )
            ],
          );
        }
      },
    );
  }
}
