import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niconico/constant.dart';

import 'search.dart';

class SearchHeader extends ConsumerStatefulWidget {
  const SearchHeader({super.key});

  @override
  ConsumerState<SearchHeader> createState() => _SearchHeaderState();
}

class _SearchHeaderState extends ConsumerState<SearchHeader> {
  bool isBanner = false;
  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      middle: SizedBox(
          height: kMinInteractiveDimensionCupertino - 10,
          child: Material(
              child: TextField(
            decoration: InputDecoration(
              fillColor: const Color.fromARGB(255, 53, 53, 53),
              filled: true,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(5),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: PopupMenuButton<int>(
                  child: const Icon(Icons.sort, color: Colors.blue),
                  onSelected: (int item) {
                    ref.read(SearchParam.sort.notifier).state =
                        SortKey.values[item];
                  },
                  itemBuilder: (BuildContext context) =>
                      SortKey.values.asMap().entries.map((e) {
                        return PopupMenuItem<int>(
                          value: e.key,
                          child: Row(children: [
                            Expanded(child: Text(e.value.display)),
                            e.key == ref.read(SearchParam.sort).index
                                ? const Icon(Icons.check, color: Colors.green)
                                : Container()
                          ]),
                        );
                      }).toList()),
            ),
            onSubmitted: (e) =>
                ref.read(SearchParam.searchWord.notifier).state = e.trim(),
          ))),
      automaticallyImplyLeading: false,
    );
  }
}
