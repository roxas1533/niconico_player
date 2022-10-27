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
    commentList.render(
      t,
      canvas,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class CommentObject {
  double _x, _y;
  late List<Point> _points;
  late final TextPainter _tp;
  late final TextPainter _ts;
  static double width = 0;
  bool isDead = false;
  double vpos;

  // for debug
  // late String com;

  CommentObject(this._x, this._y, String comment, this.vpos) {
    // com = comment;
    // t = time;
    // _span =
    _tp = TextPainter(
      text: TextSpan(
        text: comment,
        style: const TextStyle(
          fontSize: 29,
          fontFamily: "msgothic",
          fontWeight: FontWeight.w600,
          color: Colors.white,
          shadows: <Shadow>[
            Shadow(
              offset: Offset(1.3, -1.3),
              color: Color.fromARGB(255, 104, 104, 104),
            ),
          ],
        ),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    )..layout();
    _ts = TextPainter(
      text: TextSpan(
          text: comment,
          style: TextStyle(
            fontSize: 29,
            fontFamily: "msgothic",
            fontWeight: FontWeight.w600,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = const Color.fromARGB(255, 104, 104, 104),
          )),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    )..layout();

    _points = [
      Point(width, vpos),
      Point(width + _tp.width, vpos),
      Point(0, vpos + 4000),
      Point(-_tp.width, vpos + 4000),
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

  void setPosType(int type) {
    _y = 30 * type.toDouble();
  }

  void render(double t, Canvas canvas) {
    _ts.paint(canvas, Offset(_x, _y));

    _tp.paint(canvas, Offset(_x, _y));
  }

  void update(double dt, int time) {
    // final double speed = ((width + _tp.width) / (4000)) * (dt * 1000);
    final double speed = ((width + _tp.width) / (4000));
    final relativeTime = vpos - time;
    // debugPrint("$time,$relativeTime");

    // _x -= speed;
    _x = relativeTime * speed + width / 2;
    if (_x + _tp.width < 0) {
      isDead = true;
    }
  }
}

class CommentObjectList {
  List<List<CommentObject>> list = List.generate(11, (_) => []);
  int time = 0;
  bool isPlaying = false;
  List<CommentDataObject> commentDataList = [];
  CommentObjectList(Map<String, dynamic> commnetDataMap) {
    final threads = commnetDataMap["data"]["threads"];
    for (final thread in threads) {
      final comments = thread["comments"];
      for (final comment in comments) {
        commentDataList.add(CommentDataObject(
            comment["body"], comment["vposMs"], comment["nicoruCount"]));
      }
    }
    commentDataList.sort((a, b) => a.vpos.compareTo(b.vpos));
  }

  void add(CommentObject comment) {
    for (int i = 0; i < list.length; i++) {
      if (list[i].isEmpty) {
        list[i].add(comment);
        // for debug
        // print("${comment.com},$i,${comment._points},${comment.t}");
        break;
      }
      if (comment.calcuatePos(list[i].last)) {
        comment.setPosType(i + 1);
        continue;
      }
      list[i].add(comment);

      break;
    }
  }

  void update(double t) {
    if (isPlaying) {
      time += (t * 1000).toInt();
      for (final List<CommentObject> commentPos in list) {
        for (final CommentObject comment in commentPos) {
          comment.update(t, time);
        }
      }
    }
  }

  void render(double t, Canvas canvas) {
    for (final List<CommentObject> commentPos in list) {
      for (final CommentObject comment in commentPos) {
        comment.render(t, canvas);
      }
    }
  }

  void removeDead() {
    for (final List<CommentObject> commentPos in list) {
      commentPos.removeWhere((element) => element.isDead);
    }
  }
}

class CommentDataObject {
  final String comment;
  final int vpos;
  int nicoruCount;
  bool isCommented = false;
  CommentDataObject(this.comment, this.vpos, this.nicoruCount);
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
    CommentObject.width = widget.screenSize.height;
    for (final commentdata in widget.commentObjectList.commentDataList) {
      // if (!commentdata.isCommented &&
      //     commentdata.vpos <= widget.commentObjectList.time) {
      // commentdata.isCommented = true;
      widget.commentObjectList.add(CommentObject(widget.screenSize.height, 0,
          commentdata.comment, commentdata.vpos.toDouble()));
      // break;
      // }
    }
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext contex, Widget? child) {
        // widget.commentObjectList.removeDead();
        final curr = currentTime;
        final dt = curr - previous;
        previous = curr;
        // if (widget.commentObjectList.isPlaying) {

        // }
        return CustomPaint(
          size: widget.screenSize,
          painter: CommentPainter(widget.commentObjectList, dt),
        );
      },
      // ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     setState(() {});
      //     final newComment = CommentObject(
      //         widget.screenSize.height,
      //         0,
      //         [for (int i = 0; i < Random().nextInt(26) + 1; i++) "a"].join(""),
      //         widget.screenSize.height);
      //     commentList.add(newComment);
      //   },
      //   child: const Icon(Icons.add),
      // ),
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
