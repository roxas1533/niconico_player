import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import "package:niconico/constant.dart";
import 'package:niconico/contents/parts/utls/common.dart';
import 'package:niconico/functions.dart';

import '../utls/video_detail/video_detail.dart';

class NicorepoWidget extends StatelessWidget {
  const NicorepoWidget({
    super.key,
    required this.nicoRepoInfo,
  });
  final NicoRepoInfo nicoRepoInfo;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        Column(children: [
          Container(
              margin: const EdgeInsets.only(left: 5.0, top: 15),
              child: Row(children: [
                Image.network(
                  nicoRepoInfo.userInfo.icon,
                  alignment: Alignment.center,
                  width: screenSize.height * 0.045,
                  fit: BoxFit.fitWidth,
                ),
                const SpaceBox(width: 10),
                Expanded(
                    child: Column(
                  children: [
                    Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          nicoRepoInfo.userInfo.name,
                          style: const TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold),
                        )),
                    Html(data: nicoRepoInfo.title, style: {
                      "*": Style(
                        fontSize: const FontSize(12.0),
                      )
                    }),
                  ],
                )),
              ])),
          InkWell(
            onTap: nicoRepoInfo.objectType == "video"
                ? () => Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => VideoDetail(
                        videoId: extractVideoId(nicoRepoInfo.url)!)))
                : null,
            child: Container(
              margin: const EdgeInsets.only(left: 15.0),
              width: screenSize.width,
              height: screenSize.height * 0.10,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    nicoRepoInfo.objectType == "video"
                        ? const Icon(Icons.arrow_forward_ios,
                            size: 15.0, color: Colors.grey)
                        : Container(),
                    const SpaceBox(width: 10),
                  ]),
                  Row(
                    children: [
                      AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Image.network(
                            nicoRepoInfo.thumbnailUrl,
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                                    'assets/alternative_image/non-community.png'),
                          )),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        width: screenSize.width * 0.65,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: AutoSizeText(
                                  nicoRepoInfo.description,
                                  style: const TextStyle(fontSize: 12.0),
                                  minFontSize: 9,
                                  maxLines: 3,
                                ),
                              ),
                            ),
                            Container(
                                alignment: Alignment.bottomRight,
                                padding: const EdgeInsets.only(bottom: 3.0),
                                child: Text(
                                  getPostedAtTime(nicoRepoInfo.updated, true),
                                  style: const TextStyle(fontSize: 11.0),
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ]),
        const SpaceBox(height: 5)
      ],
    );
  }
}
