import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class UserIconWidget extends StatelessWidget {
  const UserIconWidget({
    required this.icon,
  });

  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 33,
      height: 33,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(R.drawable.bg_user_icon),
          ),
          Center(
              child: Image.asset(
            icon,
            width: 24,
            height: 24,
          )),
        ],
      ),
    );
  }
}
