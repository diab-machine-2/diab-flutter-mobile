import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget title;
  final Widget leadingIcon;
  final List<Widget> actions;
  final Widget bottom;
  final double bottomHeight;
  final Color backgroundColor;

  CustomAppBar(
      {Key key,
      @required this.title,
      this.leadingIcon,
      this.actions,
      this.bottom,
      this.bottomHeight = 50,
      this.backgroundColor})
      : preferredSize = Size.fromHeight(
            kToolbarHeight + (bottom == null ? 0 : bottomHeight)),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: widget.backgroundColor,
      title: Transform(
          transform: Matrix4.translationValues(-20.0, 0.0, 0.0),
          child: widget.title),
      centerTitle: false,
      automaticallyImplyLeading: false,
      actions: widget.actions,
      leading: widget.leadingIcon != null
          ? widget.leadingIcon
          : IconButton(
              splashColor: R.color.transparent,
              highlightColor: R.color.transparent,
              icon: widget.leadingIcon == null
                  ? Icon(Icons.arrow_back, color: R.color.white)
                  : widget.leadingIcon,
              onPressed: () {
                navigatorKey.currentState.pop();
              }),
      bottom: widget.bottom,
    );
  }
}
