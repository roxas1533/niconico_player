import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constant.dart';
import 'contents/history.dart';
import 'contents/nicorepo.dart';
import 'contents/other.dart';
import 'contents/ranking.dart';
import 'contents/search.dart';

class Content extends ConsumerWidget {
  const Content({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (ref.watch(naviSelectIndex)) {
      case 0:
        return const Ranking();
      case 1:
        return const Search();
      case 2:
        return const History();
      case 3:
        return const Nicorepo();
      case 4:
        return const Other();
    }
    return const Center(
      child: Text(
        "this is empty page",
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    );
  }
}
