import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';

class HomeSupportFunctions {
  static Future<void> showModalAddData(BuildContext context) async {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      backgroundColor: R.color.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 290,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Color(0xffF2F2F2)))),
                    child: Text(
                      R.string.contact.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: R.color.textDark,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 10),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  ButtonSupportWidget(
                    icon: R.icons.ic_zalo,
                    iconWidth: 30,
                    iconHeight: 30,
                    backgroundColor: Color(0xFFF2F6F9),
                    textColor: R.color.black,
                    title: 'Zalo OA Technical Support',
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO:  implement zalo OA Technical Support
                    },
                  ),
                  SizedBox(height: 15),
                  ButtonSupportWidget(
                    icon: R.icons.ic_telephone,
                    backgroundColor: Color(0xFFF2F6F9),
                    textColor: R.color.black,
                    iconColor: R.color.black,
                    title: 'Hotline Technical Support',
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO:  implement hotline Technical Support
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ButtonSupportWidget extends StatelessWidget {
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
  final bool isIconSvg;
  final Color? iconColor;
  final double? iconWidth;
  final double? iconHeight;

  const ButtonSupportWidget({
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
    this.isIconSvg = true,
    this.iconColor,
    this.iconWidth,
    this.iconHeight,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (icon != null && !isArrowRight)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: isIconSvg
                          ? SvgPicture.asset(
                              icon!,
                              width: iconWidth ?? 19,
                              height: iconHeight ?? 22,
                              color:
                                  onPressed == null ? R.color.gray : iconColor,
                              fit: BoxFit.scaleDown,
                            )
                          : Image.asset(
                              icon!,
                              width: iconWidth ?? 22,
                              height: iconHeight ?? 22,
                            ),
                    ),
                  Text(
                    title,
                    style: TextStyle(
                        color: onPressed == null
                            ? R.color.gray
                            : textColor ?? R.color.white,
                        fontSize: textSize ?? 16,
                        fontWeight: FontWeight.w400),
                  ),
                  if (icon != null && isArrowRight)
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: isIconSvg
                          ? SvgPicture.asset(
                              icon!,
                              width: iconWidth ?? 19,
                              height: iconHeight ?? 22,
                              color:
                                  onPressed == null ? R.color.gray : iconColor,
                              fit: BoxFit.scaleDown,
                            )
                          : Image.asset(
                              icon!,
                              width: iconWidth ?? 22,
                              height: iconHeight ?? 22,
                            ),
                    ),
                ],
              ),
              Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
