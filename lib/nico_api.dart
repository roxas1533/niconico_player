import 'package:flutter/cupertino.dart';
import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:webfeed/webfeed.dart';

import 'constant.dart';

Future<List<String>> getPopulerTag(String tag) async {
  List<String> tagList = [];
  final resp = await http.get(
      Uri.parse('${UrlList.pcDomain}ranking/genre/$tag?video_ranking_menu'));

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
  } else {
    debugPrint(resp.statusCode.toString());
  }
  return tagList;
}

Future<List<VideoInfo>> getRanking(
    String tag, String term, String genreId) async {
  VideoInfo makeVideoInfo(RssItem item) {
    String getStringFromClass(String className, html.Document document) {
      var elements = document.getElementsByClassName(className);
      if (elements.length != 1) {
        return "unknown";
      }
      return elements[0].text;
    }

    final desc = parse(item.description);
    final videoInfo = VideoInfo(
      title: desc.querySelector('img')!.attributes['alt']!,
      thumbnailUrl: "${desc.querySelector('img')!.attributes['src']!}.M",
      videoId: item.link!,
      viewCount: getStringFromClass('nico-info-total-view', desc),
      commentCount: getStringFromClass('nico-info-total-res', desc),
      mylistCount: getStringFromClass('nico-info-total-mylist', desc),
      goodCount: getStringFromClass('nico-info-total-like', desc),
      lengthVideo: getStringFromClass('nico-info-length', desc),
      postedAt: getStringFromClass('nico-info-date', desc),
    );
    return videoInfo;
  }

  final searchtag = tag == "すべて" ? "" : "tag=$tag&";
  final resp = await http.get(Uri.parse(
      '${UrlList.pcDomain}ranking/genre/$genreId?term=$term&${searchtag}rss=2.0&lang=ja-jp'));

  List<VideoInfo> videoInfoList = [];

  if (resp.statusCode == 200) {
    var rssFeed = RssFeed.parse(resp.body);
    final value = rssFeed.items!;
    for (var element in value) {
      videoInfoList.add(
        makeVideoInfo(element),
      );
    }
  }
  return videoInfoList;
}

Future<Response> search(String word, int searchType, {int offset = 0}) async {
  return http.get(Uri.parse(
      "${UrlList.mobileDomain}api/${SearchParam.searchTypeStr[searchType]}/$word?sort=h&order=d&page=$offset"));
}
