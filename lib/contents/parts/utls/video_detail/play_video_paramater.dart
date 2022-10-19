import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayVideoParam {
  final isPlay = StateProvider((ref) => true);
  final uiVisible = StateProvider((ref) => false);
}
