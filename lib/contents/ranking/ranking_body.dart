import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niconico/contents/parts/utls/common.dart';
import 'package:niconico/contents/ranking/ranking.dart';

import '../parts/utls/video_list_widget.dart';

class RainkingPage extends ConsumerStatefulWidget {
  const RainkingPage({
    super.key,
    required this.tag,
  });
  final String tag;

  @override
  ConsumerState<RainkingPage> createState() => RainkingPageState();
}

class RainkingPageState extends ConsumerState<RainkingPage> {
  // late Future<List<VideoInfo>> rankingFuture;
  @override
  void initState() {
    super.initState();
    // rankingFuture = getRanking(widget.tag, widget.term, widget.genre);
  }

  @override
  Widget build(BuildContext context) {
    final rankingFuture = ref.watch(RankingParam.rankingFuture(widget.tag));

    return rankingFuture.when(
        loading: () => Container(
            alignment: Alignment.center,
            child: const CupertinoActivityIndicator(
              color: Colors.grey,
            )),
        error: (err, stack) => Text('Error: $err'),
        data: (snapshot) {
          return CustomListView(
            itemCount: snapshot.length,
            itemBuilder: (BuildContext context, int index) {
              return VideoListWidget(
                videoInfo: snapshot[index],
                rank: index + 1,
              );
            },
            onRefresh: () async {
              ref.refresh(RankingParam.rankingFuture(widget.tag));
            },
          );
        });
  }
}
