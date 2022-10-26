import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/video_detail/play_video.dart';

class VideoDetailTitle extends StatelessWidget {
  const VideoDetailTitle({super.key, required this.video});
  final VideoDetailInfo video;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // Workmanager().registerPeriodicTask(
    //   simplePeriodicTask,
    //   simplePeriodicTask,
    //   initialDelay: Duration(seconds: 10),
    //   frequency: Duration(seconds: 10),
    // );
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WillPopScope(
                      //こちらを追加
                      onWillPop: () async => true,
                      child: PlayVideo(video: video))));
        },
        child: Container(
          margin: const EdgeInsets.all(8.0),
          width: screenSize.width,
          height: screenSize.height * 0.19 * (3 / 4),
          child: Row(
            children: [
              Container(
                  color: Colors.black,
                  width: screenSize.height * 0.19,
                  height: screenSize.height * 0.19 * (3 / 4),
                  child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.network(
                        video.thumbnailUrl,
                        alignment: Alignment.center,
                        width: screenSize.height * 0.19,
                        fit: BoxFit.fitWidth,
                      ))),
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(top: 3, right: 3),
                              child: AutoSizeText(
                                video.title,
                                style: const TextStyle(fontSize: 14.0),
                                minFontSize: 9,
                                maxLines: 3,
                              ),
                            ),
                          ),
                          Container(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                video.lengthVideo,
                                style: const TextStyle(fontSize: 12.0),
                              )),
                          Container(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                "${video.getPostedAtTime()} に投稿",
                                style: const TextStyle(fontSize: 12.0),
                              )),
                        ],
                      ))),
              // VideoTitle(videoInfo: videoInfo),
            ],
          ),
        ));
  }
}
