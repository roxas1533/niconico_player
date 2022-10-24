import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/common.dart';
import 'package:niconico/contents/parts/utls/video_detail/comment_player/base_view.dart';
import 'package:niconico/contents/parts/utls/video_detail/play_video_paramater.dart';
import 'package:niconico/functions.dart';
import 'package:rxdart/rxdart.dart';

class PlayVideo extends StatefulWidget {
  const PlayVideo({Key? key, required this.video}) : super(key: key);

  final VideoDetailInfo video;
  @override
  PlayVideoState createState() => PlayVideoState();
}

class PlayVideoState extends State<PlayVideo> {
  final playVideoParam = PlayVideoParam();
  bool hasListener = false;
  late Future _futureVideoViewController;
  late CommentObjectList _commentObjectList;
  bool sliderChanging = false;
  final jsonHeader = {"Content-Type": "application/json"};
  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
          audioHandler.mediaItem,
          audioHandler.currentPosSubs,
          (mediaItem, position) => MediaState(mediaItem, position));

  Future<String> _getVideoController() async {
    final videoDataResPonse = await http.post(
        Uri.parse(widget.video.session["urls"][0]["url"] + "?_format=json"),
        body: json.encode(makeSessionPayloads(widget.video.session)),
        headers: jsonHeader);
    Map<String, dynamic> videoData = json.decode(videoDataResPonse.body);

    final nvComment = widget.video.nvComment;

    final params = {
      "params": nvComment["params"],
      "additionals": {},
      "threadKey": nvComment["threadKey"],
    };

    final commentDataResPonse = await http.post(
        Uri.parse(nvComment["server"] + "/v1/threads"),
        body: json.encode(params),
        headers: {"X-Frontend-Id": "6", "X-Frontend-Version": "0"});

    Map<String, dynamic> commentData =
        json.decode(utf8.decode(commentDataResPonse.bodyBytes));
    _commentObjectList = CommentObjectList(commentData);

    await audioHandler.playerInit(
        MediaItem(
          id: videoData["data"]["session"]["content_uri"],
          title: widget.video.title,
          artist: widget.video.userName,
          duration: Duration(seconds: widget.video.lengthSeconds),
          artUri: Uri.parse(widget.video.thumbnailUrl),
        ),
        widget.video.session,
        videoData,
        _commentObjectList);

    return "temp";
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.leanBack,
    );
    _futureVideoViewController = _getVideoController();
  }

  @override
  void dispose() async {
    audioHandler.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return FutureBuilder(
        future: _futureVideoViewController,
        builder: (context, snapshot) {
          // if (snapshot.hasData) {
          if (snapshot.hasData) {
            return SizedBox(
              width: screenSize.width,
              height: screenSize.height,
              child: RotatedBox(
                quarterTurns: 1, //or 2
                child: Stack(alignment: Alignment.center, children: [
                  // SizedBox(
                  //     width: screenSize.height,
                  //     height: screenSize.width,
                  //     child: Container(
                  //       width: screenSize.width,
                  //       height: screenSize.width * 9 / 16,
                  //       color: Colors.red,
                  //     )),
                  SizedBox(
                    width: screenSize.height,
                    height: screenSize.width,
                    child: audioHandler.getPlayer(),
                  ),
                  SizedBox(
                      width: screenSize.height,
                      height: screenSize.width,
                      child: CommentPlayer(
                        screenSize: screenSize,
                        commentObjectList: _commentObjectList,
                      )),
                  SizedBox(
                    width: screenSize.height,
                    height: screenSize.width,
                    child: Consumer(builder: ((context, ref, child) {
                      return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            ref.read(playVideoParam.uiVisible.notifier).state =
                                !ref.read(playVideoParam.uiVisible);
                          },
                          child: _buildOverlayContainer(
                              screenSize: screenSize,
                              ref: ref,
                              childlen: [
                                Container(
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 10),
                                    child: AnimatedSizeIcon(
                                      touchEvent: () {
                                        SystemChrome.setEnabledSystemUIMode(
                                          SystemUiMode.edgeToEdge,
                                        );
                                        Navigator.pop(context);
                                      },
                                      icon: Icons.clear_rounded,
                                      size: 24,
                                    )),
                                Column(
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 10),
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: Row(
                                          children: [
                                            Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    AnimatedSizeIcon(
                                                      icon:
                                                          Icons.replay_10_sharp,
                                                      size: 24,
                                                      touchEvent: () {},
                                                    ),
                                                    const SpaceBox(width: 20),
                                                    StreamBuilder<bool>(
                                                      stream: audioHandler
                                                          .playbackState
                                                          .map((state) =>
                                                              state.playing)
                                                          .distinct(),
                                                      builder:
                                                          (context, snapshot) {
                                                        final playing =
                                                            snapshot.data ??
                                                                false;
                                                        return playing
                                                            ? AnimatedSizeIcon(
                                                                icon:
                                                                    Icons.pause,
                                                                size: 35,
                                                                touchEvent:
                                                                    audioHandler
                                                                        .pause,
                                                              )
                                                            : AnimatedSizeIcon(
                                                                icon: Icons
                                                                    .play_arrow,
                                                                size: 35,
                                                                touchEvent:
                                                                    audioHandler
                                                                        .play,
                                                              );
                                                      },
                                                    ),
                                                    const SpaceBox(width: 20),
                                                    GestureDetector(
                                                      onTap: () => audioHandler
                                                          .seek(audioHandler
                                                                  .currentPos +
                                                              const Duration(
                                                                  seconds: 10)),
                                                      child: const Icon(Icons
                                                          .forward_10_sharp),
                                                    ),
                                                  ],
                                                )),
                                            Expanded(
                                                child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: LayoutBuilder(
                                                  builder: (ctx, constraints) {
                                                return StreamBuilder<
                                                    MediaState>(
                                                  stream: _mediaStateStream,
                                                  builder: (context, snapshot) {
                                                    final mediaState =
                                                        snapshot.data;
                                                    _commentObjectList
                                                        .time = mediaState
                                                            ?.position
                                                            .inMilliseconds ??
                                                        0;
                                                    return SeekBar(
                                                      duration: mediaState
                                                              ?.mediaItem
                                                              ?.duration ??
                                                          Duration.zero,
                                                      position: mediaState
                                                              ?.position ??
                                                          Duration.zero,
                                                      pWidth:
                                                          constraints.maxWidth,
                                                      onChangeEnd:
                                                          (newPosition) {
                                                        audioHandler
                                                            .seek(newPosition);
                                                      },
                                                    );
                                                  },
                                                );
                                              }),
                                            )),
                                            AnimatedSizeIcon(
                                                icon: Icons.more_horiz,
                                                size: 24,
                                                touchEvent: () {}),
                                          ],
                                        )),
                                  ],
                                )
                              ]));
                    })),
                  )
                ]),
              ),
            );
          } else {
            return Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: Colors.grey,
                ));
          }
        });
  }

  Widget _buildOverlayContainer(
      {required Size screenSize,
      required List<Widget> childlen,
      required WidgetRef ref}) {
    return AnimatedOpacity(
      opacity: ref.watch(playVideoParam.uiVisible) ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: Column(children: [
          Container(
            alignment: Alignment.topLeft,
            child: _playerController(
                child: childlen[0],
                ref: ref,
                screenSize: screenSize,
                width: screenSize.width * 0.15),
          ),
          const Expanded(child: SizedBox()),
          _playerController(
              child: childlen[1],
              ref: ref,
              screenSize: screenSize,
              width: screenSize.height),
        ]),
      ),
    );
  }

  Widget _playerController(
      {required Size screenSize,
      required Widget child,
      required WidgetRef ref,
      required double width}) {
    return Material(
      color: Colors.transparent,
      child: IgnorePointer(
        ignoring: ref.watch(playVideoParam.uiVisible),
        child: GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color.fromARGB(31, 37, 37, 37).withOpacity(0.9),
            ),
            width: width,
            height: screenSize.width * 0.123,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}
