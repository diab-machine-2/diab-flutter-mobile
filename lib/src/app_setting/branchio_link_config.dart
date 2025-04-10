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
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';

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
  DateTime? lastMeetingEndTime;

  // Tracking pending deep link navigation
  bool _hasPendingDeeplink = false;
  int? _pendingClinicId;
  int? _pendingMode; // 0 = online, 1 = offline
  String? _pendingType; // dsmes, clinic, doctor
  Timer? _navigationTimer;

  // Getter to check pending deeplinks
  bool get hasPendingDeeplink => _hasPendingDeeplink;

  // Getters for pending data
  int? get pendingClinicId => _pendingClinicId;
  int? get pendingMode => _pendingMode;
  String? get pendingType => _pendingType;

  void setUpHandleDeepLink() {
    _subLink = FlutterBranchSdk.listSession().listen((data) async {
      print('listenDynamicLinks - Branchio DeepLink Data: $data');
      AppSettings.saveClickedBranchLink(data['+clicked_branch_link']);

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

        // Logged in => Prevent auto join meeting
        if (lastMeetingEndTime != null) {
          final timeSinceLastMeeting =
              DateTime.now().difference(lastMeetingEndTime!);
          if (timeSinceLastMeeting.inSeconds < 5) {
            return;
          }
        }

        // Launch zoom meeting
        ZoomService().launchZoomMeeting(meetingId, meetingPassword);
      }

      // Handle deeplinks with the format mode=X&id=XXX&type=XXXX
      if (data['+clicked_branch_link'] == true) {
        int? mode;
        int? id;
        String? type;

        if (data.containsKey('\$mode')) {
          mode = int.tryParse(data['\$mode'] as String);
        }

        if (data.containsKey('\$id')) {
          id = int.tryParse(data['\$id'] as String);
        }

        if (data.containsKey('\$type')) {
          type = data['\$type'] as String;
        }

        print('[ROUTE] Deeplink params - mode: $mode, id: $id, type: $type');

        // If we have at least one of the parameters, consider it a valid deeplink
        if (mode != null || id != null || type != null) {
          _hasPendingDeeplink = true;
          _pendingMode = mode;
          _pendingClinicId = id;
          _pendingType = type;

          // If app is initialized, navigate immediately
          if (AppSettings.splashScreenInitDone &&
              AppSettings.userInfo != null) {
            executeDeeplinkNavigation();
          }
          // Otherwise the navigation will happen after TabbarController initialization
          return;
        }
      }

      // Handle referral code deep link
      if (data['+clicked_branch_link'] == true &&
          data.containsKey("\$referral_code")) {
        _referalCode = data['\$referral_code'] as String;
        return;
      }

      //Handle old dynamic link referral code
      if (data['+non_branch_link'] != null) {
        final urlString = data['+non_branch_link'] as String;
        AppSettings.saveClickedBranchLink(urlString.isNotEmpty);
        if (urlString.isNotEmpty && urlString.contains('referralCode')) {
          List<String> separatedString = urlString.split('referralCode=');
          _referalCode = separatedString[1].substring(0, 6);
          return;
        }
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

  // Execute pending deeplink navigation based on parameters
  Future<void> executeDeeplinkNavigation() async {
    print(
        '[ROUTE] Executing deeplink navigation - mode: $_pendingMode, id: $_pendingClinicId, type: $_pendingType');
    _navigationTimer?.cancel();

    try {
      // Case 1: Only 'type' parameter is provided
      if (_pendingType != null &&
          _pendingMode == null &&
          _pendingClinicId == null) {
        if (_pendingType == 'dsmes') {
          await navigatorKey.currentState
              ?.pushNamed(NavigatorName.dsmes_booking);
        } else if (_pendingType == 'clinic' || _pendingType == 'doctor') {
          // These types will be implemented later
          print('[ROUTE] Type "$_pendingType" is not yet implemented');
        }

        // Clear pending data
        _clearPendingData();
        return;
      }

      // Case 2: 'type' and 'mode' parameters are provided
      if (_pendingType != null &&
          _pendingMode != null &&
          _pendingClinicId == null) {
        if (_pendingType == 'dsmes') {
          await navigatorKey.currentState
              ?.pushNamed(NavigatorName.dsmes_booking, arguments: {
            'pendingOnlineDeeplink': true,
            'pendingMode': _pendingMode
          });
        } else {
          // Other types will be implemented later
          print(
              '[ROUTE] Type "$_pendingType" with mode $_pendingMode is not yet implemented');
        }

        // Clear pending data
        _clearPendingData();
        return;
      }

      // Case 3: Only 'id' parameter is provided (clinic ID)
      if (_pendingClinicId != null &&
          _pendingType == null &&
          _pendingMode == null) {
        // Navigate to dsmes_booking with clinic ID in arguments
        await navigatorKey.currentState?.pushNamed(NavigatorName.dsmes_booking,
            arguments: {'pendingClinicId': _pendingClinicId});

        // Clear pending data
        _clearPendingData();
        return;
      }

      // Case 4: Both 'type', 'mode', and 'id' parameters are provided
      if (_pendingType != null &&
          _pendingMode != null &&
          _pendingClinicId != null) {
        if (_pendingType == 'dsmes') {
          if (_pendingMode == 0) {
            // Online mode with specific clinic ID
            await navigatorKey.currentState
                ?.pushNamed(NavigatorName.dsmes_booking, arguments: {
              'pendingClinicId': _pendingClinicId,
              'pendingMode': 'online'
            });
          } else {
            // Offline mode with specific clinic ID
            await navigatorKey.currentState
                ?.pushNamed(NavigatorName.dsmes_booking_offline, arguments: {
              'serviceType': 'atClinic',
              'pendingClinicId': _pendingClinicId
            });
          }
        } else {
          // Other types will be implemented later
          print(
              '[ROUTE] Type "$_pendingType" with mode $_pendingMode and id $_pendingClinicId is not yet implemented');
        }

        // Clear pending data
        _clearPendingData();
        return;
      }

      // Default case - just clear pending data
      _clearPendingData();
    } catch (e) {
      print('[ROUTE] Error executing deeplink navigation: $e');
      // Clear pending data on error
      _clearPendingData();
    }
  }

  // Helper method to clear all pending data
  void _clearPendingData() {
    _pendingClinicId = null;
    _pendingMode = null;
    _pendingType = null;
    _hasPendingDeeplink = false;
  }

  // Schedule delayed navigation for TabbarController to use after initialization
  void scheduleDeeplinkNavigation() {
    if (_navigationTimer != null) {
      _navigationTimer!.cancel();
    }

    // Use a timer to allow TabbarController to fully initialize
    _navigationTimer = Timer(Duration(seconds: 2), () {
      if (_hasPendingDeeplink) {
        executeDeeplinkNavigation();
      }
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
    _navigationTimer?.cancel();
    _subLink?.cancel();
  }
}
