import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/mylist/mylist_list_widget.dart';
import 'package:niconico/contents/parts/utls/common.dart';

class MylistList extends StatefulWidget {
  const MylistList({super.key, required this.userInfo});
  final UserInfo userInfo;

  @override
  State<MylistList> createState() => _MylistListState();
}

class _MylistListState extends State<MylistList> {
  Future<List<MylistInfo>> getMylistList() async {
    final mylist = await nicoSession.getMylist(widget.userInfo.id);
    if (mylist["data"].isEmpty) {
      return [];
    }
    final List<MylistInfo> mylistList = [];

    final data = mylist["data"]["mylists"];
    for (final d in data) {
      mylistList.add(MylistInfo.fromJson(d));
    }

    return mylistList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: topNaviBar("マイリスト一覧"),
        body: FutureBuilder(
          future: getMylistList(),
          builder: (BuildContext context,
              AsyncSnapshot<List<MylistInfo>?> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("公開マイリストがありません"),
                );
              }
              final size = MediaQuery.of(context).size;
              return Scrollbar(
                  child: SingleChildScrollView(
                      child: Column(children: [
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    child: Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.userInfo.icon,
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
                    child: Text("${snapshot.data!.length} 件")),
                ListView.separated(
                  primary: false,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => MylistListWidget(
                    mylistInfo: snapshot.data![index],
                  ),
                  separatorBuilder: (context, index) {
                    return const Divider(
                      height: 0.5,
                      thickness: 1,
                    );
                  },
                )
              ])));
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
