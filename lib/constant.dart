import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:intl/intl.dart";

import 'contents/parts/utls/video_detail/video_player.dart';

// import 'package:flutter/foundation.dart';
late AudioPlayerHandler audioHandler;
final naviSelectIndex = StateProvider((ref) => 0);
// final rankingParam = StateProvider((ref) => RrankingParam(0, "すべて"));
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
    DateTime datetime = DateFormat("yyyy年MM月dd日 hh：mm：ss").parse(postedAt);
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

class RankingParam {
  static const termKey = {
    "hour": "毎時",
    "24h": "24時間",
    "week": "週間(すべてのみ)",
    "month": "月間(すべてのみ)",
    "total": "全期間(すべてのみ)"
  };
  static final tag = StateProvider((ref) => "すべて");
  static final term = StateProvider((ref) => "24h");
  static final genreId = StateProvider((ref) => 0);
}
