import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/video_list_widget.dart';

class VideoHistoryPage extends StatefulWidget {
  const VideoHistoryPage({super.key});

  @override
  State<VideoHistoryPage> createState() => VideoHistoryPageState();
}

class VideoHistoryPageState extends State<VideoHistoryPage> {
  List<VideoHistoryInfo> videoHistory = [];
  late Future<List<VideoHistoryInfo>> future;

  Future<List<VideoHistoryInfo>> getVideoHistory({next = false}) async {
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
              child: Scrollbar(
                  child: ListView.separated(
                itemCount: snapshot.data!.length,
                padding: const EdgeInsets.only(top: 10),
                itemBuilder: (context, index) {
                  return VideoListWidget(
                    videoInfo: snapshot.data![index],
                    views: snapshot.data![index].views,
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
