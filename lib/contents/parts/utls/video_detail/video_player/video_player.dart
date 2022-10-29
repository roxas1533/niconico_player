import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:niconico/contents/parts/utls/video_detail/comment_player/comment.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  VideoPlayerController? _videoViewController;
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
    _videoViewController = VideoPlayerController.network(item.id,
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true))
      ..initialize();
    _notifyAudioHandlerAboutPlaybackEvents(c);
    _videoViewController!.play();
  }

  Widget getPlayer() {
    return AspectRatio(
      aspectRatio: _videoViewController!.value.aspectRatio,
      child: VideoPlayer(_videoViewController!),
    );
  }

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
      stoped = true;
      // _heartBeat!.stop();
      playbackState.add(playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.idle,
      ));
      _videoViewController!.dispose();
      initialized = false;
      _videoViewController = null;
    }
  }

  @override
  Future<void> seek(Duration position) async {
    await _videoViewController!.seekTo(position);
  }

  void _notifyAudioHandlerAboutPlaybackEvents(CommentObjectList c) {
    _videoViewController!.addListener(() {
      final playing = _videoViewController!.value.isPlaying;
      c.isPlaying = playing;

      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.rewind,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.fastForward,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          VideoState.loading: AudioProcessingState.idle,
          VideoState.initialized: AudioProcessingState.ready,
          VideoState.buffering: AudioProcessingState.buffering,
          VideoState.completed: AudioProcessingState.completed,
          VideoState.error: AudioProcessingState.error,
          VideoState.paused: AudioProcessingState.ready,
          VideoState.started: AudioProcessingState.ready,
        }[getState(_videoViewController?.value)]!,
        playing: playing,
        updatePosition: _videoViewController!.value.position,
        // bufferedPosition: _videoViewController!.value.bu,
        speed: _videoViewController!.value.playbackSpeed,
      ));
      if (!initialized && _videoViewController!.value.isPlaying) {
        initialized = true;
        Timer.periodic(const Duration(milliseconds: 33), (Timer timer) async {
          if (stoped) {
            timer.cancel();
          } else if (_videoViewController != null &&
              _videoViewController!.value.isInitialized) {
            _videoViewController!.position
                .then((value) => c.time = value?.inMilliseconds ?? 0);
          }
        });
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

enum VideoState {
  loading,
  initialized,
  buffering,
  completed,
  error,
  paused,
  started,
}

VideoState getState(VideoPlayerValue? value) {
  if (value == null) {
    return VideoState.loading;
  } else if (value.hasError) {
    return VideoState.error;
  } else if (value.isBuffering) {
    return VideoState.buffering;
  } else if (value.isPlaying) {
    return VideoState.started;
  } else if (value.isInitialized) {
    return VideoState.initialized;
  } else if (value.position == value.duration) {
    return VideoState.completed;
  } else {
    return VideoState.paused;
  }
}
