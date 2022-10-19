import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constant.dart';

class Footer extends ConsumerWidget {
  const Footer({
    Key? key,
  }) : super(key: key);
  static const double fontSize = 11;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: ((value) => ref.read(naviSelectIndex.notifier).state = value),
        currentIndex: ref.watch(naviSelectIndex),
        selectedItemColor: Colors.blue,
        selectedIconTheme: const IconThemeData(color: Colors.blue),
        unselectedIconTheme: const IconThemeData(color: Colors.grey),
        selectedFontSize: Footer.fontSize,
        unselectedFontSize: Footer.fontSize,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.emoji_events,
              size: 30.0,
            ),
            label: itemLabel[0],
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.search,
              size: 30.0,
            ),
            label: itemLabel[1],
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.schedule,
              size: 30.0,
            ),
            label: itemLabel[2],
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.newspaper,
              size: 30.0,
            ),
            label: itemLabel[3],
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.settings,
              size: 30.0,
            ),
            label: itemLabel[4],
          ),
        ]);
  }
}
