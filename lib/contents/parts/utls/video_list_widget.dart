import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import "package:niconico/constant.dart";
import 'package:niconico/contents/parts/utls/common.dart';
import 'package:niconico/contents/parts/utls/thumnails.dart';
import 'package:niconico/contents/parts/utls/video_counter.dart';
import 'package:niconico/contents/parts/utls/video_title.dart';
import 'package:niconico/contents/ranking/ranking_number.dart';
import 'package:niconico/functions.dart';

import 'video_detail/video_detail.dart';

class VideoListWidget extends StatelessWidget {
  const VideoListWidget(
      {super.key,
      required this.videoInfo,
      this.rank,
      this.description,
      this.views});
  final VideoInfo videoInfo;
  final int? rank;
  final String? description;
  final int? views;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Column(children: [
      InkWell(
          onTap: () {
            Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) => VideoDetail(
                videoId: extractVideoId(videoInfo.videoId)!,
              ),
            ));
          },
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 5.0),
                    height: screenSize.height * 0.10,
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              rank != null
                                  ? RankingNumber(rank: rank!)
                                  : Container(),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 15.0, color: Colors.grey),
                              const SpaceBox(width: 10),
                            ]),
                        Row(
                          children: [
                            Thumbnail(videoInfo: videoInfo),
                            VideoTitle(videoInfo: videoInfo, views: views),
                          ],
                        ),
                      ],
                    ),
                  ),
                  VideoCounter(videoInfo: videoInfo),
                ],
              ))),
      description != null
          ? Container(
              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              decoration: BoxDecoration(
                color: CupertinoTheme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Html(data: description!))
          : Container(),
    ]);
  }
}
