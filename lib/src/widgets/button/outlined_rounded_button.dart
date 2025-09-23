import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class OutlinedRoundedButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final double height;

  const OutlinedRoundedButton({
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
          color: Colors.white,
          borderRadius: borderRadius,
          border: Border.all(
            color: R.color.mainColor,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Text(
          title,
          style: R.style.primaryButtonText.copyWith(color: R.color.mainColor),
        ),
      ),
    );
  }
}
