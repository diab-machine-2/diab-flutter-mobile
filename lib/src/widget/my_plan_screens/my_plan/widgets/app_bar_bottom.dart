import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class AppBarBottom extends StatelessWidget {
  const AppBarBottom({this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: R.color.color0xfff5f5f5),
          left: BorderSide(color: R.color.color0xfff5f5f5),
          bottom: BorderSide(color: R.color.color0xfff5f5f5),
        ),
      ),
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: R.color.greenGradientBottom.withOpacity(0.08),
                spreadRadius: 5,
                blurRadius: 7,
              ),
            ],
          ),
          child: child ?? const SizedBox.shrink()),
    );
  }
}
