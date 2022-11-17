import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niconico/constant.dart';

class PositionData {
  final Duration? position;
  final Duration? duration;

  String get getStringPosition => position != null
      ? VideoDetailInfo.secToTime(position!.inSeconds)
      : '--:--';

  double get getValuePosition =>
      position != null ? position!.inMilliseconds.toDouble() : 0.0;

  String get getStringDuration => duration != null
      ? VideoDetailInfo.secToTime(duration!.inSeconds)
      : '--:--';

  double get getValueDuration => duration?.inMilliseconds.toDouble() ?? 0.0;

  PositionData(this.position, this.duration);
}

class SeekBar extends StatefulWidget {
  final PositionData positionData;

  final double pWidth;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    super.key,
    required this.positionData,
    required this.pWidth,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  double? _dragValue;
  bool _dragging = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final value = min(
      _dragValue ?? widget.positionData.getValuePosition,
      widget.positionData.getValueDuration,
    );
    if (_dragValue != null && !_dragging) {
      _dragValue = null;
    }
    return SizedBox(
        width: widget.pWidth,
        child: Row(
          children: [
            Text(
              widget.positionData.getStringPosition,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
            const SpaceBox(width: 5),
            Expanded(
                child: SliderTheme(
              data: SliderThemeData(
                  thumbColor: Colors.blue,
                  activeTrackColor: Colors.blue,
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 5)),
              child: Slider(
                min: 0.0,
                max: widget.positionData.getValueDuration,
                value: value,
                onChanged: (value) {
                  if (!_dragging) {
                    _dragging = true;
                  }
                  setState(() {
                    _dragValue = value;
                  });
                  if (widget.onChanged != null) {
                    widget.onChanged!(Duration(milliseconds: value.round()));
                  }
                },
                onChangeEnd: (value) {
                  if (widget.onChangeEnd != null) {
                    widget.onChangeEnd!(Duration(milliseconds: value.round()));
                  }
                  _dragging = false;
                },
              ),
            )),
            const SpaceBox(
              width: 5,
            ),
            Text(
              widget.positionData.getStringDuration,
              style: const TextStyle(
                fontSize: 12,
              ),
            )
          ],
        ));
  }
}

class SpaceBox extends SizedBox {
  const SpaceBox({super.key, double width = 8, double height = 8})
      : super(width: width, height: height);
}

class AnimatedSizeIcon extends StatefulWidget {
  const AnimatedSizeIcon(
      {super.key,
      required this.icon,
      required this.size,
      required this.touchEvent});
  final IconData icon;
  final double size;
  final void Function() touchEvent;
  @override
  State<AnimatedSizeIcon> createState() => _AnimatedSizeIconState();
}

class _AnimatedSizeIconState extends State<AnimatedSizeIcon> {
  bool _isPressed = false;
  double _size = 0;

  void _onTapDown(double defaultSize) {
    setState(() {
      _isPressed = !_isPressed;
      _size = _isPressed ? defaultSize * 0.8 : defaultSize;
    });
  }

  @override
  void initState() {
    _size = widget.size;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.size,
        height: widget.size,
        child: GestureDetector(
            onTap: () => widget.touchEvent(),
            onTapDown: (_) => _onTapDown(widget.size),
            onTapUp: (_) => _onTapDown(widget.size),
            onTapCancel: () => _onTapDown(widget.size),
            child: AnimatedSize(
              duration: const Duration(seconds: 3),
              curve: Curves.linear,
              child: Icon(
                widget.icon,
                size: _size,
              ),
            )));
  }
}

CupertinoNavigationBar topNaviBar(String middle,
    {Widget? trailing, Widget? leading, bool autoBack = true}) {
  return CupertinoNavigationBar(
    automaticallyImplyLeading: autoBack,
    leading: leading,
    previousPageTitle: "戻る",
    trailing: trailing,
    middle: Text(middle),
  );
}

CupertinoButton topBackButton(BuildContext context) {
  return CupertinoButton(
    padding: const EdgeInsets.all(0.0),
    child: const Text(
      'キャンセル',
      style: TextStyle(
        decoration: TextDecoration.underline,
        fontWeight: FontWeight.bold,
        fontSize: 14.0,
      ),
    ),
    onPressed: () => Navigator.of(context).pop(),
  );
}

extension SliverListEx on SliverList {
  static SliverList separated({
    required int itemCount,
    required NullableIndexedWidgetBuilder itemBuilder,
    required NullableIndexedWidgetBuilder separatorBuilder,
  }) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final itemIndex = index ~/ 2;
          return index.isEven
              ? itemBuilder(context, itemIndex)
              : separatorBuilder(context, itemIndex);
        },
        childCount: max(0, itemCount * 2 - 1),
      ),
    );
  }
}

class CustomListView extends StatelessWidget {
  const CustomListView(
      {super.key,
      required this.itemCount,
      required this.itemBuilder,
      required this.onRefresh});
  final int itemCount;
  final Widget? Function(BuildContext, int) itemBuilder;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        child:
            CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
      CupertinoSliverRefreshControl(
        onRefresh: onRefresh,
      ),
      SliverListEx.separated(
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: (BuildContext context, int index) => const Divider(
          height: 1,
          thickness: 1,
        ),
      )
    ]));
  }
}
