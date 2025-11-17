import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../res/R.dart';
import '../widgets/button_widget.dart';

class NavigationUtil {
  static Future pushAndRemoveUtilPage(BuildContext context, Widget widget) {
    return Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => widget),
        (Route<dynamic> route) => false);
  }

  static Future pushAndRemoveUtilKeepFirstPage(
      BuildContext context, Widget widget) {
    return Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => widget),
        ModalRoute.withName(Navigator.defaultRouteName));
  }

  static void popToFirst(BuildContext context) {
    return Navigator.of(context)
        .popUntil((Route<dynamic> route) => route.isFirst);
  }

  static void pop(BuildContext context, {dynamic result}) {
    return Navigator.of(context).pop(result);
  }

  static void popByTime(BuildContext context, int count, {dynamic result}) {
    for (int i = 0; i < count - 1; i++) Navigator.of(context).pop();

    Navigator.of(context).pop(result);
  }

  static void popUtil(BuildContext context, Type type) {
    return Navigator.of(context).popUntil((route) {
      return route.settings.name == type.toString();
    });
  }

  static void popPassScreen(BuildContext context, Type type) {
    Navigator.of(context).popUntil((route) {
      return route.settings.name == type.toString();
    });
    Navigator.pop(context);
  }

  static void popDialog(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).pop('dialog');
  }

  static void replace(BuildContext context, Widget widget) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => widget));
  }

  static Future navigatePage(BuildContext context, Widget widget) {
    return Navigator.of(context).pushReplacement(MaterialPageRoute(
        settings: RouteSettings(name: widget.runtimeType.toString()),
        builder: (context) => widget));
  }

  static Future rootNavigatePage(BuildContext context, Widget widget) {
    return Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (context) => widget));
  }

  static void showUpdateRequirePopup({
    required BuildContext context,
    required String title,
  }) {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      barrierDismissible: true,
      builder: (_) => GestureDetector(
        onTap: () {
          NavigationUtil.pop(context);
        },
        child: Scaffold(
          backgroundColor: R.color.transparent,
          body: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      R.color.white,
                      R.color.main_6,
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30),
                        child: Image.asset(R.drawable.img_upgrade_package),
                      ),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: R.color.textDark, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        R.string.tai_khoan_can_nang_cap.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: ButtonWidget(
                          height: 43,
                          title: R.string.agree.tr(),
                          onPressed: () {
                            NavigationUtil.pop(context);
                          },
                          textSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
