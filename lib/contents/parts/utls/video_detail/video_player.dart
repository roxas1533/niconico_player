import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:niconico/contents/parts/utls/video_detail/comment_player/base_view.dart';

class VideoPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  FijkPlayer? _videoViewController;
  _HeartBeat? _heartBeat;
  bool stoped = false;
  late MediaItem item;
  late Stream<Duration> currentPosSubs;

  bool initialized = false;
  Future<void> playerInit(MediaItem item, Map<String, dynamic> session,
      Map<String, dynamic> videoData, CommentObjectList c) async {
    this.item = item;
    stoped = false;
    mediaItem.add(item);
    _heartBeat = _HeartBeat(session, videoData);
    _videoViewController = FijkPlayer()..setDataSource(item.id, autoPlay: true);
    // await _videoViewController!
    //     .setOption(FijkOption.hostCategory, "http-detect-range-support", 0);

    await _videoViewController!
        .setOption(FijkOption.playerCategory, "enable-accurate-seek", 1);
    // await _videoViewController!
    //     .setOption(FijkOption.playerCategory, "max-buffer-size", 100);

    await _videoViewController!
        .setOption(FijkOption.formatCategory, "fflags", "fastseek");

    currentPosSubs = _videoViewController!.onCurrentPosUpdate;
    _notifyAudioHandlerAboutPlaybackEvents(c);
  }

  Widget getPlayer() {
    return Material(
        child: FijkView(
      player: _videoViewController!,
      color: Colors.black,
    ));
  }

  @override
  Future<void> play() async {
    await _videoViewController!.start();
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
      // _heartBeat!.stop();
      playbackState.add(playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.idle,
      ));
      await _videoViewController!.release();
      _videoViewController!.dispose();
      initialized = false;
      _videoViewController = null;
    }
  }

  @override
  Future<void> seek(Duration position) async {
    // await stop();
    // _videoViewController!.stop();
    // _videoViewController!.reset();
    // _videoViewController = FijkPlayer()..setDataSource(item.id, autoPlay: true);

    // _videoViewController!.setOption(
    //     FijkOption.playerCategory, "seek-at-start", position.inMilliseconds);
    // _notifyAudioHandlerAboutPlaybackEvents(null);

    await _videoViewController!.seekTo(position.inMilliseconds);

    // print(_videoViewController!.currentPos);
  }

  void _notifyAudioHandlerAboutPlaybackEvents(CommentObjectList? c) {
    _videoViewController!.addListener(() {
      final playing = _videoViewController!.state == FijkState.started;
      // c.isPlaying = playing;
      // c.time = _videoViewController!.currentPos.inMilliseconds;
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
          FijkState.idle: AudioProcessingState.idle,
          FijkState.initialized: AudioProcessingState.loading,
          FijkState.asyncPreparing: AudioProcessingState.loading,
          FijkState.prepared: AudioProcessingState.ready,
          FijkState.completed: AudioProcessingState.completed,
          FijkState.error: AudioProcessingState.error,
          FijkState.paused: AudioProcessingState.ready,
          FijkState.started: AudioProcessingState.ready,
          FijkState.stopped: AudioProcessingState.ready,
          FijkState.end: AudioProcessingState.completed,
        }[_videoViewController!.state]!,
        playing: playing,
        updatePosition: _videoViewController!.currentPos,
        bufferedPosition: _videoViewController!.bufferPos,
        // speed: _videoViewController.pla,
        // queueIndex: event.currentIndex,
      ));
      if (!initialized &&
          _videoViewController!.state == FijkState.initialized) {
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
