import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/video_detail/video_detail.dart';
import 'package:niconico/functions.dart';
import 'package:niconico/nico_api.dart';

import '../parts/utls/video_list_widget.dart';
import 'ranking.dart';

class RainkingPage extends ConsumerWidget {
  RainkingPage({
    super.key,
    required this.genreId,
    required this.tag,
  });
  final String tag;
  final String genreId;
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
        future: getRanking(tag, ref.watch(RankingParam.term), genreId),
        builder:
            (BuildContext context, AsyncSnapshot<List<VideoInfo>> snapshot) {
          if (snapshot.hasData) {
            return Scrollbar(
                child: ListView.builder(
              controller: _scrollController,
              primary: false,
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 5),
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VideoDetail(
                                  videoId: extractVideoId(
                                      snapshot.data![index].videoId)!)));
                    },
                    child: VideoListWidget(
                      videoInfo: snapshot.data![index],
                      rank: index + 1,
                    ));
              },
            ));
          } else {
            return Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: Colors.grey,
                ));
          }
        });
  }
}
