import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:simple_html_css/simple_html_css.dart';

class WidgetHtmlText extends StatelessWidget {
  const WidgetHtmlText(
    this.text, {
    this.textStyle,
    this.maxLines,
  });
  final String text;
  final TextStyle? textStyle;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, sizeLayout) {
        final TextSpan span = HTML.toTextSpan(context, """$text""",
            defaultTextStyle: textStyle ??
                TextStyle(
                  color: R.color.textDark,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ));

        return maxLines == null
            ? RichText(
                text: span,
                textAlign: TextAlign.left,
              )
            : RichText(
                text: span,
                textAlign: TextAlign.left,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              );
      },
    );
  }
}
