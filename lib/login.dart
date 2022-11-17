import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niconico/contents/parts/utls/common.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constant.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.loginState});
  final SharedPreferences loginState;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idFieldController = TextEditingController();
  final _passFieldController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool failedLogin = false;
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

  String? vailgator(String? value) {
    if (value == null || value.isEmpty) {
      return "入力してください";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(children: [
          SpaceBox(height: size.height * 0.1),
          const Text("ニコニコログイン",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              )),
          SpaceBox(height: size.height * 0.05),
          failedLogin
              ? const Text("ログインに失敗しました", style: TextStyle(color: Colors.red))
              : const SizedBox(),
          SpaceBox(height: size.height * 0.1),
          Container(
              alignment: Alignment.center,
              child: SizedBox(
                  width: size.width * 0.75,
                  child: Form(
                    key: formKey,
                    child: Column(children: [
                      TextFormField(
                        controller: _idFieldController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: getinput(context, "メールアドレス"),
                        validator: vailgator,
                      ),
                      SpaceBox(height: size.height * 0.05),
                      TextFormField(
                        controller: _passFieldController,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: getinput(context, "パスワード"),
                        validator: vailgator,
                      ),
                    ]),
                  ))),
          SpaceBox(height: size.height * 0.05),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.lightBlue,
            ),
            onPressed: () {
              primaryFocus?.unfocus();
              if (formKey.currentState!.validate()) {
                nicoSession
                    .login(_idFieldController.text, _passFieldController.text)
                    .then((value) {
                  if (value != null) {
                    widget.loginState.setString("session", value);

                    _loginPorcess(context);
                  } else {
                    setState(() {
                      failedLogin = true;
                    });
                  }
                });
              }
            },
            child: const Text('ログイン', style: TextStyle(fontSize: 20)),
          ),
          GestureDetector(
              onTap: () {
                _loginPorcess(context);
              },
              child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Text('スキップ',
                      style: TextStyle(color: Colors.lightBlue)))),
        ]));
  }

  void _loginPorcess(context) => {
        Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (context) => const MainPage(savedData: null),
        ))
      };
}
