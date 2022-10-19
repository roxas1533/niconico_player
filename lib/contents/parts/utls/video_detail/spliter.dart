import 'package:flutter/material.dart';

class Spliter extends StatelessWidget {
  const Spliter({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 5),
      width: screenSize.width,
      color: Colors.black12,
      child: Text(text,
          style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
    );
  }
}
