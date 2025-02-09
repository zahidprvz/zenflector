import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart'; // Import
import 'package:rxdart/rxdart.dart';
import 'package:zenflector/models/audio.dart';
import 'package:zenflector/utils/constants.dart';
import 'package:zenflector/widgets/seek_bar.dart';

class AudioPlayerWidget extends StatefulWidget {
  final Audio audio;
  final VoidCallback onDispose;

  const AudioPlayerWidget(
      {super.key, required this.audio, required this.onDispose});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with WidgetsBindingObserver {
  late AudioPlayer _audioPlayer;

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _audioPlayer.positionStream,
          _audioPlayer.bufferedPositionStream,
          _audioPlayer.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _audioPlayer.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An error occurred during playback: $e'),
            backgroundColor: AppColors.error),
      );
      print('A stream error occurred: $e');
    });

    try {
      // Use setAudioSource and MediaItem for background support
      await _audioPlayer.setAudioSource(AudioSource.uri(
        Uri.parse(widget.audio.fileUrl),
        tag: MediaItem(
            // Use MediaItem
            id: widget.audio.id,
            title: widget.audio.title,
            artist: widget.audio.artist,
            artUri: widget.audio.imageUrl != null
                ? Uri.parse(widget.audio.imageUrl!)
                : null, // Set art URI
            duration: Duration(seconds: widget.audio.duration)),
      ));
    } on PlayerException catch (e) {
      // ... (same error handling as before) ...
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PlayerException: ${e.message} (Code: ${e.code})'),
          backgroundColor: AppColors.error,
        ),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PlatformException: ${e.message} (Code: ${e.code})'),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Don't stop. Keep playing in the background.
    } else if (state == AppLifecycleState.resumed) {
      _audioPlayer.play(); //Plays again when come back to app
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    widget.onDispose(); // Notify that the player is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Display audio title
          Text(
            widget.audio.title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Seek Bar
          StreamBuilder<PositionData>(
            stream: _positionDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data ??
                  PositionData(Duration.zero, Duration.zero, Duration.zero);
              return SeekBar(
                // Use the custom SeekBar
                duration: positionData.duration,
                position: positionData.position,
                bufferedPosition: positionData.bufferedPosition,
                onChangeEnd: (newPosition) {
                  _audioPlayer.seek(newPosition);
                },
              );
            },
          ),

          // Playback Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10),
                iconSize: 32,
                onPressed: () {
                  _audioPlayer.seek(
                      _audioPlayer.position - const Duration(seconds: 10));
                },
              ),
              StreamBuilder<PlayerState>(
                stream: _audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;

                  if (processingState == ProcessingState.loading ||
                      processingState == ProcessingState.buffering) {
                    return Container(
                      margin: const EdgeInsets.all(8.0),
                      width: 64.0,
                      height: 64.0,
                      child: const CircularProgressIndicator(),
                    );
                  } else if (playing != true) {
                    return IconButton(
                      icon: const Icon(Icons.play_arrow),
                      iconSize: 64.0,
                      onPressed: _audioPlayer.play,
                    );
                  } else if (processingState != ProcessingState.completed) {
                    return IconButton(
                      icon: const Icon(Icons.pause),
                      iconSize: 64.0,
                      onPressed: _audioPlayer.pause,
                    );
                  } else {
                    return IconButton(
                      icon: const Icon(Icons.replay),
                      iconSize: 64.0,
                      onPressed: () => _audioPlayer.seek(Duration.zero),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.forward_30),
                iconSize: 32,
                onPressed: () {
                  _audioPlayer.seek(
                      _audioPlayer.position + const Duration(seconds: 30));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper class for progress bar data (no changes needed)
class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
