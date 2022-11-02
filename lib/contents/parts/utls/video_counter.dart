import 'package:flutter/material.dart';
import "package:niconico/constant.dart";
import 'package:niconico/contents/parts/utls/parts_icon.dart';
import 'package:niconico/functions.dart';

import 'common.dart';

class VideoCounter extends StatelessWidget {
  const VideoCounter({
    super.key,
    required this.videoInfo,
  });
  final VideoInfo videoInfo;

  @override
  Widget build(BuildContext context) {
    // final screenSize = MediaQuery.of(context).size;
    const iconSize = 11.0;
    const spaceWidth = 3.0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              const PartIcon(icon: Icons.play_circle_fill_sharp),
              const SpaceBox(width: spaceWidth),
              Text(numberFormat(videoInfo.viewCount),
                  style: const TextStyle(fontSize: iconSize)),
            ],
          ),
          Row(
            children: [
              const PartIcon(icon: Icons.chat),
              const SpaceBox(width: spaceWidth),
              Text(numberFormat(videoInfo.commentCount),
                  style: const TextStyle(fontSize: iconSize)),
            ],
          ),
          Row(
            children: [
              const PartIcon(icon: Icons.folder),
              const SpaceBox(width: spaceWidth),
              Text(numberFormat(videoInfo.mylistCount),
                  style: const TextStyle(fontSize: iconSize)),
            ],
          ),
          Row(
            children: [
              const PartIcon(icon: Icons.favorite),
              const SpaceBox(width: spaceWidth),
              Text(numberFormat(videoInfo.goodCount),
                  style: const TextStyle(fontSize: iconSize)),
            ],
          ),
        ],
      ),
    );
  }
}
