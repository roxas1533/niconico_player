import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/video_detail.dart';
import 'package:niconico/contents/parts/utls/video_list_widget.dart';

class Search extends ConsumerWidget {
  Search({
    Key? key,
  }) : super(key: key);
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
        future: _search(ref.watch(SearchParam.searchWord)),
        builder:
            (BuildContext context, AsyncSnapshot<List<VideoInfo>> snapshot) {
          if (snapshot.hasData) {
            // if (snapshot.data!.isEmpty) {
            //   return Container(
            //     alignment: Alignment.center,
            //     child: const Text('検索結果がありません'),
            //   );
            // }
            return Scrollbar(
                controller: _scrollController,
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 5),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VideoDetail(
                                      videoId: VideoInfo.extractVideoId(
                                          snapshot.data![index].videoId)!)));
                        },
                        child: VideoListWidget(
                          videoInfo: snapshot.data![index],
                        ));
                  },
                ));
          } else {
            return Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: Colors.grey,
                ));
          }
        });
  }

  Future<List<VideoInfo>> _search(String word) async {
    List<VideoInfo> videoInfoList = [];
    if (word.isEmpty) {
      return videoInfoList;
    }
    const baseUrl =
        "https://api.search.nicovideo.jp/api/v2/snapshot/video/contents/search?";
    const fields =
        "contentId,title,viewCounter,startTime,lengthSeconds,thumbnailUrl,commentCounter,mylistCounter,likeCounter";
    http.Response resp = await http.get(Uri.parse(
        "${baseUrl}q=${Uri.encodeFull(word)}&targets=title&fields=$fields&_sort=-viewCounter&_offset=0&_limit=3&_context=smileplayer"));

    if (resp.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(resp.body);
      for (final d in result["data"]) {
        videoInfoList.add(VideoInfo(
          title: d["title"],
          videoId: d["contentId"],
          viewCount: d["viewCounter"].toString(),
          thumbnailUrl: d["thumbnailUrl"],
          commentCount: d["commentCounter"].toString(),
          mylistCount: d["mylistCounter"].toString(),
          goodCount: d["likeCounter"].toString(),
          lengthVideo: d["lengthSeconds"].toString(),
          postedAt: d["startTime"],
        ));
      }
    } else {
      debugPrint(resp.statusCode.toString());
    }
    return videoInfoList;
  }
}
