import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/complete_smart_goal_request.dart';
import 'package:medical/src/model/response/create_calendar_response.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/views/bmi_on_boarding/bmi_on_boarding_page.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi_view_old/widgets/custom_height_picker.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi_view_old/widgets/custome_weight_picker.dart';
import 'package:medical/src/widget/Food/daily_nutrition/daily_nutrition.dart';
import 'package:medical/src/widget/calendar/calendar_model.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:medical/src/widget/my_plan_screens/exercise_tab/exercise_detail/exercise_detail_page.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail_page.dart';
import 'package:medical/src/widget/profile/user_info.dart';
import 'package:medical/src/widget/survey_screens/introduce_survey/introduce_survey.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility class for handling smart goal navigation and actions
class SmartGoalNavigationUtil {
  SmartGoalNavigationUtil._();

  /// Configuration for goal selection behavior
  static SmartGoalConfig _config = SmartGoalConfig();

  /// Set configuration for goal selection behavior
  static void setConfig(SmartGoalConfig config) {
    _config = config;
  }

  /// Main function to handle smart goal selection
  static Future<void> onSelectGoal(
    BuildContext context,
    ScheduleType type, {
    SmartGoalList? smartGoal,
    String? title,
    VoidCallback? onRefreshData,
  }) async {
    // Track event if title is provided
    if (title != null && _config.trackingEnabled) {
      final String eventName = "home_select_activity";
      TrackingManager.trackEvent(eventName, _config.screenName, params: {
        "object_title": title,
      });
    }

    Observable.instance.notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);

    switch (type) {
      case ScheduleType.blood_sugar:
      case ScheduleType.blood_sugar_recommend:
        await _handleBloodSugar(context, smartGoal);
        break;
      case ScheduleType.blood_pressure:
      case ScheduleType.blood_pressure_recommend:
        await _handleBloodPressure(context, smartGoal);
        break;
      case ScheduleType.weight_recommend:
        _showInputWeightDialog(context);
        break;
      case ScheduleType.height_recommend:
        _showInputHeightDialog(context);
        break;
      case ScheduleType.weight:
        await _handleWeight(context, smartGoal);
        break;
      case ScheduleType.emotion:
        await _handleEmotion(context, smartGoal);
        break;
      case ScheduleType.food:
      case ScheduleType.food_recommend:
        await _handleFood(context, smartGoal);
        break;
      case ScheduleType.exercise:
      case ScheduleType.exercise_recommend:
        await _handleExercise(context, smartGoal);
        break;
      case ScheduleType.exercise_movement:
        await _handleExerciseMovement(context, smartGoal);
        break;
      case ScheduleType.custom:
        _showCustomGoalPopup(context, smartGoal: smartGoal);
        break;
      case ScheduleType.book_1_1:
        _showCoachingPopup(context, smartGoal);
        break;
      case ScheduleType.survey:
      case ScheduleType.quiz:
        _showSurveyPopup(context, survey: smartGoal);
        break;
      case ScheduleType.lesson_recommend:
        Observable.instance
            .notifyObservers([], notifyName: Const.NAVIGATE_TO_LESSON_TAB);
        break;
      case ScheduleType.lesson:
      case ScheduleType.infographic:
      case ScheduleType.book_1_n:
        await _handleLesson(context, smartGoal);
        break;
      case ScheduleType.io_evaluate:
        _showCoachingPopup(context, smartGoal);
        break;
      case ScheduleType.update_profile:
      case ScheduleType.update_profile_recommend:
        await _handleUpdateProfile(context, smartGoal);
        break;
      case ScheduleType.output_assessment:
        _showCoachingPopup(context, smartGoal);
        break;
      case ScheduleType.hba1c_recommend:
        await _handleHbA1c(context, smartGoal);
        break;
      case ScheduleType.schedule_glucose_recommend:
        await _handleScheduleGlucose(context, smartGoal);
        break;
      case ScheduleType.food_menu:
        await _handleFoodMenu(context, smartGoal);
        break;
      case ScheduleType.goal_setting_recommend:
        await _handleGoalSetting(context, smartGoal);
        break;
      case ScheduleType.schedule_recommend:
        await _handleScheduleRecommend(context);
        break;
      case ScheduleType.peripheral_recommend:
        await _handlePeripheralRecommend(context);
        break;
      case ScheduleType.completed:
        // Do nothing
        break;
      case ScheduleType.screening_interview:
        await _handleInterviewNavigation(context,
            interviewType: 30, smartGoal: smartGoal);
        break;
      case ScheduleType.evaluate_interview:
        await _handleInterviewNavigation(context,
            interviewType: 31, smartGoal: smartGoal);
        break;
      case ScheduleType.booking_solo:
        await _handleInterviewNavigation(context,
            interviewType: 32, smartGoal: smartGoal);
        break;
    }

    // Call refresh callback if provided
    if (onRefreshData != null) {
      onRefreshData();
    }
  }

  // Private helper methods for each schedule type
  static Future<void> _handleBloodSugar(
      BuildContext context, SmartGoalList? smartGoal) async {
    if (_config.showGlucoseBottomSheet &&
        _config.customGlucoseHandler != null) {
      // Home screen specific glucose handling - call the custom function passed via config
      await _config.customGlucoseHandler!(
          NavigatorName.add_blood_sugar_new, smartGoal?.id);
    } else {
      // Standard navigation for activity tab and deeplinks
      await Navigator.pushNamed(context, NavigatorName.add_blood_sugar_new,
          arguments: {'type': 'input', 'goalId': smartGoal?.id});
    }
  }

  static Future<void> _handleBloodPressure(
      BuildContext context, SmartGoalList? smartGoal) async {
    if (_config.showBloodPressureIntro && !_config.hasInputBloodPressure) {
      await Navigator.pushNamed(
          context, NavigatorName.blood_pressure_intro_1st_page,
          arguments: {'goalId': smartGoal?.id});
    } else {
      await Navigator.pushNamed(context, NavigatorName.add_blood_pressure,
          arguments: {'type': 'input', 'goalId': smartGoal?.id});
    }
  }

  static Future<void> _handleWeight(
      BuildContext context, SmartGoalList? smartGoal) async {
    Map<String, dynamic> args = {
      'type': 'input',
      'goalId': smartGoal?.id,
      BmiOnBoardingPage.bmiBlocKey: context.read<BmiBloc>(),
    };
    await Navigator.pushNamed(context, NavigatorName.bmiInputPage,
        arguments: args);
  }

  static Future<void> _handleEmotion(
      BuildContext context, SmartGoalList? smartGoal) async {
    await Navigator.pushNamed(context, NavigatorName.add_emo,
        arguments: {'type': 'input', 'goalId': smartGoal?.id});
  }

  static Future<void> _handleFood(
      BuildContext context, SmartGoalList? smartGoal) async {
    await NavigationUtil.navigatePage(
      context,
      DailyNutritionPage(type: 'input', id: null, goalId: smartGoal?.id),
    );
  }

  static Future<void> _handleExercise(
      BuildContext context, SmartGoalList? smartGoal) async {
    await Navigator.pushNamed(context, NavigatorName.exercrise_add_v2,
        arguments: {'type': 'input', 'goalId': smartGoal?.id});
  }

  static Future<void> _handleExerciseMovement(
      BuildContext context, SmartGoalList? smartGoal) async {
    if (smartGoal?.exerciseData == null) return;

    if (smartGoal?.exerciseData?.exerciseMovementStates == null ||
        smartGoal?.state == Const.LESSON_LOCKED) {
      _showLockedDialog(
        context,
        title: R.string.exercise_lesson_locked.tr(),
        description: R.string.exercise_lesson_locked_warning.tr(),
      );
      return;
    }

    await NavigationUtil.navigatePage(
        context, ExerciseDetail(exerciseData: smartGoal?.exerciseData));

    Observable.instance.notifyObservers([], notifyName: "refresh_exercise_tab");
    Observable.instance.notifyObservers([], notifyName: "refresh_home");
  }

  static Future<void> _handleLesson(
      BuildContext context, SmartGoalList? smartGoal) async {
    final LessonSectionListResponseData? lessonDetail = smartGoal?.lessonData;
    if (lessonDetail == null) return;

    if (smartGoal?.state == Const.LESSON_LOCKED) {
      _showLockedDialog(
        context,
        title: R.string.lesson_locked.tr(),
        description: R.string.lesson_locked_warning.tr(),
      );
      return;
    }

    await NavigationUtil.navigatePage(
        context,
        LessonDetailPage(
          lessonType: lessonDetail.type,
          lessonId: lessonDetail.id ?? '',
          onComplete: (String, int) {},
          smartGoal: smartGoal,
        ));

    Observable.instance.notifyObservers([], notifyName: "refresh_lesson_tab");
    Observable.instance.notifyObservers([], notifyName: "refresh_home");
  }

  static Future<void> _handleUpdateProfile(
      BuildContext context, SmartGoalList? smartGoal) async {
    await Navigator.pushNamed(context, NavigatorName.profile_info, arguments: {
      'id': smartGoal?.state != 1 ? smartGoal?.id : null,
    });
  }

  static Future<void> _handleHbA1c(
      BuildContext context, SmartGoalList? smartGoal) async {
    await Navigator.pushNamed(context, NavigatorName.add_hba1c,
        arguments: {'type': 'input', 'goalId': smartGoal?.id});
  }

  static Future<void> _handleScheduleGlucose(
      BuildContext context, SmartGoalList? smartGoal) async {
    await Navigator.pushNamed(context, NavigatorName.schedule_glucose,
        arguments: {'smartGoal': smartGoal});
  }

  static Future<void> _handleFoodMenu(
      BuildContext context, SmartGoalList? smartGoal) async {
    await Navigator.pushNamed(context, NavigatorName.food_menu,
        arguments: {'smartGoal': smartGoal});
  }

  static Future<void> _handleGoalSetting(
      BuildContext context, SmartGoalList? smartGoal) async {
    await Navigator.pushNamed(context, NavigatorName.goal_setting,
        arguments: {'smartGoal': smartGoal});
  }

  static Future<void> _handleScheduleRecommend(BuildContext context) async {
    await Navigator.pushNamed(context, NavigatorName.reminder);
  }

  static Future<void> _handlePeripheralRecommend(BuildContext context) async {
    await Navigator.pushNamed(context, NavigatorName.connect_device_app);
  }

  static Future<void> _handleInterviewNavigation(
    BuildContext context, {
    required int interviewType,
    SmartGoalList? smartGoal,
  }) async {
    const courseId = '350a3050-c0f7-11ef-b57a-03ea338ae610';
    try {
      // Check if course exists
      bool isExist = await UserClient().IsExistCourse(courseId);
      if (!isExist) {
        Console.log("Course does not exist for interviewType: $interviewType");
        return;
      }

      final startDate = DateTime.now().add(Duration(days: 0));
      final endDate = DateTime.now().add(Duration(days: 21));
      int bookingQuantity = 0;

      final request = CalendarFilter(
        accountPatientId: AppSettings.userInfo!.accountId,
        courseId: courseId,
        fromDate: startDate,
        toDate: endDate,
        calendarType: interviewType,
      );

      final ApiResult<List<CreateCalendarResponse>> apiResult =
          await AppRepository().getMyCalendar(request);

      apiResult.when(
        success: (List<CreateCalendarResponse> response) {
          if (response.length > 0) {
            bookingQuantity = response.length;
            if (bookingQuantity >= 1) {
              // Navigate to existing calendar
              Navigator.pushNamed(context, NavigatorName.calendar, arguments: {
                "pickSlot": response.firstWhere(
                    (element) => element.isDeleted == false,
                    orElse: () => response.first),
                "courseId": courseId,
                "endTime": '',
                "bookingQuantity": bookingQuantity,
                "interviewType": interviewType,
              });
              return;
            }
          }

          // If no existing bookings, navigate to booking page
          if (bookingQuantity == 0) {
            Navigator.pushNamed(context, NavigatorName.calendar_booking,
                arguments: {
                  'courseId': courseId,
                  'endTime': '',
                  'interviewType': interviewType,
                  'smartGoal': smartGoal
                });
          }
        },
        failure: (NetworkExceptions error) {
          log("Error fetching calendar for interviewType $interviewType: $error");
          TrackingManager.recordError(error, null);
          // Still navigate to booking page on error
          Navigator.pushNamed(context, NavigatorName.calendar_booking,
              arguments: {
                'courseId': courseId,
                'endTime': '',
                'interviewType': interviewType,
                'smartGoal': smartGoal
              });
        },
      );
    } catch (e, s) {
      TrackingManager.recordError(e, s);
      log("Exception in _handleInterviewNavigation: $e");
    }
  }

  // Popup and dialog methods
  static void _showCustomGoalPopup(BuildContext context,
      {SmartGoalList? smartGoal}) {
    String description = '';
    if (smartGoal?.executeType == 0) {
      description = 'Thời gian: ${smartGoal?.executeDayTimes} phút';
    } else if (smartGoal?.executeType == 1) {
      description = 'Số lần: ${smartGoal?.executeDayTimes} lần';
    }

    _showPopup(
      context: context,
      buttonTitle: R.string.complete_lesson.tr(),
      isDisableCompleteButton: DateUtil.isAfter(
              smartGoal?.appointmentDate, AppSettings.currentDateTime) ??
          false,
      onTap: smartGoal?.isCompleted == true
          ? null
          : () async {
              await _completeSmartGoal(
                  smartGoal?.id,
                  smartGoal?.executeDayTimes,
                  smartGoal?.type,
                  smartGoal?.appointmentDate);
              NavigationUtil.pop(context);
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 57, vertical: 10),
            child: Image.asset(R.drawable.img_custom_goal),
          ),
          Text(
            smartGoal?.name ?? '',
            style: TextStyle(
                color: R.color.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
                color: R.color.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  static void _showCoachingPopup(
      BuildContext context, SmartGoalList? smartGoal) {
    if (smartGoal?.calendar == null) return;

    _showPopup(
      context: context,
      buttonTitle: R.string.join.tr(),
      isDisableCompleteButton: !DateUtil.isSameDay(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          smartGoal?.appointmentDate),
      onTap: () async {
        Navigator.pop(context);
        if (smartGoal?.calendar?.meetingLink != null) {
          await HomeClient().completeSmartGoal(
              DateTime.now(), smartGoal?.id, 1, smartGoal?.type);

          PermissionStatus statusMicrophone =
              await Permission.microphone.status;
          if (statusMicrophone.isDenied) {
            await Permission.microphone.request();
          }
          PermissionStatus statusCamera = await Permission.camera.request();
          if (statusCamera.isDenied) {
            await Permission.camera.request();
          }

          final meetingLink = smartGoal?.calendar?.meetingLink ?? '';
          if (await canLaunch(meetingLink)) {
            FlutterBranchSdk.handleDeepLink(meetingLink);
            await launch(
              meetingLink,
              forceSafariVC: false,
              forceWebView: false,
              headers: <String, String>{'my_header_key': 'my_header_value'},
            );
          } else {
            throw 'Could not launch $meetingLink';
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${getWeekDay(smartGoal?.appointmentDate ?? 0)}, ${convertToUTC(smartGoal?.appointmentDate ?? 0, "dd/MM/yyyy")}",
            style: TextStyle(
                color: R.color.main_1,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          if (smartGoal?.description != null &&
              smartGoal!.description!.isNotEmpty)
            Text(
              smartGoal.description ?? "",
              style: TextStyle(
                  color: R.color.main_1,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
          if (smartGoal?.description != null &&
              smartGoal!.description!.isNotEmpty)
            const SizedBox(height: 12),
          if (smartGoal?.calendar?.goal != null &&
              smartGoal!.calendar!.goal!.isNotEmpty)
            Text(
              smartGoal.calendar?.goal ?? "",
              style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
            ),
          if (smartGoal?.calendar?.goal != null &&
              smartGoal!.calendar!.goal!.isNotEmpty)
            const SizedBox(height: 16),
          if (smartGoal?.calendar?.performer != null)
            Row(
              children: [
                NetWorkImageWidget(
                    imageUrl: smartGoal!.calendar!.performer!.avatar?.url ?? "",
                    width: 44,
                    height: 44),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coach',
                      style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      smartGoal.calendar!.performer!.fullName ?? "",
                      style: TextStyle(
                          color: R.color.main_1,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                )
              ],
            ),
        ],
      ),
    );
  }

  static void _showSurveyPopup(BuildContext context, {SmartGoalList? survey}) {
    NavigationUtil.navigatePage(context, IntroduceSurveyPage(survey: survey));
  }

  static void _showLockedDialog(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      barrierDismissible: true,
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: R.color.transparent,
        body: Center(
          child: GestureDetector(
            child: Container(
              width: 344,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    R.color.white,
                    R.color.main_6,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(84.w, 0, 84.w, 20),
                    child: Image.asset(
                      R.drawable.img_lesson_locked,
                    ),
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: R.style.normalTextStyle,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ButtonWidget(
                      height: 43,
                      title: R.string.agree.tr(),
                      onPressed: () {
                        NavigationUtil.pop(context);
                      },
                      textSize: 14,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _showPopup({
    required BuildContext context,
    required Widget child,
    String? buttonTitle,
    VoidCallback? onTap,
    bool isDisableCompleteButton = false,
  }) {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      barrierDismissible: true,
      builder: (_) => GestureDetector(
        onTap: () {
          NavigationUtil.pop(context);
        },
        child: Scaffold(
          backgroundColor: R.color.transparent,
          body: Center(
            child: GestureDetector(
              onTap: () {},
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          R.color.white,
                          R.color.main_6,
                        ],
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          child,
                          Visibility(
                            visible: onTap != null,
                            child: SizedBox(height: 16),
                          ),
                          Visibility(
                            visible: onTap != null,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 16),
                              child: ButtonWidget(
                                backgroundColor: isDisableCompleteButton
                                    ? R.color.white
                                    : R.color.accentColor,
                                title: buttonTitle ?? '',
                                textSize: 14,
                                onPressed:
                                    isDisableCompleteButton ? null : onTap,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      top: 4,
                      right: 24,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        iconSize: 24,
                        onPressed: () {
                          NavigationUtil.pop(context);
                        },
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _showInputHeightDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => CustomNumPicker(
          callback: (data) {
            if (data == null || data <= 0) {
              Message.showToastMessage(
                  context, R.string.mes_height_must_greater_than_zero.tr());
              return;
            }
            final userInfo = AppSettings.userInfo!;
            ProfileInfoController.updateUserInfo(
              context,
              userInfo.copyWith(
                height: data.toDouble(),
              ),
            );
          },
          title: R.string.enter_height.tr(),
          max: 250,
          numberDefault: (AppSettings.userInfo!.height == null ||
                      AppSettings.userInfo!.height == 0
                  ? 150
                  : AppSettings.userInfo!.height)!
              .toInt(),
          unit: ''),
    );
  }

  static void _showInputWeightDialog(BuildContext context) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (_) => CustomWeightPicker(
          callback: (weight) {
            if (weight <= 0) {
              Message.showToastMessage(
                  context, R.string.mes_weight_must_greater_than_zero.tr());
              return;
            }
            final userInfo = AppSettings.userInfo!;
            ProfileInfoController.updateUserInfo(
              context,
              userInfo.copyWith(
                weight: weight.toDouble(),
              ),
            );
          },
          title: R.string.enter_weight.tr(),
          max: 180,
          numberDefault: (AppSettings.userInfo!.weight == null ||
                      AppSettings.userInfo!.weight == 0
                  ? 50
                  : AppSettings.userInfo!.weight)!
              .toInt(),
          unit: ''),
    );
  }

  static Future<void> _completeSmartGoal(
    String? smartGoalId,
    int? executeDayTimes,
    int? type,
    int? appointmentDate,
  ) async {
    if (smartGoalId == null) return;
    try {
      BotToast.showLoading();
      final CompleteSmartGoalRequest request = CompleteSmartGoalRequest(
          id: smartGoalId,
          executeTimes: executeDayTimes,
          type: type,
          appointmentDate: appointmentDate);
      final apiResult = await AppRepository().completeSmartGoal(request);
      apiResult.when(
        success: (response) {
          // Success handled by calling code
        },
        failure: (error) {
          TrackingManager.recordError(error, null);
        },
      );
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    } finally {
      BotToast.closeAllLoading();
    }
  }
}

class SmartGoalConfig {
  final String screenName;
  final bool trackingEnabled;
  final bool showGlucoseBottomSheet;
  final bool showBloodPressureIntro;
  final bool hasInputBloodPressure;
  final bool hasInputGlucose;
  final bool handleLessonReload;
  final Future<void> Function(String? routeName, String? smartGoalId)?
      customGlucoseHandler;
  final VoidCallback? onLessonReload;

  SmartGoalConfig({
    this.screenName = 'default',
    this.trackingEnabled = true,
    this.showGlucoseBottomSheet = false,
    this.showBloodPressureIntro = true,
    this.hasInputBloodPressure = false,
    this.hasInputGlucose = false,
    this.handleLessonReload = false,
    this.customGlucoseHandler,
    this.onLessonReload,
  });

  SmartGoalConfig copyWith({
    String? screenName,
    bool? trackingEnabled,
    bool? showGlucoseBottomSheet,
    bool? showBloodPressureIntro,
    bool? hasInputBloodPressure,
    bool? hasInputGlucose,
    bool? handleLessonReload,
    Future<void> Function(String? routeName, String? smartGoalId)?
        customGlucoseHandler,
    VoidCallback? onLessonReload,
  }) {
    return SmartGoalConfig(
      screenName: screenName ?? this.screenName,
      trackingEnabled: trackingEnabled ?? this.trackingEnabled,
      showGlucoseBottomSheet:
          showGlucoseBottomSheet ?? this.showGlucoseBottomSheet,
      showBloodPressureIntro:
          showBloodPressureIntro ?? this.showBloodPressureIntro,
      hasInputBloodPressure:
          hasInputBloodPressure ?? this.hasInputBloodPressure,
      hasInputGlucose: hasInputGlucose ?? this.hasInputGlucose,
      handleLessonReload: handleLessonReload ?? this.handleLessonReload,
      customGlucoseHandler: customGlucoseHandler ?? this.customGlucoseHandler,
      onLessonReload: onLessonReload ?? this.onLessonReload,
    );
  }
}
