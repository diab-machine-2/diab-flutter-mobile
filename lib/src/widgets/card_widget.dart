import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class CardWidget extends StatelessWidget {
  final Color? backgroundColor;
  final String? backgroundImage;
  final EdgeInsets? padding;
  final Color? borderColor;
  final double? borderWidth;
  final VoidCallback? onPressed;
  final double? radius;
  final Widget child;

  CardWidget(
      {this.backgroundColor,
      this.backgroundImage,
      this.padding,
      this.borderColor,
      this.borderWidth,
      this.onPressed,
      this.radius,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
            color: backgroundColor ?? R.color.white,
            image: backgroundImage == null
                ? null
                : DecorationImage(
                    image: AssetImage(backgroundImage!), fit: BoxFit.fill),
            border: Border.all(
                color: borderColor ?? backgroundColor ?? R.color.gray,
                width: borderWidth ?? 1.5),
            borderRadius: BorderRadius.circular(radius ?? 10)),
        child: child,
      ),
    );
  }
}
