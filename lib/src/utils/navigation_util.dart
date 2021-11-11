import 'package:flutter/material.dart';

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

  static void popDialog(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).pop('dialog');
  }

  static void replace(BuildContext context, Widget widget) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => widget));
  }

  static Future navigatePage(BuildContext context, Widget widget) {
    return Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: widget.runtimeType.toString()),
        builder: (context) => widget));
  }

  static Future rootNavigatePage(BuildContext context, Widget widget) {
    return Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (context) => widget));
  }
}
