// ACTIVITY LIST (Vận động)
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/models/completion_status.dart';

class ActivityListTracking {
  static const String screenName = 'my_schedule';
  static const String screenClass = 'MyPlanPage';

  static Future<void> firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

// Chọn 1 tuần từ danh sách tuần
  static Future<void> selectWeekActivity({
    required String? objectTitle,
    required int objectIndex,
    required CompletionStatus completionStatus,
  }) async {
    String objectStatus = '';
    switch (completionStatus) {
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
    await TrackingManager.logEvent(
      name: 'component_clicked',
      parameters: {
        "screen_name": screenName,
        'component_name': 'calendar_activity_select_week',
        'object_index': objectIndex,
        'object_title': objectTitle ?? '',
        'object_status': objectStatus,
      },
    );
  }

  // Nhấn Thống kê
  static Future<void> clickStatistical() async {
    await TrackingManager.logEvent(
      name: 'cta_button_clicked',
      parameters: {
        "screen_name": screenName,
        'cta_button_name': 'cta_activity_report',
      },
    );
  }

  // Chọn 1 item từ danh sách Bài học
  static Future<void> clickLessonItem({
    required int? objectIndex,
    required String? objectId,
    required String? objectTitle,
  }) async {
    await TrackingManager.trackEvent('home_select_lesson', "home", params: {
      "object_title": objectTitle,
      "index": objectIndex,
    });

    await TrackingManager.trackEvent(
      'select_content',
      "library",
      params: {
        'content_id': objectId,
        'index': objectIndex,
        'content_type': 'lesson',
        'object_title': objectTitle,
      },
    );
  }

  // Nhấn Play Video bài tập vận động
  // static Future<void> clickStatistical() async {
  //   await TrackingManager.logEvent(
  //     name: 'cta_button_clicked',
  //     parameters: {
  //       "screen_name": screenName,
  //       'cta_button_name': 'cta_activity_report',
  //     },
  //   );
  // }
}
