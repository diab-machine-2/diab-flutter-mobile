/// clone https://pub.dev/packages/curved_navigation_bar
import 'dart:math';

import 'src/nav_custom_clipper.dart';
import 'package:flutter/material.dart';
import 'src/nav_button.dart';
import 'src/nav_custom_painter.dart';

typedef _LetIndexPage = bool Function(int value);
typedef StringCallback = String Function(String);

class CurvedNavigationBar extends StatefulWidget {
  final List<Widget> items;
  final List<String> assetPaths;
  final List<String> tabTitles;
  final double iconSize;
  final int index;
  final Color color;
  final Color? buttonBackgroundColor;
  final Color backgroundColor;
  final Color activeButtonColor;
  final Color activeButtonBorderColor;
  final Color normalButtonColor;
  final ValueChanged<int>? onTap;
  final _LetIndexPage letIndexChange;
  final Curve animationCurve;
  final Duration animationDuration;
  final double height;
  final double? maxWidth;
  final StringCallback activeIconReplacement;

  CurvedNavigationBar({
    Key? key,
    required this.assetPaths,
    required this.tabTitles,
    required this.activeIconReplacement,
    this.iconSize = 24.0,
    this.index = 0,
    this.color = Colors.white,
    this.buttonBackgroundColor,
    this.backgroundColor = Colors.blueAccent,
    required this.activeButtonColor,
    required this.activeButtonBorderColor,
    required this.normalButtonColor,
    this.onTap,
    _LetIndexPage? letIndexChange,
    this.animationCurve = Curves.easeOut,
    this.animationDuration = const Duration(milliseconds: 600),
    this.height = 75.0,
    this.maxWidth,
  })  : items = assetPaths
            .map((path) =>
                Image.asset(path, width: iconSize, height: iconSize, color: normalButtonColor))
            .toList(),
        letIndexChange = letIndexChange ?? ((_) => true),
        super(key: key);

  @override
  CurvedNavigationBarState createState() => CurvedNavigationBarState();
}

class CurvedNavigationBarState extends State<CurvedNavigationBar>
    with SingleTickerProviderStateMixin {
  late double _startingPos;
  late int _endingIndex;
  late double _pos;
  double _buttonHide = 0;
  late Widget _icon;
  late AnimationController _animationController;
  late int _length;

  @override
  void initState() {
    super.initState();
    _icon = widget.items[widget.index];
    _length = widget.items.length;
    _pos = widget.index / _length;
    _startingPos = widget.index / _length;
    _endingIndex = widget.index;
    _animationController = AnimationController(vsync: this, value: _pos);
    _animationController.addListener(() {
      setState(() {
        _pos = _animationController.value;
        final endingPos = _endingIndex / widget.items.length;
        final middle = (endingPos + _startingPos) / 2;
        if ((endingPos - _pos).abs() < (_startingPos - _pos).abs()) {
          _icon = widget.items[_endingIndex];
        }
        _buttonHide = (1 - ((middle - _pos) / (_startingPos - middle)).abs()).abs();
      });
    });
  }

  @override
  void didUpdateWidget(CurvedNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      final newPosition = widget.index / _length;
      _startingPos = _pos;
      _endingIndex = widget.index;
      _animationController.animateTo(newPosition,
          duration: widget.animationDuration, curve: widget.animationCurve);
    }
    if (!_animationController.isAnimating) {
      _icon = widget.items[_endingIndex];
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    final media = MediaQuery.of(context);
    final extraBottomPadding = media.padding.bottom / 2;
    final double iconSize = 52.0;
    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = min(constraints.maxWidth, widget.maxWidth ?? constraints.maxWidth);
          if (widget.items.indexOf(_icon) > -1) {
            final iconPath = widget.assetPaths[widget.items.indexOf(_icon)];
            final activeIconPath = widget.activeIconReplacement(iconPath);
            _icon = Image.asset(
              activeIconPath,
              width: widget.iconSize,
              height: widget.iconSize,
              color: widget.activeButtonColor,
            );
          }
          return Align(
            alignment:
                textDirection == TextDirection.ltr ? Alignment.bottomLeft : Alignment.bottomRight,
            child: Container(
              color: widget.backgroundColor,
              width: maxWidth,
              child: ClipRect(
                clipper: NavCustomClipper(
                  deviceHeight: MediaQuery.sizeOf(context).height,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    // Clip path
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0, // 12 - (75.0 - widget.height) + extraBottomPadding,
                      child: CustomPaint(
                        painter: NavCustomPainter(_pos, _length, widget.color, textDirection, iconSize: iconSize,),
                        child: Container(
                          height: 75.0,
                        ),
                      ),
                    ),

                    // Active
                    Positioned(
                      bottom: -32 - 20 - (75.0 - widget.height) + extraBottomPadding,
                      left: textDirection == TextDirection.rtl ? null : _pos * maxWidth,
                      right: textDirection == TextDirection.rtl ? _pos * maxWidth : null,
                      width: maxWidth / _length,
                      child: Center(
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            -(1 - _buttonHide) * 80,
                          ),
                          child: SizedBox(
                            width: maxWidth / _length,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // icon
                                Container(
                                  width: iconSize,
                                  height: iconSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.buttonBackgroundColor ?? widget.color,
                                    border: Border.all(
                                      color: widget.activeButtonBorderColor,
                                      width: 4.0,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  alignment: Alignment.center,
                                  child: _icon,
                                ),

                                const SizedBox(height: 4.0),

                                // title
                                if (_endingIndex >= 0)
                                  // no scale factor
                                  MediaQuery(
                                    data: media.copyWith(
                                      textScaler: media.textScaler
                                          .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.1),
                                    ),
                                    child: Text(
                                      widget.tabTitles[_endingIndex],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: widget.buttonBackgroundColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11.0,
                                        height: 16.0 / 11.0,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Buttons
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0 - (75.0 - widget.height) + extraBottomPadding,
                      child: SizedBox(
                          height: 75.0,
                          child: Row(
                              children: widget.items.map((item) {
                            final index = widget.items.indexOf(item);
                            return NavButton(
                              onTap: _buttonTap,
                              position: _pos,
                              length: _length,
                              index: index,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4.0),
                                  item,
                                  const SizedBox(height: 4.0),
                                  Text(
                                    widget.tabTitles[index],
                                    style: TextStyle(
                                      color: widget.normalButtonColor,
                                      fontSize: 11.0,
                                      height: 16.0 / 11.0,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList())),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void setPage(int index) {
    _buttonTap(index);
  }

  void _buttonTap(int index) {
    if (widget.onTap != null) {
      widget.onTap!(index);
    }
    if (!widget.letIndexChange(index) || _animationController.isAnimating) {
      return;
    }
    final newPosition = index / _length;
    setState(() {
      _startingPos = _pos;
      _endingIndex = index;
      _animationController.animateTo(newPosition,
          duration: widget.animationDuration, curve: widget.animationCurve);
    });
  }
}
