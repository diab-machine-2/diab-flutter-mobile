import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class OutlinedRoundedButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final double height;

  final bool highlighButton;

  const OutlinedRoundedButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.height = 48.0,
    this.highlighButton = false,
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
          color: highlighButton
              ? R.color.color0xff830000.withOpacity(0.12)
              : Colors.white,
          borderRadius: borderRadius,
          border: Border.all(
            color: highlighButton ? R.color.color0xff830000 : R.color.mainColor,
            strokeAlign: BorderSide.strokeAlignInside,
            width: 2
          ),
        ),
        child: Text(
          title,
          style: R.style.primaryButtonText.copyWith(
              color:
                  highlighButton ? R.color.color0xff830000 : R.color.mainColor),
        ),
      ),
    );
  }
}
