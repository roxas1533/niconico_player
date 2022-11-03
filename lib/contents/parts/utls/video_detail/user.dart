import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/mylist/mylist_list.dart';
import 'package:niconico/contents/parts/user_nicorepo/user_nicorepo.dart';
import 'package:niconico/contents/parts/utls/video_detail/spliter.dart';
import 'package:niconico/contents/parts/utls/video_detail/video_colmun.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

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
                  onTap: (context) => {
                    pushNewScreen<dynamic>(
                      context,
                      screen: UserNicoRepo(userId: video.userInfo.id),
                    )
                  },
                ),
                VideoColmun(
                  text: "マイリスト",
                  onTap: (context) => {
                    pushNewScreen<dynamic>(
                      context,
                      screen: MylistList(userInfo: video.userInfo),
                    )
                  },
                ),
                VideoColmun(text: "投稿動画"),
                VideoColmun(text: "シリーズ"),
              ],
            ),
    ]);
  }
}
