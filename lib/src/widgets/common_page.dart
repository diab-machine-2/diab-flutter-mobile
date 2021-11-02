import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widgets/background_page.dart';

class CommonPage extends StatelessWidget {
  final String background;
  final String? title;
  final Color? textColor;
  final Widget child;
  final VoidCallback? onTapBack;
  final IconData? icon;
  final Widget? appBarAction;

  const CommonPage(
      {Key? key,
      required this.background,
      required this.child,
      this.title,
      this.textColor,
      this.onTapBack,
      this.icon,
      this.appBarAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackgroundPage(
      background: background,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            CustomAppBar(
              backgroundColor: R.color.transparent,
              title: Text(
                title ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? R.color.textDark,
                ),
              ),
              leadingIcon: GestureDetector(
                onTap: onTapBack ??
                    () {
                      NavigationUtil.pop(context);
                    },
                child: Icon(
                  Icons.arrow_back,
                  color: textColor ?? R.color.textDark,
                ),
              ),
              actions: appBarAction != null ? [appBarAction!] : null,
            ),
            Expanded(child: child)
          ],
        ),
      ),
    );
  }
}
