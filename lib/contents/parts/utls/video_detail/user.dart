import 'package:flutter/cupertino.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/all_video_list/all_video_list.dart';
import 'package:niconico/contents/parts/mylist/mylist_list.dart';
import 'package:niconico/contents/parts/nicorepo/user_nicorepo.dart';
import 'package:niconico/contents/parts/series/series_list.dart';
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
            Image.network(video.userInfo.icon, width: 50, height: 50),
            Container(
              padding: const EdgeInsets.only(left: 10),
              child: Text(video.userInfo.name,
                  style: const TextStyle(fontSize: 14.0)),
            )
          ],
        ),
      ),
      video.isChannel
          ? Container()
          : Column(
              children: [
                VideoColmun(
                  text: "ニコレポ",
                  onTap: (context) => Navigator.of(context).push(
                      CupertinoPageRoute(
                          builder: (context) =>
                              NicorepoPage(userId: video.userInfo.id))),
                ),
                VideoColmun(
                  text: "マイリスト",
                  onTap: (context) => Navigator.of(context).push(
                      CupertinoPageRoute(
                          builder: (context) =>
                              MylistList(userInfo: video.userInfo))),
                ),
                VideoColmun(
                    text: "投稿動画",
                    onTap: (context) => CupertinoPageRoute(
                        builder: (context) =>
                            AllVideoList(userInfo: video.userInfo))),
                VideoColmun(
                  text: "シリーズ",
                  onTap: (context) => CupertinoPageRoute(
                      builder: (context) =>
                          SeriesList(userInfo: video.userInfo)),
                ),
              ],
            ),
    ]);
  }
}
