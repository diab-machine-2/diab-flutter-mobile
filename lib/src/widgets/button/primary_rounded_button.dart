import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class PrimaryRoundedButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final double height;
  final Color? color;

  const PrimaryRoundedButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.height = 48.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    double halfHeight = (height / 2).roundToDouble();
    BorderRadius borderRadius = BorderRadius.circular(halfHeight - 2);
    return InkWell(
      borderRadius: borderRadius,
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        height: height,
        decoration: BoxDecoration(
          color: color,
          gradient: color == null
              ? LinearGradient(colors: [
                  Color(0xFF0DAB9C),
                  Color(0xFF01847A),
                ], begin: Alignment.centerLeft, end: Alignment.centerRight)
              : null,
          borderRadius: borderRadius,
        ),
        child: Text(
          title.tr(),
          style: R.style.primaryButtonText,
        ),
      ),
    );
  }
}
