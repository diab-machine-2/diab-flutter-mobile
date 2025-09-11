import 'package:flutter/material.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/widget/BloodSugar/widget/blood_sugar_image_capture_new.dart';
import 'package:medical/src/widget/booking_clinic/booking_clinic_page.dart';
import 'package:medical/src/widget/BloodPressure/bloodpressure_result.dto.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_page.dart';
import 'package:medical/src/widget/meeting/meeting_prepare_page.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/create_goal/create_goal.dart';
import 'package:medical/src/widget/subscription/pages/paywall_screen.dart';
import 'package:medical/src/widget/utilities/utilities_page.dart';

import 'utils/navigator_name.dart';
import 'widget/BloodPressure/add_bloodpressure_result.dart';
import 'widget/BloodPressure/bloodPressure_detail_listing.dart';
import 'widget/BloodPressure/intro/bloodpressure_intro_1st_page.dart';
import 'widget/BloodPressure/intro/bloodpressure_intro_2nd_page.dart';
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
          final data = settings.arguments as Map<String, dynamic>?;
          // empty goal
          page = FoodMenuPage(
            smartGoal: data?['smartGoal'],
          );
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
      case NavigatorName.dsmes_booking:
        {
          final data = settings.arguments as Map<String, dynamic>?;
          page = DsmesAppointmentPage(
            pendingOnlineDeeplink: data?['pendingOnlineDeeplink'],
            pendingClinicId: data?['pendingClinicId'],
            pendingMode: data?['pendingMode'],
          );
          break;
        }
      case NavigatorName.booking_clinic:
        {
          page = BookingClinicPage();
          break;
        }
      case NavigatorName.add_blood_sugar_result:
        page = PageAddBloodSugarResult(
            data: settings.arguments as BloodSugarResultDto);
        break;
      case NavigatorName.glucose_intro_1st_page:
        final data = settings.arguments as Map<String, dynamic>?;
        page = GlucoseIntro1stPage(
          goalId: data?['goalId'],
        );
        break;
      case NavigatorName.glucose_intro_2nd_page:
        page = GlucoseIntro2ndPage();
        break;
      case NavigatorName.detail_blood_sugar_listing:
        final data = settings.arguments as Map<String, dynamic>?;
        page = BloodSugarDetailController(
          glucoseID: data?['glucoseID'],
          initPeriodFilterType: data?['initPeriodFilterType'],
          glucoseDistributionType: data?['glucoseDistributionType'],
        );
        break;
      case NavigatorName.paywall_screen:
        {
          page = PaywallScreen();
          break;
        }
      // ~ Huyet Ap (mới) ~
      case NavigatorName.blood_pressure_intro_1st_page:
        final data = settings.arguments as Map<String, dynamic>?;
        page = BloodPressureIntro1stPage(
          goalId: data?['goalId'],
        );
        break;
      case NavigatorName.blood_pressure_intro_2nd_page:
        page = BloodPressureIntro2ndPage();
        break;
      case NavigatorName.add_bloodpressure_result:
        page = PageAddBloodPressureResult(
            data: settings.arguments as BloodPressureResultDto);
        break;
      case NavigatorName.detail_bloodpressure_listing:
        final data = settings.arguments as Map<String, dynamic>?;
        page = BloodPressureDetailListingController(
          initBloodPressureID: data?['initBloodPressureID'],
          initPeriodFilterType: data?['initPeriodFilterType'],
          initBloodPressureRangeType: data?['initBloodPressureRangeType'],
        );
        break;
      // ~ END: Huyet Ap (mới) ~
      case NavigatorName.blood_sugar_image_capture:
        final data = settings.arguments as Map<String, dynamic>?;
        page = BloodSugarImageCaptureNew();
        break;

      default:
        break;
    }
    return page != null
        ? MaterialPageRoute(settings: settings, builder: (_) => page!)
        : null;
  }
}
