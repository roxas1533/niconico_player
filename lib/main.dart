import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niconico/contents/history.dart';
import 'package:niconico/contents/nicorepo.dart';
import 'package:niconico/contents/other.dart';
import 'package:niconico/contents/ranking/ranking.dart';
import 'package:shared_preferences/shared_preferences.dart';

import "constant.dart";
import 'contents/parts/utls/video_detail/video_player/video_player.dart';
import 'contents/search/search.dart';
import 'login.dart';

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

const CupertinoThemeData cupertinoDark = CupertinoThemeData(
  brightness: Brightness.dark,
  textTheme: CupertinoTextThemeData(
    dateTimePickerTextStyle: TextStyle(
      color: Colors.white,
      // fontSize: 16,
    ),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MediaQuery.fromWindow(
        child: MaterialApp(
      useInheritedMediaQuery: true,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', ''), //日本語
        Locale('en', ''), //英語
      ],
      title: 'SmilePlayer3',
      // theme: ,
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color.fromARGB(255, 22, 22, 22),
          canvasColor: CupertinoColors.black,
          cupertinoOverrideTheme: const CupertinoThemeData(
              brightness: Brightness.dark,
              primaryColor: CupertinoColors.systemBlue,
              textTheme: CupertinoTextThemeData(),
              barBackgroundColor: CupertinoColors.systemBackground)),
      home: const WholeWidget(),
    ));
  }
}

class WholeWidget extends ConsumerWidget {
  const WholeWidget({super.key});

  Future<SharedPreferences> _checkCookie() async {
    final pref = await SharedPreferences.getInstance();
    if (pref.getString("session") == null) {
      return pref;
    }
    final result = await nicoSession.getHistory(0, pageSize: 1);
    if (result.isEmpty) {
      pref.remove("session");
    }
    return pref;
  }

  void loginPorcess(context) => {
        Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: const MainPage()),
        ))
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
        child: FutureBuilder<SharedPreferences>(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.getString("session") != null) {
            nicoSession.parseCookies(snapshot.data!.getString("session")!);
            return const MainPage();
          } else {
            return LoginPage(
              loginProcess: loginPorcess,
              loginState: snapshot.data!,
            );
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
      future: _checkCookie(),
    ));
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});
  final pages = const [
    Ranking(),
    Search(),
    History(),
    Nicorepo(),
    Other(),
  ];
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      // backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
      tabBar: CupertinoTabBar(
        items: NaviSelectIndex.values
            .map((e) => BottomNavigationBarItem(
                  icon: Icon(
                    e.icon,
                    size: 30,
                  ),
                  label: (e.label),
                  // activeColorPrimary: Colors.blue,
                  // inactiveColorPrimary: Colors.grey,
                ))
            .toList(),
      ),
      tabBuilder: (context, index) =>
          CupertinoTabView(builder: (context) => pages[index]),
    );
  }
}
