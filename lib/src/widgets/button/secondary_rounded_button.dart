import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class SecondaryRoundedButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final double height;
  const SecondaryRoundedButton({
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
          color: Color(0xFFE1FAF8),
          borderRadius: borderRadius,
        ),
        child: Text(
          title,
          style: R.style.secondaryButtonText,
        ),
      ),
    );
  }
}
