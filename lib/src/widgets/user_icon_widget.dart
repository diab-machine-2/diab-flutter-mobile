import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class UserIconWidget extends StatelessWidget {
  const UserIconWidget({
    required this.icon,
    required this.backgroundColor,
  });

  final String icon;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 33,
      height: 33,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              R.drawable.bg_user_icon,
              color: backgroundColor,
            ),
          ),
          Center(
            child: Image.asset(
              icon,
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
    );
  }
}
