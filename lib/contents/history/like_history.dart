import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/common.dart';
import 'package:niconico/contents/parts/utls/video_list_widget.dart';

class LikeHistoryPage extends StatefulWidget {
  const LikeHistoryPage({super.key});

  @override
  State<LikeHistoryPage> createState() => LikeHistoryPageState();
}

class LikeHistoryPageState extends State<LikeHistoryPage> {
  late Future<List<LikeHistoryInfo>> future;

  Future<List<LikeHistoryInfo>> getLikeHistory({next = false}) async {
    List<LikeHistoryInfo> likeHistory = [];

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
              child: CustomListView(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return VideoListWidget(
                    videoInfo: snapshot.data![index],
                    description: snapshot.data![index].thanksMessage,
                  );
                },
                onRefresh: () async {
                  future = getLikeHistory();

                  setState(() {});
                },
              ));
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
