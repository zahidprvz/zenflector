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
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _animationController;
  late Animation<double> _playPauseAnimation;
  bool _wasPlayingBeforePause = false; // ✅ Declared this variable

  // ✅ Custom clampDuration method
  Duration clampDuration(Duration value, Duration min, Duration max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  // ✅ Updated Position Data Stream
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) {
          duration ??= Duration.zero;

          // Clamping position and buffered position
          position = clampDuration(position, Duration.zero, duration);
          bufferedPosition =
              clampDuration(bufferedPosition, Duration.zero, duration);

          return PositionData(position, bufferedPosition, duration);
        },
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAudioPlayer();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _playPauseAnimation =
        Tween<double>(begin: 0, end: 1).animate(_animationController);

    _audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Future<void> _initAudioPlayer() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    try {
      await _audioPlayer.setAudioSource(AudioSource.uri(
        Uri.parse(widget.audio.fileUrl),
        tag: MediaItem(
          id: widget.audio.id,
          title: widget.audio.title,
          artist: widget.audio.artist,
          artUri: widget.audio.imageUrl != null
              ? Uri.parse(widget.audio.imageUrl!)
              : null,
          duration: Duration(seconds: widget.audio.duration),
        ),
      ));
      _audioPlayer.play();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred during playback: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _wasPlayingBeforePause = _audioPlayer.playing;
    } else if (state == AppLifecycleState.resumed && _wasPlayingBeforePause) {
      _audioPlayer.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<PositionData>(
            stream: _positionDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data ??
                  PositionData(Duration.zero, Duration.zero, Duration.zero);
              return Column(
                children: [
                  SeekBar(
                    duration: positionData.duration,
                    position: positionData.position,
                    bufferedPosition: positionData.bufferedPosition,
                    onChangeEnd: (newPosition) {
                      _audioPlayer.seek(newPosition);
                    },
                    barHeight: 8,
                    thumbRadius: 12,
                    progressBarColor: Colors.white,
                    baseBarColor: Colors.white.withOpacity(0.3),
                    bufferedBarColor: Colors.white.withOpacity(0.5),
                    thumbColor: Colors.white,
                    timeLabelTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12), // ✅ Added vertical space
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(positionData.position),
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        "-${_formatDuration(positionData.duration - positionData.position)}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 30), // Spacing before controls

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10),
                iconSize: 40,
                color: Colors.white,
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
                    return const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    );
                  } else if (playing != true) {
                    return FloatingActionButton(
                      onPressed: _audioPlayer.play,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueAccent,
                      child: const Icon(Icons.play_arrow, size: 48),
                    );
                  } else {
                    return FloatingActionButton(
                      onPressed: _audioPlayer.pause,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueAccent,
                      child: AnimatedIcon(
                        icon: AnimatedIcons.play_pause,
                        progress: _animationController,
                        size: 48,
                      ),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.forward_30),
                iconSize: 40,
                color: Colors.white,
                onPressed: () {
                  _audioPlayer.seek(
                      _audioPlayer.position + const Duration(seconds: 30));
                },
              ),
            ],
          ),

          const SizedBox(height: 20), // More spacing

          Text(
            widget.audio.title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: Colors.white),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            widget.audio.artist,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
