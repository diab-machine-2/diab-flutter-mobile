import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/model/localization/localization.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/utils/logger.dart';
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
import 'package:flutter_localizations/flutter_localizations.dart';

// class SimpleBlocObserver extends BlocObserver {
//
//   @override
//   void onChange(BlocBase bloc, Change change) {
//     super.onChange(bloc, change);
//     logger.i('${bloc.runtimeType} $change');
//   }
//
//   @override
//   void onTransition(Bloc bloc, Transition transition) {
//     super.onTransition(bloc, transition);
//     logger.i(transition);
//   }
//
//   @override
//   void onError(BlocBase bloc, Object error, StackTrace stacktrace) {
//     super.onError(bloc, error, stacktrace);
//     logger.i("Error", error, stacktrace);
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  //await initializeDateFormatting('vi_VN');
  await Firebase.initializeApp();
  await TrackingManager.initializeFlutterFire();

  runApp(Localization.getLocalizationWidget(app: App()));
}


