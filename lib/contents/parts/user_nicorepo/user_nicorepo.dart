import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/icon_text_button.dart';
import 'package:niconico/nico_api.dart';

import 'nicorepo_widget.dart';

class NicoRepoObject {
  List<NicoRepoInfo> nicorepoList = [];
  bool hasNext = true;
  String id = "";
}

class UserNicoRepo extends StatefulWidget {
  const UserNicoRepo({super.key, required this.userId});
  final String userId;

  @override
  State<UserNicoRepo> createState() => _UserNicoRepoState();
}

class _UserNicoRepoState extends State<UserNicoRepo> {
  final NicoRepoObject nicoRepoObject = NicoRepoObject();
  late Future<List<NicoRepoInfo>> nicorepoFuture;
  Future<List<NicoRepoInfo>> getNicorepoList({next = false}) async {
    final nicorepoList = await getNicorepo(widget.userId,
        untilId: next ? nicoRepoObject.id : null);

    if (nicorepoList.isEmpty) {
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
          title: const Text("ニコレポ"),
        ),
        body: FutureBuilder(
          future: nicorepoFuture,
          builder: (BuildContext context,
              AsyncSnapshot<List<NicoRepoInfo>?> snapshot) {
            if (snapshot.hasData) {
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
