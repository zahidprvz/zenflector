import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenflector/components/audio_player_widget.dart';
import 'package:zenflector/models/audio.dart';
import 'package:zenflector/providers/audio_player_provider.dart';
import 'package:zenflector/utils/constants.dart';

class AudioPlayerScreen extends StatelessWidget {
  const AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioPlayerProvider = Provider.of<AudioPlayerProvider>(context);
    final Audio? currentAudio = audioPlayerProvider.currentAudio;

    if (currentAudio == null) {
      return const Scaffold(
        body: Center(
          child: Text("No audio selected."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(currentAudio.title),
      ),
      body: Column(
        // Use a Column to arrange image and player
        children: [
          // Display Image (if available)
          if (currentAudio.imageUrl != null &&
              currentAudio.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                child: CachedNetworkImage(
                  imageUrl: currentAudio.imageUrl!,
                  placeholder: (context, url) => Container(
                      height: 300, // Set a fixed height while loading/error
                      width: 300,
                      color: AppColors.highlightColor), // Placeholder color
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error), // Show error icon

                  fit: BoxFit.cover, // Cover the available space
                  height: 300, //  fixed height
                  width: 300, //  fixed width
                ),
              ),
            )
          else // Show a placeholder if no image
            Container(
              height: 300,
              width: double.infinity,
              color: AppColors.highlightColor,
              child:
                  const Icon(Icons.music_note, size: 50, color: Colors.white),
            ),

          // Audio Player Widget
          Expanded(
            // Allow the player to take remaining space
            child: AudioPlayerWidget(audio: currentAudio),
          ),
        ],
      ),
    );
  }
}
