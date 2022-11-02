import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/functions.dart';

class VideoDetailCounter extends StatelessWidget {
  const VideoDetailCounter({super.key, required this.video});
  final VideoDetailInfo video;

  Expanded counterItem(int text, String detail) {
    const style = TextStyle(fontSize: 15.3, fontWeight: FontWeight.bold);

    return Expanded(
        child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(numberFormat(text), style: style),
              Text(detail, style: const TextStyle(fontSize: 11.0)),
            ])));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const verticalDriver = VerticalDivider(
      color: Colors.grey,
      thickness: 0.3,
      width: 2,
    );
    return Container(
        // padding: const EdgeInsets.only(bottom: 5.0),
        // margin: const EdgeInsets.all(8.0),
        decoration: const BoxDecoration(
          border: Border.symmetric(
            horizontal: BorderSide(color: Colors.grey, width: 0.4),
          ),
        ),
        width: screenSize.width,
        // height: screenSize.height * 0.07,
        child: IntrinsicHeight(
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              counterItem(video.viewCount, '再生'),
              verticalDriver,
              counterItem(video.commentCount, 'コメント'),
              verticalDriver,
              counterItem(video.mylistCount, 'マイリスト'),
              verticalDriver,
              counterItem(video.goodCount, 'いいね'),
            ],
          ),
        ));
  }
}
