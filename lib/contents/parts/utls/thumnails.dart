import 'package:flutter/material.dart';
import "package:niconico/constant.dart";

class Thumbnail extends StatelessWidget {
  const Thumbnail({
    super.key,
    required this.videoInfo,
  });
  final VideoInfo videoInfo;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.height * 0.1777,
      // height: screenSize.width * 0.19125,
      child: Stack(
        children: [
          Image.network(videoInfo.thumbnailUrl,
              alignment: Alignment.center,
              width: screenSize.height * 0.1777,
              fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
            final thum = videoInfo.getNextThumbnailUrl();
            return Image.network(
              width: screenSize.height * 0.1777,
              fit: BoxFit.cover,
              thum,
            );
          }),
          Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.only(bottom: 3.0),
            child: Container(
                color: Colors.black.withOpacity(0.7),
                margin: const EdgeInsets.all(3.0),
                padding: const EdgeInsets.all(1.5),
                child: Text(videoInfo.lengthVideo,
                    style:
                        const TextStyle(fontSize: 11.0, color: Colors.white))),
          )
        ],
      ),
    );
  }
}
