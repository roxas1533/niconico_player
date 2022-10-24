import 'package:flutter/material.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({Key? key}) : super(key: key);

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage>
    with SingleTickerProviderStateMixin {
  var position = 0.0;
  late AnimationController _animationController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        // alignment: Alignment.center,
        children: [
          PositionedTransition(
            rect: RelativeRectTween(
              begin: const RelativeRect.fromLTRB(100, 0, 0, 0),
              end: const RelativeRect.fromLTRB(0, 0, 100, 0),
            ).animate(CurvedAnimation(
                parent: _animationController, curve: Curves.linear)),
            child: const Text(
              'Hello',
              style: TextStyle(
                fontSize: 30,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
