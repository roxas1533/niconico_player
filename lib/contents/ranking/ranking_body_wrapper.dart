import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niconico/constant.dart';

import 'ranking.dart';
import 'ranking_body.dart';

class RankigBodyWrapper extends ConsumerStatefulWidget {
  const RankigBodyWrapper(
      {super.key, required this.tagList, required this.genreId});
  final List<String> tagList;
  final GenreKey genreId;
  @override
  ConsumerState<RankigBodyWrapper> createState() => _RankigBodyWrapperState();
}

class _RankigBodyWrapperState extends ConsumerState<RankigBodyWrapper>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(
      length: widget.tagList.length,
      vsync: this,
    );
    tabController.addListener(() {
      final tag = widget.tagList[tabController.index];
      ref.watch(RankingParam.tag.notifier).state = tag;
      if (tag != "すべて" &&
          !["hour", "24h"].contains(ref.read(RankingParam.term))) {
        ref.watch(RankingParam.term.notifier).state = "24h";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          isScrollable: true,
          indicatorColor: Colors.blue,
          tabs: [
            for (final d in widget.tagList)
              Container(
                  alignment: Alignment.center,
                  // height: screenSize.height * 0.085,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(d, style: const TextStyle(fontSize: 14)))
          ],
        ),
        Expanded(
            child: TabBarView(
                controller: tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
              for (final tag in widget.tagList)
                RainkingPage(
                  genre: widget.genreId.key,
                  tag: tag,
                )
            ]))
      ],
    );
  }
}
