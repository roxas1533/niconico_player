import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/common.dart';
import 'package:niconico/contents/parts/utls/video_detail/spliter.dart';
import 'package:niconico/contents/parts/utls/video_detail/video_colmun.dart';
import 'package:niconico/contents/search/search_core.dart';

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
              onTap: (context) => Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) =>
                      SearchForVideoDetail(searchWord: tag.name))),
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
        appBar: topNaviBar(
          widget.searchWord,
          trailing: CupertinoButton(
              onPressed: () => showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return FractionallySizedBox(
                        heightFactor: 0.8,
                        child: Scaffold(
                          appBar: topNaviBar(
                            "絞り込み",
                            leading: TextButton(
                              child: const Text(
                                'キャンセル',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          body: Scrollbar(
                              child: ListView.separated(
                            itemBuilder: (BuildContext context, int index) =>
                                ListTile(
                                    trailing: Visibility(
                                        visible: sort.index == index,
                                        child: const Icon(Icons.check,
                                            color: Colors.green)),
                                    onTap: () => {
                                          setState(() {
                                            sort = SortKey.values[index];
                                          }),
                                          Navigator.of(context).pop()
                                        },
                                    title: Text(
                                      SortKey.values[index].display,
                                      style: const TextStyle(fontSize: 18),
                                    )),
                            itemCount: SortKey.values.length,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(height: 0.5),
                          )),
                        ),
                      );
                    },
                  ),
              child: const Icon(Icons.sort, color: Colors.blue)),
        ),
        body: SearchCore(
          searchWord: widget.searchWord,
          sort: sort,
          isTag: true,
        ));
  }
}
