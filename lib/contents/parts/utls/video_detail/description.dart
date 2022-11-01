import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/video_detail/video_detail.dart';
import 'package:niconico/functions.dart';

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
              final videoId = parsedUrl.pathSegments.last;
              final id = extractVideoId(videoId);
              if (id != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VideoDetail(videoId: id)));
              }
            }
          }
        },
      ),
    );
  }
}
