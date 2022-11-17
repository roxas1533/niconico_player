import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'mylist.dart';
import 'parts/utls/common.dart';
import 'setting.dart';

enum OtherPage {
  mylist(MylistPage(), Icons.star, "マイリスト"),
  setting(SettingPage(), Icons.settings, "設定");

  final StatelessWidget page;
  final IconData icon;
  final String label;

  const OtherPage(this.page, this.icon, this.label);
}

class Other extends StatelessWidget {
  const Other({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: topNaviBar("その他"),
        body: ListView.separated(
          itemCount: OtherPage.values.length,
          itemBuilder: (context, index) {
            return InkWell(
                onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => OtherPage.values[index].page,
                      ),
                    ),
                child: ListTile(
                  leading:
                      Icon(OtherPage.values[index].icon, color: Colors.blue),
                  title: Text(OtherPage.values[index].label),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 18, color: Colors.grey),
                ));
          },
          separatorBuilder: (context, index) {
            return const Divider();
          },
        ));
  }
}
