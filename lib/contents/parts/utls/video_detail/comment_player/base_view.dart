import 'dart:math';

import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';

class CommentPlayer extends StatefulWidget {
  final Size screenSize;
  final CommentObjectList commentObjectList;
  const CommentPlayer(
      {super.key, required this.screenSize, required this.commentObjectList});

  @override
  State<CommentPlayer> createState() => _CommentPlayerState();
}

class CommentPainter extends CustomPainter {
  final CommentObjectList commentList;
  final double t;

  CommentPainter(this.commentList, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    commentList.update(t);
    commentList.render(t, canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class CommentObject {
  double _x, _y;
  late List<Point> _points;
  late final TextPainter _tp;
  late final TextPainter _ts;
  static double playerWidth = 0;
  static double playerHeight = 0;
  late final double height;
  final CommentDataObject commentDataObject;
  bool isPosLock = false;

  // for debug
  // late String com;

  CommentObject(this._x, this._y, this.commentDataObject) {
    final comment = commentDataObject.comment;
    final ts = TextStyle(
      fontSize: commentDataObject.fontSize,
      fontFamily: commentDataObject.fontName,
      fontWeight: FontWeight.w600,
      color: commentDataObject.color,
      shadows: const <Shadow>[
        Shadow(
          offset: Offset(1.3, -1.3),
          color: Color.fromARGB(255, 104, 104, 104),
        ),
      ],
    );
    _tp = TextPainter(
      text: TextSpan(text: comment, style: ts),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    )..layout();
    _ts = TextPainter(
      text: TextSpan(
          text: comment,
          style: TextStyle(
            fontSize: commentDataObject.fontSize,
            fontFamily: commentDataObject.fontName,
            fontWeight: FontWeight.w600,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = const Color.fromARGB(255, 104, 104, 104),
          )),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    )..layout();
    height = _tp.height;
    if (commentDataObject.pos == CommentPositoinState.shita) {
      _y = playerHeight - height - 10;
    }
    if (playerHeight <= height) {
      isPosLock = true;
    }
    final myTime =
        (commentDataObject.pos == CommentPositoinState.naka) ? 4000 : 3000;

    _points = [
      Point(playerWidth, commentDataObject.vpos.toDouble()),
      Point(playerWidth + _tp.width, commentDataObject.vpos.toDouble()),
      Point(0, commentDataObject.vpos.toDouble() + myTime),
      Point(-_tp.width, commentDataObject.vpos.toDouble() + myTime),
    ];
  }

  bool calcuatePos(CommentObject o) {
    final Point a = o._points[1];
    final Point b = o._points[2];

    final Point c = _points[0];
    final Point d = _points[1];
    final Point e = _points[2];
    final Point f = _points[3];
    if (Point.lineJudge(a, b, c, d)) {
      return true;
    }
    if (Point.lineJudge(a, b, d, e)) {
      return true;
    }
    if (Point.lineJudge(a, b, c, f)) {
      return true;
    }
    return false;
  }

  void render(double t, Canvas canvas, int time) {
    if (commentDataObject.pos == CommentPositoinState.naka) {
      if (_x < playerWidth && _x + _tp.width > 0) {
        _ts.paint(canvas, Offset(_x, _y));
        _tp.paint(canvas, Offset(_x, _y));
      }
    } else if (time >= commentDataObject.vpos &&
        time <= commentDataObject.vpos + 3000) {
      _ts.paint(canvas, Offset(_x, _y));
      _tp.paint(canvas, Offset(_x, _y));
    }
  }

  void update(double dt, int time) {
    if (commentDataObject.pos == CommentPositoinState.naka) {
      final double speed = ((playerWidth + _tp.width) / (4000));
      final relativeTime = commentDataObject.vpos - time;

      // _x -= speed;
      _x = relativeTime * speed + playerWidth / 2 - _tp.width / 2;
    } else {
      _x = playerWidth / 2 - _tp.width / 2;
    }
  }
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
      for (final comment in comments) {
        comment["commands"] = comment["commands"].cast<String>();
        commentDataList.add(CommentDataObject(
          comment: comment["body"],
          vpos: comment["vposMs"],
          nicoruCount: comment["nicoruCount"],
          color: parseCommandColor(comment["commands"]),
          fontSize: 29 * parseCommandSize(comment["commands"]),
          pos: parseCommandPos(comment["commands"]),
          fontName: parseCommandFont(comment["commands"]),
        ));
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
          comment._y = n.last._y + n.last.commentDataObject.fontSize + 10;
          continue;
        }
      } else {
        if (comment.commentDataObject.vpos <=
            n.last.commentDataObject.vpos + 3000) {
          var offsetY = n.last.commentDataObject.fontSize + 10;
          if (comment.commentDataObject.pos == CommentPositoinState.shita) {
            offsetY *= -1;
          }
          comment._y = n.last._y + offsetY;
          continue;
        }
      }

      n.add(comment);
      return;
    }
    comment._y =
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

class CommentDataObject {
  final String comment;
  final int vpos;
  final int nicoruCount;
  final double fontSize;
  final Color color;
  final CommentPositoinState pos;
  final String fontName;
  bool isCommented = false;
  CommentDataObject({
    required this.comment,
    required this.vpos,
    required this.nicoruCount,
    required this.fontSize,
    required this.color,
    required this.pos,
    required this.fontName,
  });
}

class _CommentPlayerState extends State<CommentPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final DateTime _initialTime = DateTime.now();
  double previous = 0.0;
  double get currentTime =>
      DateTime.now().difference(_initialTime).inMilliseconds / 1000.0;

  @override
  Widget build(BuildContext context) {
    CommentObject.playerWidth = widget.screenSize.height;
    CommentObject.playerHeight = widget.screenSize.width;
    for (final commentdata in widget.commentObjectList.commentDataList) {
      // if (!commentdata.isCommented &&
      //     commentdata.vpos <= widget.commentObjectList.time) {
      // commentdata.isCommented = true;
      widget.commentObjectList
          .add(CommentObject(widget.screenSize.height, 10, commentdata));
      // break;
      // }
    }
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext contex, Widget? child) {
        final curr = currentTime;
        final dt = curr - previous;
        previous = curr;
        return CustomPaint(
          size: widget.screenSize,
          painter: CommentPainter(widget.commentObjectList, dt),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    previous = currentTime;
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

Color parseCommandColor(List<String> command) {
  for (final c in command) {
    if (c.startsWith("#")) {
      return Color(int.parse(c.substring(1), radix: 16));
    }
    final color = commentColor[c];
    if (color != null) {
      return color;
    }
  }
  return Colors.white;
}

double parseCommandSize(List<String> command) {
  for (final c in command) {
    final size = commentSize[c];
    if (size != null) {
      return size;
    }
  }
  return 1.0;
}

CommentPositoinState parseCommandPos(List<String> command) {
  for (final c in command) {
    final pos = commetPositoin[c];
    if (pos != null) {
      return pos;
    }
  }
  return CommentPositoinState.naka;
}

String parseCommandFont(List<String> command) {
  for (final c in command) {
    if (c == "mincho" || c == "gothic") {
      return c;
    }
  }
  return "msgothic";
}
