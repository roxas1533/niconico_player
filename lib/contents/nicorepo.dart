import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';

import 'parts/nicorepo/user_nicorepo.dart';

class Nicorepo extends StatelessWidget {
  const Nicorepo({super.key});

  @override
  Widget build(BuildContext context) {
    return nicoSession.cookies.isEmpty
        ? const Center(
            child: AutoSizeText(
            "ログインしてください",
            maxLines: 1,
            maxFontSize: 25,
          ))
        : const NicorepoPage(
            userId: null,
          );
  }
}
