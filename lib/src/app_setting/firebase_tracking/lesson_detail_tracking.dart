import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/models/video_manager.dart';

// LESSON (Bài học)
class LessonDetailTracking {
  static const String screenName = 'lesson_detail';

  static Future<void> firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: screenName,
      screenClass: "LessonDetailPage",
    );
    AppSettings.currentScreenName = screenName;
  }

  // 1. Nhấn Gợi ý trong Bài học
  static Future<void> lessonBegin({
    required String objectTitle,
    required String objectId,
  }) async {
    await TrackingManager.analytics.logEvent(
      name: 'lesson_begin',
      parameters: {
        'object_id': objectId,
        'object_title': objectTitle,
        "screen_name": screenName,
      },
    );
  }

  static Future<void> tabLessonRecommend() async {
    await TrackingManager.analytics.logEvent(
      name: 'component_clicked',
      parameters: {
        "screen_name": 'my_schedule',
        'component_name': 'tab_lesson_recommend',
      },
    );
  }

  // 2. Tương tác video bài học (Ngoại trừ start video)
  static Future<void> videoPlayerLesson({
    required Duration videoDuration,
    required String objectTitle,
    required String objectId,
    required CustomPlayerEventType eventType,
  }) async {
    late String componentAction;
    switch (eventType) {
      case CustomPlayerEventType.videoPause:
        componentAction = 'video_pause';
        break;
      case CustomPlayerEventType.videoFoward:
        componentAction = 'video_foward';
        break;
      case CustomPlayerEventType.videoPrevious:
        componentAction = 'video_previous';
        break;
      case CustomPlayerEventType.videoCompleted:
        componentAction = 'video_completed';
        break;
      case CustomPlayerEventType.videoReplay:
        componentAction = 'video_replay';
        break;
    }
    await TrackingManager.analytics.logEvent(
      name: 'component_video_action',
      parameters: {
        'object_id': objectId,
        'object_title': objectTitle,
        "screen_name": screenName,
        'component_action': componentAction,
        'component_name': 'video_player_lesson',
        'object_value': DateUtil.formatDuration(videoDuration),
      },
    );
  }

  // Xem Video đạt >=50%
  static Future<void> completed50PercentVideo({
    required String? objectId,
    required String? objectTitle,
  }) async {
    await TrackingManager.analytics.logEvent(
      name: 'component_video_hit_target',
      parameters: {
        'object_id': objectId,
        'object_title': objectTitle,
        "screen_name": screenName,
        'component_name': 'video_player_lesson',
      },
    );
  }

  static Future<void> playVideo({
    required String objectId,
    required String objectTitle,
  }) async {
    await TrackingManager.analytics.logEvent(
      name: 'component_clicked',
      parameters: {
        "screen_name": screenName,
        "component_name": 'video_player_lesson',
        'object_id': objectId,
        'object_title': objectTitle,
      },
    );
  }

  static Future<void> lessonDetailScrolling({
    required int percentComplete,
    required String objectId,
    required String objectTitle,
  }) async {
    String objectValue = '<10%';
    if (percentComplete <= 10) {
      objectValue = '<10%';
    } else if (percentComplete <= 30) {
      objectValue = '30%';
    } else if (percentComplete <= 50) {
      objectValue = '50%';
    } else if (percentComplete <= 70) {
      objectValue = '70%';
    } else if (percentComplete <= 90) {
      objectValue = '90%';
    } else {
      objectValue = '100%';
    }
    await TrackingManager.analytics.logEvent(
      name: 'component_scrolling',
      parameters: {
        "screen_name": screenName,
        "component_name": 'text_view_lesson',
        'object_id': objectId,
        'object_title': objectTitle,
        'object_value': objectValue,
      },
    );
  }

  static Future<void> lessonCompleted({
    required String? objectId,
    required String? objectTitle,
  }) async {
    await TrackingManager.analytics.logEvent(
      name: 'lesson_complete',
      parameters: {
        "screen_name": screenName,
        'object_id': objectId,
        'object_title': objectTitle
      },
    );
  }
}
