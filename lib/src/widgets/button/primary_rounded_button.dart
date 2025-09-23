import 'package:easy_localization/easy_localization.dart';
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
          gradient: LinearGradient(
            colors: [
              Color(0xFF0DAB9C),
              R.color.mainColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter
          ),
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
