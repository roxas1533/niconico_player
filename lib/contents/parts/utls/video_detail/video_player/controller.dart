import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niconico/constant.dart';
import 'package:niconico/contents/parts/utls/common.dart';

class Controller extends StatefulWidget {
  const Controller(
      {super.key, required this.screenSize, required this.mediaStateStream});
  final Size screenSize;
  final Stream<MediaState> mediaStateStream;

  @override
  State<Controller> createState() => _ControllerState();
}

class _ControllerState extends State<Controller> {
  bool uiVisible = false;
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: ((context, ref, child) {
      return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              uiVisible = !uiVisible;
            });
          },
          child: _buildOverlayContainer(
              screenSize: widget.screenSize,
              ref: ref,
              childlen: [
                Container(
                    padding: const EdgeInsets.only(left: 15, right: 10),
                    child: AnimatedSizeIcon(
                      touchEvent: () {
                        SystemChrome.setEnabledSystemUIMode(
                          SystemUiMode.edgeToEdge,
                        );
                        Navigator.pop(context);
                      },
                      icon: Icons.clear_rounded,
                      size: 24,
                    )),
                Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.only(left: 15, right: 10),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedSizeIcon(
                                      icon: Icons.replay_10_sharp,
                                      size: 30,
                                      touchEvent: () {
                                        audioHandler.seek(audioHandler
                                                .playbackState
                                                .value
                                                .updatePosition +
                                            const Duration(seconds: -10));
                                      },
                                    ),
                                    const SpaceBox(width: 20),
                                    StreamBuilder<bool>(
                                      stream: audioHandler.playbackState
                                          .map((state) => state.playing)
                                          .distinct(),
                                      builder: (context, snapshot) {
                                        final playing = snapshot.data ?? false;
                                        return AnimatedSizeIcon(
                                            icon: playing
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            size: 35,
                                            touchEvent: playing
                                                ? audioHandler.pause
                                                : audioHandler.play);
                                      },
                                    ),
                                    const SpaceBox(width: 20),
                                    AnimatedSizeIcon(
                                      touchEvent: () {
                                        audioHandler.seek(audioHandler
                                                .playbackState
                                                .value
                                                .updatePosition +
                                            const Duration(seconds: 10));
                                      },
                                      icon: Icons.forward_10_sharp,
                                      size: 30,
                                    ),
                                  ],
                                )),
                            Expanded(
                                child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: LayoutBuilder(builder: (ctx, constraints) {
                                return StreamBuilder<MediaState>(
                                  stream: widget.mediaStateStream,
                                  builder: (context, snapshot) {
                                    final mediaState = snapshot.data;
                                    return SeekBar(
                                      positionData: PositionData(
                                          mediaState?.position,
                                          mediaState?.mediaItem?.duration),
                                      pWidth: constraints.maxWidth,
                                      onChangeEnd: (newPosition) {
                                        audioHandler.seek(newPosition);
                                      },
                                    );
                                  },
                                );
                              }),
                            )),
                            AnimatedSizeIcon(
                                icon: Icons.more_horiz,
                                size: 24,
                                touchEvent: () {}),
                          ],
                        )),
                  ],
                )
              ]));
    }));
  }

  Widget _buildOverlayContainer(
      {required Size screenSize,
      required List<Widget> childlen,
      required WidgetRef ref}) {
    return AnimatedOpacity(
      opacity: uiVisible ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: Column(children: [
          Container(
            alignment: Alignment.topLeft,
            child: _playerController(
                child: childlen[0],
                ref: ref,
                screenSize: screenSize,
                width: screenSize.width * 0.15),
          ),
          const Expanded(child: SizedBox()),
          _playerController(
              child: childlen[1],
              ref: ref,
              screenSize: screenSize,
              width: screenSize.height),
        ]),
      ),
    );
  }

  Widget _playerController(
      {required Size screenSize,
      required Widget child,
      required WidgetRef ref,
      required double width}) {
    return Material(
      color: Colors.transparent,
      child: IgnorePointer(
        ignoring: uiVisible,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color.fromARGB(31, 37, 37, 37).withOpacity(0.9),
            ),
            width: width,
            height: screenSize.width * 0.123,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: child),
            ),
          ),
        ),
      ),
    );
  }
}
