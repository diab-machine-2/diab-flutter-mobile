import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/create_calendar_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/calendar/calendar_model.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/service/zoom_service.dart';

import '../model/response/lesson_section_list_response.dart';

class BranchioLinkConfig {
  BranchioLinkConfig._privateConstructor();
  static final BranchioLinkConfig instance =
      BranchioLinkConfig._privateConstructor();

  StreamSubscription? _subLink;
  String? _courseId;
  String? _endTime;

  String? _meetingId;
  String? _meetingPassword;
  String? _referalCode;
  String? get meetingId => _meetingId;
  String? get meetingPassword => _meetingPassword;
  String? get referalCode => _referalCode;

  void setUpHandleDeepLink() {
    _subLink = FlutterBranchSdk.listSession().listen((data) async {
      print('listenDynamicLinks - DeepLink Data: $data');
      if (data['+clicked_branch_link'] == true) {
        AppSettings.saveClickedBranchLink(data['+clicked_branch_link']);
      }
      if (data['+clicked_branch_link'] == true &&
          data.containsKey("\$course")) {
        _processBookingCourseLink(
            data['\$course'] as String, data['\$end_time'] as String?);
        return;
      } else if (data['+clicked_branch_link'] == true &&
          data.containsKey("\$meetingId") &&
          data.containsKey("\$meetingPassword")) {
        String meetingId = data['\$meetingId'] as String;
        String meetingPassword = data['\$meetingPassword'] as String;

        // Not logged in => save meetingId and meetingPassword
        if (AppSettings.userInfo == null) {
          _meetingId = meetingId;
          _meetingPassword = meetingPassword;
          return;
        }

        // Logged in => launch zoom meeting
        ZoomService().launchZoomMeeting(meetingId, meetingPassword);
      }
      // TODO: Handle other deep link
      if (data['+clicked_branch_link'] == true &&
          data.containsKey("\$referral_code")) {
        _referalCode = data['\$referral_code'] as String;
        return;
      }
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
    if (_courseId == null) {
      return;
    }
    bool isExist = await UserClient().IsExistCourse(_courseId!);
    if (!isExist) {
      return;
    }

    if (_courseId != null) {
      if (initial) {
        await Future.delayed(Duration(milliseconds: 500));
      }

      final startDate = DateTime.now().add(Duration(days: 0));
      final endDate = DateTime.now().add(Duration(days: 21));
      int bookingQuantity = 0;

      final request = CalendarFilter(
          accountPatientId: AppSettings.userInfo!.accountId,
          courseId: _courseId!,
          fromDate: startDate,
          toDate: endDate,
          calendarType: 1);
      final ApiResult<List<CreateCalendarResponse>> apiResult =
          await AppRepository().getMyCalendar(request);
      apiResult.when(success: (List<CreateCalendarResponse> response) {
        if (response.length > 0) {
          bookingQuantity = response.length;
          if (bookingQuantity >= 1) {
            navigatorKey.currentState
                ?.pushNamed(NavigatorName.calendar, arguments: {
              "pickSlot": response.firstWhere(
                  (element) => element.isDeleted == false,
                  orElse: null),
              "courseId": _courseId,
              "endTime": _endTime,
              "bookingQuantity": bookingQuantity,
            });
            _resetDataLink();
            return;
          }
        }
      }, failure: (NetworkExceptions error) {
        // emit(CalendarBookingFailure("Lỗi hệ thống trong quá trình tạo lịch"));
        return;
      });

      if (bookingQuantity == 0) {
        navigatorKey.currentState?.pushNamed(NavigatorName.calendar_booking,
            arguments: {'courseId': _courseId, 'endTime': _endTime});
        _resetDataLink();
      }
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

  void removeMeetingId() {
    _meetingId = null;
  }

  void removeActivityId() {
    _courseId = null;
  }

  static Future<String?> createShareNewsLink(
      LearningPostModel newsDetail) async {
    // TODO:
    return '';
  }

  void _processBookingCourseLink(String courseId, String? endTime) {
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
