import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constant.dart';
import 'ranking.dart';

class Genre extends ConsumerWidget {
  const Genre({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genreList = genreMap.entries.map((e) => e.value).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("カテゴリ"),
        leadingWidth: 100,
        leading: TextButton(
          child: const Text(
            'キャンセル',
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.blue, //文字の色を白にする
              fontWeight: FontWeight.bold, //文字を太字する
              fontSize: 14.0, //文字のサイズを調整する
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Scrollbar(
        child: ListView.separated(
          itemCount: genreList.length,
          itemBuilder: (context2, index) => InkWell(
            // padding: const EdgeInsets.all(11.0),
            // color: Colors.orange,
            splashColor: Colors.orange,
            child: ListTile(
                trailing: Visibility(
                    visible: ref.watch(RankingParam.genreId) == index,
                    child: const Icon(Icons.check, color: Colors.green)),
                onTap: () => {
                      ref.watch(RankingParam.genreId.notifier).state = index,
                      Navigator.of(context).pop()
                    },
                title: Text(
                  genreList[index],
                  style: const TextStyle(fontSize: 18),
                )),
          ),
          separatorBuilder: (context, index) {
            return const Divider(height: 0.5);
          },
        ),
      ),
    );
  }
}