import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/mylist/my_mylist_list.dart';

class MylistPage extends StatelessWidget {
  const MylistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return nicoSession.cookies.isEmpty
        ? const Center(
            child: AutoSizeText(
            "ログインしてください",
            maxLines: 1,
            maxFontSize: 25,
          ))
        : const MyMylistList();
  }
}
