import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/common.dart';
import 'package:niconico/nico_api.dart';

import '../utls/video_list_widget.dart';

class AllVideoList extends StatefulWidget {
  const AllVideoList({super.key, required this.userInfo});
  final UserInfo userInfo;

  @override
  State<AllVideoList> createState() => _AllVideoListState();
}

class _AllVideoListState extends State<AllVideoList> {
  late int maxPage;
  late Future<List<VideoInfo>> videoListFuture;
  int page = 1;
  int totalCount = 0;
  AllVideoListSort filter = AllVideoListSort.registeredAtD;
  Future<List<VideoInfo>> getAllVideolist({next = false}) async {
    if (next) page++;
    final allVideoList = await getUserVideoList(widget.userInfo.id.toString(),
        page: page, sortKey: filter.key, sortOrder: filter.order);

    if (allVideoList["data"]["items"].isEmpty) {
      return [];
    }

    final List<VideoInfo> videoList = [];

    final data = allVideoList["data"];
    totalCount = data["totalCount"];

    maxPage = (totalCount / 100).round();
    for (final d in data["items"]) {
      videoList.add(VideoInfo.fromJson(d["essential"]));
    }

    return videoList;
  }

  @override
  void initState() {
    super.initState();
    videoListFuture = getAllVideolist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topNaviBar(
        "投稿動画一覧",
        trailing: CupertinoButton(
            onPressed: () => showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    return FractionallySizedBox(
                      heightFactor: 0.8,
                      child: Scaffold(
                        appBar: AppBar(
                          centerTitle: true,
                          elevation: 0,
                          automaticallyImplyLeading: false,
                          title: const Text("絞り込み"),
                          leadingWidth: 100,
                          leading: TextButton(
                            child: const Text(
                              'キャンセル',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        body: Scrollbar(
                            child: ListView.separated(
                          itemBuilder: (BuildContext context, int index) =>
                              ListTile(
                                  trailing: Visibility(
                                      visible: filter.index == index,
                                      child: const Icon(Icons.check,
                                          color: Colors.green)),
                                  onTap: () => {
                                        setState(() {
                                          filter =
                                              AllVideoListSort.values[index];
                                          videoListFuture = getAllVideolist();
                                        }),
                                        Navigator.of(context).pop()
                                      },
                                  title: Text(
                                    AllVideoListSort.values[index].label,
                                    style: const TextStyle(fontSize: 18),
                                  )),
                          itemCount: AllVideoListSort.values.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(height: 0.5),
                        )),
                      ),
                    );
                  },
                ),
            child: const Icon(Icons.tune, color: Colors.blue)),
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
                    getAllVideolist(next: true).then((value) {
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
                          Image.network(
                            widget.userInfo.icon,
                            alignment: Alignment.center,
                            width: size.height * 0.045,
                            fit: BoxFit.fitWidth,
                          ),
                          Container(
                              padding: const EdgeInsets.only(left: 10),
                              alignment: Alignment.centerLeft,
                              child: Text(widget.userInfo.name)),
                        ],
                      )),
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
                      child: Text("$totalCount 件")),
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
      ),
    );
  }
}
