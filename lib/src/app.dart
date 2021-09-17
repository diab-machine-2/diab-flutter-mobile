import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/BloodPressure/add_bloodPressure.dart';
import 'package:medical/src/widget/BloodPressure/bloodPressure_detail_tabbar.dart';
import 'package:medical/src/widget/BloodPressure/widget/bloodPressure_table.dart';
import 'package:medical/src/widget/BloodSugar/add_bloodSugar.dart';
import 'package:medical/src/widget/BloodSugar/bloodSugar_detail_tabbar.dart';
import 'package:medical/src/widget/BloodSugar/bloodSugar_table_distribution.dart';
import 'package:medical/src/widget/BloodSugar/widget/bloodSugar_table.dart';
import 'package:medical/src/widget/BloodSugar/widget/bloodSugar_table_compare.dart';
import 'package:medical/src/widget/Bmi/bmi_detail_tabbar.dart';
import 'package:medical/src/widget/Bmi/widget/add_bmi.dart';
import 'package:medical/src/widget/Emotion/emotion_detail_tabbar.dart';
import 'package:medical/src/widget/Emotion/widget/add_emo.dart';
import 'package:medical/src/widget/Emotion/widget/add_insight.dart';
import 'package:medical/src/widget/Emotion/widget/add_symbo.dart';
import 'package:medical/src/widget/Emotion/widget/add_work.dart';
import 'package:medical/src/widget/Emotion/widget/emotion_table.dart';
import 'package:medical/src/widget/Exercrises/add_exercrises.dart';
import 'package:medical/src/widget/Exercrises/exercrises_detail_tabbar.dart';
import 'package:medical/src/widget/Exercrises/input_detail_exercrise.dart';
import 'package:medical/src/widget/Exercrises/search_exercrises.dart';
import 'package:medical/src/widget/Food/add_food.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/Food/search_food_controller.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/flash_screen/flash_screen.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/login/change_password.dart';
import 'package:medical/src/widget/login/login.dart';
import 'package:medical/src/widget/login/register.dart';
import 'package:medical/src/widget/login/policy.dart';
import 'package:medical/src/widget/login/rules.dart';
import 'package:medical/src/widget/login/step_list.dart';
import 'package:medical/src/widget/login/forgot_password.dart';
import 'package:medical/src/widget/login/verify_phone.dart';
import 'package:medical/src/widget/login/create_new_password.dart';
import 'package:medical/src/widget/login/register_success.dart';
import 'package:medical/src/widget/login/update_info.dart';
import 'package:medical/src/widget/notification/notification_detail.dart';
import 'package:medical/src/widget/notification/notification_tabbar.dart';
import 'package:medical/src/widget/profile/add_reminder.dart';
import 'package:medical/src/widget/profile/contact.dart';
import 'package:medical/src/widget/profile/goal_setting.dart';
import 'package:medical/src/widget/profile/manual_detail.dart';
import 'package:medical/src/widget/profile/manuals.dart';
import 'package:medical/src/widget/profile/motivation_diary.dart';
import 'package:medical/src/widget/profile/profile.dart';
import 'package:medical/src/widget/profile/reminder.dart';
import 'package:medical/src/widget/profile/schedule_activities.dart';
import 'package:medical/src/widget/profile/schedule_glucose.dart';
import 'package:medical/src/widget/profile/setting_schedule_glucose.dart';
import 'package:medical/src/widget/profile/user_info.dart';
import 'package:medical/src/widget/tabbar/tabbar.dart';
import 'package:medical/src/widget/HbA1C/add_hba1c.dart';
import 'package:medical/src/widget/HbA1C/hba1c_tabble.dart';
import 'package:medical/src/widget/HbA1C/hba1c_detail_tabbar.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
class _AppState extends State<App> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(375, 812),
        builder: () => MaterialApp(
            title: 'diaB',
            color: Colors.white,
            theme: AppTheme.theme,
            builder: BotToastInit(),
            navigatorKey: navigatorKey,
            navigatorObservers: [
              BotToastNavigatorObserver(),
              routeObserver,
              TrackingManager.observerFirebase
            ],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('vi')],
            home: FlashScreenController(),
            debugShowCheckedModeBanner: false,
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/tabbar':
                  return _buildRoute(settings, TabbarController());
                case '/login':
                  return _buildRoute(settings, LoginController(), isPresent: true);
                case '/register':
                  return _buildRoute(settings, RegisterController(), isPresent: true);
                case '/register_success':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      RegisterSuccess(
                          phone: data['phone'], password: data['password']));
                case '/update_info':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      UpdateInfoController(
                          type: data['type'],
                          googleAccount: data['googleAccount'],
                          facebookAccount: data['facebookAccount'],
                          appleAccount: data['appleAccount'],
                          userInfo: data['userInfo']));
                case '/forgot_password':
                  return _buildRoute(settings, ForgotPasswordController());
                case '/new_password':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      NewPasswordController(
                          phone: data['phone'], token: data['token']),
                      isPresent: true);
                case '/verify':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      VerifyPhoneController(
                          type: data['type'],
                          otp: data['otp'],
                          phone: data['phone'],
                          password: data['password'],
                          remainingRequestCount: data['remainingRequestCount'],
                          googleAccount: data['googleAccount'],
                          facebookAccount: data['facebookAccount'],
                          appleAccount: data['appleAccount'],
                          userInfo: data['userInfo']));

                case '/change_password':
                  return _buildRoute(settings, ChangePasswordController());
                case '/policy':
                  return _buildRoute(settings, PolicyController(), isPresent: true);
                case '/step_list':
                  return _buildRoute(settings, StepListController(), isPresent: true);
                case '/rules':
                  return _buildRoute(settings, RulesController());
                case '/add_hba1c':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      AddHBA1CController(
                        type: data['type'],
                        id: data['id'],
                      ));
                case '/detail_hba1c':
                  return _buildRoute(settings, Hba1cDetailTabbarController(),
                      isPresent: true);
                case '/detail_exercrises':
                  return _buildRoute(settings, ExercrisesDetailTabbarController(),
                      isPresent: true);
                case '/detail_bloodSugar':
                  return _buildRoute(settings, BloodSugarDetailTabbarController(),
                      isPresent: true);
                case '/hba1c_tabble':
                  return _buildRoute(settings, HbA1CTable(), isPresent: true);
                case '/add_bloodSugar':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      AddBloodSugarController(
                        type: data['type'],
                        id: data['id'],
                      ));
                case '/add_exercrises':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      AddExercrisesController(
                        type: data['type'],
                        id: data['id'],
                      ));
                case '/search_exercrises':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      SearchExercrisesController(
                        type: data['type'],
                        id: data['id'],
                        model: data['model'],
                      ));
                case '/add_bloodPressure':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      AddBloodPressureController(
                        type: data['type'],
                        id: data['id'],
                      ));
                case '/input_detail_exercrise':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      InputDetailExercrisesController(
                        model: data['model'],
                      ));
                case '/bloodPressureTable':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      BloodPressureTableController(
                          title: data['title'],
                          bloodPressureType: data['bloodPressureType'],
                          periodFilterType: data['periodFilterType'],
                          isPulseRate: data['isPulseRate']),
                      isPresent: true);
                case '/bloodSugarTable':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      BloodSugarTableController(
                          title: data['title'],
                          timeFrameType: data['timeFrameType'],
                          periodFilterType: data['periodFilterType'],
                          glucoseDistributionType: data['glucoseDistributionType']),
                      isPresent: true);
                case '/bloodSugarDistributionTable':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      BloodSugarDistribuitonTableController(
                          title: data['title'],
                          timeFrameType: data['timeFrameType'],
                          periodFilterType: data['periodFilterType'],
                          glucoseDistributionType: data['glucoseDistributionType']),
                      isPresent: true);
                case '/bloodSugarCompareTable':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      BloodSugarTableCompareController(
                          model: data['model'], title: data['title']),
                      isPresent: true);
                case '/detail_bloodPressure':
                  return _buildRoute(settings, BloodPressureDetailTabbarController(),
                      isPresent: true);
                case '/detail_bmi':
                  return _buildRoute(settings, BmiDetailTabbarController(),
                      isPresent: true);
                case '/bmi':
                  return _buildRoute(settings, FoodDetailTabbarController(),
                      isPresent: true);
                case '/add_bmi':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      AddBmiController(
                        type: data['type'],
                        id: data['id'],
                      ));
                case '/add_emo':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      AddEmoController(
                        type: data['type'],
                        emotion: data['emotion'],
                      ));
                case '/add_symbo':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      AddSymboController(
                        type: data['type'],
                        emotion: data['emotion'],
                        symptoms: data['symptoms'],
                        otherSymptom: data['otherSymptom'],
                      ));
                case '/add_work':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      AddWorkController(
                          type: data['type'],
                          emotion: data['emotion'],
                          symptoms: data['symptoms'],
                          activities: data['activities'],
                          otherSymptom: data['otherSymptom'],
                          otherActivity: data['otherActivity']));

                case '/add_insight':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      AddInsightController(
                          id: data['id'],
                          type: data['type'],
                          emotion: data['emotion'],
                          symptoms: data['symptoms'],
                          activities: data['activities'],
                          otherSymptom: data['otherSymptom'],
                          otherActivity: data['otherActivity']));
                case '/detail_food':
                  return _buildRoute(settings, FoodDetailTabbarController(),
                      isPresent: true);
                case '/detail_emotion':
                  return _buildRoute(settings, EmotionDetailTabbarController(),
                      isPresent: true);
                case '/add_food':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      AddFoodController(
                        type: data['type'],
                        id: data['id'],
                      ));
                case '/emotionTable':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings,
                      EmotionTableController(
                          title: data['title'],
                          emotionId: data['emotionId'],
                          periodFilterType: data['periodFilterType']),
                      isPresent: true);
                case '/profile':
                  return _buildRoute(settings, ProfileController());
                case '/goal_setting':
                  return _buildRoute(settings, GoalSettingController());
                case '/profile_info':
                  return _buildRoute(settings, ProfileInfoController());
                case '/notification':
                  return _buildRoute(settings, NotificationTabbarController());
                case '/notification_detail':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings, NotificationDetailController(id: data['id']));
                case '/schedule_activity':
                  return _buildRoute(settings, ScheduleActivityController());
                case '/manual':
                  return _buildRoute(settings, ManualController());
                case '/manual_detail':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings, ManualDetailController(model: data['manual']));
                case '/contact':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(
                      settings, ContactController(model: data['contact']));
                case '/motivation':
                  return _buildRoute(settings, MotivationController());
                case '/reminder':
                  return _buildRoute(settings, ReminderController());
                case '/add_reminder':
                  final data = settings.arguments as Map<String, dynamic>;
                  return _buildRoute(settings,
                      AddReminderController(type: data['type'], id: data['id']));
                case '/schedule_glucose':
                  return _buildRoute(settings, ScheduleGlucoseController());
                case '/setting_schedule_glucose':
                  return _buildRoute(settings, SettingScheduleGlucoseController());
                default:
                  return null;
              }
            }),
            );
  }

  PageRoute _buildRoute(RouteSettings settings, Widget builder,
      {bool isPresent = false}) {
    // return MaterialPageRoute(
    //   fullscreenDialog: true,
    //   settings: settings,
    //   builder: (ctx) => builder,
    // );
    if (isPresent) {
      return CupertinoPageRoute(
          settings: settings,
          fullscreenDialog: true,
          builder: (context) => builder);
    } else {
      return MaterialPageRoute(
        settings: settings,
        builder: (ctx) => builder,
      );
    }
  }
}
