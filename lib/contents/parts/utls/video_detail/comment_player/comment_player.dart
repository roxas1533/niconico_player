import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/video_detail/comment_player/comment.dart';

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
  double _x, y;
  late List<Point> _points;
  late final TextPainter _tp;
  late final TextPainter _ts;
  static double playerWidth = 0;
  static double playerHeight = 0;
  late final double height;
  final CommentDataObject commentDataObject;
  bool isPosLock = false;
  CommentObject? collisionComment;

  CommentObject(this._x, this.y, this.commentDataObject) {
    final comment = commentDataObject.comment;
    var fontSize = (playerHeight - 66) / 11 * commentDataObject.fontSizeScale;
    if (!commentDataObject.ender) {
      fontSize = _resizeHeight(commentDataObject, fontSize);
      fontSize = _resizeWidth(commentDataObject, fontSize);
    }
    const fontFamilyFallback = ["msgothic2", "cour", "jhenghei"];
    final ts = TextStyle(
      fontSize: fontSize,
      fontFamily: commentDataObject.fontName,
      fontFamilyFallback: fontFamilyFallback,
      fontWeight: FontWeight.w600,
      height: 1,
      color: commentDataObject.color,
      shadows: const <Shadow>[
        Shadow(
          offset: Offset(1.1, -1.1),
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
            fontSize: fontSize,
            fontFamily: commentDataObject.fontName,
            fontFamilyFallback: fontFamilyFallback,
            fontWeight: FontWeight.w600,
            height: 1,
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
      y = playerHeight - height - 10;
    }
    if (playerHeight <= height) {
      isPosLock = true;
      if (commentDataObject.pos == CommentPositoinState.naka) {
        y = playerHeight / 2 - height / 2;
      }
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
        _ts.paint(canvas, Offset(_x, y));
        _tp.paint(canvas, Offset(_x, y));
      }
    } else if (time >= commentDataObject.vpos &&
        time <= commentDataObject.vpos + 3000) {
      _ts.paint(canvas, Offset(_x, y));
      _tp.paint(canvas, Offset(_x, y));
    }
  }

  void update(double dt, int time) {
    if (!isPosLock && collisionComment != null) {
      var offsetY = collisionComment!.height + 6;
      if (commentDataObject.pos == CommentPositoinState.shita) offsetY *= -1;
      y = collisionComment!.y + offsetY;
    }
    if (commentDataObject.pos == CommentPositoinState.naka) {
      final double speed = ((playerWidth + _tp.width) / (4000));
      final relativeTime = commentDataObject.vpos - time;

      // _x -= speed;
      _x = relativeTime * speed + playerWidth / 2 - _tp.width / 2;
    } else {
      _x = playerWidth / 2 - _tp.width / 2;
    }
  }

  double _resizeHeight(CommentDataObject comment, double fontSize) {
    if (comment.comment.split("\n").length >= 6) {
      if (comment.fontSizeScale != 1.0) {
        return playerHeight / 38;
      } else {
        return playerHeight / 25;
      }
    }
    return fontSize;
  }

  double _resizeWidth(CommentDataObject comment, double fontSize) {
    if (comment.pos == CommentPositoinState.naka) {
      return fontSize;
    }
    final ts = TextStyle(
      fontSize: fontSize,
      height: 1,
    );
    final tempTp = TextPainter(
      text: TextSpan(text: comment.comment, style: ts),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    )..layout();
    if (tempTp.width > playerWidth) {
      return playerWidth / tempTp.width * fontSize;
    }
    return fontSize;
  }
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
      widget.commentObjectList
          .add(CommentObject(widget.screenSize.height, 10, commentdata));
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
