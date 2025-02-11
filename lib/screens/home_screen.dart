import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenflector/components/audio_card.dart';
import 'package:zenflector/components/section_header.dart';
import 'package:zenflector/models/audio.dart'; // Import Audio model
import 'package:zenflector/providers/audio_player_provider.dart';
import 'package:zenflector/providers/auth_provider.dart';
import 'package:zenflector/providers/favorites_provider.dart';
import 'package:zenflector/providers/genre_provider.dart';
import 'package:zenflector/screens/audio_player_screen.dart';
import 'package:zenflector/screens/genre_screen.dart';
import 'package:zenflector/screens/search_screen.dart'; // Import SearchScreen
import 'package:zenflector/utils/constants.dart';
import 'package:zenflector/components/genre_card.dart';
import 'package:zenflector/widgets/audio_list_item.dart'; // Import AudioListItem

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _genresFuture;
  late Future<void> _audioFuture;
  late Future<void> _favoritesFuture; // For fetching favorites

  @override
  void initState() {
    super.initState();
    final genreProvider = Provider.of<GenreProvider>(context, listen: false);
    _genresFuture = genreProvider.fetchGenres();
    _audioFuture = genreProvider.fetchAllAudio();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      _favoritesFuture = Provider.of<FavoritesProvider>(context, listen: false)
          .fetchFavorites(authProvider.currentUser!.uid); // Pass UID
    } else {
      _favoritesFuture =
          Future.value(); // Complete immediately if not logged in
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
        // centerTitle: true,
        actions: [
          // Search Icon
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const SearchScreen()), // Navigate to SearchScreen
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Re-fetch data on refresh.  Await to ensure UI updates correctly.
          await Provider.of<GenreProvider>(context, listen: false)
              .fetchGenres();
          await Provider.of<GenreProvider>(context, listen: false)
              .fetchAllAudio();
          if (authProvider.currentUser != null) {
            // Only fetch favorites if logged in.
            await Provider.of<FavoritesProvider>(context, listen: false)
                .fetchFavorites(authProvider.currentUser!.uid);
          }
        },
        child: ListView(
          children: [
            _buildGreeting(authProvider),
            _buildGenresSection(genreProvider),
            const SizedBox(height: 16),
            _buildFeaturedAudioSection(
                genreProvider, audioPlayerProvider, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          CircleAvatar(
            // Display user's profile image
            radius: 25, // Adjust size as needed
            backgroundImage: authProvider.currentUser?.photoURL != null
                ? CachedNetworkImageProvider(
                    authProvider.currentUser!.photoURL!)
                : null, // Use CachedNetworkImageProvider
            child: authProvider.currentUser?.photoURL == null
                ? const Icon(Icons.person, size: 20) // Default icon if no image
                : null,
          ),
          const SizedBox(width: 16),
          Text(
            'Welcome, ${authProvider.currentUser?.name ?? 'User'}!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildGenresSection(GenreProvider genreProvider) {
    // This remains largely the same, as it's for genres
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
              const SectionHeader(title: "Categories"),
              SizedBox(
                height: 170, // Keep fixed height
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.85),
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

  Widget _buildFeaturedAudioSection(
    GenreProvider genreProvider,
    AudioPlayerProvider audioPlayerProvider,
    AuthProvider authProvider,
  ) {
    return FutureBuilder(
      future: _favoritesFuture, // Use FutureBuilder for favorites
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          return Consumer<FavoritesProvider>(
            // Use Consumer for Favorites
            builder: (context, favoritesProvider, child) {
              final List<Audio> favoriteAudios =
                  favoritesProvider.favoriteAudios ?? [];
              final List<Audio> displayAudios =
                  favoriteAudios.take(5).toList(); // Limit to 5

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: "Featured Audio"),
                  if (displayAudios.isEmpty) ...[
                    if (authProvider.currentUser != null)
                      const Padding(
                        padding: EdgeInsets.all(AppConstants.defaultPadding),
                        child: Center(child: Text("No favorites yet!")),
                      ),
                  ] else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayAudios.length,
                      itemBuilder: (context, index) {
                        final audio = displayAudios[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.defaultPadding,
                            vertical: AppConstants.defaultPadding / 2,
                          ),
                          child: AudioListItem(
                            // Use AudioListItem, not AudioCard
                            audio: audio,
                            isPlaying: audioPlayerProvider.currentAudio?.id ==
                                    audio.id &&
                                audioPlayerProvider.isPlaying,
                            isFavorite: favoritesProvider
                                .isFavorite(audio), // This is correct now
                            onFavoritePressed: () {
                              favoritesProvider.toggleFavorite(
                                  audio, authProvider.currentUser?.uid);
                            },
                            onTap: () {
                              audioPlayerProvider.playAudio(audio);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AudioPlayerScreen(),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          );
        }
      },
    );
  }
}
