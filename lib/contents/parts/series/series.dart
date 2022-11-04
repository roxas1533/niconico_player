import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/icon_text_button.dart';
import 'package:niconico/nico_api.dart';

import '../utls/video_list_widget.dart';

class Series extends StatefulWidget {
  const Series({super.key, required this.seriesInfo});
  final SeriesInfo seriesInfo;

  @override
  State<Series> createState() => _SeriesState();
}

class _SeriesState extends State<Series> {
  late int maxPage;
  late Future<List<VideoInfo>> videoListFuture;
  late UserInfo owner;
  int page = 1;
  int totalCount = 0;
  late String decoratedDescriptionHtml;
  Future<List<VideoInfo>> getSeriesVideo({next = false}) async {
    if (next) page++;
    final seriesVideoData = await getSeriesDetail(widget.seriesInfo.id, page);

    if (seriesVideoData["data"]["items"].isEmpty) {
      return [];
    }

    final List<VideoInfo> videoList = [];

    final data = seriesVideoData["data"];
    totalCount = data["totalCount"];

    maxPage = (totalCount / 100).round();
    for (final d in data["items"]) {
      videoList.add(VideoInfo.fromJson(d["video"]));
    }
    owner = UserInfo(
        icon: data["detail"]["owner"]["user"]["icons"]["small"],
        name: data["detail"]["owner"]["user"]["nickname"],
        id: data["detail"]["owner"]["id"]);
    decoratedDescriptionHtml = data["detail"]["decoratedDescriptionHtml"];

    return videoList;
  }

  @override
  void initState() {
    super.initState();
    videoListFuture = getSeriesVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          leadingWidth: 80,
          automaticallyImplyLeading: false,
          leading: IconTextButton(
            text: const Text("戻る",
                style: TextStyle(color: Colors.blue, fontSize: 19)),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.blue,
            ),
            onPressed: () => Navigator.pop(context),
            margin: 0,
          ),
          title: const Text("シリーズ"),
        ),
        body: FutureBuilder(
          future: videoListFuture,
          builder:
              (BuildContext context, AsyncSnapshot<List<VideoInfo>?> snapshot) {
            if (snapshot.hasData) {
              final videoList = snapshot.data!;
              if (videoList.isEmpty) {
                return const Center(
                  child: Text("動画がありません"),
                );
              }
              final size = MediaQuery.of(context).size;

              return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification &&
                        notification.metrics.extentAfter == 0 &&
                        maxPage > page) {
                      getSeriesVideo(next: true).then((value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            videoList.addAll(value);
                          });
                        }
                      });
                      return true;
                    }
                    return false;
                  },
                  child: Scrollbar(
                      child: SingleChildScrollView(
                          child: Column(children: [
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        child: Row(
                          children: [
                            const Icon(Icons.video_library, size: 30),
                            Container(
                                padding: const EdgeInsets.only(left: 10),
                                alignment: Alignment.centerLeft,
                                child: Text(widget.seriesInfo.title,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold))),
                          ],
                        )),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        child: Row(
                          children: [
                            Image.network(
                              owner.icon,
                              alignment: Alignment.center,
                              width: size.height * 0.045,
                              fit: BoxFit.fitWidth,
                            ),
                            Container(
                                padding: const EdgeInsets.only(left: 10),
                                alignment: Alignment.centerLeft,
                                child: Text(owner.name)),
                          ],
                        )),
                    Html(
                      data: decoratedDescriptionHtml,
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        height: size.height * 0.05,
                        decoration: const BoxDecoration(
                            border: Border.symmetric(
                          horizontal: BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        )),
                        child: Text("$totalCount 動画")),
                    ListView.separated(
                      primary: false,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: videoList.length,
                      padding: const EdgeInsets.only(top: 10),
                      itemBuilder: (context, index) {
                        return VideoListWidget(
                          videoInfo: videoList[index],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(
                        height: 1,
                        thickness: 1,
                      ),
                    )
                  ]))));
            } else {
              return Container(
                  alignment: Alignment.center,
                  child: const CupertinoActivityIndicator(
                    color: Colors.grey,
                  ));
            }
          },
        ));
  }
}
