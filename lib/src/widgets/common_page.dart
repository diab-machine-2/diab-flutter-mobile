import 'package:flutter/material.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/custom_app_bar.dart';

class CommonPage extends StatelessWidget {
  final String background;
  final String? title;
  final Color? textColor;
  final Widget child;
  final VoidCallback? onTapBack;
  final IconData? icon;
  final Widget? appBarAction;
  final bool? bottomSafeArea;
  final bool? showBackButton;

  const CommonPage(
      {Key? key,
      required this.background,
      required this.child,
      this.title,
      this.textColor,
      this.onTapBack,
      this.icon,
      this.appBarAction,
      this.bottomSafeArea,
      this.showBackButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackgroundPage(
      background: background,
      child: SafeArea(
        top: true,
        bottom: bottomSafeArea ?? false,
        child: Column(
          children: [
            CustomAppBar(
              title: title ?? "",
              textColor: textColor,
              backCallback: onTapBack,
              icon: icon,
              rightWidget: appBarAction,
              isShowBack: showBackButton ?? true,
            ),
            Expanded(child: child)
          ],
        ),
      ),
    );
  }
}

