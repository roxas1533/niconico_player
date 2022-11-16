import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/video_detail/counter.dart';
import 'package:niconico/contents/parts/utls/video_detail/description.dart';
import 'package:niconico/contents/parts/utls/video_detail/series.dart';
import 'package:niconico/contents/parts/utls/video_detail/tag.dart';
import 'package:niconico/contents/parts/utls/video_detail/title.dart';
import 'package:niconico/contents/parts/utls/video_detail/user.dart';
import 'package:niconico/nico_api.dart';

import '../common.dart';

class VideoDetail extends StatelessWidget {
  const VideoDetail({
    super.key,
    required this.videoId,
  });
  final String videoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: topNaviBar("動画詳細"),
        body: FutureBuilder(
          future: getVideoDetail(videoId),
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
                  VideoDetailSeries(video: video),
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
}
