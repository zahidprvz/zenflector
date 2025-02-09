import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zenflector/models/audio.dart';
import 'package:zenflector/utils/constants.dart';
import 'package:zenflector/widgets/seek_bar.dart';

class AudioPlayerWidget extends StatefulWidget {
  final Audio audio;

  const AudioPlayerWidget({super.key, required this.audio});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with WidgetsBindingObserver {
  late final AudioPlayer _audioPlayer = AudioPlayer();

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) {
          // 1. Handle null duration (defensive programming)
          duration ??= Duration.zero;

          // 2. Handle zero duration (prevent division by zero)
          if (duration == Duration.zero) {
            return PositionData(Duration.zero, Duration.zero, Duration.zero);
          }

          // 3. Clamp position *both* to 0 and to duration.  CORRECTED
          position = Duration(
              microseconds:
                  position.inMicroseconds.clamp(0, duration.inMicroseconds));
          bufferedPosition = Duration(
              microseconds: bufferedPosition.inMicroseconds
                  .clamp(0, duration.inMicroseconds));

          return PositionData(
            position,
            bufferedPosition,
            duration,
          );
        },
      );
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _audioPlayer.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      // Show a user-friendly error message.
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
      _audioPlayer.play();
    } on PlayerException catch (e) {
      // iOS/macOS: maps to NSError.code
      // Android: maps to ExoPlayerException.type
      // Web: maps to MediaError.code
      // Linux/Windows: maps to PlayerErrorCode.index
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PlayerException: ${e.message} (Code: ${e.code})'),
          backgroundColor: AppColors.error,
        ),
      );
    } on PlatformException catch (e) {
      // iOS/macOS: maps to NSError.code
      // Android: maps to ExoPlaybackException.type
      // Web: maps to MediaError.code
      // Linux/Windows: maps to PlatformErrorCode.index
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PlatformException: ${e.message} (Code: ${e.code})'),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      // Catch other errors
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Display audio title and artist
          Text(
            widget.audio.title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          Text(
            widget.audio.artist,
            style: Theme.of(context).textTheme.bodyMedium,
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
              // Rewind
              IconButton(
                icon: const Icon(Icons.replay_10),
                iconSize: 32,
                onPressed: () {
                  _audioPlayer.seek(
                      _audioPlayer.position - const Duration(seconds: 10));
                },
              ),
              // Play/Pause Button
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
              // Fast Forward
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

// Helper class for progress bar data
class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
