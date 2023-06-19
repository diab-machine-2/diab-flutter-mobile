import 'package:flutter/material.dart';
import 'package:medical/src/utils/app_media_query.dart';

class NormalTemplate extends StatefulWidget {
  final Function? myInterceptor;
  final Widget child;
  final Widget? appBar;
  final Widget? footer;
  final bool hasBackground;
  const NormalTemplate({
    Key? key,
    required this.child,
    this.appBar,
    this.hasBackground = false,
    this.footer,
    this.myInterceptor,
  }) : super(key: key);

  @override
  State<NormalTemplate> createState() => _NormalTemplateState();
}

class _NormalTemplateState extends State<NormalTemplate> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double topSafeArea =
        widget.appBar != null ? AppMediaQuery.deviceSafeAreaTop : 0;
    double heightStatusBar = AppMediaQuery.deviceStatusBar;
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: widget.appBar != null ? heightStatusBar : 0,
          ),
          child: SafeArea(
            bottom: widget.footer != null,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: widget.child,
            ),
          ),
        ),
        if (widget.appBar != null)
          Positioned(
            left: 0,
            right: 0,
            child: SizedBox(
              height: topSafeArea + heightStatusBar,
              child: widget.appBar,
            ),
          ),
        if (widget.footer != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: widget.footer!,
          ),
      ],
    );
  }
}
