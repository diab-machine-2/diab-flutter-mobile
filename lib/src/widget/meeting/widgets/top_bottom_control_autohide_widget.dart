import 'dart:async';

import 'package:flutter/material.dart';

class TopBottomControlAutohideWidget extends StatefulWidget {
  final Widget topWidget;
  final double topWidgetHeight;
  final Widget bottomWidget;
  final double bottomWidgetHeight;
  final Widget? floatingRightWidget;

  const TopBottomControlAutohideWidget({
    Key? key,
    required this.topWidget,
    required this.topWidgetHeight,
    required this.bottomWidget,
    required this.bottomWidgetHeight,
    this.floatingRightWidget,
  }) : super(key: key);

  @override
  State<TopBottomControlAutohideWidget> createState() => _FadeTransitionStateWidget();
}

class _FadeTransitionStateWidget extends State<TopBottomControlAutohideWidget>
    with TickerProviderStateMixin {
  bool _visible = true;
  Timer? _timer;
  final int _autohideInSeconds = 10;
  final Duration _animationDuration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _triggerTimer(seconds: 15);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    return Column(
      children: [
        AnimatedContainer(
          duration: _animationDuration,
          curve: Curves.easeInOut,
          height: media.padding.top + (_visible ? widget.topWidgetHeight : 0.0),
          child: _visible ? widget.topWidget : null,
        ),
        Expanded(
          child: GestureDetector(
            onTap: _toggleVisibility,
            onDoubleTap: () {},
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: widget.floatingRightWidget == null
                  ? null
                  : Align(
                      alignment: Alignment.topRight,
                      child: widget.floatingRightWidget!,
                    ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: _animationDuration,
          curve: Curves.easeInOut,
          height: _visible ? widget.bottomWidgetHeight : 0.0,
          transformAlignment: Alignment.bottomCenter,
          child: SingleChildScrollView(
            child: _visible ? widget.bottomWidget : SizedBox.shrink(),
            physics: NeverScrollableScrollPhysics(),
          ),
        ),
      ],
    );
  }

  void _toggleVisibility() {
    setState(() {
      _visible = !_visible;
    });
    _triggerTimer();
  }

  void _triggerTimer({int? seconds}) {
    _timer?.cancel();
    if (_visible) {
      _timer = Timer(Duration(seconds: seconds ?? _autohideInSeconds), () {
        if (_visible) {
          setState(() {
            _visible = false;
          });
        }
      });
    }
  }
}
