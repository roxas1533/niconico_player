import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/common.dart';
import 'package:niconico/nico_api.dart';

import 'series_list_widget.dart';

class SeriesList extends StatefulWidget {
  const SeriesList({super.key, required this.userInfo});
  final UserInfo userInfo;

  @override
  State<SeriesList> createState() => _SeriesListState();
}

class _SeriesListState extends State<SeriesList> {
  late int totalCount;
  Future<List<SeriesInfo>> getSeriesList() async {
    final sereisRes = await getSeries(widget.userInfo.id);
    if (sereisRes["data"]["items"].isEmpty) {
      return [];
    }

    final List<SeriesInfo> seriesList = [];

    final data = sereisRes["data"]["items"];
    totalCount = sereisRes["data"]["totalCount"];

    for (final d in data) {
      seriesList.add(SeriesInfo(d));
    }

    return seriesList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: topNaviBar("シリーズ一覧"),
        body: FutureBuilder(
          future: getSeriesList(),
          builder: (BuildContext context,
              AsyncSnapshot<List<SeriesInfo>?> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("シリーズがありません"),
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
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => SeriesListWidget(
                    seriesInfto: snapshot.data![index],
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
