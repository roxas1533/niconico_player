import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/ranking/ranking_body_wrapper.dart';
import 'package:niconico/header_wrapper.dart';
import 'package:niconico/nico_api.dart';

import 'ranking_header.dart';

class RankingParam {
  static const termKey = {
    "hour": "毎時",
    "24h": "24時間",
    "week": "週間(すべてのみ)",
    "month": "月間(すべてのみ)",
    "total": "全期間(すべてのみ)"
  };
  static final tag = StateProvider((ref) => "すべて");
  static final term = StateProvider((ref) => "24h");
  static var genreId = StateProvider((ref) => GenreKey.all);
  static final popularTagFuture =
      FutureProvider((ref) => getPopulerTag(ref.watch(genreId).key));
  static final rankingFuture = FutureProvider.family<List<VideoInfo>, String>(
      (ref, tag) => getRanking(tag, ref.watch(term), ref.watch(genreId).key));
}

class Ranking extends ConsumerStatefulWidget {
  const Ranking({super.key, required this.savedGenreId});
  final int savedGenreId;
  @override
  RankingState createState() => RankingState();
}

class RankingState extends ConsumerState<Ranking>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    RankingParam.genreId =
        StateProvider((ref) => GenreKey.values[widget.savedGenreId]);
  }

  @override
  Widget build(BuildContext context) {
    final getPopularTag = ref.watch(RankingParam.popularTagFuture);
    return Scaffold(
      appBar: const Header(child: RankingHeader()),
      body: getPopularTag.when(
          loading: () => Container(
              alignment: Alignment.center,
              child: const CupertinoActivityIndicator(
                color: Colors.grey,
              )),
          error: (err, stack) => Text('Error: $err'),
          data: (snapshot) {
            return RankigBodyWrapper(tagList: snapshot);
          }),
    );
  }
}
