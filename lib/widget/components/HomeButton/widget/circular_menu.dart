import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'circular_menu_item.dart';

class CircularMenu extends StatefulWidget {
  /// use global key to control animation anywhere in the code
  final GlobalKey<CircularMenuState> key;

  final double bottom;

  /// list of CircularMenuItem contains at least two items.
  final List<CircularMenuItem> items;

  final List<Widget> titles;

  /// menu alignment
  final AlignmentGeometry alignment;

  /// menu radius
  final double radius;

  /// widget holds actual page content
  final Widget backgroundWidget;

  /// animation duration
  final Duration animationDuration;

  /// animation curve in forward
  final Curve curve;

  /// animation curve in rverse
  final Curve reverseCurve;

  /// callback
  final VoidCallback toggleButtonOnPressed;
  final Color toggleButtonColor;
  final double toggleButtonSize;
  final List<BoxShadow> toggleButtonBoxShadow;
  final double toggleButtonPadding;
  final double toggleButtonMargin;
  final Color toggleButtonIconColor;
  final AnimatedIconData toggleButtonAnimatedIconData;

  /// staring angle in clockwise radian
  final double startingAngleInRadian;

  /// ending angle in clockwise radian
  final double endingAngleInRadian;

  /// creates a circular menu with specific [radius] and [alignment] .
  /// [toggleButtonElevation] ,[toggleButtonPadding] and [toggleButtonMargin] must be
  /// equal or greater than zero.
  /// [items] must not be null and it must contains two elements at least.
  CircularMenu({
    @required this.items,
    this.bottom,
    @required this.titles,
    this.alignment = Alignment.bottomCenter,
    this.radius = 150,
    this.backgroundWidget,
    this.animationDuration = const Duration(milliseconds: 300),
    this.curve = Curves.linear,
    this.reverseCurve = Curves.easeOut,
    this.toggleButtonOnPressed,
    this.toggleButtonColor,
    this.toggleButtonBoxShadow,
    this.toggleButtonMargin = 5,
    this.toggleButtonPadding = 20,
    this.toggleButtonSize = 40,
    this.toggleButtonIconColor,
    this.toggleButtonAnimatedIconData = AnimatedIcons.close_menu,
    this.key,
    this.startingAngleInRadian,
    this.endingAngleInRadian,
  })  : assert(items != null, 'items can not be empty list'),
        assert(items.length > 1, 'if you have one item no need to use a Menu'),
        super(key: key);

  @override
  CircularMenuState createState() => CircularMenuState();
}

class CircularMenuState extends State<CircularMenu>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  AnimationController animationXController;

  double _completeAngle;
  double _initialAngle;
  double _endAngle;
  double _startAngle;
  int _itemsCount;
  Animation<double> _animation;
  AnimationController _controller;

  /// forward animation
  void forwardAnimation() {
    animationController.forward();
  }

  /// reverse animation
  void reverseAnimation() {
    animationController.reverse();
  }

  @override
  void initState() {
    _configure();
    animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..addListener(() {
        setState(() {});
      });

    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: animationController,
          curve: widget.curve,
          reverseCurve: widget.reverseCurve),
    );
    _itemsCount = widget.items.length;
    super.initState();
    forwardAnimation();
  }

  void _configure() {
    if (widget.startingAngleInRadian != null ||
        widget.endingAngleInRadian != null) {
      if (widget.startingAngleInRadian == null) {
        throw ('startingAngleInRadian can not be null');
      }
      if (widget.endingAngleInRadian == null) {
        throw ('endingAngleInRadian can not be null');
      }

      if (widget.startingAngleInRadian < 0) {
        throw 'startingAngleInRadian has to be in clockwise radian';
      }
      if (widget.endingAngleInRadian < 0) {
        throw 'endingAngleInRadian has to be in clockwise radian';
      }
      _startAngle = (widget.startingAngleInRadian / math.pi) % 2;
      _endAngle = (widget.endingAngleInRadian / math.pi) % 2;
      if (_endAngle < _startAngle) {
        throw 'startingAngleInRadian can not be greater than endingAngleInRadian';
      }
      _completeAngle = _startAngle == _endAngle
          ? 2 * math.pi
          : (_endAngle - _startAngle) * math.pi;
      _initialAngle = _startAngle * math.pi;
    } else {
      switch (widget.alignment.toString()) {
        case 'bottomCenter':
          _completeAngle = 1 * math.pi;
          _initialAngle = 1 * math.pi;
          break;
        case 'topCenter':
          _completeAngle = 1 * math.pi;
          _initialAngle = 0 * math.pi;
          break;
        case 'centerLeft':
          _completeAngle = 1 * math.pi;
          _initialAngle = 1.5 * math.pi;
          break;
        case 'centerRight':
          _completeAngle = 1 * math.pi;
          _initialAngle = 0.5 * math.pi;
          break;
        case 'center':
          _completeAngle = 2 * math.pi;
          _initialAngle = 0 * math.pi;
          break;
        case 'bottomRight':
          _completeAngle = 0.5 * math.pi;
          _initialAngle = 1 * math.pi;
          break;
        case 'bottomLeft':
          _completeAngle = 0.5 * math.pi;
          _initialAngle = 1.5 * math.pi;
          break;
        case 'topLeft':
          _completeAngle = 0.5 * math.pi;
          _initialAngle = 0 * math.pi;
          break;
        case 'topRight':
          _completeAngle = 0.5 * math.pi;
          _initialAngle = 0.5 * math.pi;
          break;
        default:
          throw 'startingAngleInRadian and endingAngleInRadian can not be null';
      }
    }
  }

  @override
  void didUpdateWidget(oldWidget) {
    _configure();
    super.didUpdateWidget(oldWidget);
  }

  List<Widget> _buildMenuItems() {
    List<Widget> items = [];
    widget.items.asMap().forEach((index, item) {
      var direction = 0.0;
      var distance = _animation.value * widget.radius;
      switch (index) {
        case 0:
          direction = 4.71;
          distance = _animation.value * widget.radius - 50;
          break;
        case 1:
          direction = 4.16;
          distance = _animation.value * widget.radius + 123;
          break;
        case 2:
          direction = 4.71;
          distance = _animation.value * widget.radius + 82;
          break;
        case 3:
          direction = 5.26;
          distance = _animation.value * widget.radius + 122;
          break;
        case 4:
          direction = 5.075;
          distance = _animation.value * widget.radius + 250;
          break;
        case 5:
          direction = 4.71;
          distance = _animation.value * widget.radius + 224;
          break;
        case 6:
          direction = 4.35;
          distance = _animation.value * widget.radius + 250;
          break;
        default:
          direction = 3.5;
          distance = _animation.value * widget.radius;
      }

      items.add(
        Positioned.fill(
          child: Align(
            alignment: widget.alignment,
            child: Transform.translate(
              offset: Offset.fromDirection(direction, distance),
              child: Transform.scale(
                scale: _animation.value,
                child: item,
              ),
            ),
          ),
        ),
      );
    });
    return items;
  }

  Widget _buildMenuButton(BuildContext context) {
    return Positioned.fill(
      child: Align(
          alignment: widget.alignment,
          child: Transform.rotate(
              angle: -animationController.value * 0.8,
              child: CircularMenuItem(
                bottom: widget.bottom,
                icon: Icon(Icons.add, color: Colors.white, size: 30),
                title: SizedBox(),
                margin: widget.toggleButtonMargin,
                color:
                    widget.toggleButtonColor ?? Theme.of(context).primaryColor,
                // padding: (-_animation.value * widget.toggleButtonPadding * 0.5) +
                //     widget.toggleButtonPadding,
                onTap: () {
                  animationController.status == AnimationStatus.dismissed
                      ? (animationController).forward()
                      : (animationController).reverse().then((value) {
                          Navigator.pop(context);
                        });
                  if (widget.toggleButtonOnPressed != null) {
                    widget.toggleButtonOnPressed();
                  }
                },
                boxShadow: widget.toggleButtonBoxShadow,
                // animatedIcon: AnimatedIcon(
                //   icon:
                //       widget.toggleButtonAnimatedIconData, //AnimatedIcons.menu_close,
                //   size: widget.toggleButtonSize,
                //   color: widget.toggleButtonIconColor ?? Colors.white,
                //   progress: _animation,
                // ),
              ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // GestureDetector(
        //   onTap: () {
        //     //Navigator
        //   },
        //   child: Container(color: Colors.black.withOpacity(0.7)),
        // ), //widget.backgroundWidget ?? Container(),

        _buildMenuButton(context),
        ..._buildMenuItems(),
      ],
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
