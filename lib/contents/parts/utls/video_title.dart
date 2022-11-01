import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import "package:niconico/constant.dart";
import 'package:niconico/functions.dart';

class VideoTitle extends StatelessWidget {
  const VideoTitle({
    super.key,
    required this.videoInfo,
  });
  final VideoInfo videoInfo;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      width: screenSize.width * 0.54,
      child: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: AutoSizeText(
                videoInfo.title,
                style: const TextStyle(fontSize: 12.0),
                minFontSize: 9,
                maxLines: 3,
              ),
            ),
          ),
          Container(
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.only(bottom: 3.0),
              child: Text(
                getPostedAtTime(videoInfo.postedAt, true),
                style: const TextStyle(fontSize: 11.0),
              )),
        ],
      ),
    );
  }
}
