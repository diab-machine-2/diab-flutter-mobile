import 'package:flutter/material.dart';

import 'utils/navigator_name.dart';
import 'widget/tabbar/tabbar_v2.dart';

class AppRoutes {
  static Route<dynamic>? tryGenerateNewRoutes(RouteSettings settings) {
    Widget? page;
    switch (settings.name) {
      // Override tabbar + home to new UI
      case NavigatorName.tabbar:
        {
          String sharedCode = '';
          bool isRedirectFromNotification = false;
          if (settings.arguments != null) {
            if (settings.arguments is String) {
              sharedCode = settings.arguments! as String;
            } else if (settings.arguments is Map<String, dynamic>) {
              final data = settings.arguments as Map<String, dynamic>?;
              isRedirectFromNotification = data!['isRedirectFromNotification'];
            }
          }
          page = TabbarController(
            sharedCode: sharedCode,
            isRedirectFromNotification: isRedirectFromNotification,
          );
          break;
        }
      default:
        break;
    }
    return page != null ? MaterialPageRoute(settings: settings, builder: (_) => page!) : null;
  }
}
