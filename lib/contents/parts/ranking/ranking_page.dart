import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/video_detail.dart';
import 'package:webfeed/webfeed.dart';

import '../utls/video_list_widget.dart';

class RainkingPage extends ConsumerWidget {
  RainkingPage({
    Key? key,
    required this.genreId,
    required this.tag,
  }) : super(key: key);
  final String tag;
  final String genreId;
  final _scrollController = ScrollController();

  // void setTerm

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
        future: _getRanking(tag, ref.watch(RankingParam.term), context),
        builder:
            (BuildContext context, AsyncSnapshot<List<VideoInfo>> snapshot) {
          if (snapshot.hasData) {
            return Scrollbar(
                child: ListView.builder(
              controller: _scrollController,
              primary: false,
              shrinkWrap: true,
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
                      rank: index + 1,
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

  Future<List<VideoInfo>> _getRanking(
      String tag, String term, BuildContext context) async {
    List<VideoInfo> videoInfoList = [];
    final searchtag = tag == "すべて" ? "" : "tag=$tag&";
    http.Response resp = await http.get(Uri.parse(
        'https://www.nicovideo.jp/ranking/genre/$genreId?term=$term&${searchtag}rss=2.0&lang=ja-jp'));

    if (resp.statusCode == 200) {
      var rssFeed = RssFeed.parse(resp.body);
      final value = rssFeed.items!;
      for (var element in value) {
        videoInfoList.add(
          _makeVideoInfo(element),
        );
      }
    }
    return videoInfoList;
  }

  VideoInfo _makeVideoInfo(RssItem item) {
    final desc = parse(item.description);
    final videoInfo = VideoInfo(
      title: desc.querySelector('img')!.attributes['alt']!,
      thumbnailUrl: "${desc.querySelector('img')!.attributes['src']!}.M",
      videoId: item.link!,
      viewCount: _getStringFromClass('nico-info-total-view', desc),
      commentCount: _getStringFromClass('nico-info-total-res', desc),
      mylistCount: _getStringFromClass('nico-info-total-mylist', desc),
      goodCount: _getStringFromClass('nico-info-total-like', desc),
      lengthVideo: _getStringFromClass('nico-info-length', desc),
      postedAt: _getStringFromClass('nico-info-date', desc),
    );
    return videoInfo;
  }

  String _getStringFromClass(String className, html.Document document) {
    var elements = document.getElementsByClassName(className);
    if (elements.length != 1) {
      return "unknown";
    }
    return elements[0].text;
  }
}
