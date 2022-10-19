import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/space_box.dart';
import 'package:niconico/contents/parts/utls/video_detail/play_video_paramater.dart';

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
  late VlcPlayerController _videoViewController;
  bool sliderChanging = false;
  bool disposeed = false;
  int duration = 0;
  Future<VlcPlayerController> _getVideoController() async {
    final res = await http.post(
        Uri.parse(widget.video.session["urls"][0]["url"] + "?_format=json"),
        body: json.encode(makeSessionPayloads(widget.video.session)),
        headers: {"Content-Type": "application/json"});
    Map<String, dynamic> videoData = json.decode(res.body);

    _videoViewController = VlcPlayerController.network(
      videoData["data"]["session"]["content_uri"],
      autoPlay: true,
      hwAcc: HwAcc.full,
      options: VlcPlayerOptions(
        video: VlcVideoOptions(["--no-drop-late-frames", "--no-skip-frames"]),
      ),
    );
    _videoViewController.addListener(controllerLisner);
    return _videoViewController;
    // return "temp";
  }

  void controllerLisner() {
    if (_videoViewController.value.isInitialized && !disposeed) {
      if (!sliderChanging) {
        _videoViewController.getPosition().then((value) {
          duration = value.inSeconds;
        });
      }
    }
  }

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
    super.dispose();

    if (_videoViewController.value.isInitialized) {
      await _videoViewController.stopRendererScanning();
      await _videoViewController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return FutureBuilder(
        future: _futureVideoViewController,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Stack(alignment: Alignment.center, children: [
              // Temp(),
              // Container(
              //   width: screenSize.width,
              //   height: screenSize.width * 9 / 16,
              //   color: Colors.red,
              // ),
              SizedBox(
                  width: screenSize.width,
                  height: screenSize.height,
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: VlcPlayer(
                      controller: _videoViewController,
                      aspectRatio: 9 / 16,
                      placeholder:
                          const Center(child: CupertinoActivityIndicator()),
                    ),
                  )),

              Consumer(builder: ((context, ref, child) {
                // ignore: invalid_use_of_protected_member
                // if (!hasListener) {

                //   hasListener = true;
                // }
                return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      ref.read(playVideoParam.uiVisible.notifier).state =
                          !ref.read(playVideoParam.uiVisible);
                    },
                    child: _buildOverlayContainer(
                        screenSize: screenSize,
                        ref: ref,
                        child: Column(
                          children: [
                            Container(
                                padding: const EdgeInsets.only(
                                    top: 15, left: 15, right: 10),
                                child: Column(
                                  children: [
                                    SliderTheme(
                                        data: SliderThemeData(
                                            thumbColor: Colors.blue,
                                            activeTrackColor: Colors.blue,
                                            overlayShape:
                                                SliderComponentShape.noOverlay,
                                            thumbShape:
                                                const RoundSliderThumbShape(
                                                    enabledThumbRadius: 5)),
                                        child: Slider(
                                            value: duration.toDouble(),
                                            min: 0,
                                            max: widget.video.lengthSeconds
                                                .toDouble(),
                                            onChangeStart: (value) =>
                                                sliderChanging = true,
                                            onChanged: (double newValue) {
                                              setState(() {
                                                duration = newValue.toInt();
                                              });
                                            },
                                            onChangeEnd: (double newValue) {
                                              sliderChanging = false;
                                              _videoViewController
                                                  .seekTo(Duration(
                                                seconds: newValue.toInt(),
                                              ));
                                            })),
                                    const SpaceBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          VideoDetailInfo.secToTime(duration),
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          VideoDetailInfo.secToTime(
                                              widget.video.lengthSeconds),
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const IconButton(
                                  onPressed: null,
                                  disabledColor: Colors.transparent,
                                  icon: Icon(Icons.more_horiz),
                                ),
                                Expanded(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.replay),
                                    ),
                                    IconButton(
                                      onPressed: () => _playOrPauseVideo(
                                          _videoViewController, ref),
                                      iconSize: 35,
                                      icon: Icon(
                                          ref.watch(playVideoParam.isPlay)
                                              ? Icons.pause
                                              : Icons.play_arrow),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Transform(
                                          transform: Matrix4.rotationY(3.1415),
                                          alignment: Alignment.center,
                                          child: const Icon(Icons.replay)),
                                    ),
                                  ],
                                )),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.more_horiz),
                                ),
                              ],
                            ),
                          ],
                        )));
              })),
            ]);
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

  void _playOrPauseVideo(VlcPlayerController controller, WidgetRef ref) async {
    if ((await controller.isPlaying())!) {
      controller.pause();
      debugPrint(controller.value.bufferPercent.toString());
      ref.read(playVideoParam.isPlay.notifier).state = false;
    } else {
      controller.play();
      ref.read(playVideoParam.isPlay.notifier).state = true;
    }
  }

  Widget _buildOverlayContainer(
      {required Size screenSize,
      required Widget child,
      required WidgetRef ref}) {
    return AnimatedOpacity(
      opacity: ref.watch(playVideoParam.uiVisible) ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: Container(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: IgnorePointer(
              ignoring: ref.watch(playVideoParam.uiVisible),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color:
                        const Color.fromARGB(31, 66, 66, 66).withOpacity(0.5),
                  ),
                  width: screenSize.width * 0.9,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: child),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
