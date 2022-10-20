import 'package:audio_service/audio_service.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class AudioPlayerHandler extends BaseAudioHandler
    with
        QueueHandler, // mix in default queue callback implementations
        SeekHandler {
  VlcPlayerController? _videoViewController;
  Future<void> playerInit(MediaItem item) async {
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

    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: AudioProcessingState.loading,
    ));
    // _videoViewController.initialize().then((_) {
    //   playbackState.add(playbackState.value.copyWith(
    //     processingState: AudioProcessingState.ready,
    //   ));
    //   _videoViewController.play();
    // });
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
        processingState: AudioProcessingState.ready,
      ));
      if (_videoViewController!.value.isInitialized) {
        await _videoViewController!.stopRendererScanning();
        await _videoViewController!.dispose();
      }
      _videoViewController = null;
    }
  }

  @override
  Future<void> seek(Duration position) async {
    await _videoViewController!.seekTo(position);
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
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
        // processingState: const {
        //   ProcessingState.idle: AudioProcessingState.idle,
        //   ProcessingState.loading: AudioProcessingState.loading,
        //   ProcessingState.buffering: AudioProcessingState.buffering,
        //   ProcessingState.ready: AudioProcessingState.ready,
        //   ProcessingState.completed: AudioProcessingState.completed,
        // }[_player.processingState]!,
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
