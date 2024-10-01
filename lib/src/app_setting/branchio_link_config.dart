import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/login/routing.dart';

import '../model/response/lesson_section_list_response.dart';

class BranchioLinkConfig {
  BranchioLinkConfig._privateConstructor();
  static final BranchioLinkConfig instance =
      BranchioLinkConfig._privateConstructor();

  StreamSubscription? _subLink;
  String? _courseId;
  String? _endTime;

  void setUpHandleDeepLink() {
    _subLink = FlutterBranchSdk.listSession().listen((data) async {
      print('listenDynamicLinks - DeepLink Data: $data');
      if (data['+clicked_branch_link'] == true &&
          data.containsKey("\$course")) {
        _processBookingCourseLink(
            data['\$course'] as String, data['\$end_time'] as String?);
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

  void tryNavigateBooking({bool initial = false}) async {
    bool isExist = await UserClient().IsExistCourse(_courseId!);
    if (!isExist) {
      return;
    }
    if (_courseId != null) {
      if (initial) {
        await Future.delayed(Duration(milliseconds: 500));
      }
      navigatorKey.currentState?.pushNamed(NavigatorName.calendar_booking,
          arguments: {'courseId': _courseId, 'endTime': _endTime});
      _resetDataLink();
    }
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

  void _processBookingCourseLink(String courseId, String? endTime) async {
    _courseId = courseId;
    _endTime = endTime;

    if (AppSettings.userInfo != null) {
      tryNavigateBooking();
    }
  }

  void _resetDataLink() {
    _courseId = null;
    _endTime = null;
  }

  void dispose() {
    _subLink?.cancel();
  }
}
