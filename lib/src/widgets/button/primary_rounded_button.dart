import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class PrimaryRoundedButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final double height;
  const PrimaryRoundedButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    double halfHeight = (height / 2).roundToDouble();
    BorderRadius borderRadius = BorderRadius.circular(halfHeight);
    return InkWell(
      borderRadius: borderRadius,
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        height: height,
        decoration: BoxDecoration(
          color: R.color.mainColor,
          borderRadius: borderRadius,
        ),
        child: Text(
          title,
          style: R.style.primaryButtonText,
        ),
      ),
    );
  }
}
