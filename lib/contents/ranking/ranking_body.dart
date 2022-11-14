import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/nico_api.dart';

import '../parts/utls/video_list_widget.dart';
import 'ranking.dart';

class RainkingPage extends ConsumerWidget {
  RainkingPage({
    super.key,
    required this.genre,
    required this.tag,
  });
  final String tag;
  final String genre;
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
        future: getRanking(tag, ref.watch(RankingParam.term), genre),
        builder:
            (BuildContext context, AsyncSnapshot<List<VideoInfo>> snapshot) {
          if (snapshot.hasData) {
            return Scrollbar(
                child: ListView.separated(
              controller: PrimaryScrollController.of(context),
              primary: false,
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 5),
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return VideoListWidget(
                  videoInfo: snapshot.data![index],
                  rank: index + 1,
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(
                height: 1,
                thickness: 1,
              ),
            ));
          } else {
            return Container(
                alignment: Alignment.center,
                child: const CupertinoActivityIndicator(
                  color: Colors.grey,
                ));
          }
        });
  }
}
