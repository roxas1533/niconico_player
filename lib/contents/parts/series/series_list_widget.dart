import 'package:flutter/material.dart';
import "package:niconico/constant.dart";
import 'package:niconico/contents/parts/series/series.dart';
import 'package:niconico/contents/parts/utls/common.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

class SeriesListWidget extends StatelessWidget {
  const SeriesListWidget({
    super.key,
    required this.seriesInfto,
  });
  final SeriesInfo seriesInfto;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return InkWell(
      onTap: () => {
        pushNewScreen<dynamic>(
          context,
          screen: Series(seriesId: seriesInfto.id),
        )
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        width: screenSize.width,
        height: screenSize.height * 0.08,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: const [
              Icon(Icons.arrow_forward_ios, size: 15.0, color: Colors.grey),
              SpaceBox(width: 10),
            ]),
            Row(
              children: [
                AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: SizedBox(
                            width: screenSize.height * 0.1477,
                            child: Stack(
                                alignment: AlignmentDirectional.centerEnd,
                                children: [
                                  Image.network(
                                    seriesInfto.thumbnailUrl,
                                    alignment: Alignment.center,
                                    width: screenSize.height * 0.1477,
                                    fit: BoxFit.fitWidth,
                                  ),
                                  Opacity(
                                      opacity: 0.9,
                                      child: Container(
                                          alignment: Alignment.center,
                                          color: Colors.black,
                                          width: screenSize.height * 0.1477 / 3,
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                    "${seriesInfto.itemsCount} 件",
                                                    style: const TextStyle(
                                                        fontSize: 10)),
                                                const Icon(Icons.video_library,
                                                    size: 15.0),
                                              ]))),
                                ])))),
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: screenSize.width * 0.85,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(seriesInfto.title,
                            style: const TextStyle(fontSize: 14.0),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                          alignment: Alignment.centerLeft,
                          child: Text(seriesInfto.description,
                              style: const TextStyle(
                                  fontSize: 11.0, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}