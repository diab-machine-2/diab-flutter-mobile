import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/src/utils/navigator_name.dart';

class LoginRouting {
  const LoginRouting();

  void navigateToHome(BuildContext context, {dynamic arguments}) {
    // Navigate to home
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacementNamed(context, NavigatorName.tabbar, arguments: arguments);

    // Trigger first time load, next time after fetch user-info will trigger
    Future.delayed(Duration(milliseconds: 300), () async {
      Observable.instance.notifyObservers([], notifyName: "refresh_home");
    });
  }
}
