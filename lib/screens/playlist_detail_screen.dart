import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenflector/models/audio.dart';
import 'package:zenflector/models/playlist.dart';
import 'package:zenflector/providers/audio_player_provider.dart';
import 'package:zenflector/providers/auth_provider.dart'; // Import AuthProvider
import 'package:zenflector/providers/favorites_provider.dart';
import 'package:zenflector/providers/genre_provider.dart';
import 'package:zenflector/providers/playlist_provider.dart';
import 'package:zenflector/screens/audio_player_screen.dart';
import 'package:zenflector/widgets/audio_list_item.dart'; // Use AudioListItem
import 'package:zenflector/utils/constants.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  List<Audio> _playlistAudio = [];
  bool _isLoading = true;
  String? _currentUserId; // Store the current user's ID for use in callbacks

  @override
  void initState() {
    super.initState();
    // Get the current user's ID when the screen initializes
    _currentUserId =
        Provider.of<AuthProvider>(context, listen: false).currentUser?.uid;
    _loadPlaylistAudio();
    // Fetch favorites, but only *after* getting the current user.  Important!
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      Provider.of<FavoritesProvider>(context, listen: false)
          .fetchFavorites(authProvider.currentUser!.uid); // Pass user ID.
    }
  }

  Future<void> _loadPlaylistAudio() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final genreProvider = Provider.of<GenreProvider>(context, listen: false);
      await genreProvider.fetchAllAudio(); // Ensure all audio is loaded.
      final allAudio = genreProvider.audioFiles;

      // Filter the audio files to include only those in the playlist
      setState(() {
        _playlistAudio = allAudio
            .where((audio) => widget.playlist.audioIds.contains(audio.id))
            .toList();
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load playlist details: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayerProvider = Provider.of<AudioPlayerProvider>(context);
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    // final favoritesProvider = Provider.of<FavoritesProvider>(context); // Don't get here
    final authProvider =
        Provider.of<AuthProvider>(context, listen: false); // For currentUser

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name),
        actions: [
          // Delete Playlist Button
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Playlist'),
                  content: const Text(
                      'Are you sure you want to delete this playlist?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmDelete == true && authProvider.currentUser != null) {
                await playlistProvider.deletePlaylist(widget.playlist.id);
                if (mounted) {
                  Navigator.pop(context); // Go back
                }
              }
            },
          ),
          // Add to Playlist Button
          IconButton(
            onPressed: () {
              _showAddAudioDialog(context);
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _playlistAudio.isEmpty
                    ? const Center(
                        child: Text('No audio in this playlist yet.'))
                    : Consumer2<FavoritesProvider, PlaylistProvider>(
                        // Use Consumer
                        builder: (context, favoritesProvider, playlistProvider,
                            child) {
                          return ListView.builder(
                            itemCount: _playlistAudio.length,
                            itemBuilder: (context, index) {
                              final audio = _playlistAudio[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AudioListItem(
                                  // Use AudioListItem
                                  audio: audio,
                                  isPlaying:
                                      audioPlayerProvider.currentAudio?.id ==
                                              audio.id &&
                                          audioPlayerProvider.isPlaying,
                                  isFavorite:
                                      favoritesProvider.isFavorite(audio),
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
                                  onRemovePressed: () {
                                    // Use _currentUserId
                                    if (_currentUserId != null) {
                                      playlistProvider.removeAudioFromPlaylist(
                                        widget.playlist.id,
                                        audio.id,
                                        _currentUserId!,
                                      );
                                      setState(() {
                                        _playlistAudio.remove(audio);
                                      });
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showAddAudioDialog(BuildContext context) {
    final genreProvider = Provider.of<GenreProvider>(context, listen: false);
    final allAudio = genreProvider.audioFiles;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Audio to Playlist'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allAudio.length,
              itemBuilder: (context, index) {
                final audio = allAudio[index];
                final isAdded = widget.playlist.audioIds.contains(audio.id);
                return ListTile(
                  title: Text(audio.title),
                  subtitle: Text(audio.artist),
                  trailing:
                      isAdded ? const Icon(Icons.check) : null, // Show check
                  onTap: () async {
                    if (!isAdded) {
                      // Get current user.
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      final currentUser = authProvider.currentUser;

                      if (currentUser != null) {
                        await Provider.of<PlaylistProvider>(context,
                                listen: false)
                            .addAudioToPlaylist(widget.playlist.id, audio.id,
                                currentUser.uid); // Pass UID

                        if (mounted) {
                          Navigator.pop(
                              context); // Close on success after this line
                        }
                        // Update local list *immediately*
                        setState(() {
                          _playlistAudio.add(audio);
                        });
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('User is not logged in.')),
                          );
                        }
                      }
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
