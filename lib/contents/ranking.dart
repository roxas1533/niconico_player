import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/ranking/ranking_page.dart';

class Ranking extends ConsumerStatefulWidget {
  const Ranking({Key? key}) : super(key: key);

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
    return Ink(
      color: Colors.transparent,
      height: screenSize.height,
      child: FutureBuilder(
          future: _getPopulerTag(genreIdList[genreId]),
          builder:
              (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            if (snapshot.hasData) {
              final tabController =
                  TabController(length: snapshot.data!.length, vsync: this);
              tabController.addListener(() {
                final tag = snapshot.data![tabController.index];
                ref.read(RankingParam.tag.notifier).state = tag;
                if (tag != "すべて" &&
                    !["hour", "24h"].contains(ref.read(RankingParam.term))) {
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
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child:
                                Text(d, style: const TextStyle(fontSize: 14)))
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
    );
  }

  Future<List<String>> _getPopulerTag(String tag) async {
    List<String> tagList = [];
    //TODO: キャッシュ対応
    http.Response resp = await http.get(Uri.parse(
        'https://www.nicovideo.jp/ranking/genre/$tag?video_ranking_menu'));
    if (resp.statusCode == 200) {
      var document = parse(resp.body);
      final tagListFromHTML =
          document.getElementsByClassName("RepresentedTagsContainer");
      if (tagListFromHTML.isNotEmpty) {
        final tagListElement = tagListFromHTML[0].getElementsByTagName("li");
        for (var element in tagListElement) {
          tagList.add(element.text.trim());
        }
      } else {
        tagList.add("すべて");
      }
    }
    return tagList;
  }
}
