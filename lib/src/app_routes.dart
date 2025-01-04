import 'package:flutter/material.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/widget/meeting/meeting_prepare_page.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/create_goal/create_goal.dart';
import 'package:medical/src/widget/utilities/utilities_page.dart';

import 'utils/navigator_name.dart';
import 'widget/BloodSugar/add_bloodSugar_result.dart';
import 'widget/BloodSugar/bloodSugar_detail.dart';
import 'widget/BloodSugar/bloodSugar_result.dto.dart';
import 'widget/Food/daily_nutrition/daily_nutrition.dart';
import 'widget/food_menu_screens/food_menu/food_menu.dart';
import 'widget/glucose_intro/glucose_intro_1st_page.dart';
import 'widget/glucose_intro/glucose_intro_2nd_page.dart';
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
      case NavigatorName.add_goal:
        {
          page = CreateGoalPage(AppSettings.smartGoalDayList);
          break;
        }
      case NavigatorName.meeting_prepare:
        {
          page = MeetingPreparePage();
          break;
        }
      case NavigatorName.add_blood_sugar_result:
        page = PageAddBloodSugarResult(data: settings.arguments as BloodSugarResultDto);
        break;
      case NavigatorName.glucose_intro_1st_page:
        page = GlucoseIntro1stPage();
        break;
      case NavigatorName.glucose_intro_2nd_page:
        page = GlucoseIntro2ndPage();
        break;
      case NavigatorName.detail_blood_sugar_listing:
        final data = settings.arguments as Map<String, dynamic>?;
        page = BloodSugarDetailController(
          glucoseID: data?['glucoseID'],
          initPeriodFilterType: data?['initPeriodFilterType'],
        );
        break;
      default:
        break;
    }
    return page != null ? MaterialPageRoute(settings: settings, builder: (_) => page!) : null;
  }
}
