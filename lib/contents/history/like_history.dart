import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/video_list_widget.dart';

class LikeHistoryPage extends StatefulWidget {
  const LikeHistoryPage({super.key});

  @override
  State<LikeHistoryPage> createState() => LikeHistoryPageState();
}

class LikeHistoryPageState extends State<LikeHistoryPage> {
  List<LikeHistoryInfo> likeHistory = [];
  late Future<List<LikeHistoryInfo>> future;

  Future<List<LikeHistoryInfo>> getLikeHistory({next = false}) async {
    final videoHistoryData = await nicoSession.getHistory(1);
    if (videoHistoryData["data"]["items"].isEmpty) {
      return [];
    }
    final data = videoHistoryData["data"]["items"];
    for (final d in data) {
      likeHistory.add(LikeHistoryInfo(d));
    }

    return likeHistory;
  }

  @override
  void initState() {
    super.initState();
    future = getLikeHistory();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context,
          AsyncSnapshot<List<LikeHistoryInfo>?> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text("いいね履歴はありません"),
            );
          }
          return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.extentAfter == 0) {
                  // getNicorepoList(next).then((value) {
                  //   if (value.isNotEmpty) setState(() {});
                  // });
                  return true;
                }
                return false;
              },
              child: Scrollbar(
                  child: ListView.separated(
                itemCount: snapshot.data!.length,
                padding: const EdgeInsets.only(top: 10),
                itemBuilder: (context, index) {
                  return VideoListWidget(
                    videoInfo: snapshot.data![index],
                    description: snapshot.data![index].thanksMessage,
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(height: 0.5);
                },
              )));
        } else {
          return Container(
              alignment: Alignment.center,
              child: const CupertinoActivityIndicator(
                color: Colors.grey,
              ));
        }
      },
    );
  }
}
