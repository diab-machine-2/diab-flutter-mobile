import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';

class ButtonWidget extends StatelessWidget {
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final String title;
  final VoidCallback? onPressed;
  final double? radius;
  final bool modeFlatButton;

  ButtonWidget({
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.height,
    required this.title,
    required this.onPressed,
    this.radius,
    this.modeFlatButton: false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
//        color: backgroundColor,
        height: height ?? 50.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: backgroundColor ?? R.color.accentColor,
            gradient: backgroundColor == null ? LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4BB2AB), Color(0xFF01857A), Color(0xFF008479)],
            ) : null,
//            gradient: LinearGradient(
//              colors: [Theme.of(context).primaryColor, Colors.lightBlue],
//            ),
            border: Border.all(
                color: borderColor ?? backgroundColor ?? R.color.accentColor,
                width: 1),
            borderRadius: BorderRadius.circular(200.sp)),
        child: Text(
          title,
          style: TextStyle(
              color: textColor ?? R.color.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
