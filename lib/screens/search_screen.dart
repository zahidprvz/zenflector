import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenflector/models/audio.dart';
import 'package:zenflector/providers/audio_player_provider.dart';
import 'package:zenflector/providers/favorites_provider.dart';
import 'package:zenflector/providers/genre_provider.dart';
import 'package:zenflector/screens/audio_player_screen.dart';
import 'package:zenflector/utils/constants.dart';
import 'package:zenflector/widgets/audio_list_item.dart'; // Use AudioListItem
import 'package:zenflector/providers/auth_provider.dart';
import 'dart:async'; // Import for Timer

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchTerm = '';
  List<Audio> _searchResults = [];
  Timer? _debounce; // Timer for debouncing

  @override
  void initState() {
    super.initState();
    final genreProvider = Provider.of<GenreProvider>(context, listen: false);
    genreProvider.fetchAllAudio();
    _searchController.addListener(_onSearchChanged);
    // Fetch favorites, but only *after* getting the current user.  Important!
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      Provider.of<FavoritesProvider>(context, listen: false)
          .fetchFavorites(authProvider.currentUser!.uid); // Pass UID
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel(); // Cancel the timer
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // 500ms delay
      if (mounted) {
        _performSearch();
      }
    });
  }

  void _performSearch() async {
    if (_searchTerm.isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
        });
      }
      return;
    }

    final genreProvider = Provider.of<GenreProvider>(context, listen: false);
    // Ensure all audio is loaded.  Important!

    final allAudio = genreProvider.audioFiles;

    final results = allAudio.where((audio) {
      final title = audio.title.toLowerCase();
      final artist = audio.artist.toLowerCase();
      final term = _searchTerm.toLowerCase();
      return title.contains(term) || artist.contains(term);
    }).toList();

    // Update the state and loading indicator
    if (mounted) {
      setState(() {
        _searchResults = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayerProvider = Provider.of<AudioPlayerProvider>(context);
    final authProvider =
        Provider.of<AuthProvider>(context, listen: false); // For currentUser

    return Scaffold(
      appBar: AppBar(
        // Wrap TextField in a Container for size control
        title: Container(
          width: MediaQuery.of(context).size.width *
              0.7, // Example: 70% of screen width
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for audio...',
              hintStyle:
                  TextStyle(color: AppColors.inputHint), // Use a defined color
              border: OutlineInputBorder(
                // Add a border
                borderRadius: BorderRadius.circular(25.0), // Rounded corners
                borderSide: BorderSide.none, // No border side
              ),
              filled: true,
              fillColor:
                  AppColors.appBarBackground, // Use a contrasting background
              prefixIcon: Icon(Icons.search,
                  color: AppColors.textSecondary), // Icon color
            ),
            style: const TextStyle(color: AppColors.textPrimary), // Text color
            autofocus: true,
            onChanged: (value) {
              // Update search term
              setState(() {
                _searchTerm = value;
              });
            },
          ),
        ),
      ),
      body: Consumer<FavoritesProvider>(
        // Use Consumer for Favorites
        builder: (context, favoritesProvider, child) {
          return _searchResults.isEmpty
              ? const Center(child: Text('No results found.'))
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final audio = _searchResults[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AudioListItem(
                        audio: audio,
                        isPlaying:
                            audioPlayerProvider.currentAudio?.id == audio.id &&
                                audioPlayerProvider.isPlaying,
                        isFavorite: favoritesProvider.isFavorite(audio),
                        onFavoritePressed: () {
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
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
