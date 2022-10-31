import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:intl/intl.dart";

import 'contents/parts/utls/video_detail/video_player/video_player.dart';

// import 'package:flutter/foundation.dart';
late VideoPlayerHandler audioHandler;
final naviSelectIndex = StateProvider((ref) => 1);
final List<String> itemLabel = ["ランキング", "検索", "視聴履歴", "ニコレポ", "その他"];
final Map<String, String> genreMap = {
  "all": "全ジャンル",
  "entertainment": "エンターテイメント",
  "radio": "ラジオ",
  "music_sound": "音楽・サウンド",
  "dance": "ダンス",
  "animal": "動物",
  "nature": "自然",
  "cooking": "料理",
  "traveling_outdoor": "旅行・アウトドア",
  "vehicle": "乗り物",
  "sports": "スポーツ",
  "society_politics_news": "社会・政治・時事",
  "technology_craft": "技術・工作",
  "commentary_lecture": "解説・講座",
  "anime": "アニメ",
  "game": "ゲーム",
  "other": "その他",
  "r18": "R-18",
};

class VideoInfo {
  VideoInfo({
    required this.title,
    required this.thumbnailUrl,
    required this.videoId,
    required this.viewCount,
    required this.commentCount,
    required this.mylistCount,
    required this.goodCount,
    required this.lengthVideo,
    required this.postedAt,
  });
  final String title;
  String thumbnailUrl;
  final String videoId;
  final String viewCount;
  final String commentCount;
  final String mylistCount;
  final String goodCount;
  final String lengthVideo;
  final String postedAt;
  String getPostedAtTime() {
    late DateTime datetime;
    try {
      datetime = DateFormat("yyyy年MM月dd日 hh：mm：ss").parse(postedAt);
    } catch (e) {
      try {
        datetime = DateTime.parse(postedAt);
      } catch (e) {
        return postedAt;
      }
    }
    DateTime now = DateTime.now();
    final difference = now.difference(datetime);
    final formatter = DateFormat('yyyy/MM/dd HH:mm:ss', "ja_JP");
    var formatted = formatter.format(datetime);
    if (difference.inHours < 24) formatted = "${difference.inHours} 時間前";

    return formatted;
  }

  String getNextThumbnailUrl() {
    String thum = thumbnailUrl.substring(thumbnailUrl.length - 2);
    if (thum == ".M") {
      thum = thumbnailUrl.substring(0, thumbnailUrl.length - 2);
    }
    return thum;
  }

  static String? extractVideoId(String url) {
    final re =
        RegExp(r"(?:sm|nm|so|ca|ax|yo|nl|ig|na|cw|z[a-e]|om|sk|yk)\d{1,14}\b")
            .firstMatch(url);
    if (re != null) {
      return re.group(0).toString();
    }
    return null;
  }
}

class TagInfo {
  TagInfo({
    required this.name,
    required this.isNicodicArticleExists,
  });
  final String name;
  final bool isNicodicArticleExists;
}

class VideoDetailInfo extends VideoInfo {
  VideoDetailInfo({
    required super.title,
    required super.thumbnailUrl,
    required super.videoId,
    required super.viewCount,
    required super.commentCount,
    required super.mylistCount,
    required super.goodCount,
    required super.lengthVideo,
    required super.postedAt,
    required this.lengthSeconds,
    required this.description,
    required this.userName,
    required this.isChannel,
    required this.userId,
    required this.userThumailUrl,
    required this.tags,
    required this.session,
    required this.nvComment,
  });
  VideoDetailInfo.copy(
      VideoInfo videoInfo,
      this.description,
      this.userName,
      this.isChannel,
      this.userId,
      this.userThumailUrl,
      this.tags,
      this.session,
      this.nvComment,
      this.lengthSeconds)
      : super(
          title: videoInfo.title,
          thumbnailUrl: videoInfo.thumbnailUrl,
          videoId: videoInfo.videoId,
          viewCount: videoInfo.viewCount,
          commentCount: videoInfo.commentCount,
          mylistCount: videoInfo.mylistCount,
          goodCount: videoInfo.goodCount,
          lengthVideo: videoInfo.lengthVideo,
          postedAt: videoInfo.postedAt,
        );
  final String description;
  final String userName;
  final bool isChannel;
  final String userId;
  final String userThumailUrl;
  final int lengthSeconds;
  final List<TagInfo> tags;
  final Map<String, dynamic> session;
  final Map<String, dynamic> nvComment;

  @override
  String getPostedAtTime() {
    DateTime datetime = DateTime.parse(postedAt);
    final formatter = DateFormat('yyyy/MM/dd HH:mm:ss', "ja_JP");
    // var formatted = formatter.format(datetime);

    return formatter.format(datetime);
  }

  static String secToTime(int duration, [bool forceHour = false]) {
    final hour = duration ~/ 3600;
    final min = (duration % 3600) ~/ 60;
    final sec = duration % 60;

    final hourString = forceHour
        ? "${hour.toString()}:"
        : hour == 0
            ? ""
            : "${hour.toString()}:";
    return "$hourString${min.toString().padLeft(2, "0")}:${sec.toString().padLeft(2, "0")}";
  }
}

abstract class SearchParam {
  static const sortKey = [
    {"key": "h", "order": "d", "display": "人気が高い順"},
    {"key": "f", "order": "d", "display": "投稿日時が新しい順"},
    {"key": "v", "order": "d", "display": "再生数が多い順"},
    {"key": "likeCount", "order": "d", "display": "いいね！数が多い順"},
    {"key": "m", "order": "d", "display": "マイリストが多い順"},
    {"key": "n", "order": "d", "display": "コメントが新しい順"},
    {"key": "n", "order": "a", "display": "コメントが古い順"},
    {"key": "v", "order": "a", "display": "再生数が少ない順"},
    {"key": "r", "order": "d", "display": "コメント数が多い順"},
    {"key": "r", "order": "a", "display": "コメント数が少ない順"},
    {"key": "likeCount", "order": "a", "display": "いいね！数が少ない順"},
    {"key": "f", "order": "a", "display": "投稿日時が古い順"},
    {"key": "l", "order": "d", "display": "再生時間が長い順"},
    {"key": "l", "order": "a", "display": "再生時間が短い順"},
  ];
  static const searchTypeStr = [
    "search",
    "tag",
  ];
  static final searchWord = StateProvider((ref) => "");
  static final sort = StateProvider((ref) => 0);
  // static final genreId = StateProvider((ref) => 0);
}

abstract class UrlList {
  static const pcDomain = "https://www.nicovideo.jp/";
  static const mobileDomain = "https://sp.nicovideo.jp/";
}

class Point {
  double x;
  double y;
  Point(this.x, this.y);
  @override
  String toString() {
    return 'Point{x: $x, y: $y}';
  }

  static bool lineJudge(Point a, Point b, Point c, Point d) {
    double s, t;
    s = (a.x - b.x) * (c.y - a.y) - (a.y - b.y) * (c.x - a.x);
    t = (a.x - b.x) * (d.y - a.y) - (a.y - b.y) * (d.x - a.x);
    if (s * t > 0) {
      return false;
    }

    s = (c.x - d.x) * (a.y - c.y) - (c.y - d.y) * (a.x - c.x);
    t = (c.x - d.x) * (b.y - c.y) - (c.y - d.y) * (b.x - c.x);
    if (s * t > 0) {
      return false;
    }
    return true;
  }
}

const commentColor = {
  "white": Colors.white,
  "black": Colors.black,
  "red": Color(0xFFFF0000),
  "pink": Color(0xFFFF8080),
  "purple": Color(0xFFc080FF),
  "blue": Color(0xFF0000FF),
  "cyan": Color(0xFF00FFFF),
  "green": Color(0xFF00FF00),
  "yellow": Color(0xFFFFFF00),
  "orange": Color(0xFFFFC000),
  "niconicowhite": Color(0xFFCCCC99),
  "white2": Color(0xFFCCCC99),
  "truered": Color(0xFFCC0033),
  "red2": Color(0xFFCC0033),
  "passionorange": Color(0xFFFF6600),
  "orange2": Color(0xFFFF6600),
  "madyellow": Color(0xFF999900),
  "yellow2": Color(0xFF999900),
  "elementalgreen": Color(0xFF00CC66),
  "green2": Color(0xFF00CC66),
  "marineblue": Color(0xFF3399FF),
  "blue2": Color(0xFF3399FF),
  "nobleviolet": Color(0xFF6633CC),
  "purple2": Color(0xFF6633CC),
  "black2": Color(0xFF666666),
};

const commentSize = {
  "small": 0.55,
  "medium": 1.0,
  "big": 1.55,
};

enum CommentPositoinState {
  ue,
  shita,
  naka,
}

const commetPositoin = {
  "ue": CommentPositoinState.ue,
  "shita": CommentPositoinState.shita,
  "naka": CommentPositoinState.naka,
};

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}
