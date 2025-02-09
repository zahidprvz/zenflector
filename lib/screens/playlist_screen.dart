import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenflector/providers/auth_provider.dart'; // Import AuthProvider
import 'package:zenflector/providers/playlist_provider.dart';
import 'package:zenflector/screens/playlist_detail_screen.dart';
import 'package:zenflector/widgets/playlist_item.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final _playlistNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch playlists *only if* the user is logged in
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      Provider.of<PlaylistProvider>(context, listen: false)
          .fetchPlaylists(authProvider.currentUser!.uid); // Pass the UID
    }
  }

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  void _showCreatePlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Playlist'),
          content: TextField(
            controller: _playlistNameController,
            decoration: const InputDecoration(hintText: 'Playlist Name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _playlistNameController.text.trim();
                if (name.isNotEmpty) {
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  final currentUser = authProvider.currentUser;

                  if (currentUser != null) {
                    await Provider.of<PlaylistProvider>(context, listen: false)
                        .createPlaylist(
                            currentUser.uid, name); // Pass the UID and name
                    _playlistNameController.clear(); // Clear after creation

                    if (mounted) {
                      Navigator.pop(context); // Close dialog
                    }
                  } else {
                    // Handle the case where the user is not logged in.
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User is not logged in.')),
                      );
                    }
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreatePlaylistDialog,
          ),
        ],
      ),
      body: playlistProvider.playlists.isEmpty
          ? const Center(child: Text('No playlists yet!'))
          : ListView.builder(
              itemCount: playlistProvider.playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlistProvider.playlists[index];
                return PlaylistItem(
                  playlist: playlist,
                  onTap: () {
                    Navigator.push(
                      // Added Navigation
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PlaylistDetailScreen(playlist: playlist),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
