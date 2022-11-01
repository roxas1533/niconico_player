import 'package:flutter/material.dart';

class PartIcon extends StatelessWidget {
  const PartIcon({
    super.key,
    required this.icon,
    this.size = 11.0,
  });
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
