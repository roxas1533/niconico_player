import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/nico_api.dart';

class SearchClass {
  List<VideoInfo> videoInfoList = [];
  String searchWord = "";
  SortKey sortdesc = SortKey.popular;
  SearchType searchType = SearchType.word;
  int page = 1;
  int maxPage = 0;
  Future<bool> searchVideo(String searchWord, SearchType searchType, int page,
      SortKey sortdesc) async {
    this.searchWord = searchWord;
    this.searchType = searchType;
    this.sortdesc = sortdesc;
    if (page == 1) {
      videoInfoList = [];
      if (searchWord.isEmpty) {
        videoInfoList = [];
        return false;
      }
    }

    final resp = await search(
      searchWord,
      searchType.type,
      sortdesc.key,
      sortdesc.order,
      offset: page,
    );

    if (resp.statusCode == 200) {
      final result = parse(resp.body);
      final data = result.body!.firstChild!.children;

      for (final d in data) {
        if (d.attributes.containsKey("data-view_counter")) {
          videoInfoList.add(VideoInfo(
            title: d.attributes["data-title"]!,
            videoId: d.attributes["data-video_id"]!,
            viewCount: int.parse(d.attributes["data-view_counter"]!),
            thumbnailUrl: d
                .getElementsByClassName("video-item-thumbnail")[0]
                .attributes["data-original"]!,
            commentCount: int.parse(d.attributes["data-comment_counter"]!),
            mylistCount: int.parse(d.attributes["data-mylist_counter"]!),
            goodCount: int.parse(d.attributes["data-like_counter"]!),
            lengthVideo: VideoDetailInfo.secToTime(
                int.parse(d.attributes["data-video_length"]!)),
            postedAt: d.getElementsByClassName("video-item-date")[0].text,
          ));
        }
      }
      final resultData =
          result.getElementsByClassName("jsSearchResultContainer")[0];
      final dataContext = resultData.attributes["data-context"]!;
      maxPage = json.decode(dataContext)["max_page"];
    } else {
      debugPrint(resp.statusCode.toString());
      debugPrint(resp.body.toString());
      debugPrint("$searchWord, $searchType, $page");
      return false;
    }
    return videoInfoList.isNotEmpty;
  }

  Future<bool> nextPage() async {
    if (page < maxPage) {
      page++;
      return searchVideo(searchWord, searchType, page, sortdesc);
    }
    return false;
  }
}
