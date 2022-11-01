import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:niconico/contents/history.dart';
import 'package:niconico/contents/nicorepo.dart';
import 'package:niconico/contents/other.dart';
import 'package:niconico/contents/ranking/ranking.dart';
import 'package:niconico/contents/search/search.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

import "constant.dart";
import 'contents/parts/utls/video_detail/video_player/video_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //向き指定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, //縦固定
  ]);
  audioHandler = await AudioService.init(
    builder: () => VideoPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mycompany.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting("ja_JP");
    return MaterialApp(
      title: 'SmilePlayer3',
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
        fontFamily: 'NotoSansCJKJp',
      ),
      home: const WholeWidget(),
    );
  }
}

class WholeWidget extends ConsumerWidget {
  const WholeWidget({super.key});
  final pages = const [
    Ranking(),
    Search(),
    History(),
    Nicorepo(),
    Other(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // appBar: Header(),
      body: PersistentTabView(
        context,
        screens: pages,
        navBarStyle: NavBarStyle.simple,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        items: NaviSelectIndex.values
            .map((e) => PersistentBottomNavBarItem(
                  icon: Icon(
                    e.icon,
                    size: 30,
                  ),
                  title: (e.label),
                  activeColorPrimary: Colors.blue,
                  inactiveColorPrimary: Colors.grey,
                ))
            .toList(),
      ),
    );
  }
}
