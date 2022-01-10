import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widgets/background_page.dart';

class CommonPage extends StatelessWidget {
  final String background;
  final String? title;
  final Color? textColor;
  final Color? appbarColor;
  final Widget child;
  final VoidCallback? onTapBack;
  final IconData? icon;
  final Widget? appBarAction;
  final bool? showCloseBackButton;
  final bool? hideAllBackButton;
  final bool? bottomSafeArea;
  final VoidCallback? onTapClose;
  final VoidCallback? onShowDetail;
  final VoidCallback? onTapAppBar;

  const CommonPage(
      {Key? key,
      required this.background,
      required this.child,
      this.title,
      this.textColor,
      this.appbarColor,
      this.onTapBack,
      this.icon,
      this.appBarAction,
      this.showCloseBackButton,
      this.hideAllBackButton,
      this.bottomSafeArea,
      this.onTapClose,
      this.onShowDetail,
      this.onTapAppBar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackgroundPage(
      background: background,
      child: SafeArea(
        top: appbarColor == null,
        bottom: bottomSafeArea ?? false,
        child: Column(
          children: [
            GestureDetector(
              onTap: onTapAppBar,
              child: CustomAppBar(
                backgroundColor: appbarColor ?? R.color.transparent,
                title: Text(
                  title ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? R.color.textDark,
                  ),
                ),
                showRightCloseButton: showCloseBackButton,
                hideAllBackButton: hideAllBackButton,
                leadingIcon: GestureDetector(
                  onTap: onTapBack ??
                      () {
                        NavigationUtil.pop(context);
                      },
                  child: Icon(
                    icon ?? Icons.arrow_back,
                    color: textColor ?? R.color.textDark,
                  ),
                ),
                actions: showCloseBackButton == true
                    ? [
                        if (onShowDetail != null)
                          GestureDetector(
                            onTap: onShowDetail,
                            child: Image.asset(
                              R.drawable.ic_question_circle,
                              width: 24,
                              height: 24,
                              color: R.color.grayCaption,
                            ),
                          ),
                        IconButton(
                            icon: Icon(Icons.close, color: R.color.black),
                            onPressed: onTapBack ??
                                onTapClose ??
                                () {
                                  NavigationUtil.pop(context);
                                })
                      ]
                    : appBarAction != null
                        ? [appBarAction!]
                        : null,
              ),
            ),
            Expanded(child: child)
          ],
        ),
      ),
    );
  }
}
