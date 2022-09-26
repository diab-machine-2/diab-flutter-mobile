import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:url_launcher/url_launcher.dart';

class WidgetHtmlText extends StatelessWidget {
  const WidgetHtmlText(
    this.text, {
    this.textStyle,
  });
  final String? text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    if (text == null) return SizedBox();
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
      onLinkTap: (String? url, RenderContext context,
          Map<String, String> attributes, element) async {
        if (url != null) {
          Uri link = Uri.parse(url);
          if (await canLaunchUrl(link)) {
            await launchUrl(link);
          }
        }
      },
    );
  }
}
