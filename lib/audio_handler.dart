import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;

class AudioPlayerHandler extends BaseAudioHandler
    with
        QueueHandler, // mix in default queue callback implementations
        SeekHandler {
  VlcPlayerController? _videoViewController;
  _HeartBeat? _heartBeat;
  // TimerNotifer _timerNotifer = TimerNotifer();
  bool stoped = false;
  bool initialized = false;
  Future<void> playerInit(MediaItem item, Map<String, dynamic> session,
      Map<String, dynamic> videoData) async {
    stoped = false;
    mediaItem.add(item);
    _heartBeat = _HeartBeat(session, videoData);

    _videoViewController = VlcPlayerController.network(
      item.id,
      autoPlay: true,
      hwAcc: HwAcc.full,
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
      stoped = true;
      _heartBeat!.stop();
      playbackState.add(playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.idle,
      ));
      await _videoViewController!.stopRendererScanning();
      await _videoViewController!.dispose();
      initialized = false;
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
      if (!initialized &&
          _videoViewController!.value.playingState ==
              PlayingState.initialized) {
        initialized = true;
        Timer.periodic(const Duration(seconds: 40), (timer) {
          if (stoped) {
            timer.cancel();
          } else if (_heartBeat != null) {
            _heartBeat!.kepp();
          }
        });
      }
    });
  }
}

class _HeartBeat {
  static const ua =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.63 Safari/537.36";
  static const headers = {
    "Accept-Language": "ja,en-US;q=0.9,en;q=0.8",
    "Content-Type": "application/json",
    "Origin": "https://www.nicovideo.jp",
    "Referer": "https://www.nicovideo.jp/",
    "Connection": "keep-alive",
    "Host": "api.dmc.nico",
    "Sec-Fetch-Mode": "cors",
    "Sec-Fetch-Dest": "empty",
    "Sec-Fetch-Site": "cross-site",
    "User-Agent": ua,
    "Accept": "application/json"
  };
  late String _url;
  late Map<String, dynamic> _data;
  final Map<String, dynamic> _session;
  final Map<String, dynamic> _videoData;
  _HeartBeat(this._session, this._videoData) {
    final urlApi = _session["urls"][0]["url"];
    final id = _videoData["data"]["session"]["id"];

    _data = _videoData["data"];

    _url = "$urlApi/$id?_format=json&_method=";
  }
  Future<void> kepp() async {
    const method = "PUT";
    await http.post(Uri.parse(_url + method),
        headers: headers, body: json.encode(_data));
  }

  Future<void> stop() async {
    const method = "DELETE";
    await http.post(Uri.parse(_url + method),
        headers: headers, body: json.encode(_data));
  }
}
