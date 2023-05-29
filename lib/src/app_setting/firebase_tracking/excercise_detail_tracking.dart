// ACTIVITY LIST (Vận động)
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/models/video_manager.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/models/completion_status.dart';

class ExcerciseDetailTracking {
  static const String screenName = 'excercise_detail';
  static const String screenClass = 'ExerciseDetail';

  static Future<void> firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
    AppSettings.currentScreenName = screenName;
  }

  static Future<void> playVideo({
    required Duration videoDuration,
    required String? objectTitle,
    required String? objectId,
    required CustomPlayerEventType eventType,
  }) async {
    print('eventType: $eventType');
    if (eventType == CustomPlayerEventType.videoPlay) {
      await TrackingManager.analytics.logEvent(
        name: 'component_clicked',
        parameters: {
          "screen_name": screenName,
          'component_name': 'video_player_exercise',
          'object_id': objectId,
          'object_title': objectTitle,
        },
      );
    } else {
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
        case CustomPlayerEventType.videoPlay:
          // TODO: Handle this case.
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
  }
}
