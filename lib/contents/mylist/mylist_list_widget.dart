import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:niconico/constant.dart";
import 'package:niconico/contents/parts/utls/common.dart';

import 'mylist.dart';

class MylistListWidget extends StatelessWidget {
  const MylistListWidget(
      {super.key, required this.mylistInfo, this.isMine = false});
  final MylistInfo mylistInfo;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return InkWell(
      onTap: () => Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) =>
              Mylist(mylistId: mylistInfo.id, isMine: isMine))),
      child: Container(
        margin: const EdgeInsets.only(left: 15.0),
        width: screenSize.width,
        height: screenSize.height * 0.08,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: const [
              Icon(Icons.arrow_forward_ios, size: 15.0, color: Colors.grey),
              SpaceBox(width: 10),
            ]),
            Row(
              children: [
                getFolderIcon(mylistInfo.isPublic),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  width: screenSize.width * 0.85,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(mylistInfo.name,
                            style: const TextStyle(fontSize: 14.0),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                          alignment: Alignment.centerLeft,
                          child: Text(mylistInfo.description,
                              style: const TextStyle(
                                  fontSize: 11.0, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getFolderIcon(bool isPublic) {
    if (isPublic) {
      return const Icon(Icons.folder_outlined);
    } else {
      return Stack(
        children: const [
          Icon(Icons.folder_outlined),
          Positioned(
              right: 3,
              bottom: 6,
              child: Icon(Icons.lock, size: 9.0, color: Colors.grey)),
        ],
      );
    }
  }
}
