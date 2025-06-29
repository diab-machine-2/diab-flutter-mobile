import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/create_calendar_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Food/widget/food_action_popup.dart';
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

  DateTime? lastMeetingEndTime;

  // Tracking pending deep link navigation
  bool _hasPendingDeeplink = false;
  int? _pendingClinicId;
  int? _pendingMode; // 0 = online, 1 = offline
  String? _pendingType; // dsmes, clinic, doctor
  bool _hasPendingLoginDeeplink = false;
  Timer? _navigationTimer;

  String? _pendingMeasurementScreen;

  // Getter to check pending deeplinks
  bool get hasPendingDeeplink => _hasPendingDeeplink;
  bool get hasPendingLoginDeeplink => _hasPendingLoginDeeplink;

  // Getters for pending data
  int? get pendingClinicId => _pendingClinicId;
  int? get pendingMode => _pendingMode;
  String? get pendingType => _pendingType;

  // Tracking map for booking feature pages is already open
  Map<String, bool> _openBookingPages = {
    'dsmes': false,
    'clinic': false,
    'doctor': false
  };

  void setUpHandleDeepLink() {
    _subLink = FlutterBranchSdk.listSession().listen((data) async {
      log('listenDynamicLinks - Branchio DeepLink Data: $data');
      AppSettings.saveClickedBranchLink(data['+clicked_branch_link']);

      final zoomStatus = await ZoomService().getMeetingStatus();
      print('[Meeting Status] Zoom Status: ${zoomStatus[0]}');

      if (zoomStatus[0] == 'MEETING_STATUS_INMEETING') {
        await ZoomService().returnToMeeting();
        return;
      }

      // Handle login deeplink
      if (data['+clicked_branch_link'] == true && data.containsKey("\$login")) {
        final token = await AppSettings.getToken();
        if (token.isNotEmpty) return;
        _hasPendingLoginDeeplink = true;

        // Navigate immediately if app is initialized
        if (AppSettings.splashScreenInitDone) {
          executeLoginDeeplinkNavigation();
        }
        return;
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

        if (id != null && type == null) {
          type = 'dsmes';
          print(
              '[ROUTE] Setting default type to "dsmes" for clinicId-only deeplink');
        }

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

      // Handle input index deep link
      if (data['+clicked_branch_link'] == true &&
          data.containsKey("\$screen_value")) {
        final inputIndexScreen = data['\$screen_value'] as String;
        _processMeasurementDeepLink(inputIndexScreen);
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

  // Execute login deeplink navigation to the login screen
  Future<void> executeLoginDeeplinkNavigation() async {
    print('[ROUTE] Executing login deeplink navigation');

    try {
      // Navigate to login screen
      await navigatorKey.currentState?.pushNamed(NavigatorName.login);

      // Clear pending login data
      clearPendingLoginData();
    } catch (e) {
      print('[ROUTE] Error executing login deeplink navigation: $e');
      clearPendingLoginData();
    }
  }

  void _processMeasurementDeepLink(String screenValue) async {
    // Wait for the app to be fully initialized
    if (!AppSettings.splashScreenInitDone || AppSettings.userInfo == null) {
      _pendingMeasurementScreen = screenValue;
      return;
    }

    navigatorKey.currentState?.popUntil((route) {
      return route.settings.name == NavigatorName.tabbar;
    });

    // Map of measurement types to their corresponding routes and arguments
    Map<String, Map<String, dynamic>> measurementRoutes = {
      'duong-huyet': {
        'route': NavigatorName.add_blood_sugar_new,
        'args': {'type': 'input'}
      },
      'huyet-ap': {
        'route': NavigatorName.add_blood_pressure,
        'args': {'type': 'input', 'id': null}
      },
      'van-dong': {
        'route': NavigatorName.add_exercrises,
        'args': {'type': 'input'}
      },
      'dinh-duong': {
        'route': NavigatorName.add_food,
        'args': {'type': 'input'}
      },
      'hba1c': {
        'route': NavigatorName.add_hba1c,
        'args': {'type': 'input', 'id': null}
      },
      'can-nang': {
        'route': NavigatorName.add_bmi,
        'args': {'type': 'input'}
      }
    };

    // If the screen value is in our map, navigate to it
    if (measurementRoutes.containsKey(screenValue)) {
      final routeInfo = measurementRoutes[screenValue]!;

      if (routeInfo['route'] == NavigatorName.add_food) {
        FoodActionPopup.show(navigatorKey.currentContext!);
        return;
      }

      // For all other measurements, navigate directly
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
          routeInfo['route'] as String,
          (route) => route.settings.name == NavigatorName.tabbar,
          arguments: routeInfo['args']);
    } else {
      print('Unknown measurement screen value: $screenValue');
    }
  }

  void checkPendingMeasurementScreen() {
    if (_pendingMeasurementScreen != null) {
      final screenValue = _pendingMeasurementScreen ?? '';
      _pendingMeasurementScreen = null;

      if (screenValue.isEmpty) return;

      // This shouldn't happen, but just in case
      _processMeasurementDeepLink(screenValue);
    }
  }

  // Execute pending deeplink navigation based on parameters
  Future<void> executeDeeplinkNavigation() async {
    print(
        '[ROUTE] Executing deeplink navigation - mode: $_pendingMode, id: $_pendingClinicId, type: $_pendingType');
    _navigationTimer?.cancel();

    // Store the current pending data for navigation
    final String? pendingType = _pendingType;
    final int? pendingMode = _pendingMode;
    final int? pendingClinicId = _pendingClinicId;

    // Clear pending data to prevent re-execution
    _clearPendingData();

    try {
      // If no type specified, default to dsmes
      final String navigationType = pendingType ?? 'dsmes';

      // Check if we need to close any other open pages before navigating
      bool hasConflictingPageOpen = false;
      String? openPageType;

      // Find if any page other than the target type is open
      _openBookingPages.forEach((type, isOpen) {
        if (isOpen && type != navigationType) {
          hasConflictingPageOpen = true;
          openPageType = type;
        }
      });

      // If a conflicting page is open, close it before opening new one
      if (hasConflictingPageOpen && openPageType != null) {
        print(
            '[ROUTE] Conflicting page open: $openPageType, closing before opening $navigationType');

        // Pop the current page to return to TabBar before navigating to new page
        navigatorKey.currentState?.popUntil((route) {
          return route.settings.name == NavigatorName.tabbar;
        });

        // Mark all pages as closed
        _openBookingPages.updateAll((key, value) => false);

        // Short delay to ensure navigation completes
        await Future.delayed(Duration(milliseconds: 100));
      }

      // Handle update if the page of current type is already open
      if (_openBookingPages[navigationType] == true) {
        print(
            '[ROUTE] $navigationType page already open, updating parameters only');

        // Post a notification to update the current page with new parameters
        Observable.instance.notifyObservers([], map: {
          'pendingMode': pendingMode,
          'pendingClinicId': pendingClinicId,
          // Set this flag for ALL parameter updates, not just ones with mode
          'pendingOnlineDeeplink': true
        }, notifyName: "update_${navigationType}_parameters");

        return;
      }

      // Now handle navigation based on type
      switch (navigationType) {
        case 'dsmes':
          if (pendingClinicId != null && pendingMode == null) {
            print(
                '[ROUTE] Executing clinic detail navigation for clinicId: $pendingClinicId');
            await _navigateToClinicDetailPage(pendingClinicId);
          } else {
            await _navigateToDsmesPage(pendingMode, pendingClinicId);
          }
          break;
        case 'clinic':
          await _navigateToClinicPage(pendingMode, pendingClinicId);
          break;
        case 'doctor':
          // Add handling for doctor page when implemented
          print('[ROUTE] Doctor navigation not yet implemented');
          break;
        default:
          print('[ROUTE] Unknown navigation type: $navigationType');
      }
    } catch (e) {
      print('[ROUTE] Error executing deeplink navigation: $e');
    }
  }

// Navigate to DSMES page with appropriate parameters
  Future<void> _navigateToDsmesPage(int? mode, int? clinicId) async {
    // Mark page as open
    _openBookingPages['dsmes'] = true;

    Map<String, dynamic> args = {};
    args['pendingOnlineDeeplink'] = true;

    if (mode != null) {
      args['pendingMode'] = mode;
    }

    if (clinicId != null) {
      args['pendingClinicId'] = clinicId;
    }

    await navigatorKey.currentState
        ?.pushNamed(NavigatorName.dsmes_booking, arguments: args);
  }

  Future<void> _navigateToClinicDetailPage(int clinicId) async {
    print('[ROUTE] Navigating to clinic detail page with clinicId: $clinicId');

    // Mark dsmes page as open since clinic detail is within the dsmes flow
    _openBookingPages['dsmes'] = true;

    // First, navigate to the dsmes booking page
    Map<String, dynamic> args = {
      'pendingClinicId': clinicId,
      'pendingOnlineDeeplink': true,
    };

    // Navigate to dsmes booking first
    await navigatorKey.currentState
        ?.pushNamed(NavigatorName.dsmes_booking, arguments: args);

    // Schedule a small delay to ensure the dsmes page is fully loaded before
    // sending the notification to navigate to clinic detail
    Future.delayed(Duration(milliseconds: 300), () {
      // Use Observable to notify dsmes page to navigate to clinic detail
      Observable.instance.notifyObservers([],
          map: {'pendingClinicId': clinicId, 'pendingOnlineDeeplink': true},
          notifyName: "update_dsmes_parameters");
    });
  }

// Navigate to Clinic page with appropriate parameters
  Future<void> _navigateToClinicPage(int? mode, int? clinicId) async {
    // Mark page as open
    _openBookingPages['clinic'] = true;

    Map<String, dynamic> args = {};

    if (mode != null) {
      args['pendingMode'] = mode;
    }

    if (clinicId != null) {
      args['pendingClinicId'] = clinicId;
    }

    /// TODO: Attached navigator of booking clinic page
    // await navigatorKey.currentState?.pushNamed(
    //     NavigatorName.booking_clinic,
    //     arguments: args);
  }

// Notify that a page is closed - to be called from page's dispose method
  void notifyPageClosed(String pageType) {
    if (_openBookingPages.containsKey(pageType)) {
      _openBookingPages[pageType] = false;
      print('[ROUTE] $pageType page marked as closed');
    }
  }

  // Helper method to clear all pending data
  void _clearPendingData() {
    _pendingClinicId = null;
    _pendingMode = null;
    _pendingType = null;
    _hasPendingDeeplink = false;
  }

  void resetPageTracking() {
    _openBookingPages.updateAll((key, value) => false);
  }

  // Helper method to clear pending login data
  void clearPendingLoginData() {
    _hasPendingLoginDeeplink = false;
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
            bool isCalendarPage = _isCurrentRoute(NavigatorName.calendar);
            if (isCalendarPage) {
              navigatorKey.currentState
                  ?.pushReplacementNamed(NavigatorName.calendar, arguments: {
                "pickSlot": response.firstWhere(
                    (element) => element.isDeleted == false,
                    orElse: null),
                "courseId": _courseId,
                "endTime": _endTime ?? '',
                "bookingQuantity": bookingQuantity,
              });
            } else {
              navigatorKey.currentState
                  ?.pushNamed(NavigatorName.calendar, arguments: {
                "pickSlot": response.firstWhere(
                    (element) => element.isDeleted == false,
                    orElse: null),
                "courseId": _courseId,
                "endTime": _endTime ?? '',
                "bookingQuantity": bookingQuantity,
              });
            }
            _resetDataLink();
            return;
          }
        }
      }, failure: (NetworkExceptions error) {
        // emit(CalendarBookingFailure("Lỗi hệ thống trong quá trình tạo lịch"));
        return;
      });

      if (bookingQuantity == 0) {
        bool isCalendarBookingPage =
            _isCurrentRoute(NavigatorName.calendar_booking);
        if (isCalendarBookingPage) {
          navigatorKey.currentState?.pushReplacementNamed(
              NavigatorName.calendar_booking,
              arguments: {'courseId': _courseId, 'endTime': _endTime});
        } else {
          navigatorKey.currentState?.pushNamed(NavigatorName.calendar_booking,
              arguments: {'courseId': _courseId, 'endTime': _endTime});
        }
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

  bool _isCurrentRoute(String routeName) {
    bool result = false;
    navigatorKey.currentState?.popUntil((route) {
      result = route.settings.name == routeName;
      // Don't actually pop any routes
      return true;
    });
    return result;
  }
}
