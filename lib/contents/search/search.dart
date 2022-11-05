import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/header_wrapper.dart';

import 'search_core.dart';
import 'search_header.dart';

abstract class SearchParam {
  static final searchWord = StateProvider((ref) => "");
  static final sort = StateProvider((ref) => SortKey.popular);
}

class Search extends ConsumerWidget {
  const Search({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: const Header(child: SearchHeader()),
        body: SearchCore(
            searchWord: ref.watch(SearchParam.searchWord),
            sort: ref.watch(SearchParam.sort)));
  }
}
