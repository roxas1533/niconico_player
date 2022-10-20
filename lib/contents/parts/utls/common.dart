import 'dart:math';

// import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';

import 'space_box.dart';

// import 'package:rxdart/rxdart.dart';
class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final double pWidth;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    Key? key,
    required this.duration,
    required this.position,
    required this.pWidth,
    this.bufferedPosition = Duration.zero,
    this.onChanged,
    this.onChangeEnd,
  }) : super(key: key);

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  double? _dragValue;
  bool _dragging = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final value = min(
      _dragValue ?? widget.position.inMilliseconds.toDouble(),
      widget.duration.inMilliseconds.toDouble(),
    );
    if (_dragValue != null && !_dragging) {
      _dragValue = null;
    }
    return SizedBox(
        width: widget.pWidth,
        child: Row(
          children: [
            Text(
              VideoDetailInfo.secToTime(widget.position.inSeconds),
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
            const SpaceBox(width: 5),
            Expanded(
                child: SliderTheme(
              data: SliderThemeData(
                  thumbColor: Colors.blue,
                  activeTrackColor: Colors.blue,
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 5)),
              child: Slider(
                min: 0.0,
                max: widget.duration.inMilliseconds.toDouble(),
                value: value,
                onChanged: (value) {
                  if (!_dragging) {
                    _dragging = true;
                  }
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
                  _dragging = false;
                },
              ),
            )),
            const SpaceBox(
              width: 5,
            ),
            Text(
              VideoDetailInfo.secToTime(widget.duration.inSeconds),
              style: const TextStyle(
                fontSize: 12,
              ),
            )
          ],
        ));
  }
}
