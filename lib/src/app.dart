import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/service/zoom_service.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/widget/BloodPressure/add_bloodPressure.dart';
import 'package:medical/src/widget/BloodPressure/bloodPressure_detail_tabbar.dart';
import 'package:medical/src/widget/BloodPressure/widget/bloodPressure_table.dart';
import 'package:medical/src/widget/BloodSugar/add_bloodSugar.dart';
import 'package:medical/src/widget/BloodSugar/bloodSugar_detail_tabbar.dart';
import 'package:medical/src/widget/BloodSugar/bloodSugar_table_distribution.dart';
import 'package:medical/src/widget/BloodSugar/widget/bloodSugar_table.dart';
import 'package:medical/src/widget/BloodSugar/widget/bloodSugar_table_compare.dart';
import 'package:medical/src/widget/Bmi/bmi_detail_tabbar.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi_view/add_bmi_view.dart';
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
import 'package:medical/src/widget/HbA1C/add_hba1c.dart';
import 'package:medical/src/widget/HbA1C/hba1c_detail_tabbar.dart';
import 'package:medical/src/widget/HbA1C/hba1c_tabble.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/flash_screen/flash_screen.dart';
import 'package:medical/src/widget/home/widget/sync_loading.dart';
import 'package:medical/src/widget/login/change_password.dart';
import 'package:medical/src/widget/login/create_new_password.dart';
import 'package:medical/src/widget/login/forgot_password.dart';
import 'package:medical/src/widget/login/login.dart';
import 'package:medical/src/widget/login/policy.dart';
import 'package:medical/src/widget/login/register.dart';
import 'package:medical/src/widget/login/register_success.dart';
import 'package:medical/src/widget/login/rules.dart';
import 'package:medical/src/widget/login/step_list.dart';
import 'package:medical/src/widget/login/update_info.dart';
import 'package:medical/src/widget/login/verify_phone.dart';
import 'package:medical/src/widget/meeting/meeting_cubit.dart';
import 'package:medical/src/widget/meeting/meeting_page.dart';
import 'package:medical/src/widget/meeting/meeting_prepare_page.dart';
import 'package:medical/src/widget/nipro/connect_device_app.dart';
import 'package:medical/src/widget/nipro/connection_instructions.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';
import 'package:medical/src/widget/notification/notification_detail.dart';
import 'package:medical/src/widget/notification/notification_tabbar.dart';
import 'package:medical/src/widget/profile/add_reminder.dart';
import 'package:medical/src/widget/profile/contact.dart';
import 'package:medical/src/widget/profile/delete_account/presentation/views/delete_account_view.dart';
import 'package:medical/src/widget/profile/goal_setting.dart';
import 'package:medical/src/widget/profile/manual_detail.dart';
import 'package:medical/src/widget/profile/manuals.dart';
import 'package:medical/src/widget/profile/motivation_diary.dart';
import 'package:medical/src/widget/profile/reminder.dart';
import 'package:medical/src/widget/profile/schedule_activities.dart';
import 'package:medical/src/widget/profile/schedule_glucose.dart';
import 'package:medical/src/widget/profile/setting_schedule_glucose.dart';
import 'package:medical/src/widget/profile/user_info.dart';
import 'package:medical/src/widget/question_answer/make_question/make_question_page.dart';
import 'package:medical/src/widget/question_answer/question_detail/question_detail_page.dart';
import 'package:medical/src/widget/tabbar/tabbar.dart';
import 'package:medical/src/widget/voucher/presentation/voucher_detail/pages/voucher_detail_view.dart';
import 'package:medical/src/widget/voucher/presentation/voucher_list/pages/voucher_list_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'utils/navigator_name.dart';
import 'widget/BloodSugar/add_bloodSugar_new.dart';
import 'widget/helper/photo_view.dart';
import 'widget/home/widget/sync_screen.dart';
import 'widget/meeting/meeting_wait_room_page.dart';
import 'widget/news_detail/presentation/news_detail_view.dart';
import 'widget/ocr/test_ocr_camera_page.dart';
import 'widget/ocr/test_ocr_gallery_page.dart';
import 'widget/ocr/test_ocr_page.dart';
import 'widget/profile/profile_controller.dart';
import 'widget/shared_profile/pages/share_app_detail/share_app_detail.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    // DeepLinkConfig.instance.handleDeepLink();
  }

  @override
  void dispose() {
    // DeepLinkConfig.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      designSize: const Size(375, 812),
      builder: (_, child) {
        return RefreshConfiguration(
          headerTriggerDistance: 25,
          headerBuilder: () => MaterialClassicHeader(
            color: R.color.accentColor,
          ), // Configure the default header indicator. If you have the same header indicator for each page, you need to set this
          footerBuilder: () => const ClassicFooter(),
          child: PiPMaterialApp(
              title: 'diaB',
              color: Colors.white,
              theme: AppTheme.theme,
              builder: (context, child) {
                // TODO: textScaleFactor deprecated >> CHECK LATER
                // MediaQueryData mediaData = MediaQuery.of(context);
                // child = MediaQuery(
                //   data: mediaData.copyWith(textScaleFactor: min(1.1, mediaData.textScaleFactor)),
                //   child: child!,
                // );
                child = BotToastInit()(context, child);
                return child;
              },
              navigatorKey: navigatorKey,
              navigatorObservers: [
                BotToastNavigatorObserver(),
                routeObserver,
                // TrackingManager.observerFirebase
              ],
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: FlashScreenController(),
              debugShowCheckedModeBanner: false,
              useInheritedMediaQuery: true,
              onGenerateRoute: (settings) {
                Console.log('settings.name', settings.name);
                switch (settings.name) {
                  case NavigatorName.tabbar:
                    String sharedCode = '';
                    bool isRedirectFromNotification = false;
                    if (settings.arguments != null) {
                      if (settings.arguments is String) {
                        sharedCode = settings.arguments! as String;
                      } else if (settings.arguments is Map<String, dynamic>) {
                        final data =
                            settings.arguments as Map<String, dynamic>?;
                        isRedirectFromNotification =
                            data!['isRedirectFromNotification'];
                      }
                    }
                    return _buildRoute(
                        settings,
                        TabbarController(
                          sharedCode: sharedCode,
                          isRedirectFromNotification:
                              isRedirectFromNotification,
                        ));
                  case NavigatorName.login:
                    String sharedCode = '';
                    if (settings.arguments != null) {
                      sharedCode = settings.arguments! as String;
                    }
                    return _buildRoute(settings, LoginController(sharedCode),
                        isPresent: true);
                  case NavigatorName.register:
                    final data = settings.arguments as Map<String, dynamic>?;
                    // String sharedCode = '';
                    // if (settings.arguments != null) {
                    //   sharedCode = settings.arguments! as String;
                    // }
                    return _buildRoute(
                        settings,
                        RegisterController(
                          sharedCode: data?['referalCode'],
                          phone: data?['phone'],
                        ),
                        isPresent: true);
                  case NavigatorName.register_success:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        RegisterSuccess(
                          phone: data?['phone'],
                          password: data?['password'],
                          referalCode: data?['referalCode'],
                          type: data?['type'],
                          googleAccount: data?['googleAccount'],
                          appleAccount: data?['appleAccount'],
                          diabeteStates: data?['diabeteStates'],
                        ));
                  case NavigatorName.update_info:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        UpdateInfoController(
                          type: data?['type'],
                          phone: data?['phone'],
                          zaloAccount: data?['zaloAccount'],
                          googleAccount: data?['googleAccount'],
                          facebookAccount: data?['facebookAccount'],
                          appleAccount: data?['appleAccount'],
                          userInfo: data?['userInfo'],
                          referalCode: data?['referalCode'],
                          diabeteStates: data?['diabeteStates'],
                        ));
                  case NavigatorName.forgot_password:
                    return _buildRoute(settings, ForgotPasswordController());
                  case NavigatorName.new_password:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        NewPasswordController(
                            phone: data?['phone'], token: data?['token']),
                        isPresent: true);
                  case NavigatorName.verify:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        VerifyPhoneController(
                            type: data?['type'],
                            otp: data?['otp'],
                            phone: data?['phone'],
                            password: data?['password'],
                            remainingRequestCount:
                                data?['remainingRequestCount'],
                            referalCode: data?['referalCode'],
                            googleAccount: data?['googleAccount'],
                            facebookAccount: data?['facebookAccount'],
                            appleAccount: data?['appleAccount'],
                            userInfo: data?['userInfo']));

                  case NavigatorName.change_password:
                    return _buildRoute(settings, ChangePasswordController());
                  case NavigatorName.policy:
                    return _buildRoute(settings, PolicyController(),
                        isPresent: true);
                  case NavigatorName.step_list:
                    String sharedCode = '';
                    if (settings.arguments != null) {
                      sharedCode = settings.arguments! as String;
                    }
                    return _buildRoute(settings, StepListController(sharedCode),
                        isPresent: true);
                  // case NavigatorName.rules:
                  //   final data = settings.arguments as Map<String, dynamic>?;
                  //   return _buildRoute(
                  //       settings,
                  //       RulesController(
                  //         googleAccount: data?['googleAccount'],
                  //         appleCredential: data?['appleCredential'],
                  //       ));
                  case NavigatorName.add_hba1c:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        AddHBA1CController(
                          type: data?['type'],
                          id: data?['id'],
                        ));
                  case NavigatorName.detail_hba1c:
                    return _buildRoute(settings, Hba1cDetailTabbarController(),
                        isPresent: true);
                  case NavigatorName.detail_exercrises:
                    return _buildRoute(
                        settings, ExercrisesDetailTabbarController(),
                        isPresent: true);
                  case NavigatorName.detail_blood_sugar:
                    final data = settings.arguments as Map<dynamic, dynamic>?;
                    return _buildRoute(
                        settings, BloodSugarDetailTabbarController(data: data),
                        isPresent: true);
                  case NavigatorName.hba1c_tabble:
                    return _buildRoute(settings, HbA1CTable(), isPresent: true);
                  case NavigatorName.add_blood_sugar:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        AddBloodSugarController(
                          type: data?['type'],
                          id: data?['id'],
                          goalId: data?['goalId'],
                        ));
                  case NavigatorName.add_blood_sugar_new:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        AddBloodSugarControllerNew(
                          type: data?['type'],
                          id: data?['id'],
                          goalId: data?['goalId'],
                        ));
                  case NavigatorName.add_exercrises:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        AddExercrisesController(
                          type: data?['type'],
                          id: data?['id'],
                          goalId: data?['goalId'],
                        ));
                  case NavigatorName.search_exercrises:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        SearchExercrisesController(
                          type: data?['type'],
                          id: data?['id'],
                          model: data?['model'],
                        ));
                  case NavigatorName.add_blood_pressure:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        AddBloodPressureController(
                          type: data?['type'],
                          id: data?['id'],
                          goalId: data?['goalId'],
                        ));
                  case NavigatorName.input_detail_exercrise:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        InputDetailExercrisesController(
                          model: data?['model'],
                        ));
                  case NavigatorName.blood_pressure_table:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        BloodPressureTableController(
                            title: data?['title'],
                            bloodPressureType: data?['bloodPressureType'],
                            periodFilterType: data?['periodFilterType'],
                            isPulseRate: data?['isPulseRate']),
                        isPresent: true);
                  case NavigatorName.blood_sugar_table:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        BloodSugarTableController(
                            title: data?['title'],
                            timeFrameType: data?['timeFrameType'],
                            periodFilterType: data?['periodFilterType'],
                            glucoseDistributionType:
                                data?['glucoseDistributionType']),
                        isPresent: true);
                  case NavigatorName.blood_sugar_distribution_table:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        BloodSugarDistribuitonTableController(
                            title: data?['title'],
                            timeFrameType: data?['timeFrameType'],
                            periodFilterType: data?['periodFilterType'],
                            glucoseDistributionType:
                                data?['glucoseDistributionType']),
                        isPresent: true);
                  case NavigatorName.blood_sugar_compare_table:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        BloodSugarTableCompareController(
                          model: data?['model'],
                          title: data?['title'],
                          comparerType: data?['comparerType'],
                          periodFilterType: data?['periodFilterType'],
                        ),
                        isPresent: true);
                  case NavigatorName.detail_blood_pressure:
                    return _buildRoute(
                        settings, BloodPressureDetailTabbarController(),
                        isPresent: true);
                  case NavigatorName.detail_bmi:
                    return _buildRoute(settings, BmiDetailTabbarController(),
                        isPresent: true);
                  case NavigatorName.bmi:
                    return _buildRoute(settings, FoodDetailTabbarController(),
                        isPresent: true);
                  case NavigatorName.add_bmi:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        AddBmiView(
                          // AddBmiController(
                          type: data?['type'],
                          id: data?['id'],
                          goalId: data?['goalId'],
                        ));
                  case NavigatorName.add_emo:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        AddEmoController(
                          type: data?['type'],
                          emotion: data?['emotion'],
                          goalId: data?['goalId'],
                        ));
                  case NavigatorName.add_symbo:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        AddSymboController(
                          type: data?['type'],
                          emotion: data?['emotion'],
                          symptoms: data?['symptoms'],
                          otherSymptom: data?['otherSymptom'],
                          goalId: data?['goalId'],
                        ));
                  case NavigatorName.add_work:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        AddWorkController(
                          type: data?['type'],
                          emotion: data?['emotion'],
                          symptoms: data?['symptoms'],
                          activities: data?['activities'],
                          otherSymptom: data?['otherSymptom'],
                          otherActivity: data?['otherActivity'],
                          goalId: data?['goalId'],
                        ));

                  case NavigatorName.add_insight:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        AddInsightController(
                          id: data?['id'],
                          type: data?['type'],
                          emotion: data?['emotion'],
                          symptoms: data?['symptoms'],
                          activities: data?['activities'],
                          otherSymptom: data?['otherSymptom'],
                          otherActivity: data?['otherActivity'],
                          goalId: data?['goalId'],
                        ));
                  case NavigatorName.detail_emotion:
                    return _buildRoute(
                        settings, EmotionDetailTabbarController(),
                        isPresent: true);
                  case '/add_food':
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        AddFoodController(
                          type: data?['type'],
                          id: data?['id'],
                        ));
                  case NavigatorName.profile:
                    return _buildRoute(settings, const ProfileController());
                  case NavigatorName.profile_info:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings, ProfileInfoController(id: data?['id']));
                  case NavigatorName.delete_account:
                    return _buildRoute(settings, DeleteAccountController());
                  case NavigatorName.notification_detail:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        NotificationDetailController(
                            id: data?['id'],
                            communicationId: data?['communicationId']));
                  case NavigatorName.detail_food:
                    return _buildRoute(settings, FoodDetailTabbarController(),
                        isPresent: true);
                  case '/add_food':
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        AddFoodController(
                          type: data?['type'],
                          id: data?['id'],
                        ));
                  case NavigatorName.emotion_table:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        EmotionTableController(
                            title: data?['title'],
                            emotionId: data?['emotionId'],
                            periodFilterType: data?['periodFilterType']),
                        isPresent: true);
                  case NavigatorName.goal_setting:
                    return _buildRoute(settings, GoalSettingController());
                  case NavigatorName.notification:
                    return _buildRoute(
                        settings, NotificationTabbarController());
                  case NavigatorName.schedule_activity:
                    return _buildRoute(settings, ScheduleActivityController());
                  case NavigatorName.manual:
                    return _buildRoute(settings, ManualController());
                  case NavigatorName.manual_detail:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(settings,
                        ManualDetailController(model: data?['manual']));
                  case NavigatorName.contact:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings, ContactController(model: data?['contact']));
                  case NavigatorName.motivation:
                    return _buildRoute(settings, MotivationController());
                  case NavigatorName.reminder:
                    return _buildRoute(settings, ReminderController());
                  case NavigatorName.add_reminder:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        AddReminderController(
                            type: data?['type'], id: data?['id']));
                  case NavigatorName.schedule_glucose:
                    return _buildRoute(
                        settings, const ScheduleGlucoseController());
                  case NavigatorName.setting_schedule_glucose:
                    return _buildRoute(
                        settings, SettingScheduleGlucoseController());
                  case '/photo_view':
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(settings,
                        PhotoView(files: data?['files'], index: data?['index']),
                        isPresent: true);
                  case NavigatorName.make_question:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        MakeQuestionPage(
                            lessonModuleItems: data!['lessonModuleItems']),
                        isPresent: true);
                  case NavigatorName.question_detail:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        QuestionDetailPage(
                            questionModel: data!['questionModel'],
                            isAll: data['isAll']),
                        isPresent: true);
                  case NavigatorName.news_detail:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                      settings,
                      NewsDetailView(id: data?['id']),
                    );
                  case NavigatorName.connection_instructions:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                      settings,
                      ConnectionInstructionsController(
                          connectOnly:
                              data == null ? false : data['connectOnly']),
                    );

                  case NavigatorName.connect_device_app:
                    return _buildRoute(
                      settings,
                      ConnectDeviceApp(),
                    );
                  case NavigatorName.voucher_list:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(settings,
                        VoucherListView(voucherId: data?['voucherId']));
                  case NavigatorName.voucher_detail:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        VoucherDetailView(
                          voucherId: data?['voucherId'],
                          updateVoucherList: data?['updateVoucherList'],
                        ));
                  case NavigatorName.share_app_detail:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                        settings,
                        ShareAppDetail(
                            isVoucherAvailable: data?['isVoucherAvailable']));
                  case NavigatorName.lesson_detail:
                    final data = settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                      settings,
                      LessonDetailPage(
                        lessonId: data?['lessonId'],
                        lessonType: data?['lessonType'],
                        onComplete: (String, int) {},
                      ),
                    );
                  // case NavigatorName.zoom:
                  //   final data = settings.arguments as Map<String, dynamic>?;
                  //   if (Platform.isAndroid) {
                  //       return _buildRoute(
                  //           settings, ZoomAndroidView(calendarID: data?['id']));
                  //   } else {
                  //       return _buildRoute(
                  //           settings, ZoomIosView(calendarID: data?['id']));
                  //   }

                  case NavigatorName.meeting_wait_room:
                    {
                      final args = settings.arguments as MeetingArguments;
                      return _buildRoute(
                          settings, MeetingWaitRoomPage(args: args));
                    }
                  case NavigatorName.sync_screen:
                    return _buildRoute(settings, SyncScreenController());
                  case NavigatorName.sync_screen:
                    return _buildRoute(settings, SyncScreenController());
                  case NavigatorName.sync_loading:
                    {
                      final args = settings.arguments as Map<String, dynamic>;
                      return _buildRoute(
                          settings,
                          SyncLoadingController(
                            phoneNumber: args['phoneNumber'],
                            providerName: args['providerName'],
                            providerKey: args['providerKey'],
                          ));
                    }
                  case NavigatorName.meeting:
                    {
                      // if (settings.arguments is MeetingCubit) {
                      //   final cubit = settings.arguments as MeetingCubit;
                      //   return _buildRoute(settings, MeetingPage(null, cubit));
                      // }
                      final args = settings.arguments as MeetingArguments;
                      return _buildRoute(settings, MeetingPage(args));
                    }
                  // test ocr
                  case NavigatorName.test_ocr:
                    return _buildRoute(settings, TestOcrPage());
                  case NavigatorName.test_ocr_camera:
                    return _buildRoute(settings, TestOcrCamera());
                  case NavigatorName.test_ocr_gallery:
                    return _buildRoute(settings, TestOcrGallery());

                  default:
                    return null;
                }
              }),
        );
      },
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
