import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:niconico/functions.dart';
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

  const header = {"X-Frontend-Id": "6", "X-Frontend-Version": "0"};
  final actionTrackId = makeActionTrackId();
  http.Response resp = await http.get(
      Uri.parse(
          '${UrlList.pcDomain.url}api/watch/v3_guest/$videoId?actionTrackId=$actionTrackId'),
      headers: header);
  if (resp.statusCode == 200) {
    Map<String, dynamic> info = json.decode(resp.body);
    final video = info["data"]["video"];
    String userName;
    String userId;
    String userIconUrl;
    bool isChannel;

    if (info["data"]["channel"] != null) {
      final channel = info["data"]["channel"];
      userName = channel["name"];
      userId = channel["id"].toString();
      userIconUrl = channel["thumbnail"]["url"];
      isChannel = true;
    } else {
      final user = info["data"]["owner"];
      userName = user["nickname"];
      userId = user["id"].toString();
      userIconUrl = user["iconUrl"];
      isChannel = false;
    }

    final VideoDetailInfo videoDetailInfo = VideoDetailInfo(
      title: video["title"],
      thumbnailUrl:
          video["thumbnail"]["middleUrl"] ?? video["thumbnail"]["url"],
      videoId: video["id"],
      viewCount: numberFormat(video["count"]["view"]),
      commentCount: numberFormat(video["count"]["comment"]),
      mylistCount: numberFormat(video["count"]["mylist"]),
      goodCount: numberFormat(video["count"]["like"]),
      lengthVideo: VideoDetailInfo.secToTime(video["duration"]),
      lengthSeconds: video["duration"],
      postedAt: video["registeredAt"],
      description: video["description"],
      userName: userName,
      userThumailUrl: userIconUrl,
      userId: userId,
      isChannel: isChannel,
      tags: [
        for (var tag in info["data"]["tag"]["items"])
          TagInfo(
              name: tag["name"],
              isNicodicArticleExists: tag["isNicodicArticleExists"])
      ],
      session: info["data"]["media"]["delivery"]["movie"]["session"],
      nvComment: info["data"]["comment"]["nvComment"],
    );
    return videoDetailInfo;
  } else {
    debugPrint(resp.statusCode.toString());
  }
  return null;
}

Future<Map<String, dynamic>> getNicorepo(String? userId,
    {String? untilId}) async {
  // if (userId == null) {
  //   return Future.value([]);
  // }

  final query = {
    "untilId": untilId,
  };
  query.removeWhere((key, value) => value == null);
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
