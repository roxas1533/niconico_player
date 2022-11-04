import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'contents/parts/utls/video_detail/video_player/video_player.dart';

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

enum GenreKey {
  all("all", "全ジャンル"),
  entertainment("entertainment", "エンターテイメント"),
  radio("radio", "ラジオ"),
  musicSound("music_sound", "音楽・サウンド"),
  dance("dance", "ダンス"),
  animal("animal", "動物"),
  nature("nature", "自然"),
  cooking("cooking", "料理"),
  travelingOutdoor("traveling_outdoor", "旅行・アウトドア"),
  sports("sports", "スポーツ"),
  societyPoliticsNews("society_politics_news", "社会・政治・時事"),
  technologyCraft("technology_craft", "技術・工作"),
  commentaryLecture("commentary_lecture", "解説・講座"),
  anime("anime", "アニメ"),
  game("game", "ゲーム"),
  other("other", "その他"),
  r18("r18", "R-18");

  final String label;
  final String key;
  const GenreKey(this.key, this.label);
}

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
  VideoInfo.fromJson(Map<String, dynamic> json)
      : title = json["title"],
        thumbnailUrl =
            json["thumbnail"]["middleUrl"] ?? json["thumbnail"]["url"],
        videoId = json["id"],
        viewCount = json["count"]["view"],
        commentCount = json["count"]["comment"],
        mylistCount = json["count"]["mylist"],
        goodCount = json["count"]["like"],
        lengthVideo = VideoDetailInfo.secToTime(json["duration"]),
        postedAt = json["registeredAt"];

  final String title;
  String thumbnailUrl;
  final String videoId;
  final int viewCount;
  final int commentCount;
  final int mylistCount;
  final int goodCount;
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
  final String id;
  final String name;
  final String icon;
  UserInfo({required this.id, required this.name, required this.icon});
}

class NicoRepoInfo {
  final UserInfo userInfo;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String updated;
  final String objectType;
  final String url;
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

class MylistInfo {
  final UserInfo userInfo;
  final String name;
  final String description;
  final String decoratedDescriptionHtml;
  final int id;
  final bool isPublic;
  MylistInfo({
    required this.userInfo,
    required this.name,
    required this.description,
    required this.decoratedDescriptionHtml,
    required this.id,
    required this.isPublic,
  });
  MylistInfo.fromJson(Map<String, dynamic> json)
      : userInfo = UserInfo(
          id: json["owner"]["id"],
          name: json["owner"]["name"],
          icon: json["owner"]["iconUrl"],
        ),
        name = json["name"],
        description = json["description"],
        decoratedDescriptionHtml = json["decoratedDescriptionHtml"],
        id = json["id"],
        isPublic = json["isPublic"];
}

class MylistVideoInfo extends VideoInfo {
  final String description;
  MylistVideoInfo(Map<String, dynamic> json)
      : description = json["decoratedDescriptionHtml"],
        super(
          title: json["video"]["title"],
          thumbnailUrl: json["video"]["thumbnail"]["middleUrl"] ??
              json["video"]["thumbnail"]["url"],
          videoId: json["video"]["id"],
          viewCount: json["video"]["count"]["view"],
          commentCount: json["video"]["count"]["comment"],
          mylistCount: json["video"]["count"]["mylist"],
          goodCount: json["video"]["count"]["like"],
          lengthVideo: VideoDetailInfo.secToTime(json["video"]["duration"]),
          postedAt: json["video"]["registeredAt"],
        );
}

class MylistDetailInfo extends MylistInfo {
  final bool hasNext;
  final int totalItemCount;
  MylistDetailInfo({
    required super.userInfo,
    required super.name,
    required super.description,
    required super.decoratedDescriptionHtml,
    required super.id,
    required super.isPublic,
    required this.hasNext,
    required this.totalItemCount,
  });
  MylistDetailInfo.fromJson(Map<String, dynamic> json)
      : hasNext = json["hasNext"],
        totalItemCount = json["totalItemCount"],
        super.fromJson(json);
}

class SeriesInfo {
  int id;
  String title;
  String thumbnailUrl;
  String description;
  int itemsCount;
  SeriesInfo(Map<String, dynamic> json)
      : id = json["id"],
        title = json["title"],
        thumbnailUrl = json["thumbnailUrl"],
        description = json["description"],
        itemsCount = json["itemsCount"];
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
    userInfo = UserInfo(id: userId, name: userName, icon: userThumailUrl);
  }
  VideoDetailInfo.fromJson(Map<String, dynamic> json)
      : userInfo = UserInfo(
            id: (json["channel"] != null
                    ? json["channel"]["id"]
                    : json["owner"]["id"])
                .toString(),
            name: json["channel"] != null
                ? json["channel"]["name"]
                : json["owner"]["nickname"],
            icon: json["channel"] != null
                ? json["channel"]["thumbnail"]["url"]
                : json["owner"]["iconUrl"]),
        lengthSeconds = json["video"]["duration"],
        description = json["video"]["description"],
        isChannel = json["channel"] != null,
        tags = [
          for (var tag in json["tag"]["items"])
            TagInfo(
                name: tag["name"],
                isNicodicArticleExists: tag["isNicodicArticleExists"])
        ],
        session = json["media"]["delivery"]["movie"]["session"],
        nvComment = json["comment"]["nvComment"],
        super.fromJson(json["video"]);
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
  publicApiDomain("public.api.nicovideo.jp"),
  nvApiDomain("nvapi.nicovideo.jp");

  final String url;
  const UrlList(this.url);
}

const apiHeader = {"X-Frontend-Id": "6", "X-Frontend-Version": "0"};

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

enum MylistSort {
  mylistNew("addedAt", "desc", "マイリスト登録が新しい順"),
  mylistOld("addedAt", "asc", "マイリスト登録が古い順"),
  titleD("title", "asc", "タイトル昇順"),
  titleA("title", "desc", "タイトル降順"),
  memoA("mylistComment", "asc", "メモ昇順"),
  memoD("mylistComment", "desc", "メモ降順"),
  registeredAtD("registeredAt", "desc", "投稿日時が新しい順"),
  registeredAtA("registeredAt", "asc", "投稿日時が古い順"),
  viewCountD("viewCount", "desc", "再生数が多い順"),
  viewCountA("viewCount", "asc", "再生数が少ない順"),
  lastCommentTimeD("lastCommentTime", "desc", "コメントが新しい順"),
  lastCommentTimeA("lastCommentTime", "asc", "コメントが古い順"),
  mylistCountD("mylistCount", "desc", "マイリスト数が多い順"),
  mylistCountA("mylistCount", "asc", "マイリスト数が少ない順"),
  likeCountD("likeCount", "desc", "いいね！数が多い順"),
  likeCountA("likeCount", "asc", "いいね!数が少ない順"),
  commentCountD("commentCount", "desc", "コメント数が多い順"),
  commentCountA("commentCount", "asc", "コメント数が少ない順"),
  durationD("duration", "desc", "再生時間が長い順"),
  durationA("duration", "asc", "再生時間が短い順");

  final String key;
  final String order;
  final String label;

  const MylistSort(this.key, this.order, this.label);
}

enum AllVideoListSort {
  registeredAtD("registeredAt", "desc", "投稿日時が新しい順"),
  registeredAtA("registeredAt", "asc", "投稿日時が古い順"),
  viewCountD("viewCount", "desc", "再生数が多い順"),
  viewCountA("viewCount", "asc", "再生数が少ない順"),
  lastCommentTimeD("lastCommentTime", "desc", "コメントが新しい順"),
  lastCommentTimeA("lastCommentTime", "asc", "コメントが古い順"),
  commentCountD("commentCount", "desc", "コメント数が多い順"),
  commentCountA("commentCount", "asc", "コメント数が少ない順"),
  likeCountD("likeCount", "desc", "いいね！数が多い順"),
  likeCountA("likeCount", "asc", "いいね!数が少ない順"),
  mylistCountD("mylistCount", "desc", "マイリスト数が多い順"),
  mylistCountA("mylistCount", "asc", "マイリスト数が少ない順"),
  durationD("duration", "desc", "再生時間が長い順"),
  durationA("duration", "asc", "再生時間が短い順");

  final String key;
  final String order;
  final String label;

  const AllVideoListSort(this.key, this.order, this.label);
}

enum SortKey {
  popular("h", "d", "人気が高い順"),
  mylistD("m", "d", "マイリストが多い順"),
  mylistA("m", "a", "マイリストが少ない順"),
  commentqD("r", "d", "コメント数が多い順"),
  commentqA("r", "a", "コメント数が少ない順"),
  commenttD("n", "d", "コメントが新しい順"),
  commenttA("n", "a", "コメントが古い順"),
  viewD("v", "d", "再生数が多い順"),
  viewA("v", "a", "再生数が少ない順"),
  lengthD("l", "d", "再生時間が長い順"),
  lengthA("l", "a", "再生時間が短い順"),
  dateD("f", "d", "投稿日時が新しい順"),
  dateA("f", "a", "投稿日時が古い順"),
  likeD("likeCount", "d", "いいね！数が多い順"),
  likeA("likeCount", "a", "いいね！数が少ない順");

  final String key;
  final String order;
  final String display;
  const SortKey(this.key, this.order, this.display);
}

enum SearchType {
  word("search"),
  tag("tag");

  final String type;
  const SearchType(this.type);
}
