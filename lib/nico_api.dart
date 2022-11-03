import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:webfeed/webfeed.dart';

import 'constant.dart';

Future<List<String>> getPopulerTag(String tag) async {
  List<String> tagList = [];
  final resp = await http.get(Uri.parse(
      '${UrlList.pcDomain.url}ranking/genre/$tag?video_ranking_menu'));

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
    String getTextFromClass(String className, html.Document document) {
      var elements = document.getElementsByClassName(className);
      if (elements.length != 1) {
        return "unknown";
      }

      return elements[0].text.replaceAll(',', '');
    }

    final desc = parse(item.description);

    final videoInfo = VideoInfo(
      title: desc.querySelector('img')!.attributes['alt']!,
      thumbnailUrl: "${desc.querySelector('img')!.attributes['src']!}.M",
      videoId: item.link!,
      viewCount: int.parse(getTextFromClass('nico-info-total-view', desc)),
      commentCount: int.parse(getTextFromClass('nico-info-total-res', desc)),
      mylistCount: int.parse(getTextFromClass('nico-info-total-mylist', desc)),
      goodCount: int.parse(getTextFromClass('nico-info-total-like', desc)),
      lengthVideo: getTextFromClass('nico-info-length', desc),
      postedAt: getTextFromClass('nico-info-date', desc),
    );
    return videoInfo;
  }

  final searchtag = tag == "すべて" ? "" : "tag=$tag&";
  final resp = await http.get(Uri.parse(
      '${UrlList.pcDomain.url}ranking/genre/$genreId?term=$term&${searchtag}rss=2.0&lang=ja-jp'));

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

Future<Response> search(
    String word, String searchType, String sort, String order,
    {int offset = 0}) async {
  return http.get(Uri.parse(
      "${UrlList.mobileDomain.url}api/$searchType/$word?sort=$sort&order=$order&page=$offset"));
}

Future<VideoDetailInfo?> getVideoDetail(String videoId) async {
  String makeActionTrackId() {
    const alphabetsList =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    const numList = "0123456789";
    final randomString = [
      for (int i = 0; i < 10; i++) alphabetsList[Random().nextInt(26 * 2)]
    ].join("");
    final randomInt =
        [for (int i = 0; i < 13; i++) numList[Random().nextInt(10)]].join("");
    return "${randomString}_$randomInt";
  }

  final actionTrackId = makeActionTrackId();
  http.Response resp = await http.get(
      Uri.parse(
          '${UrlList.pcDomain.url}api/watch/v3_guest/$videoId?actionTrackId=$actionTrackId'),
      headers: apiHeader);
  if (resp.statusCode == 200) {
    Map<String, dynamic> info = json.decode(resp.body);
    final VideoDetailInfo videoDetailInfo = VideoDetailInfo.fromJson(info);

    return videoDetailInfo;
  } else {
    debugPrint(resp.statusCode.toString());
    debugPrint(resp.body.toString());
  }
  return null;
}

Future<Map<String, dynamic>> getNicorepo(String? userId,
    {String? untilId, String? objectType, String? type}) async {
  // if (userId == null) {
  //   return Future.value([]);
  // }

  final query = {
    "untilId": untilId,
    "object[type]": objectType,
    "type": type,
  }..removeWhere((_, value) => value == null);
  Uri uri = Uri.https(
    UrlList.publicApiDomain.url,
    "v1/timelines/nicorepo/last-6-months/users/$userId/pc/entries.json",
    query,
  );

  http.Response resp = await http.get(uri);

  if (resp.statusCode == 200) {
    Map<String, dynamic> info = json.decode(resp.body);
    return info;
  } else {
    debugPrint(resp.body.toString());
  }
  return {};
}

Future<Map<String, dynamic>> getMylist(
  String? userId,
) async {
  // if (userId == null) {
  //   return Future.value([]);
  // }
  Uri uri = Uri.https(
    UrlList.nvApiDomain.url,
    "v1/users/$userId/mylists",
    {"sampleItemCount": "3"},
  );

  http.Response resp = await http.get(uri, headers: apiHeader);

  if (resp.statusCode == 200) {
    Map<String, dynamic> info = json.decode(resp.body);
    return info;
  } else {
    debugPrint(resp.body.toString());
  }
  return {};
}

Future<Map<String, dynamic>> getMylistDetail(String? mylistId,
    {int page = 1, String? sortKey, String? sortOrder}) async {
  final query = {
    "sortKey": sortKey,
    "sortOrder": sortOrder,
    "pageSize": "100",
    "page": "$page"
  }..removeWhere((_, value) => value == null);
  Uri uri = Uri.https(
    UrlList.nvApiDomain.url,
    "v2/mylists/$mylistId",
    query,
  );
  http.Response resp = await http.get(uri, headers: apiHeader);

  if (resp.statusCode == 200) {
    Map<String, dynamic> info = json.decode(resp.body);
    return info;
  } else {
    debugPrint(resp.body.toString());
  }
  return {};
}

Future<Map<String, dynamic>> getUserVideoList(String? useId,
    {int page = 1, String? sortKey, String? sortOrder}) async {
  final query = {
    "sortKey": sortKey,
    "sortOrder": sortOrder,
    // "sensitiveContents": "mask",
    "pageSize": "100",
    "page": "$page"
  }..removeWhere((_, value) => value == null);
  Uri uri = Uri.https(
    UrlList.nvApiDomain.url,
    "v3/users/$useId/videos",
    query,
  );
  http.Response resp = await http.get(uri, headers: apiHeader);

  if (resp.statusCode == 200) {
    Map<String, dynamic> info = json.decode(resp.body);
    return info;
  } else {
    debugPrint(resp.body.toString());
  }
  return {};
}
