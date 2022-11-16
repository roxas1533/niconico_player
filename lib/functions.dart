import 'package:flutter/cupertino.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart';
import 'package:niconico/contents/parts/mylist/mylist.dart';
import 'package:niconico/contents/parts/series/series.dart';
import 'package:niconico/contents/parts/utls/video_detail/video_detail.dart';

String tf2yn(bool tf) {
  return tf ? "yes" : "no";
}

Map<String, dynamic> makeSessionPayloads(Map<String, dynamic> session) {
  final protocol = session["protocols"][0];
  final urls = session["urls"];
  bool isWellKnownPort = true;
  bool isSsl = true;
  for (final url in urls) {
    isWellKnownPort = url["isWellKnownPort"];
    isSsl = url["isSsl"];
    break;
  }
  final payloads = {};
  payloads["recipe_id"] = session["recipeId"];
  payloads["content_id"] = session["contentId"];
  payloads["content_type"] = "movie";
  payloads["content_src_id_sets"] = [
    {
      "content_src_ids": [
        {
          "src_id_to_mux": {
            "video_src_ids": session["videos"],
            "audio_src_ids": session["audios"]
          }
        },
      ]
    }
  ];
  payloads["timing_constraint"] = "unlimited";
  payloads["keep_method"] = {
    "heartbeat": {"lifetime": session["heartbeatLifetime"]}
  };
  payloads["protocol"] = {
    "name": protocol,
    "parameters": {
      "http_parameters": {
        "parameters": {
          "hls_parameters": {
            "use_well_known_port": tf2yn(isWellKnownPort),
            "use_ssl": tf2yn(isSsl),
            "transfer_preset": "",
            "segment_duration": 6000,
          }
        }
      }
    }
  };
  payloads["content_uri"] = "";
  payloads["session_operation_auth"] = {
    "session_operation_auth_by_signature": {
      "token": session["token"],
      "signature": session["signature"]
    }
  };
  payloads["content_auth"] = {
    "auth_type": session["authTypes"][protocol],
    "content_key_timeout": session["contentKeyTimeout"],
    "service_id": "nicovideo",
    "service_user_id": session["serviceUserId"]
  };
  payloads["client_info"] = {
    "player_id": session["playerId"],
  };
  payloads["priority"] = session["priority"];
  return {"session": payloads};
}

String numberFormat(int number) {
  final formatter = NumberFormat("#,##0");
  return formatter.format(number);
}

String? extractVideoId(String url) {
  final re =
      RegExp(r"(?:sm|nm|so|ca|ax|yo|nl|ig|na|cw|z[a-e]|om|sk|yk)\d{1,14}\b")
          .firstMatch(url);
  if (re != null) {
    return re.group(0).toString();
  }
  return null;
}

String getPostedAtTime(String postedAt, bool islast24h) {
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

  if (islast24h && difference.inHours < 24) {
    if (difference.inMinutes < 1) {
      formatted = "1分以内";
    } else if (difference.inMinutes < 60) {
      formatted = "${difference.inMinutes} 分前";
    } else {
      formatted = "${difference.inHours} 時間前";
    }
  }

  return formatted;
}

void onLinkTap(
  String? url,
  RenderContext rContext,
  Map<String, String> attributes,
  dom.Element? element,
  BuildContext context,
) {
  if (url != null) {
    final parsedUrl = Uri.parse(url);
    if (parsedUrl.host == "www.nicovideo.jp") {
      if (parsedUrl.pathSegments.length == 2) {
        switch (parsedUrl.pathSegments[0]) {
          case "watch":
            Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) =>
                  VideoDetail(videoId: parsedUrl.pathSegments[1]),
            ));
            break;
          case "mylist":
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) =>
                    Mylist(mylistId: int.parse(parsedUrl.pathSegments[1]))));
            break;
          case "series":
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) =>
                    Series(seriesId: int.parse(parsedUrl.pathSegments[1]))));

            break;
        }
      }
    }
  }
}

extension DateTimeStringExtension on DateTime {
  String timeZoneOffsetString() {
    final offset = timeZoneOffset;
    // ignore: prefer_interpolation_to_compose_strings
    return (offset.isNegative ? '-' : '+') +
        offset.inHours.abs().toString().padLeft(2, '0') +
        ':' +
        (offset.inMinutes - offset.inHours * 60).toString().padLeft(2, '0');
  }

  String toIso8601StringWithTimeZoneOffsetString() {
    if (isUtc) {
      return toIso8601String();
    }

    return '${toIso8601String()}${timeZoneOffsetString()}';
  }
}
