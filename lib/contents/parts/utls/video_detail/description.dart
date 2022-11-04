import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/mylist/mylist.dart';
import 'package:niconico/contents/parts/series/series.dart';
import 'package:niconico/contents/parts/utls/video_detail/video_detail.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

class VideoDescription extends StatelessWidget {
  const VideoDescription({super.key, required this.video});
  final VideoDetailInfo video;

  @override
  Widget build(BuildContext context) {
    // final screenSize = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Html(
        data: video.description,
        onLinkTap: (url, rContext, attributes, element) {
          if (url != null) {
            final parsedUrl = Uri.parse(url);
            if (parsedUrl.host == "www.nicovideo.jp") {
              if (parsedUrl.pathSegments.length == 2) {
                switch (parsedUrl.pathSegments[0]) {
                  case "watch":
                    pushNewScreen<dynamic>(
                      context,
                      screen: VideoDetail(videoId: parsedUrl.pathSegments[1]),
                    );
                    break;
                  case "mylist":
                    pushNewScreen<dynamic>(context,
                        screen: Mylist(
                            mylistId: int.parse(parsedUrl.pathSegments[1])));
                    break;
                  case "series":
                    pushNewScreen<dynamic>(context,
                        screen: Series(
                            seriesId: int.parse(parsedUrl.pathSegments[1])));
                    break;
                }
              }
            }
          }
        },
      ),
    );
  }
}
