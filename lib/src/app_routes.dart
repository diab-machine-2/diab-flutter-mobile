import 'package:flutter/material.dart';
import 'package:medical/src/widget/utilities/utilities_page.dart';

import 'utils/navigator_name.dart';
import 'widget/Food/daily_nutrition/daily_nutrition.dart';
import 'widget/food_menu_screens/food_menu/food_menu.dart';
import 'widget/home/schema/home_schema.dart';
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
      case NavigatorName.food_menu:
        {
          // empty goal
          page = FoodMenuPage();
          break;
        }
      case NavigatorName.utilities:
        {
          final utilities = settings.arguments as List<HomeUtilityData>;
          page = UtilitiesPage(utilities: utilities);
          break;
        }
      case NavigatorName.add_nutrition:
        {
          page = DailyNutritionPage(type: "input", id: null);
          break;
        }
      default:
        break;
    }
    return page != null ? MaterialPageRoute(settings: settings, builder: (_) => page!) : null;
  }
}
