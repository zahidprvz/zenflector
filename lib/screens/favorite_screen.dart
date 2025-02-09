import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenflector/widgets/audio_list_item.dart'; // Use AudioListItem
import 'package:zenflector/providers/audio_player_provider.dart';
import 'package:zenflector/providers/auth_provider.dart'; // Import AuthProvider
import 'package:zenflector/providers/favorites_provider.dart';
import 'package:zenflector/screens/audio_player_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<void> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _favoritesFuture = _fetchFavorites(authProvider);
  }

  Future<void> _fetchFavorites(AuthProvider authProvider) async {
    if (authProvider.currentUser != null) {
      await Provider.of<FavoritesProvider>(context, listen: false)
          .fetchFavorites(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayerProvider = Provider.of<AudioPlayerProvider>(context);
    final authProvider =
        Provider.of<AuthProvider>(context, listen: false); // For currentUser

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: FutureBuilder<void>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            return Consumer<FavoritesProvider>(
              builder: (context, favoritesProvider, child) {
                final favoriteAudios = favoritesProvider.favoriteAudios;

                if (favoriteAudios == null || favoriteAudios.isEmpty) {
                  return const Center(child: Text('No favorites yet!'));
                } else {
                  return ListView.builder(
                    itemCount: favoriteAudios.length,
                    itemBuilder: (context, index) {
                      final audio = favoriteAudios[index];
                      if (audio == null) {
                        print("Error: audio object is null at index $index");
                        return const SizedBox
                            .shrink(); // Return an empty widget if audio is null
                      }
                      return AudioListItem(
                        // Use AudioListItem
                        audio: audio,
                        isPlaying:
                            audioPlayerProvider.currentAudio?.id == audio.id &&
                                audioPlayerProvider.isPlaying,
                        isFavorite: true, // Always true on the Favorites screen
                        onFavoritePressed: () {
                          // Pass currentUser to toggleFavorite
                          favoritesProvider.toggleFavorite(
                              audio, authProvider.currentUser?.uid);
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
                        // No onRemovePressed on the Favorites screen
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
