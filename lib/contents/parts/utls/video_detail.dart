import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/icon_text_button.dart';
import 'package:niconico/contents/parts/utls/video_detail/counter.dart';
import 'package:niconico/contents/parts/utls/video_detail/description.dart';
import 'package:niconico/contents/parts/utls/video_detail/tag.dart';
import 'package:niconico/contents/parts/utls/video_detail/title.dart';
import 'package:niconico/contents/parts/utls/video_detail/user.dart';
import 'package:niconico/functions.dart';

class VideoDetail extends StatelessWidget {
  const VideoDetail({
    Key? key,
    required this.videoId,
  }) : super(key: key);
  final String videoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          leadingWidth: 80,
          automaticallyImplyLeading: false,
          leading: IconTextButton(
            text: const Text("戻る",
                style: TextStyle(color: Colors.blue, fontSize: 19)),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.blue,
            ),
            onPressed: () => Navigator.pop(context),
            margin: 0,
          ),
          title: const Text("動画詳細"),
        ),
        body: FutureBuilder(
          future: _getVideoDetail(),
          builder:
              (BuildContext context, AsyncSnapshot<VideoDetailInfo?> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              final video = snapshot.data!;
              return Scrollbar(
                  child: ListView(
                children: [
                  VideoDetailTitle(video: video),
                  VideoDetailCounter(video: video),
                  VideoDescription(video: video),
                  User(video: video),
                  Tag(video: video),
                ],
              ));
            } else {
              return Container(
                  alignment: Alignment.center,
                  child: const CupertinoActivityIndicator(
                    color: Colors.grey,
                  ));
            }
          },
        ));
  }

  String _actionTrackId() {
    const alphabetsList =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    const numList = "0123456789";
    final randomString = [
      for (int i = 0; i < 10; i++) alphabetsList[Random().nextInt(26 * 2)]
    ].join("");
    final randomInt =
        [for (int i = 0; i < 13; i++) numList[Random().nextInt(10)]].join("");
    return "${randomString}_$randomInt";
  }

  Future<VideoDetailInfo?> _getVideoDetail() async {
    const header = {"X-Frontend-Id": "6", "X-Frontend-Version": "0"};
    final actionTrackId = _actionTrackId();
    http.Response resp = await http.get(
        Uri.parse(
            'https://www.nicovideo.jp/api/watch/v3_guest/$videoId?actionTrackId=$actionTrackId'),
        headers: header);
    if (resp.statusCode == 200) {
      Map<String, dynamic> info = json.decode(resp.body);
      // debugPrint(info.toString());
      final video = info["data"]["video"];
      String userName;
      String userId;
      String userIconUrl;
      bool isChannel;

      if (info["data"]["channel"] != null) {
        final channel = info["data"]["channel"];
        userName = channel["name"];
        userId = channel["id"].toString();
        userIconUrl = channel["thumbnail"]["url"];
        isChannel = true;
      } else {
        final user = info["data"]["owner"];
        userName = user["nickname"];
        userId = user["id"].toString();
        userIconUrl = user["iconUrl"];
        isChannel = false;
      }

      final VideoDetailInfo videoDetailInfo = VideoDetailInfo(
        title: video["title"],
        thumbnailUrl:
            video["thumbnail"]["middleUrl"] ?? video["thumbnail"]["url"],
        videoId: video["id"],
        viewCount: numberFormat(video["count"]["view"]),
        commentCount: numberFormat(video["count"]["comment"]),
        mylistCount: numberFormat(video["count"]["mylist"]),
        goodCount: numberFormat(video["count"]["like"]),
        lengthVideo: VideoDetailInfo.secToTime(video["duration"]),
        lengthSeconds: video["duration"],
        postedAt: video["registeredAt"],
        description: video["description"],
        userName: userName,
        userThumailUrl: userIconUrl,
        userId: userId,
        isChannel: isChannel,
        tags: [
          for (var tag in info["data"]["tag"]["items"])
            TagInfo(
                name: tag["name"],
                isNicodicArticleExists: tag["isNicodicArticleExists"])
        ],
        session: info["data"]["media"]["delivery"]["movie"]["session"],
        nvComment: info["data"]["comment"]["nvComment"],
      );
      return videoDetailInfo;
    } else {
      debugPrint(resp.statusCode.toString());
    }
    return null;
  }
}
