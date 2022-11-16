import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:niconico/constant.dart";
import 'package:niconico/contents/parts/series/series.dart';
import 'package:niconico/contents/parts/utls/common.dart';

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
      onTap: () => Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => Series(seriesId: seriesInfto.id))),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        width: screenSize.width,
        height: screenSize.height * 0.1,
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
                            height: screenSize.height * 0.1,
                            child: Stack(
                                alignment: AlignmentDirectional.centerStart,
                                children: [
                                  Image.network(
                                    seriesInfto.thumbnailUrl,
                                    alignment: Alignment.centerLeft,
                                    height: screenSize.height * 0.1,
                                    fit: BoxFit.fitWidth,
                                  ),
                                  Row(children: [
                                    Expanded(
                                      child: Container(),
                                    ),
                                    Opacity(
                                        opacity: 0.8,
                                        child: Container(
                                            alignment: Alignment.center,
                                            color: Colors.black,
                                            width: screenSize.height *
                                                0.1477 *
                                                0.4,
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                      "${seriesInfto.itemsCount} 件",
                                                      style: const TextStyle(
                                                          fontSize: 10)),
                                                  const Icon(
                                                      Icons.video_library,
                                                      size: 15.0),
                                                ])))
                                  ]),
                                ])))),
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(seriesInfto.title,
                            style: const TextStyle(fontSize: 14.0),
                            maxLines: 2,
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
