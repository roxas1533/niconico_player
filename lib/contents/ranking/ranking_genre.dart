import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constant.dart';
import 'ranking.dart';

class Genre extends ConsumerWidget {
  const Genre({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          itemCount: GenreKey.values.length,
          itemBuilder: (context2, index) => InkWell(
            // padding: const EdgeInsets.all(11.0),
            // color: Colors.orange,
            splashColor: Colors.orange,
            child: ListTile(
                trailing: Visibility(
                    visible: ref.watch(RankingParam.genreId) ==
                        GenreKey.values[index],
                    child: const Icon(Icons.check, color: Colors.green)),
                onTap: () => {
                      ref.watch(RankingParam.genreId.notifier).state =
                          GenreKey.values[index],
                      // ref.watch(RankingParam.popularTagFuture).state =
                      //     getPopulerTag(GenreKey.values[index].key),
                      Navigator.of(context).pop()
                    },
                title: Text(
                  GenreKey.values[index].label,
                  style: const TextStyle(fontSize: 18),
                )),
          ),
          separatorBuilder: (context, index) => const Divider(height: 0.5),
        ),
      ),
    );
  }
}
