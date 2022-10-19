import 'package:flutter/material.dart';
import "package:niconico/constant.dart";
import 'package:niconico/contents/parts/ranking/ranking_number.dart';
import 'package:niconico/contents/parts/utls/space_box.dart';
import 'package:niconico/contents/parts/utls/thumnails.dart';
import 'package:niconico/contents/parts/utls/video_counter.dart';
import 'package:niconico/contents/parts/utls/video_title.dart';

class RainkingWidget extends StatelessWidget {
  const RainkingWidget({
    Key? key,
    required this.videoInfo,
    required this.rank,
  }) : super(key: key);
  final VideoInfo videoInfo;
  final int rank;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          // padding: const EdgeInsets.only(bottom: 5.0),
          margin: const EdgeInsets.only(left: 5.0),
          // width: screenSize.width * 0.6,
          height: screenSize.height * 0.10,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                RankingNumber(rank: rank),
                const Icon(Icons.arrow_forward_ios,
                    size: 15.0, color: Colors.grey),
                const SpaceBox(width: 10),
              ]),
              Row(
                children: [
                  Thumbnail(videoInfo: videoInfo),
                  VideoTitle(videoInfo: videoInfo),
                ],
              ),
            ],
          ),
        ),
        VideoCounter(videoInfo: videoInfo),
        const SpaceBox(height: 5)
      ],
    );
  }
}
