import 'package:flutter/material.dart';
import 'package:medical/src/utils/navigator_name.dart';

class LoginRouting {
  const LoginRouting();

  void navigateToHome(BuildContext context, {dynamic arguments}) {
    // Navigate to home
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacementNamed(context, NavigatorName.tabbar, arguments: arguments);
  }
}
