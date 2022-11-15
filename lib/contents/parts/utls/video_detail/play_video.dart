import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/video_detail/comment_player/comment.dart';
import 'package:niconico/functions.dart';
import 'package:rxdart/rxdart.dart';

import 'comment_player/comment_player.dart';
import 'video_player/controller.dart';

class PlayVideo extends StatefulWidget {
  const PlayVideo({super.key, required this.video});

  final VideoDetailInfo video;
  @override
  PlayVideoState createState() => PlayVideoState();
}

class PlayVideoState extends State<PlayVideo> {
  bool hasListener = false;
  late Future _futureVideoViewController;
  late CommentObjectList _commentObjectList;
  bool sliderChanging = false;
  final jsonHeader = {"Content-Type": "application/json"};
  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
          audioHandler.mediaItem,
          // audioHandler.currentPosSubs,
          AudioService.position,
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
          artist: widget.video.userInfo.name,
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
      SystemUiMode.immersive,
    );
    _futureVideoViewController = _getVideoController();
  }

  @override
  void dispose() async {
    audioHandler.stop();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.height;
    final height = screenSize.width;
    return Container(
      color: Colors.black,
      width: width,
      height: height,
      child: RotatedBox(
        quarterTurns: 1, //or 2
        child: Stack(alignment: Alignment.center, children: [
          FutureBuilder(
              future: _futureVideoViewController,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Stack(alignment: Alignment.center, children: [
                    StreamBuilder<MediaState>(
                        stream: _mediaStateStream,
                        builder: (__, _) {
                          return SizedBox(
                            width: height < width ? null : width,
                            height: height < width ? height : null,
                            child: audioHandler.getPlayer(),
                          );
                        }),
                    SizedBox(
                        width: width,
                        height: height,
                        child: CommentPlayer(
                          screenSize: screenSize,
                          commentObjectList: _commentObjectList,
                        )),
                  ]);
                } else {
                  return Container(
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: Colors.grey,
                      ));
                }
              }),
          SizedBox(
            width: width,
            height: height,
            child: Controller(
                mediaStateStream: _mediaStateStream, screenSize: screenSize),
          )
        ]),
      ),
    );
  }
}
