import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBar extends StatelessWidget {
  final String? title;
  final double? titleSize;
  final Color? textColor;
  final double? iconSize;
  final double? paddingVertical;
  final bool isShowBack;
  final VoidCallback? backCallback;
  final Widget? rightWidget;
  final IconData? icon;

  CustomAppBar(
      {required this.title,
      this.textColor,
      this.isShowBack = true,
      this.backCallback,
      this.rightWidget,
      this.titleSize,
      this.iconSize,
      this.paddingVertical,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: paddingVertical ?? 18, horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Visibility(
            visible: isShowBack,
            child: InkWell(
              onTap: backCallback ?? () => NavigationUtil.pop(context),
              child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(
                    icon ?? CupertinoIcons.arrow_left,
                    color: textColor ?? R.color.textDark,
                    size: iconSize ?? 28,
                  )),
            ),
          ),
          Expanded(
            child: Text(
              title ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: titleSize ?? 20,
                  color: textColor ?? R.color.textDark,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Visibility(
              visible: rightWidget != null,
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: rightWidget ?? Container(),
              )),
        ],
      ),
    );
  }
}
