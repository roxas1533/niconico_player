import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niconico/contents/parts/ranking/ranking_header.dart';

import 'constant.dart';
import 'contents/parts/search/search_header.dart';

class Header extends ConsumerWidget implements PreferredSizeWidget {
  const Header({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ind = ref.watch(naviSelectIndex);
    switch (ref.watch(naviSelectIndex)) {
      case 0:
        return const RankingHeader();
      case 1:
        return const SearchHeader();
    }
    return AppBar(
      centerTitle: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(itemLabel[ind]),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight - 15);
}
