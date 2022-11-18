import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/header_wrapper.dart';

import 'history/like_history.dart';
import 'history/watch_hisory.dart';
import 'parts/utls/common.dart';

class History extends StatefulWidget {
  const History({super.key});
  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this);
  @override
  Widget build(BuildContext context) {
    return nicoSession.cookies.isEmpty
        ? const Center(
            child: AutoSizeText(
            "ログインしてください",
            maxLines: 1,
            maxFontSize: 25,
          ))
        : Scaffold(
            appBar: Header(child: topNaviBar("履歴")),
            body: Column(
              children: [
                Container(
                  color: Theme.of(context).dividerColor,
                  child: TabBar(
                    tabs: const [
                      Tab(text: "視聴"),
                      Tab(text: "いいね！"),
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
                  children: const [VideoHistoryPage(), LikeHistoryPage()],
                ))
              ],
            ));
  }
}
