import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niconico/contents/parts/utls/video_detail/video_detail.dart';
import 'package:niconico/contents/parts/utls/video_list_widget.dart';
import 'package:niconico/functions.dart';
import 'package:niconico/header_wrapper.dart';

import 'search_class.dart';
import 'search_header.dart';

abstract class SearchParam {
  static const sortKey = [
    {"key": "h", "order": "d", "display": "人気が高い順"},
    {"key": "f", "order": "d", "display": "投稿日時が新しい順"},
    {"key": "v", "order": "d", "display": "再生数が多い順"},
    {"key": "likeCount", "order": "d", "display": "いいね！数が多い順"},
    {"key": "m", "order": "d", "display": "マイリストが多い順"},
    {"key": "n", "order": "d", "display": "コメントが新しい順"},
    {"key": "n", "order": "a", "display": "コメントが古い順"},
    {"key": "v", "order": "a", "display": "再生数が少ない順"},
    {"key": "r", "order": "d", "display": "コメント数が多い順"},
    {"key": "r", "order": "a", "display": "コメント数が少ない順"},
    {"key": "likeCount", "order": "a", "display": "いいね！数が少ない順"},
    {"key": "f", "order": "a", "display": "投稿日時が古い順"},
    {"key": "l", "order": "d", "display": "再生時間が長い順"},
    {"key": "l", "order": "a", "display": "再生時間が短い順"},
  ];
  static const searchTypeStr = [
    "search",
    "tag",
  ];
  static final searchWord = StateProvider((ref) => "");
  static final sort = StateProvider((ref) => 0);
}

class Search extends ConsumerStatefulWidget {
  const Search({super.key});

  @override
  ConsumerState<Search> createState() => _SearchState();
}

class _SearchState extends ConsumerState<Search>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final SearchClass _searchClass;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchClass = SearchClass();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const Header(child: SearchHeader()),
        body: Column(
          children: [
            Container(
              color: Theme.of(context).backgroundColor,
              child: TabBar(
                tabs: const [
                  Tab(text: "キーワード"),
                  Tab(text: "タグ"),
                ],
                indicator: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor),
                controller: _tabController,
              ),
            ),
            Expanded(
                child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [0, 1].map((tab) {
                return Consumer(
                    builder: (context, ref, child) => FutureBuilder(
                        future: _searchClass.searchVideo(
                            ref.watch(SearchParam.searchWord),
                            tab,
                            1,
                            ref.watch(SearchParam.sort)),
                        builder: (BuildContext context,
                            AsyncSnapshot<bool> snapshot) {
                          if (snapshot.hasData) {
                            if (!snapshot.data!) {
                              return Container(
                                alignment: Alignment.center,
                                child: const Text('検索結果がありません'),
                              );
                            }
                            return _Result(
                                searchClass: _searchClass,
                                searchWord: ref.read(SearchParam.searchWord),
                                tab: tab);
                          } else {
                            return Container(
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(
                                  color: Colors.grey,
                                ));
                          }
                        }));
              }).toList(),
            )),
          ],
        ));
  }
}

class _Result extends StatefulWidget {
  const _Result(
      {required this.searchClass, required this.searchWord, required this.tab});
  final SearchClass searchClass;
  final String searchWord;
  final int tab;

  @override
  State<_Result> createState() => _ResultState();
}

class _ResultState extends State<_Result> {
  final ScrollController _scrollController = ScrollController();
  late SearchClass searchClass;
  @override
  void initState() {
    super.initState();
    searchClass = widget.searchClass;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter == 0) {
            searchClass.nextPage().then((value) {
              if (value) setState(() {});
            });
            return true;
          }
          return false;
        },
        child: Scrollbar(
            controller: _scrollController,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 5),
              itemCount: searchClass.videoInfoList.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VideoDetail(
                                  videoId: extractVideoId(searchClass
                                      .videoInfoList[index].videoId)!)));
                    },
                    child: VideoListWidget(
                      videoInfo: searchClass.videoInfoList[index],
                    ));
              },
            )));
  }
}
