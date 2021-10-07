import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'pending_action.dart';

class StackLoadingView extends StatelessWidget {
  final Widget child;
  final bool visibleLoading;

  const StackLoadingView(
      {Key? key, required this.child, required this.visibleLoading})
      : super(key: key);

  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        Visibility(visible: visibleLoading, child: PendingAction())
      ],
    );
  }
}
