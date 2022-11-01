import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'contents/parts/utls/video_detail/video_player/video_player.dart';

// import 'package:flutter/foundation.dart';
late VideoPlayerHandler audioHandler;
final naviSelectIndex = StateProvider((ref) => 1);
const List<String> itemLabel = ["ランキング", "検索", "視聴履歴", "ニコレポ", "その他"];

enum NaviSelectIndex {
  ranking(0, "ランキング", Icons.emoji_events),
  search(1, "検索", Icons.search),
  history(2, "視聴履歴", Icons.schedule),
  nicorepo(3, "ニコレポ", Icons.newspaper),
  other(4, "その他", Icons.settings);

  final String label;
  final IconData icon;
  const NaviSelectIndex(index, this.label, this.icon);
}

enum UserNicoRepoOrder {
  all("すべて", null, null),
  video("動画投稿", "video", "upload"),
  live("生放送開始", "program", "onair"),
  illust("イラスト投稿", "image", "add"),
  manga("マンガ投稿", "comicStory", "add"),
  article("記事投稿", "article", "add"),
  game("ゲーム投稿", "game", "add");

  final String label;
  final String? objectType;
  final String? type;
  const UserNicoRepoOrder(this.label, this.objectType, this.type);
}

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

  String getNextThumbnailUrl() {
    String thum = thumbnailUrl.substring(thumbnailUrl.length - 2);
    if (thum == ".M") {
      thum = thumbnailUrl.substring(0, thumbnailUrl.length - 2);
    }
    return thum;
  }
}

class UserInfo {
  String id;
  String name;
  String icon;
  UserInfo({required this.id, required this.name, required this.icon});
}

class NicoRepoInfo {
  UserInfo userInfo;
  String title;
  String description;
  String thumbnailUrl;
  String updated;
  String objectType;
  String url;
  NicoRepoInfo({
    required this.userInfo,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.updated,
    required this.objectType,
    required this.url,
  });
  NicoRepoInfo.fromJson(Map<String, dynamic> json)
      : userInfo = UserInfo(
          id: Uri.parse(json["actor"]["url"]).pathSegments.last,
          name: json["actor"]["name"],
          icon: json["actor"]["icon"],
        ),
        title = json["title"],
        description = json["object"]["name"],
        thumbnailUrl = json["object"]["image"],
        updated = json["updated"],
        objectType = json["object"]["type"],
        url = json["object"]["url"];
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
    required userName,
    required this.isChannel,
    required userId,
    required userThumailUrl,
    required this.tags,
    required this.session,
    required this.nvComment,
  }) {
    super.thumbnailUrl = super.getNextThumbnailUrl();
    userInfo = UserInfo(id: userId, name: userName, icon: userThumailUrl);
  }
  VideoDetailInfo.copy(
      VideoInfo videoInfo,
      this.description,
      userName,
      this.isChannel,
      userId,
      userThumailUrl,
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
        ) {
    super.thumbnailUrl = super.getNextThumbnailUrl();
    userInfo = UserInfo(id: userId, name: userName, icon: userThumailUrl);
  }
  final String description;
  final bool isChannel;
  final int lengthSeconds;
  late final UserInfo userInfo;
  final List<TagInfo> tags;
  final Map<String, dynamic> session;
  final Map<String, dynamic> nvComment;

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

enum UrlList {
  pcDomain("https://www.nicovideo.jp/"),
  mobileDomain("https://sp.nicovideo.jp/"),
  publicApiDomain("public.api.nicovideo.jp");

  final String url;
  const UrlList(this.url);
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
