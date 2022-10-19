import 'package:flutter/material.dart';

class RankingNumber extends StatelessWidget {
  const RankingNumber({
    Key? key,
    required this.rank,
  }) : super(key: key);
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.3,
      child: Text(
        rank.toString(),
        style: const TextStyle(
          fontSize: 35.0,
          color: Colors.grey,
        ),
      ),
    );
  }
}
