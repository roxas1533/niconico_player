import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:niconico/constant.dart";
import 'package:niconico/contents/parts/utls/common.dart';

import 'mylist.dart';

class MylistListWidget extends StatelessWidget {
  const MylistListWidget({
    super.key,
    required this.mylistInfto,
  });
  final MylistInfo mylistInfto;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return InkWell(
      onTap: () => Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => Mylist(mylistId: mylistInfto.id))),
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
                const Icon(Icons.folder),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  width: screenSize.width * 0.85,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(mylistInfto.name,
                            style: const TextStyle(fontSize: 14.0),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                          alignment: Alignment.centerLeft,
                          child: Text(mylistInfto.description,
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
}
