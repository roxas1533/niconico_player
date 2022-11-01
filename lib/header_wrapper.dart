import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Header extends ConsumerWidget implements PreferredSizeWidget {
  const Header({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return child;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight - 15);
}
