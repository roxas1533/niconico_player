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
    return IndexedStack(
      index: ref.watch(naviSelectIndex),
      children: <Widget>[
        const Ranking(),
        Search(),
        const History(),
        const Nicorepo(),
        const Other(),
      ],
    );
  }
}
