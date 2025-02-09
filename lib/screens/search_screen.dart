import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenflector/components/audio_card.dart'; // Use AudioCard
import 'package:zenflector/models/audio.dart';
import 'package:zenflector/providers/audio_player_provider.dart';
import 'package:zenflector/providers/auth_provider.dart'; // Import AuthProvider
import 'package:zenflector/providers/favorites_provider.dart';
import 'package:zenflector/providers/genre_provider.dart';
import 'package:zenflector/screens/audio_player_screen.dart';
import 'package:zenflector/utils/constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchTerm = '';
  List<Audio> _searchResults = [];
  // Add a loading state
  bool _isLoading = false;

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
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchTerm = _searchController.text;
      _isLoading = true; // Set loading to true when starting the search
    });
    // Debounce the search (wait for user to stop typing)
    Future.delayed(const Duration(milliseconds: 300), () {
      // 300ms delay
      if (mounted) {
        // Check if the widget is still mounted
        _performSearch();
      }
    });
  }

  void _performSearch() async {
    if (_searchTerm.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    final genreProvider = Provider.of<GenreProvider>(context, listen: false);
    final allAudio = genreProvider.audioFiles; // Get all loaded audio

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
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayerProvider = Provider.of<AudioPlayerProvider>(context);
    // final favoritesProvider = Provider.of<FavoritesProvider>(context); // Get the provider. Don't use here
    final authProvider =
        Provider.of<AuthProvider>(context, listen: false); // For currentUser

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search for audio...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.inputHint),
          ),
          style: const TextStyle(color: AppColors.textPrimary),
          autofocus: true,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Show loading indicator
                : _searchResults.isEmpty
                    ? const Center(child: Text('No results found.'))
                    : Consumer<FavoritesProvider>(
                        // Wrap with Consumer
                        builder: (context, favoritesProvider, child) {
                          return ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final audio = _searchResults[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AudioCard(
                                  audio: audio,
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
                                  isFavorite:
                                      favoritesProvider.isFavorite(audio),
                                  onFavoritePressed: () {
                                    // Pass currentUser to toggleFavorite
                                    favoritesProvider.toggleFavorite(
                                        audio, authProvider.currentUser?.uid);
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
}
