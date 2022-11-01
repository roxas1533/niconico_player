import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/ranking/ranking_body.dart';
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
  static final genreId = StateProvider((ref) => 0);
}

class Ranking extends ConsumerStatefulWidget {
  const Ranking({super.key});

  @override
  RankingState createState() => RankingState();
}

class RankingState extends ConsumerState<Ranking>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  final genreIdList = genreMap.entries.map((e) => e.key).toList();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final genreId = ref.watch(RankingParam.genreId);
    return Scaffold(
        appBar: const Header(
          child: RankingHeader(),
        ),
        body: Ink(
          color: Colors.transparent,
          height: screenSize.height,
          child: FutureBuilder(
              future: getPopulerTag(genreIdList[genreId]),
              builder:
                  (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.hasData) {
                  final tabController =
                      TabController(length: snapshot.data!.length, vsync: this);
                  tabController.addListener(() {
                    final tag = snapshot.data![tabController.index];
                    ref.read(RankingParam.tag.notifier).state = tag;
                    if (tag != "すべて" &&
                        !["hour", "24h"]
                            .contains(ref.read(RankingParam.term))) {
                      ref.read(RankingParam.term.notifier).state = "24h";
                    }
                  });
                  return Column(
                    children: [
                      TabBar(
                        controller: tabController,
                        isScrollable: true,
                        indicatorColor: Colors.blue,
                        tabs: [
                          for (final d in snapshot.data!)
                            Container(
                                alignment: Alignment.center,
                                // height: screenSize.height * 0.085,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: Text(d,
                                    style: const TextStyle(fontSize: 14)))
                        ],
                      ),
                      Expanded(
                          child: TabBarView(
                              controller: tabController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                            for (final tag in snapshot.data!)
                              RainkingPage(
                                genreId: genreIdList[genreId],
                                tag: tag,
                              )
                          ]))
                    ],
                  );
                } else {
                  return Container(
                      alignment: Alignment.center,
                      child: const CupertinoActivityIndicator(
                        color: Colors.grey,
                      ));
                }
              }),
        ));
  }
}
