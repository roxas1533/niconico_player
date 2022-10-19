import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/video_detail/spliter.dart';
import 'package:niconico/contents/parts/utls/video_detail/video_colmun.dart';

class Tag extends StatelessWidget {
  const Tag({super.key, required this.video});
  final VideoDetailInfo video;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Spliter(
        text: "タグ",
      ),
      Column(
        children: [
          for (final tag in video.tags)
            VideoColmun(
              text: tag.name,
              icon: tag.isNicodicArticleExists
                  ? const Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.blue,
                    )
                  : const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
            ),
        ],
      ),
    ]);
  }
}
