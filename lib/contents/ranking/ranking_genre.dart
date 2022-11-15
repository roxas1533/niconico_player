import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niconico/contents/parts/utls/common.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant.dart';
import 'ranking.dart';

class Genre extends ConsumerWidget {
  const Genre({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: topNaviBar(
        "カテゴリ",
        leading: topBackButton(context),
      ),
      child: Scrollbar(
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
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setInt("genreId", GenreKey.values[index].index);
                      }),
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
