import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/icon_text_button.dart';
import 'package:niconico/nico_api.dart';

import '../utls/video_list_widget.dart';

class Mylist extends StatefulWidget {
  const Mylist({super.key, required this.mylistId});
  final int mylistId;

  @override
  State<Mylist> createState() => _MylistState();
}

class _MylistState extends State<Mylist> {
  late MylistDetailInfo mylistDetailObject;
  late Future<List<MylistVideoInfo>> videoListFuture;
  int page = 1;
  MylistSort filter = MylistSort.mylistNew;
  Future<List<MylistVideoInfo>> getMylist({next = false}) async {
    if (next) page++;
    final mylistList = await getMylistDetail(widget.mylistId.toString(),
        page: page, sortKey: filter.key, sortOrder: filter.order);

    if (mylistList["data"]["mylist"]["items"].isEmpty) {
      return [];
    }

    final List<MylistVideoInfo> videoList = [];
    final data = mylistList["data"]["mylist"];

    mylistDetailObject = MylistDetailInfo.fromJson(data);

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
          title: const Text("マイリスト"),
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
                  child: Text("動画がありません"),
                );
              }
              final size = MediaQuery.of(context).size;

              return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification &&
                        notification.metrics.extentAfter == 0 &&
                        mylistDetailObject.hasNext) {
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
                      child: SingleChildScrollView(
                          child: Column(children: [
                    Container(
                        padding: const EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        child: Text(mylistDetailObject.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        child: Row(
                          children: [
                            Image.network(
                              mylistDetailObject.userInfo.icon,
                              alignment: Alignment.center,
                              width: size.height * 0.045,
                              fit: BoxFit.fitWidth,
                            ),
                            Container(
                                padding: const EdgeInsets.only(left: 10),
                                alignment: Alignment.centerLeft,
                                child: Text(mylistDetailObject.userInfo.name)),
                          ],
                        )),
                    Html(
                      data: mylistDetailObject.decoratedDescriptionHtml,
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
                        child: Text("${mylistDetailObject.totalItemCount} 件")),
                    ListView.separated(
                      primary: false,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
