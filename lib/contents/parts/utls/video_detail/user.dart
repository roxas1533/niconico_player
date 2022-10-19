import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/video_detail/spliter.dart';
import 'package:niconico/contents/parts/utls/video_detail/video_colmun.dart';

class User extends StatelessWidget {
  const User({super.key, required this.video});
  final VideoDetailInfo video;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Column(children: [
      Spliter(text: video.isChannel ? "チャンネル" : "ユーザー"),
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(8),
        width: screenSize.width,
        child: Row(
          children: [
            Image.network(video.userThumailUrl, width: 50, height: 50),
            Container(
              padding: const EdgeInsets.only(left: 10),
              child:
                  Text(video.userName, style: const TextStyle(fontSize: 14.0)),
            )
          ],
        ),
      ),
      video.isChannel
          ? Container()
          : Column(
              children: const [
                VideoColmun(text: "ニコレポ"),
                VideoColmun(text: "マイリスト"),
                VideoColmun(text: "投稿動画"),
                VideoColmun(text: "シリーズ"),
              ],
            ),
    ]);
  }
}
