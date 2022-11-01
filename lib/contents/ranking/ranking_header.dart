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
    return AppBar(
      centerTitle: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text("ランキング"),
      leading: IconButton(
        icon: const Icon(
          Icons.menu,
          color: Colors.blue,
        ),
        onPressed: () => showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: const Genre(),
            );
          },
        ),
      ),
      actions: <Widget>[
        SizedBox(
          width: 120,
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
          ),
        )
      ],
    );
  }
}
