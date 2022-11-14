import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/common.dart';
import 'package:niconico/header_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nicorepo_widget.dart';

class NicoRepoObject {
  List<NicoRepoInfo> nicorepoList = [];
  bool hasNext = true;
  String id = "";
}

class NicorepoPage extends StatefulWidget {
  const NicorepoPage({super.key, required this.userId});
  final String? userId;

  @override
  State<NicorepoPage> createState() => NicorepoPageState();
}

class NicorepoPageState extends State<NicorepoPage> {
  NicoRepoObject nicoRepoObject = NicoRepoObject();
  late Future<List<NicoRepoInfo>> nicorepoFuture;
  late SharedPreferences prefs;

  late int filter;
  Future<List<NicoRepoInfo>> getNicorepoList({next = false}) async {
    prefs = await SharedPreferences.getInstance();
    filter = prefs.getInt("NicoRepoFilter") ?? 0;
    final nicorepoList = await nicoSession.getNicorepo(widget.userId,
        untilId: next ? nicoRepoObject.id : null,
        objectType: UserNicoRepoOrder.values[filter].objectType,
        type: UserNicoRepoOrder.values[filter].type);

    if (nicorepoList["data"].isEmpty) {
      return [];
    }
    final data = nicorepoList["data"];
    for (final d in data) {
      nicoRepoObject.nicorepoList.add(NicoRepoInfo.fromJson(d));
    }

    nicoRepoObject.hasNext = nicorepoList["meta"]["hasNext"];
    nicoRepoObject.id = data.last["id"];

    return nicoRepoObject.nicorepoList;
  }

  @override
  void initState() {
    super.initState();
    nicorepoFuture = getNicorepoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header(
            child: topNaviBar(
          "ニコレポ",
          autoBack: widget.userId != null ? true : false,
          trailing: CupertinoButton(
              onPressed: () => showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return FractionallySizedBox(
                        heightFactor: 0.8,
                        child: Scaffold(
                          appBar: topNaviBar(
                            "絞り込み",
                            leading: topBackButton(context),
                          ),
                          body: ListView.separated(
                            itemBuilder: (BuildContext context, int index) =>
                                ListTile(
                                    trailing: Visibility(
                                        visible: filter == index,
                                        child: const Icon(Icons.check,
                                            color: Colors.green)),
                                    onTap: () => {
                                          setState(() {
                                            filter = index;
                                            prefs.setInt(
                                                "NicoRepoFilter", filter);
                                            nicoRepoObject = NicoRepoObject();
                                            nicorepoFuture = getNicorepoList();
                                          }),
                                          Navigator.of(context).pop()
                                        },
                                    title: Text(
                                      UserNicoRepoOrder.values[index].label,
                                      style: const TextStyle(fontSize: 18),
                                    )),
                            itemCount: UserNicoRepoOrder.values.length,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(height: 0.5),
                          ),
                        ),
                      );
                    },
                  ),
              child: const Icon(Icons.tune, color: Colors.blue)),
          // SpaceBox(width: 10)
        )),
        body: FutureBuilder(
          future: nicorepoFuture,
          builder: (BuildContext context,
              AsyncSnapshot<List<NicoRepoInfo>?> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("ニコレポがありません"),
                );
              }
              return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification &&
                        notification.metrics.extentAfter == 0 &&
                        nicoRepoObject.hasNext) {
                      getNicorepoList(next: true).then((value) {
                        if (value.isNotEmpty) setState(() {});
                      });
                      return true;
                    }
                    return false;
                  },
                  child: Scrollbar(
                      child: ListView.separated(
                    itemCount: snapshot.data!.length,
                    padding: const EdgeInsets.only(top: 10),
                    itemBuilder: (context, index) => NicorepoWidget(
                      nicoRepoInfo: snapshot.data![index],
                    ),
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
        ));
  }
}
