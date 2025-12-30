// This file has been replaced by branchio_link_config.dart
// All functionality has been migrated to BranchioLinkConfig
// This file is kept for backward compatibility but redirects to BranchioLinkConfig

import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/service/zoom_service.dart';
import '../model/response/lesson_section_list_response.dart';
import '../modal/learning/learning_post_model.dart';

// Re-export BranchioLinkConfig as DynamicLinkConfig for backward compatibility
class DynamicLinkConfig {
  DynamicLinkConfig._privateConstructor();
  static final DynamicLinkConfig instance =
      DynamicLinkConfig._privateConstructor();

  // Delegate to BranchioLinkConfig
  String? get referalCode => BranchioLinkConfig.instance.referalCode;
  String? get lessonId => BranchioLinkConfig.instance.lessonId;
  String? get activityId => BranchioLinkConfig.instance.activityId;
  String? get zoomId => BranchioLinkConfig.instance.zoomId;
  String? get shareLink => BranchioLinkConfig.instance.shareLink;

  Future<void> setUpHandleDeepLink() async {
    // Delegate to BranchioLinkConfig
    BranchioLinkConfig.instance.setUpHandleDeepLink();
  }

  Future<void> createShareReferralLink() async {
    // Delegate to BranchioLinkConfig
    await BranchioLinkConfig.instance.createShareReferralLink();
  }

  Future<String> createShareLessonLink({
    required LessonSectionItem lesson,
    required String? featureImage,
    required String? lessonDescription,
  }) async {
    // Delegate to BranchioLinkConfig
    return await BranchioLinkConfig.instance.createShareLessonLink(
      lesson: lesson,
      featureImage: featureImage,
      lessonDescription: lessonDescription,
    );
  }

  removeLessonId() {
    BranchioLinkConfig.instance.removeLessonId();
  }

  void removeActivityId() {
    BranchioLinkConfig.instance.removeActivityId();
  }

  void removeZoomId() {
    BranchioLinkConfig.instance.removeZoomId();
  }

  void setZoomId(String zoomId) {
    BranchioLinkConfig.instance.setZoomId(zoomId);
  }

  static Future<String?> createShareNewsLink(
      LearningPostModel newsDetail) async {
    // Delegate to BranchioLinkConfig
    return await BranchioLinkConfig.createShareNewsLink(newsDetail);
  }

  Future<String?> getInitLink() async {
    // BranchioLinkConfig handles initial links automatically
    return null;
  }

  void progressDynamicLink(Uri deepLink, {bool initializing = false}) async {
    // This method is kept for backward compatibility
    // BranchioLinkConfig handles deep links automatically via setUpHandleDeepLink
    String urlString = deepLink.toString();

    // Handle Zoom meeting links
    String? meetRoomId = _tryGetMeetRoomId(urlString);
    if (meetRoomId != null) {
      String roomId = meetRoomId;
      if (initializing || AppSettings.userInfo == null) {
        BranchioLinkConfig.instance.setZoomId(roomId);
      } else {
        ZoomService().launchZoom(
          roomId,
          AppSettings.userInfo?.fullName ?? 'Người dùng',
          navigatorKey.currentState!.context,
        );
      }
      return;
    }
  }

  String? _tryGetMeetRoomId(String urlString) {
    // case: https://diab.com.vn/?calendar=123456
    String meetingSignalPattern1 = "calendar=";
    String? meetRoomId;
    if (urlString.contains(meetingSignalPattern1)) {
      meetRoomId = urlString.split(meetingSignalPattern1).last;
    }

    // case: https://click.diab.com.vn/meet/123456
    String meetingSignalPattern2 = "meet/";
    if (urlString.contains(meetingSignalPattern2)) {
      meetRoomId = urlString.split(meetingSignalPattern2).last;
    }

    // case: https://meet.diab.com.vn/123456
    String meetingSignalPattern3 = "meet.diab.com.vn/";
    if (urlString.contains(meetingSignalPattern3)) {
      meetRoomId = urlString.split(meetingSignalPattern3).last;
    }

    // remove pattern after "?"
    if (meetRoomId != null && meetRoomId.contains("?")) {
      List<String> separatedString = meetRoomId.split("?");
      meetRoomId = separatedString[0];
    }

    return meetRoomId;
  }

  void dispose() {
    BranchioLinkConfig.instance.dispose();
  }
}
