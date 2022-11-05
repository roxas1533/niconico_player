import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/video_detail/spliter.dart';
import 'package:niconico/contents/parts/utls/video_detail/video_colmun.dart';
import 'package:niconico/contents/search/search_core.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

import '../icon_text_button.dart';

class Tag extends StatelessWidget {
  const Tag({super.key, required this.video});
  final VideoDetailInfo video;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Spliter(
        text: "タグ",
      ),
      Column(
        children: [
          for (final tag in video.tags)
            VideoColmun(
              text: tag.name,
              icon: tag.isNicodicArticleExists
                  ? const Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.blue,
                    )
                  : const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
              onTap: (context) => {
                pushNewScreen<dynamic>(
                  context,
                  screen: SearchForVideoDetail(
                    searchWord: tag.name,
                  ),
                )
              },
            ),
        ],
      ),
    ]);
  }
}

class SearchForVideoDetail extends StatefulWidget {
  const SearchForVideoDetail({super.key, required this.searchWord});
  final String searchWord;

  @override
  State<SearchForVideoDetail> createState() => _SearchForVideoDetailState();
}

class _SearchForVideoDetailState extends State<SearchForVideoDetail> {
  SortKey sort = SortKey.popular;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          leadingWidth: 80,
          automaticallyImplyLeading: false,
          leading: IconTextButton(
            text: const Text("戻る",
                style: TextStyle(color: Colors.blue, fontSize: 19)),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.blue,
            ),
            onPressed: () => Navigator.pop(context),
            margin: 0,
          ),
          title: Text(widget.searchWord),
          actions: [
            PopupMenuButton<int>(
                child: Container(
                    padding: const EdgeInsets.only(right: 10),
                    child: const Icon(Icons.sort, color: Colors.blue)),
                onSelected: (int item) {
                  setState(() {
                    sort = SortKey.values[item];
                  });
                },
                itemBuilder: (BuildContext context) =>
                    SortKey.values.asMap().entries.map((e) {
                      return PopupMenuItem<int>(
                        value: e.key,
                        child: Row(children: [
                          Expanded(child: Text(e.value.display)),
                          e.key == sort.index
                              ? const Icon(Icons.check, color: Colors.green)
                              : Container()
                        ]),
                      );
                    }).toList()),
          ],
        ),
        body: SearchCore(
          searchWord: widget.searchWord,
          sort: sort,
          isTag: true,
        ));
  }
}
