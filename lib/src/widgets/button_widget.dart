import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';

class ButtonWidget extends StatelessWidget {
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? textSize;
  final Color? borderColor;
  final String? icon;
  final String title;
  final VoidCallback? onPressed;
  final double? radius;
  final bool modeTextButton;
  final bool isArrowRight;

  const ButtonWidget({
    this.backgroundColor,
    this.textSize,
    this.textColor,
    this.borderColor,
    this.height,
    required this.title,
    required this.onPressed,
    this.radius,
    this.modeTextButton = false,
    this.icon,
    this.isArrowRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height ?? 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onPressed == null
              ? R.color.white
              : (backgroundColor ?? R.color.accentColor),
          gradient: backgroundColor == null && onPressed != null
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4BB2AB),
                    Color(0xFF01857A),
                    Color(0xFF008479)
                  ],
                )
              : null,
          border: onPressed == null
              ? Border.all(color: R.color.gray, width: 1.5)
              : borderColor == null
                  ? null
                  : Border.all(
                      color: onPressed == null
                          ? R.color.gray
                          : (borderColor ??
                              backgroundColor ??
                              R.color.accentColor),
                      width: 1.5),
          borderRadius: BorderRadius.circular(radius ?? 200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null && !isArrowRight)
              Padding(
                padding: const EdgeInsets.only(right: 3),
                child: SvgPicture.asset(
                  icon!,
                  width: 19,
                  height: 22,
                  color: onPressed == null
                      ? R.color.gray
                      : textColor ?? R.color.white,
                  fit: BoxFit.scaleDown,
                ),
              ),
            Text(
              title,
              style: TextStyle(
                  color: onPressed == null
                      ? R.color.gray
                      : textColor ?? R.color.white,
                  fontSize: textSize ?? 16,
                  fontWeight: FontWeight.w700),
            ),
            if (icon != null && isArrowRight)
              Padding(
                padding: const EdgeInsets.only(left: 3),
                child: SvgPicture.asset(
                  icon!,
                  width: 19,
                  height: 22,
                  color: onPressed == null
                      ? R.color.gray
                      : textColor ?? R.color.white,
                  fit: BoxFit.scaleDown,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
