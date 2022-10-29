import 'dart:math';

import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';

import 'comment_player.dart';

class CommentDataObject {
  final String comment;
  final int vpos;
  final int nicoruCount;
  double fontSize;
  final Color color;
  final CommentPositoinState pos;
  final String fontName;
  bool isCommented = false;
  final bool ender;
  CommentDataObject({
    required this.comment,
    required this.vpos,
    required this.nicoruCount,
    required this.fontSize,
    required this.color,
    required this.pos,
    required this.fontName,
    required this.ender,
  });
}

class CommentObjectList {
  final Map<CommentPositoinState, List<List<CommentObject>>> commentList = {
    CommentPositoinState.naka: List.generate(11, (_) => []),
    CommentPositoinState.ue: List.generate(11, (_) => []),
    CommentPositoinState.shita: List.generate(11, (_) => []),
  };
  List<CommentObject> random = [];

  int time = 0;
  bool isPlaying = false;
  List<CommentDataObject> commentDataList = [];
  CommentObjectList(Map<String, dynamic> commnetDataMap) {
    final threads = commnetDataMap["data"]["threads"];
    for (final thread in threads) {
      final comments = thread["comments"];
      if (thread["fork"] == "owner") {
        for (final comment in comments) {
          comment["commands"] = comment["commands"].cast<String>();
          Color color = Colors.white;
          double fontSize = 1.0;
          CommentPositoinState pos = CommentPositoinState.naka;
          String fontName = "msgothic";
          bool ender = false;
          for (final c in comment["commands"]) {
            color = parseCommandColor(c) ?? color;
            fontSize = parseCommandSize(c) ?? fontSize;
            pos = parseCommandPos(c) ?? pos;
            fontName = parseCommandFont(c) ?? fontName;
            ender = c == "ender" ? true : ender;
          }

          commentDataList.add(CommentDataObject(
            comment: comment["body"],
            vpos: comment["vposMs"],
            nicoruCount: comment["nicoruCount"],
            color: color,
            fontSize: fontSize,
            pos: pos,
            fontName: fontName,
            ender: comment["ender"],
          ));
        }
      }
    }
    commentDataList.sort((a, b) => a.vpos.compareTo(b.vpos));
  }

  void add(CommentObject comment) {
    for (final n in commentList[comment.commentDataObject.pos]!) {
      if (n.isEmpty || comment.isPosLock) {
        n.add(comment);

        return;
      }
      if (comment.commentDataObject.pos == CommentPositoinState.naka) {
        if (comment.calcuatePos(n.last)) {
          comment.y = n.last.y + n.last.commentDataObject.fontSize + 10;
          continue;
        }
      } else {
        if (comment.commentDataObject.vpos <=
            n.last.commentDataObject.vpos + 3000) {
          var offsetY = n.last.commentDataObject.fontSize + 10;
          if (comment.commentDataObject.pos == CommentPositoinState.shita) {
            offsetY *= -1;
          }
          comment.y = n.last.y + offsetY;
          continue;
        }
      }

      n.add(comment);
      return;
    }
    comment.y =
        Random().nextDouble() * (CommentObject.playerHeight - comment.height);
    random.add(comment);
  }

  void update(double t) {
    if (isPlaying) {
      time += (t * 1000).toInt();
      for (final pos in commentList.values) {
        for (final list in pos) {
          for (final comment in list) {
            comment.update(t, time);
          }
        }
      }
    }
  }

  void render(double t, Canvas canvas) {
    for (final pos in commentList.values) {
      for (final list in pos) {
        for (final comment in list) {
          comment.render(t, canvas, time);
        }
      }
    }
  }
}

Color? parseCommandColor(String c) {
  if (c.startsWith("#")) {
    return Color(int.parse("FF${c.substring(1)}", radix: 16));
  }
  final color = commentColor[c];
  return color;
}

double? parseCommandSize(String c) {
  final size = commentSize[c];
  return size;
}

CommentPositoinState? parseCommandPos(String c) {
  final pos = commetPositoin[c];
  return pos;
}

String? parseCommandFont(String c) {
  if (c == "mincho" || c == "gothic") {
    return c;
  }
  return null;
}
