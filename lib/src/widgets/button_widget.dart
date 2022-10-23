import 'package:flutter/widgets.dart';
import 'package:medical/res/R.dart';

class ButtonWidget extends StatelessWidget {
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? textSize;
  final Color? borderColor;
  final String title;
  final VoidCallback? onPressed;
  final double? radius;
  final bool modeFlatButton;

  const ButtonWidget({
    this.backgroundColor,
    this.textSize,
    this.textColor,
    this.borderColor,
    this.height,
    required this.title,
    required this.onPressed,
    this.radius,
    this.modeFlatButton = false,
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
        child: Text(
          title,
          style: TextStyle(
              color:
                  onPressed == null ? R.color.gray : textColor ?? R.color.white,
              fontSize: textSize ?? 16,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
