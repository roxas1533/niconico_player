import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/series/series.dart';
import 'package:niconico/contents/parts/utls/common.dart';
import 'package:niconico/contents/parts/utls/video_detail/video_detail.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

import 'spliter.dart';

class VideoDetailSeries extends StatelessWidget {
  const VideoDetailSeries({super.key, required this.video});
  final VideoDetailInfo video;
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    if (video.series == null) {
      return Container();
    } else {
      final series = video.series!;
      return Column(children: [
        const Spliter(text: "シリーズ"),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(8),
          width: screenSize.width,
          child: Row(
            children: [
              Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    onTap: () => {
                      pushNewScreen<dynamic>(
                        context,
                        screen: Series(seriesId: series["id"]),
                      )
                    },
                    child: Text(
                      series["title"],
                      style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.lightBlue,
                          decoration: TextDecoration.underline),
                    ),
                  ))
            ],
          ),
        ),
        seriesVideoContainer(context, series["video"]["prev"], true),
        const SpaceBox(height: 8),
        seriesVideoContainer(context, series["video"]["next"], false),
        const SpaceBox(height: 8),
      ]);
    }
  }

  Widget seriesVideoContainer(
      BuildContext context, Map<String, dynamic>? seriesVideo, bool isPrev) {
    VideoInfo? video =
        seriesVideo != null ? VideoInfo.fromJson(seriesVideo) : null;
    String text = isPrev ? "前" : "次";
    Color color = video == null
        ? Theme.of(context).disabledColor
        : Theme.of(context).textTheme.bodyText1!.color!;
    return ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: Material(
            color: Theme.of(context).cardColor,
            child: InkWell(
                onTap: video != null
                    ? () {
                        pushNewScreen<dynamic>(context,
                            screen: VideoDetail(
                              videoId: video.videoId,
                            ));
                      }
                    : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.08,
                  child: Row(
                    children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(text,
                                style: TextStyle(fontSize: 14.0, color: color)),
                            Icon(isPrev ? Icons.arrow_left : Icons.arrow_right,
                                color: color)
                          ]),
                      const SpaceBox(width: 15),
                      Expanded(
                          child: video != null
                              ? Container(
                                  alignment: Alignment.center,
                                  child: Row(
                                    children: [
                                      Image.network(video.thumbnailUrl),
                                      const SpaceBox(width: 8),
                                      Flexible(
                                          child: Text(video.title,
                                              style: const TextStyle(
                                                  fontSize: 12.0)))
                                    ],
                                  ),
                                )
                              : Container(
                                  alignment: Alignment.center,
                                  child: Text("$textの動画がありません",
                                      style: const TextStyle(
                                          fontSize: 12.0, color: Colors.grey)),
                                ))
                    ],
                  ),
                ))));
  }
}
