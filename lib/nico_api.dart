import 'dart:convert';
import 'dart:io';

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
  http.Response resp =
      await http.get(Uri.parse('${UrlList.pcDomain.url}watch/$videoId'));
  if (resp.statusCode == 200) {
    final rawData = parse(resp.body)
        .querySelector("#js-initial-watch-data")!
        .attributes['data-api-data']!;

    Map<String, dynamic> info = json.decode(rawData);
    final VideoDetailInfo videoDetailInfo = VideoDetailInfo.fromJson(info);
    return videoDetailInfo;
  } else {
    debugPrint(resp.statusCode.toString());
    debugPrint(resp.body.toString());
  }
  return null;
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

Future<Map<String, dynamic>> getSeries(String? userId) async {
  Uri uri = Uri.https(
    UrlList.nvApiDomain.url,
    "v1/users/$userId/series",
    {"page": "1", "pageSize": "100"},
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

Future<Map<String, dynamic>> getSeriesDetail(int seriesId, int page) async {
  Uri uri = Uri.https(
    UrlList.nvApiDomain.url,
    "v2/series/$seriesId",
    {"page": "$page", "pageSize": "100"},
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

class NicoSession {
  List<Cookie> _cookies = [];
  final _regexSplitSetCookies = RegExp(',(?=[^ ])');
  Future<Map<String, dynamic>> getNicorepo(String? userId,
      {String? untilId, String? objectType, String? type}) async {
    var url = "last-6-months/users/$userId";
    if (userId == null) {
      url = "last-1-month/my";
      if (_cookies.isEmpty) {
        return {};
      }
    }

    final query = {
      "untilId": untilId,
      "object[type]": objectType,
      "type": type,
    }..removeWhere((_, value) => value == null);
    final headers = {
      "Cookie": _toSetCookieHeader(),
    };
    Uri uri = Uri.https(
      UrlList.publicApiDomain.url,
      "v1/timelines/nicorepo/$url/pc/entries.json",
      query,
    );

    http.Response resp = await http.get(uri, headers: headers);

    if (resp.statusCode == 200) {
      Map<String, dynamic> info = json.decode(resp.body);
      return info;
    } else {
      debugPrint(resp.body.toString());
    }
    return {};
  }

  Future<String?> login(String id, String password) async {
    Uri uri = Uri.https(
      "secure.nicovideo.jp",
      "secure/login",
      {"site": "niconico"},
    );
    http.Response resp = await http.post(
      uri,
      body: {"mail": "roxas1533@gmail.com", "password": "kingdom8"},
    );

    if (resp.statusCode == 200 || resp.statusCode == 302) {
      final cookies = resp.headers[HttpHeaders.setCookieHeader]!;
      bool success = false;
      for (final setCookie in cookies.split(_regexSplitSetCookies)) {
        final cookie = Cookie.fromSetCookieValue(setCookie);
        if (cookie.name == "user_session") {
          success = true;
        }
        _cookies.add(cookie);
      }
      _cookies = success ? _cookies : [];
      return success ? cookies : null;
    } else {
      debugPrint(resp.statusCode.toString());
      debugPrint(resp.body.toString());
    }
    return null;
  }

  String _toSetCookieHeader() {
    return _cookies.map((e) => e.toString()).join('; ');
  }

  void parseCookies(String cookie) {
    _cookies = [];
    for (final setCookie in cookie.split(_regexSplitSetCookies)) {
      final cookie = Cookie.fromSetCookieValue(setCookie);
      _cookies.add(cookie);
    }
  }
}
