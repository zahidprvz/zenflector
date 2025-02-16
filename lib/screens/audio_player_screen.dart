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
        children: [
          // Display Image
          if (currentAudio.imageUrl != null &&
              currentAudio.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                child: CachedNetworkImage(
                  imageUrl: currentAudio.imageUrl!,
                  placeholder: (context, url) => Container(
                      height: 300, width: 300, color: AppColors.highlightColor),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                  height: 300,
                  width: 300,
                ),
              ),
            )
          else
            Container(
              height: 300,
              width: double.infinity,
              color: AppColors.highlightColor,
              child:
                  const Icon(Icons.music_note, size: 50, color: Colors.white),
            ),

          // // **Title**
          // Padding(
          //   padding:
          //       const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          //   child: Text(
          //     currentAudio.title,
          //     style: Theme.of(context).textTheme.headlineSmall,
          //     textAlign: TextAlign.center,
          //   ),
          // ),

          // // **Artist Name**
          // if (currentAudio.artist != null &&
          //     currentAudio.artist!.isNotEmpty) // Show artist only if available
          //   Padding(
          //     padding:
          //         const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          //     child: Text(
          //       currentAudio.artist!,
          //       style: Theme.of(context)
          //           .textTheme
          //           .bodyMedium
          //           ?.copyWith(color: Colors.grey.shade600),
          //       textAlign: TextAlign.center,
          //     ),
          //   ),

          // **Scrollable Description Section**
          if (currentAudio.description != null &&
              currentAudio.description!.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Text(
                    currentAudio.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          // **Audio Player Widget**
          AudioPlayerWidget(audio: currentAudio),
        ],
      ),
    );
  }
}
