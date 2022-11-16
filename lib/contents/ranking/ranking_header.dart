import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niconico/contents/ranking/ranking_genre.dart';

import 'ranking.dart';

class RankingHeader extends ConsumerWidget {
  const RankingHeader({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tag = ref.watch(RankingParam.tag);
    return CupertinoNavigationBar(
        middle: Column(children: [
          const Text("ランキング"),
          Text(ref.watch(RankingParam.genreId).label,
              style: const TextStyle(fontSize: 11))
        ]),
        leading: CupertinoButton(
          child: const Icon(
            Icons.menu,
            color: Colors.blue,
          ),
          onPressed: () => showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return const FractionallySizedBox(
                heightFactor: 0.8,
                child: Genre(),
              );
            },
          ),
        ),
        trailing: SizedBox(
          width: 120,
          child: Material(
              child: DropdownButton(
            style: const TextStyle(fontSize: 11),
            isExpanded: true,
            itemHeight: 48.0,
            items: RankingParam.termKey.keys.toList().asMap().entries.map((e) {
              final isEnable = e.key < 2 ? true : (tag == "すべて" ? true : false);
              return DropdownMenuItem<String>(
                value: e.value,
                enabled: isEnable,
                child: Text(RankingParam.termKey[e.value]!,
                    style: TextStyle(
                        color: isEnable ? Colors.white : Colors.grey)),
              );
            }).toList(),
            onChanged: (String? value) {
              ref.read(RankingParam.term.notifier).state = value!;
            },
            value: ref.watch(RankingParam.term),
          )),
        ));
  }
}
