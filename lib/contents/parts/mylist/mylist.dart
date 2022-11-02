import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/icon_text_button.dart';
import 'package:niconico/nico_api.dart';

import '../utls/video_list_widget.dart';

class Mylist extends StatefulWidget {
  const Mylist({super.key, required this.mylist});
  final MylistInfo mylist;

  @override
  State<Mylist> createState() => _MylistState();
}

class _MylistState extends State<Mylist> {
  late MylistDetailInfo nicoRepoObject;
  late Future<List<MylistVideoInfo>> videoListFuture;
  int page = 1;
  MylistSort filter = MylistSort.mylistNew;
  Future<List<MylistVideoInfo>> getMylist({next = false}) async {
    if (next) page++;
    final nicorepoList = await getMylistDetail(widget.mylist.id.toString(),
        page: page, sortKey: filter.key, sortOrder: filter.order);

    if (nicorepoList["data"]["mylist"]["items"].isEmpty) {
      return [];
    }

    final List<MylistVideoInfo> videoList = [];
    final data = nicorepoList["data"]["mylist"];

    nicoRepoObject = MylistDetailInfo.fromJson(data);

    for (final d in data["items"]) {
      videoList.add(MylistVideoInfo(d));
    }

    return videoList;
  }

  @override
  void initState() {
    super.initState();
    videoListFuture = getMylist();
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
          title: Text(widget.mylist.name),
          actions: [
            IconButton(
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
                                              filter = MylistSort.values[index];
                                              videoListFuture = getMylist();
                                            }),
                                            Navigator.of(context).pop()
                                          },
                                      title: Text(
                                        MylistSort.values[index].label,
                                        style: const TextStyle(fontSize: 18),
                                      )),
                              itemCount: MylistSort.values.length,
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const Divider(height: 0.5),
                            )),
                          ),
                        );
                      },
                    ),
                icon: const Icon(Icons.tune, color: Colors.blue)),
            // SpaceBox(width: 10)
          ],
        ),
        body: FutureBuilder(
          future: videoListFuture,
          builder: (BuildContext context,
              AsyncSnapshot<List<MylistVideoInfo>?> snapshot) {
            if (snapshot.hasData) {
              final videoList = snapshot.data!;
              if (videoList.isEmpty) {
                return const Center(
                  child: Text("マイリストに動画がありません"),
                );
              }
              return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification &&
                        notification.metrics.extentAfter == 0 &&
                        nicoRepoObject.hasNext) {
                      getMylist(next: true).then((value) {
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
                      child: ListView.separated(
                    itemCount: videoList.length,
                    padding: const EdgeInsets.only(top: 10),
                    itemBuilder: (context, index) {
                      final desc = videoList[index].description;
                      return VideoListWidget(
                        videoInfo: videoList[index],
                        description: desc.isEmpty ? null : desc,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(
                      height: 1,
                      thickness: 1,
                    ),
                  )));
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
