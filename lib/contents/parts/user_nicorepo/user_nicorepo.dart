import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/icon_text_button.dart';
import 'package:niconico/nico_api.dart';

import 'nicorepo_widget.dart';

class NicoRepoObject {
  List<NicoRepoInfo> nicorepoList = [];
  bool isEnd = false;
}

class UserNicoRepo extends StatelessWidget {
  UserNicoRepo({
    super.key,
    required this.userId,
  });
  final String userId;
  final NicoRepoObject nicoRepoObject = NicoRepoObject();

  Future<List<NicoRepoInfo>> getNicorepoList() async {
    final nicorepoList = await getNicorepo(userId);
    if (nicorepoList.isEmpty) {
      return [];
    }
    final data = nicorepoList["data"];
    for (final d in data) {
      nicoRepoObject.nicorepoList.add(NicoRepoInfo.fromJson(d));
    }

    return nicoRepoObject.nicorepoList;
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
          future: getNicorepoList(),
          builder: (BuildContext context,
              AsyncSnapshot<List<NicoRepoInfo>?> snapshot) {
            if (snapshot.hasData) {
              return Scrollbar(
                  // margin: EdgeInsets.only(top: 10),
                  child: ListView.separated(
                itemCount: snapshot.data!.length,
                padding: const EdgeInsets.only(top: 10),
                itemBuilder: (context, index) => NicorepoWidget(
                  nicoRepoInfo: snapshot.data![index],
                ),
                separatorBuilder: (context, index) {
                  return const Divider(height: 0.5);
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
        ));
  }
}
