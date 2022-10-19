import 'package:flutter/material.dart';

class VideoColmun extends StatelessWidget {
  const VideoColmun(
      {super.key,
      required this.text,
      this.icon = const Icon(
        Icons.arrow_forward_ios,
        // Icons.info_outline,
        size: 16,
        color: Colors.grey,
      )});
  final String text;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => {},
        child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [Expanded(child: Text(text)), icon],
            )));
  }
}
