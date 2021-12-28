import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';

class WidgetHtmlText extends StatelessWidget {
  const WidgetHtmlText(
    this.text, {
    this.textStyle,
  });
  final String text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Html(
      data: text,
      style: {
        "body": Style(
          color: R.color.textDark,
          fontSize: FontSize(textStyle != null ? textStyle!.fontSize : 16.sp),
          fontWeight:
              textStyle != null ? textStyle!.fontWeight : FontWeight.w400,
        ),
      },
    );
  }
}
