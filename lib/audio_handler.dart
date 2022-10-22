import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  FijkPlayer? _videoViewController;
  _HeartBeat? _heartBeat;
  bool stoped = false;
  bool initialized = false;
  Future<void> playerInit(MediaItem item, Map<String, dynamic> session,
      Map<String, dynamic> videoData) async {
    stoped = false;
    mediaItem.add(item);
    _heartBeat = _HeartBeat(session, videoData);
    _videoViewController = FijkPlayer();
    _videoViewController!.setDataSource(item.id, autoPlay: true);
    _notifyAudioHandlerAboutPlaybackEvents();
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
      _heartBeat!.stop();
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
    await _videoViewController!.seekTo(position.inMilliseconds);
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _videoViewController!.addListener(() {
      final playing = _videoViewController!.state == FijkState.started;
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
          FijkState.prepared: AudioProcessingState.ready,
          FijkState.completed: AudioProcessingState.completed,
          FijkState.error: AudioProcessingState.error,
          FijkState.paused: AudioProcessingState.ready,
          FijkState.started: AudioProcessingState.ready,
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
