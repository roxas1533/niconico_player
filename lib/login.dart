import 'package:flutter/material.dart';
import 'package:niconico/contents/parts/utls/common.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constant.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key, required this.loginProcess, required this.loginState});
  final Function(BuildContext context) loginProcess;
  final SharedPreferences loginState;
  final _idFieldController = TextEditingController();
  final _passFieldController = TextEditingController();

  InputDecoration getinput(BuildContext context, String text) =>
      InputDecoration(
        labelText: text,
        fillColor: Theme.of(context).cardColor,
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: Theme.of(context).cardColor,
            width: 1.0,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        body: Column(children: [
      SpaceBox(height: size.height * 0.1),
      const Text("ニコニコログイン",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          )),
      SpaceBox(height: size.height * 0.1),
      Container(
          alignment: Alignment.center,
          child: SizedBox(
            width: size.width * 0.75,
            child: Column(children: [
              TextField(
                controller: _idFieldController,
                keyboardType: TextInputType.emailAddress,
                decoration: getinput(context, "メールアドレス"),
              ),
              SpaceBox(height: size.height * 0.05),
              TextField(
                controller: _passFieldController,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                decoration: getinput(context, "パスワード"),
              ),
            ]),
          )),
      SpaceBox(height: size.height * 0.05),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.lightBlue,
        ),
        onPressed: () {
          // print(_idFieldController.text);
          // print(_passFieldController.text);
          nicoSession
              .login(_idFieldController.text, _passFieldController.text)
              .then((value) {
            if (value != null) {
              loginState.setString("session", value);
              loginProcess(context);
            } else {
              print("ログイン失敗");
            }
          });
        },
        child: const Text('ログイン', style: TextStyle(fontSize: 20)),
      ),
      GestureDetector(
          onTap: () {
            loginProcess(context);
          },
          child: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Text('スキップ',
                  style: TextStyle(color: Colors.lightBlue)))),
    ]));
  }
}
