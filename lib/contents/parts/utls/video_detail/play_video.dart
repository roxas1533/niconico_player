import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/common.dart';
import 'package:niconico/contents/parts/utls/space_box.dart';
import 'package:niconico/contents/parts/utls/video_detail/play_video_paramater.dart';
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
  // VlcPlayerController? _videoViewController;
  bool sliderChanging = false;
  bool disposeed = false;
  int duration = 0;
  Future<String> _getVideoController() async {
    final res = await http.post(
        Uri.parse(widget.video.session["urls"][0]["url"] + "?_format=json"),
        body: json.encode(makeSessionPayloads(widget.video.session)),
        headers: {"Content-Type": "application/json"});
    Map<String, dynamic> videoData = json.decode(res.body);
    await audioHandler.playerInit(MediaItem(
      id: videoData["data"]["session"]["content_uri"],
      title: widget.video.title,
      artist: widget.video.userName,
      duration: Duration(seconds: widget.video.lengthSeconds),
      artUri: Uri.parse(widget.video.thumbnailUrl),
    ));

    // _videoViewController = VlcPlayerController.network(
    //   videoData["data"]["session"]["content_uri"],
    //   autoPlay: true,
    //   hwAcc: HwAcc.full,
    //   options: VlcPlayerOptions(
    //     video: VlcVideoOptions(["--no-drop-late-frames", "--no-skip-frames"]),
    //   ),
    // );
    // _videoViewController!.addListener(controllerLisner);
    // return _videoViewController!;
    return "temp";
  }

  // void controllerLisner() {
  //   if (_videoViewController!.value.isInitialized && !disposeed) {
  //     if (!sliderChanging) {
  //       _videoViewController!.getPosition().then((value) {
  //         duration = value.inSeconds;
  //       });
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.leanBack,
    );
    _futureVideoViewController = _getVideoController();
  }

  Map<String, dynamic> makeSessionPayloads(Map<String, dynamic> session) {
    final protocol = session["protocols"][0];
    final urls = session["urls"];
    bool isWellKnownPort = true;
    bool isSsl = true;
    for (final url in urls) {
      isWellKnownPort = url["isWellKnownPort"];
      isSsl = url["isSsl"];
      break;
    }
    final payloads = {};
    payloads["recipe_id"] = session["recipeId"];
    payloads["content_id"] = session["contentId"];
    payloads["content_type"] = "movie";
    payloads["content_src_id_sets"] = [
      {
        "content_src_ids": [
          {
            "src_id_to_mux": {
              "video_src_ids": session["videos"],
              "audio_src_ids": session["audios"]
            }
          },
        ]
      }
    ];
    payloads["timing_constraint"] = "unlimited";
    payloads["keep_method"] = {
      "heartbeat": {"lifetime": session["heartbeatLifetime"]}
    };
    payloads["protocol"] = {
      "name": protocol,
      "parameters": {
        "http_parameters": {
          "parameters": {
            "hls_parameters": {
              "use_well_known_port": tf2yn(isWellKnownPort),
              "use_ssl": tf2yn(isSsl),
              "transfer_preset": "",
              "segment_duration": 6000,
            }
          }
        }
      }
    };
    payloads["content_uri"] = "";
    payloads["session_operation_auth"] = {
      "session_operation_auth_by_signature": {
        "token": session["token"],
        "signature": session["signature"]
      }
    };
    payloads["content_auth"] = {
      "auth_type": session["authTypes"][protocol],
      "content_key_timeout": session["contentKeyTimeout"],
      "service_id": "nicovideo",
      "service_user_id": session["serviceUserId"]
    };
    payloads["client_info"] = {
      "player_id": session["playerId"],
    };
    payloads["priority"] = session["priority"];
    return {"session": payloads};
  }

  @override
  void dispose() async {
    disposeed = true;
    audioHandler.stop();
    super.dispose();
    // if (_videoViewController != null) {
    //   if (_videoViewController!.value.isInitialized) {
    //     await _videoViewController!.stopRendererScanning();
    //     await _videoViewController!.dispose();
    //   }
    // }
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
                  // Temp(),
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
                    child: audioHandler.getVlcPlayer(),
                    // VlcPlayer(
                    //   controller: _videoViewController!,
                    //   aspectRatio: 9 / 16,
                    //   placeholder:
                    //       const Center(child: CupertinoActivityIndicator()),
                    // ),
                  ),
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
                                    child: GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: const Icon(Icons.clear_rounded),
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
                                                    GestureDetector(
                                                      onTap: () {},
                                                      child: const Icon(Icons
                                                          .replay_10_sharp),
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
                                                            ? _button(
                                                                Icons.pause,
                                                                audioHandler
                                                                    .pause)
                                                            : _button(
                                                                Icons
                                                                    .play_arrow,
                                                                audioHandler
                                                                    .play);
                                                      },
                                                    ),
                                                    const SpaceBox(width: 20),
                                                    GestureDetector(
                                                      onTap: () {},
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
                                            GestureDetector(
                                              onTap: () {},
                                              child:
                                                  const Icon(Icons.more_horiz),
                                            ),
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

  String tf2yn(bool tf) {
    return tf ? "yes" : "no";
  }

  GestureDetector _button(IconData iconData, VoidCallback onPressed,
          {double size = 35}) =>
      GestureDetector(
        onTap: onPressed,
        child: Icon(iconData, size: size),
      );

  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
          audioHandler.mediaItem,
          AudioService.position,
          (mediaItem, position) => MediaState(mediaItem, position));

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
