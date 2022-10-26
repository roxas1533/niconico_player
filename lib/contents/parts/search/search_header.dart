import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niconico/constant.dart';

class SearchHeader extends ConsumerWidget {
  const SearchHeader({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      elevation: 0,
      title: SizedBox(
          height: kToolbarHeight - 25,
          child: TextField(
            decoration: const InputDecoration(
              fillColor: Color.fromARGB(255, 53, 53, 53),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (e) =>
                ref.read(SearchParam.searchWord.notifier).state = e.trim(),
          )),
      automaticallyImplyLeading: false,
    );
  }
}
