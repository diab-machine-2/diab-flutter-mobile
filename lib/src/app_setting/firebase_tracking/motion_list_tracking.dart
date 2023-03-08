import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/models/completion_status.dart';

// MOTION LIST (Vận động)
class MotionListTracking {
  static const String screenName = 'excercise_route';
  static const String screenClass = 'ExerciseTabPage';

  static Future<void> firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
    AppSettings.currentScreenName = screenName;
  }

  static Future<void> clickChangeRoadMap() async {
    await TrackingManager.analytics.logEvent(
      name: 'cta_button_clicked',
      parameters: {
        'cta_button_name': 'cta_exercise_route',
      },
    );
  }

  static Future<void> clickJoinRoadMap({
    required String objectTitle,
    required String objectId,
  }) async {
    await TrackingManager.analytics.logEvent(
      name: 'cta_button_clicked',
      parameters: {
        "screen_name": screenName,
        'cta_button_name': 'cta_route_join',
        'object_title': objectTitle,
        'object_id': objectId,
      },
    );
  }

  static Future<void> clickConfirmJoinRoadMap({
    required String objectTitle,
    required String objectId,
  }) async {
    await TrackingManager.analytics.logEvent(
      name: 'cta_button_clicked',
      parameters: {
        "screen_name": screenName,
        'cta_button_name': 'cta_route_confirm',
        'object_title': objectTitle,
        'object_id': objectId,
      },
    );
  }

  static Future<void> selectWeekWorkout({
    required String objectTitle,
    required String objectIndex,
    required CompletionStatus status,
  }) async {
    String objectStatus = 'fail';
    switch (status) {
      case CompletionStatus.completed:
        objectStatus = 'done';
        break;
      case CompletionStatus.not_completed:
        objectStatus = 'new';
        break;
      case CompletionStatus.studying:
        objectStatus = 'this_week';
        break;
      case CompletionStatus.not_start_yet:
        objectStatus = 'fail';
        break;
    }

    await TrackingManager.analytics.logEvent(
      name: 'component_clicked',
      parameters: {
        "screen_name": screenName,
        'component_name': 'calendar_motion_select_week',
        'object_title': objectTitle,
        'object_index': objectIndex,
        'object_status': objectStatus,
      },
    );
  }

  static Future<void> selectDayWorkout({
    required String? objectTitle,
    required int objectIndex,
    required int? objectStatus,
  }) async {
    String status = 'fail';
    switch (objectStatus) {
      case Const.LESSON_LOCKED:
        status = 'fail';
        break;
      case Const.LESSON_NOT_LEARN:
        status = 'new';
        break;
      case Const.LESSON_LEARNING:
        status = 'today';
        break;
      case Const.LESSON_LEARNT:
        status = 'done';
        break;
      case Const.LESSON_CAN_NOT_LEARN:
        status = 'lock';
        break;
    }
    await TrackingManager.analytics.logEvent(
      name: 'component_clicked',
      parameters: {
        'screen_name': screenName,
        'component_name': 'calendar_motion_select_day',
        'object_title': objectTitle,
        'object_index': objectIndex,
        'object_status': status,
      },
    );
  }
}
