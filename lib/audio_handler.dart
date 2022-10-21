import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class AudioPlayerHandler extends BaseAudioHandler
    with
        QueueHandler, // mix in default queue callback implementations
        SeekHandler {
  VlcPlayerController? _videoViewController;
  TimerNotifer _timerNotifer = TimerNotifer();
  Future<void> playerInit(MediaItem item) async {
    _timerNotifer = TimerNotifer();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _timerNotifer.count();
      print(_timerNotifer.value.time);
      if (_timerNotifer.value.time == 30) {
        timer.cancel();
      }
    });
    mediaItem.add(item);
    _videoViewController = VlcPlayerController.network(
      item.id,
      autoPlay: true,
      hwAcc: HwAcc.full,
      options: VlcPlayerOptions(
        video: VlcVideoOptions(["--no-drop-late-frames", "--no-skip-frames"]),
      ),
    );
    _notifyAudioHandlerAboutPlaybackEvents();
  }

  VlcPlayer getVlcPlayer() {
    return VlcPlayer(
      controller: _videoViewController!,
      aspectRatio: 16 / 9,
    );
  }

  // The most common callbacks:
  @override
  Future<void> play() async {
    await _videoViewController!.play();
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      processingState: AudioProcessingState.ready,
    ));
  }

  @override
  Future<void> pause() async {
    await _videoViewController!.pause();
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      processingState: AudioProcessingState.ready,
    ));
  }

  @override
  Future<void> stop() async {
    if (_videoViewController != null) {
      await _videoViewController!.stop();
      playbackState.add(playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.completed,
      ));
      await _videoViewController!.stopRendererScanning();
      await _videoViewController!.dispose();
      _videoViewController = null;
    }
  }

  @override
  Future<void> seek(Duration position) async {
    await _videoViewController!.seekTo(position);
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    // _timerNotifer.addListener(() {
    //   print(_timerNotifer.value.time);
    // });
    _videoViewController!.addListener(() {
      final playing = _videoViewController!.value.isPlaying;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          // PlayingState.initializing : AudioProcessingState.idle,
          PlayingState.initializing: AudioProcessingState.loading,
          PlayingState.buffering: AudioProcessingState.buffering,
          PlayingState.initialized: AudioProcessingState.ready,
          PlayingState.ended: AudioProcessingState.completed,
          PlayingState.error: AudioProcessingState.error,
          PlayingState.paused: AudioProcessingState.ready,
          PlayingState.playing: AudioProcessingState.ready,
          PlayingState.stopped: AudioProcessingState.completed,
        }[_videoViewController!.value.playingState]!,
        playing: playing,
        updatePosition: _videoViewController!.value.position,
        bufferedPosition: _videoViewController!.value.duration *
            _videoViewController!.value.bufferPercent,
        speed: _videoViewController!.value.playbackSpeed,
        // queueIndex: event.currentIndex,
      ));
    });
  }
}

class _Timer {
  final int time;
  _Timer({required this.time});
  _Timer copyWith({int? time}) {
    return _Timer(time: time ?? this.time);
  }
}

class TimerNotifer extends ValueNotifier<_Timer> {
  TimerNotifer() : super(_Timer(time: 0));
  Future<void> count() async {
    value = value.copyWith(time: value.time + 1);
  }
}
