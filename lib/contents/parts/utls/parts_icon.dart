import 'package:flutter/material.dart';

class PartIcon extends StatelessWidget {
  const PartIcon({
    Key? key,
    required this.icon,
    this.size = 11.0,
  }) : super(key: key);
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: Colors.grey,
      size: 11,
    );
  }
}
