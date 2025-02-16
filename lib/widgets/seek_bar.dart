import 'package:flutter/material.dart';
import 'package:zenflector/utils/constants.dart';

/// A seek bar widget to control and display audio playback position.
class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;
  final double barHeight; // Add barHeight
  final double thumbRadius; // Add thumbRadius
  final Color progressBarColor; // Add these
  final Color baseBarColor;
  final Color bufferedBarColor;
  final Color thumbColor;
  final TextStyle? timeLabelTextStyle;

  const SeekBar({
    Key? key,
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    this.onChanged,
    this.onChangeEnd,
    this.barHeight = 3, // Default values
    this.thumbRadius = 10,
    this.progressBarColor = AppColors.primary,
    this.baseBarColor = AppColors.inputBorder,
    this.bufferedBarColor = AppColors.highlightColor,
    this.thumbColor = AppColors.primary,
    this.timeLabelTextStyle,
  }) : super(key: key);

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  double? _dragValue;
  late SliderThemeData _sliderThemeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: widget.barHeight, // Use provided barHeight
      thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: widget.thumbRadius), // Use thumbRadius
      overlayShape: RoundSliderOverlayShape(
          overlayRadius:
              widget.thumbRadius + 4), // Add small padding to thumb radius.
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.timeLabelTextStyle ??
        Theme.of(context).textTheme.bodySmall; // Use provided style, or default

    return Stack(
      children: [
        // Buffered Progress Bar (Inactive Part)
        SliderTheme(
          data: _sliderThemeData.copyWith(
            thumbShape: HiddenThumbComponentShape(), // Hide thumb
            activeTrackColor: widget.bufferedBarColor, // Use provided color
            inactiveTrackColor: widget.baseBarColor, // Use provided color
          ),
          child: ExcludeSemantics(
            // Exclude from accessibility tree
            child: Slider(
              max: widget.duration.inMilliseconds.toDouble(),
              value: widget.bufferedPosition.inMilliseconds.toDouble().clamp(
                  0.0,
                  widget.duration.inMilliseconds
                      .toDouble()), // Clamp value, and handle 0 duration.
              onChanged: (value) {
                // No action needed, this slider is for display only
              },
            ),
          ),
        ),

        // Seek Bar (Active Part)
        SliderTheme(
          data: _sliderThemeData.copyWith(
            inactiveTrackColor:
                Colors.transparent, // Make inactive part transparent
            activeTrackColor: widget.progressBarColor, // Use provided color
            thumbColor: widget.thumbColor, // Use provided color
          ),
          child: Slider(
            max: widget.duration.inMilliseconds.toDouble(),
            value: (_dragValue ?? widget.position.inMilliseconds.toDouble())
                .clamp(
                    0.0,
                    widget.duration.inMilliseconds
                        .toDouble()), // Clamp value, and handle 0 duration.
            onChanged: (value) {
              setState(() {
                _dragValue = value;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(Duration(milliseconds: value.round()));
              }
            },
            onChangeEnd: (value) {
              if (widget.onChangeEnd != null) {
                widget.onChangeEnd!(Duration(milliseconds: value.round()));
              }
              _dragValue = null; // Reset drag value after dragging ends
            },
          ),
        ),

        // Time Labels (Positioned)
        Positioned(
          right: 16.0,
          bottom: -4.0,
          child: Text(
              RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                      .firstMatch("$_remaining")
                      ?.group(1) ??
                  '$_remaining', // Remaining time
              style: textStyle),
        ),
        Positioned(
          left: 16.0,
          bottom: -4.0,
          child: Text(
            _formatDuration(widget.position), // Current position
            style: textStyle,
          ),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;

  // Helper function to format Duration as mm:ss
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

// Custom Slider Thumb to hide it when not dragging
class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}
