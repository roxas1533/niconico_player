import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niconico/login.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'parts/utls/common.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: topNaviBar("設定"),
        body: FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SettingsList(
                  sections: [
                    SettingsSection(
                      title: const Text('アカウント'),
                      tiles: <SettingsTile>[
                        SettingsTile(
                            enabled:
                                snapshot.data!.getString("session") == null,
                            title: const Text("ログイン",
                                style: TextStyle(color: Colors.greenAccent)),
                            leading: const Icon(Icons.login,
                                color: Colors.greenAccent),
                            onPressed: (BuildContext context) =>
                                Navigator.of(context, rootNavigator: true)
                                    .pushAndRemoveUntil(
                                        CupertinoPageRoute(
                                            builder: (context) => LoginPage(
                                                  loginState: snapshot.data!,
                                                )),
                                        (_) => false)),
                        SettingsTile(
                            enabled:
                                snapshot.data!.getString("session") != null,
                            title: const Text("ログアウト",
                                style: TextStyle(color: Colors.red)),
                            leading:
                                const Icon(Icons.logout, color: Colors.red),
                            onPressed: (BuildContext context) =>
                                showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                          title: const Text('ログアウトしますか？'),
                                          actions: [
                                            CupertinoDialogAction(
                                              child: const Text('はい',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                              onPressed: () {
                                                snapshot.data!
                                                    .remove('session');
                                                Navigator.pushAndRemoveUntil(
                                                    context,
                                                    CupertinoPageRoute(
                                                        builder: (context) =>
                                                            LoginPage(
                                                              loginState:
                                                                  snapshot
                                                                      .data!,
                                                            )),
                                                    (_) => false);
                                              },
                                            ),
                                            CupertinoDialogAction(
                                              child: const Text('いいえ'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ))),
                        // SettingsTile.switchTile(
                        //   onToggle: (value) {},
                        //   initialValue: true,
                        //   leading: Icon(Icons.format_paint),
                        //   title: Text('Enable custom theme'),
                        // ),
                      ],
                    ),
                  ],
                );
              } else {
                return const Center(child: CupertinoActivityIndicator());
              }
            }));
  }
}
