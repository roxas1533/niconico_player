import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/common.dart';
import 'package:niconico/contents/parts/utls/video_list_widget.dart';

import 'search_class.dart';

class SearchCore extends ConsumerStatefulWidget {
  const SearchCore(
      {super.key,
      required this.searchWord,
      required this.sort,
      this.isTag = false});
  final String searchWord;
  final SortKey sort;
  final bool isTag;

  @override
  ConsumerState<SearchCore> createState() => _SearchState();
}

class _SearchState extends ConsumerState<SearchCore>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this, initialIndex: widget.isTag ? 1 : 0);
  final SearchClass _searchClass = SearchClass();

  @override
  void initState() {
    super.initState();
    // _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          color: Theme.of(context).backgroundColor,
          height: screenSize.height * 0.035,
          child: TabBar(
            tabs: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.key),
                  SpaceBox(width: 5),
                  Text('キーワード'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.more, size: 20),
                  SpaceBox(width: 5),
                  Text('タグ'),
                ],
              ),
            ],
            indicator:
                BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
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
                    future: _searchClass.searchVideo(widget.searchWord,
                        SearchType.values[tab], 1, widget.sort),
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      if (snapshot.hasData) {
                        if (!snapshot.data!) {
                          return Container(
                            alignment: Alignment.center,
                            child: const Text('検索結果がありません'),
                          );
                        }
                        return _Result(
                            searchClass: _searchClass,
                            searchWord: widget.searchWord,
                            tab: tab);
                      } else {
                        return Container(
                            alignment: Alignment.center,
                            child: const CupertinoActivityIndicator(
                              color: Colors.grey,
                            ));
                      }
                    }));
          }).toList(),
        )),
      ],
    );
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
            controller: PrimaryScrollController.of(context),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 5),
              itemCount: searchClass.videoInfoList.length,
              itemBuilder: (BuildContext context, int index) {
                return VideoListWidget(
                  videoInfo: searchClass.videoInfoList[index],
                );
              },
            )));
  }
}
