import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/common.dart';
import 'package:niconico/contents/parts/utls/video_list_widget.dart';

class VideoHistoryPage extends StatefulWidget {
  const VideoHistoryPage({super.key});

  @override
  State<VideoHistoryPage> createState() => VideoHistoryPageState();
}

class VideoHistoryPageState extends State<VideoHistoryPage> {
  late Future<List<VideoHistoryInfo>> future;

  Future<List<VideoHistoryInfo>> getVideoHistory({next = false}) async {
    List<VideoHistoryInfo> videoHistory = [];

    final videoHistoryData = await nicoSession.getHistory(0);
    if (videoHistoryData["data"]["items"].isEmpty) {
      return [];
    }
    final data = videoHistoryData["data"]["items"];
    for (final d in data) {
      videoHistory.add(VideoHistoryInfo(d));
    }

    return videoHistory;
  }

  @override
  void initState() {
    super.initState();
    future = getVideoHistory();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context,
          AsyncSnapshot<List<VideoHistoryInfo>?> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text("視聴履歴はありません"),
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
                    views: snapshot.data![index].views,
                  );
                },
                onRefresh: () async {
                  future = getVideoHistory();
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
