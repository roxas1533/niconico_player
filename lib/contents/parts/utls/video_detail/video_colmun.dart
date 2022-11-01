import 'package:flutter/material.dart';

class VideoColmun extends StatelessWidget {
  const VideoColmun(
      {super.key,
      required this.text,
      this.onTap,
      this.icon = const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      )});
  final String text;
  final Icon icon;
  final void Function(BuildContext nextContext)? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap!(context),
        child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [Expanded(child: Text(text)), icon],
            )));
  }
}
