import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/mylist/mylist_list_widget.dart';
import 'package:niconico/contents/parts/utls/common.dart';

class MyMylistList extends StatefulWidget {
  const MyMylistList({super.key});

  @override
  State<MyMylistList> createState() => _MyMylistListState();
}

class _MyMylistListState extends State<MyMylistList> {
  Future<List<MylistInfo>> getMylistList() async {
    final mylist = await nicoSession.getMylist("me");
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
                  child: Text("マイリストがありません"),
                );
              }
              final size = MediaQuery.of(context).size;
              return Scrollbar(
                  child: SingleChildScrollView(
                      child: Column(children: [
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
                    isMine: true,
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
