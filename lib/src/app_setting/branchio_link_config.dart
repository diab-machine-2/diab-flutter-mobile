import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import '../model/response/lesson_section_list_response.dart';

class BranchioLinkConfig {
  BranchioLinkConfig._privateConstructor();
  static final BranchioLinkConfig instance =
      BranchioLinkConfig._privateConstructor();

  StreamSubscription? _subLink;
  String? _courseId;
  String? _endTime;

  String? get courseId => _courseId;
  String? get endTime => _endTime;

  void setUpHandleDeepLink() {
    _subLink = FlutterBranchSdk.initSession().listen((data) async {
      print('listenDynamicLinks - DeepLink Data: $data');
      if (data['+clicked_branch_link'] == true &&
          data.containsKey("\$course")) {
        processBookingCourseLink(
            data['\$course'] as String, data['\$end_time'] as String);
        return;
      }
      // TODO: Handle other deep link
    }, onError: (error) {
      if (error is PlatformException) {
        PlatformException platformException = error;
        print(
            'InitSession error: ${platformException.code} - ${platformException.message}');
      } else {
        print('InitSession error: $error');
      }
      TrackingManager.recordError(error, null);
    });
  }

  Future<void> createShareReferralLink() async {
    // TODO:
  }

  Future<String> createShareLessonLink({
    required LessonSectionItem lesson,
    required String? featureImage,
    required String? lessonDescription,
  }) async {
    // TODO:
    return '';
  }

  void removeActivityId() {
    _courseId = null;
  }

  static Future<String?> createShareNewsLink(
      LearningPostModel newsDetail) async {
    // TODO:
    return '';
  }

  void processBookingCourseLink(String courseId, String endTime) {
    if (AppSettings.userInfo == null) {
      _courseId = courseId;
      _endTime = endTime;
    } else {
      // Navigate
      navigatorKey.currentState?.pushNamed(NavigatorName.calendar_booking,
          arguments: {'courseId': courseId, 'endTime': endTime});
    }
  }

  void dispose() {
    _subLink?.cancel();
  }
}
