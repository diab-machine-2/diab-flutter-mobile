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
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/smart_goal_navigation_util.dart';
import 'package:medical/src/widget/calendar/calendar_model.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/service/zoom_service.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';

import '../model/response/lesson_section_list_response.dart';

class BranchioLinkConfig {
  BranchioLinkConfig._privateConstructor();
  static final BranchioLinkConfig instance =
      BranchioLinkConfig._privateConstructor();

  StreamSubscription? _subLink;
  String? _courseId;
  String? _endTime;
  int? _interviewType;

  String? _meetingId;
  String? _meetingPassword;
  String? _referalCode;
  String? _lessonId;
  String? _activityId;

  String? get meetingId => _meetingId;
  String? get meetingPassword => _meetingPassword;
  String? get referalCode => _referalCode;
  String? get lessonId => _lessonId;
  String? get activityId => _activityId;

  DateTime? lastMeetingEndTime;

  // Tracking pending deep link navigation
  bool _hasPendingDeeplink = false;
  int? _pendingClinicId;
  int? _pendingMode; // 0 = online, 1 = offline
  String? _pendingType; // dsmes, clinic, doctor
  bool _hasPendingLoginDeeplink = false;
  Timer? _navigationTimer;

  String? _pendingMeasurementScreen;

  int? _pendingTargetType;
  String? _pendingSmartGoalId;
  String? _pendingSurveyId;
  String? _pendingLessonId;
  String? _pendingLessonType;

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

  bool isActivatedSubscription = false;

  void setUpHandleDeepLink() {
    SmartGoalNavigationUtil.setConfig(SmartGoalConfig(
      screenName: 'deeplink',
      trackingEnabled: false, // Disable tracking for deeplinks
      showGlucoseBottomSheet: false,
      showBloodPressureIntro: false, // Skip intro for deeplinks
      hasInputBloodPressure: true,
      hasInputGlucose: true,
    ));
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

      // Handle lesson deeplink
      if (data['+clicked_branch_link'] == true &&
          data.containsKey("\$lessonId") &&
          !data.containsKey("\$smartGoalId")) {
        _lessonId = data['\$lessonId'] as String;
        print('[ROUTE] Lesson deeplink detected: $_lessonId');

        // Navigate immediately if app is initialized and user is logged in
        if (AppSettings.splashScreenInitDone && AppSettings.userInfo != null) {
          Observable.instance
              .notifyObservers([], notifyName: Const.NAVIGATE_TO_LESSON_DETAIL);
        }
        // Otherwise navigation will happen after app initialization
        return;
      }

      // Handle activity deeplink
      if (data['+clicked_branch_link'] == true &&
          data.containsKey("\$activityId")) {
        _activityId = data['\$activityId'] as String;
        print('[ROUTE] Activity deeplink detected: $_activityId');

        // Navigate immediately if app is initialized and user is logged in
        if (AppSettings.splashScreenInitDone && AppSettings.userInfo != null) {
          Observable.instance.notifyObservers([],
              notifyName: Const.NAVIGATE_TO_ACTIVITY_DETAIL);
        }
        // Otherwise navigation will happen after app initialization
        return;
      }

      if (data['+clicked_branch_link'] == true &&
          data.containsKey("\$subscription")) {
        // Process reload program tab and home (api /currentToken)
        // to fetch User with activated package
        isActivatedSubscription = true;
        Observable.instance
            .notifyObservers([], notifyName: Const.UPDATE_SUBSCRIPTION);
        return;
      }

      if (data['+clicked_branch_link'] == true &&
          data.containsKey("\$course")) {
        _processBookingCourseLink(data['\$course'] as String,
            data['\$end_time'] as String?, data['\$type'] as String?);
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

      // Handle targetType and smartGoalId deeplink
      if (data['+clicked_branch_link'] == true &&
          data.containsKey('\$targetType') &&
          data.containsKey('\$smartGoalId')) {
        final smartGoalId = data['\$smartGoalId'] as String?;
        final targetType = data['\$targetType'] as String?;
        final surveyId = data['\$surveyId'] as String?;
        final lessonId = data['\$lessonId'] as String?;
        final lessonType = data['\$lessonType'] as String?;

        if (targetType == null || smartGoalId == null) {
          return;
        }

        final targetTypeNum = int.tryParse(targetType);
        if (targetTypeNum == null) {
          return;
        }

        print(
            '[ROUTE] Handling targetType deeplink: $targetTypeNum with smartGoalId: $smartGoalId, lessonId: $lessonId, surveyId: $surveyId');

        // Create a SmartGoalList object with the provided data
        SmartGoalList smartGoal = SmartGoalList(
          id: smartGoalId,
          surveyId: surveyId,
          type: targetTypeNum,
        );

        // Handle lesson data if lessonId and lessonType are provided
        if (lessonId != null && lessonType != null) {
          final lessonTypeNum = int.tryParse(lessonType);
          if (lessonTypeNum != null) {
            // Create lesson data with the actual lesson ID
            final lessonData = LessonSectionListResponseData(
              id: lessonId,
              type: lessonTypeNum,
            );

            // Set the lesson data to the smartGoal
            smartGoal.data = lessonData;
          }
        }

        // Navigate immediately if app is initialized and user is logged in
        if (AppSettings.splashScreenInitDone && AppSettings.userInfo != null) {
          await _handleTargetTypeDeeplink(targetTypeNum, smartGoal);
        } else {
          // Store for later execution
          _pendingTargetType = targetTypeNum;
          _pendingSmartGoalId = smartGoalId;
          _pendingSurveyId = surveyId;
          _pendingLessonId = lessonId;
          _pendingLessonType = lessonType;
        }
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
    _pendingTargetType = null;
    _pendingSmartGoalId = null;
    _pendingSurveyId = null;
    _pendingLessonId = null;
    _pendingLessonType = null;
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

      // Also check for pending content navigation
      checkPendingContentNavigation();
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
        calendarType: _interviewType ?? 30,
      );
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
                "interviewType": _interviewType ?? 30,
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
                "interviewType": _interviewType ?? 30,
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
              arguments: {
                'courseId': _courseId,
                'endTime': _endTime,
                'interviewType': _interviewType
              });
        } else {
          navigatorKey.currentState?.pushNamed(NavigatorName.calendar_booking,
              arguments: {
                'courseId': _courseId,
                'endTime': _endTime,
                'interviewType': _interviewType
              });
        }
        _resetDataLink();
      }
    }
  }

  // Methods for creating share links (migrated from DynamicLinkConfig)
  Future<void> createShareReferralLink() async {
    // TODO: Implement Branch.io referral link creation
  }

  Future<String> createShareLessonLink({
    required LessonSectionItem lesson,
    required String? featureImage,
    required String? lessonDescription,
  }) async {
    // TODO: Implement Branch.io lesson link creation
    return '';
  }

  static Future<String?> createShareNewsLink(
      LearningPostModel newsDetail) async {
    // TODO: Implement Branch.io news link creation
    return '';
  }

  // Clear methods for lesson and activity
  void removeLessonId() {
    _lessonId = null;
    print('[ROUTE] Lesson ID cleared');
  }

  void removeMeetingId() {
    _meetingId = null;
  }

  void removeActivityId() {
    _activityId = null;
    print('[ROUTE] Activity ID cleared');
  }

  void _processBookingCourseLink(
      String courseId, String? endTime, String? type) {
    _courseId = courseId;
    _endTime = endTime;
    _interviewType = int.tryParse(type ?? '30');
    if (AppSettings.userInfo != null) {
      tryNavigateBooking();
    }
  }

  void _resetDataLink() {
    _courseId = null;
    _endTime = null;
    _interviewType = null;
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

  Future<void> _handleTargetTypeDeeplink(
      int targetType, SmartGoalList smartGoal) async {
    try {
      // Convert targetType string to ScheduleType enum
      ScheduleType scheduleType =
          ScheduleTypeExtend.getTypeFromIndex(targetType);

      // Call the existing _onSelectGoal function
      await _onSelectGoal(scheduleType, smartGoal: smartGoal);
    } catch (e) {
      print('[ROUTE] Error handling targetType deeplink: $e');
      TrackingManager.recordError(e, null);
    }
  }

  void checkPendingContentNavigation() {
    if (_lessonId != null &&
        AppSettings.splashScreenInitDone &&
        AppSettings.userInfo != null) {
      print('[ROUTE] Executing pending lesson navigation: $_lessonId');
      Observable.instance
          .notifyObservers([], notifyName: Const.NAVIGATE_TO_LESSON_DETAIL);
    }

    if (_activityId != null &&
        AppSettings.splashScreenInitDone &&
        AppSettings.userInfo != null) {
      print('[ROUTE] Executing pending activity navigation: $_activityId');
      Observable.instance
          .notifyObservers([], notifyName: Const.NAVIGATE_TO_ACTIVITY_DETAIL);
    }

    if (_pendingTargetType != null &&
        _pendingSmartGoalId != null &&
        AppSettings.splashScreenInitDone &&
        AppSettings.userInfo != null) {
      print(
          '[ROUTE] Executing pending targetType navigation: $_pendingTargetType with smartGoalId: $_pendingSmartGoalId');

      SmartGoalList smartGoal = SmartGoalList(
        id: _pendingSmartGoalId,
        surveyId: _pendingSurveyId,
        type: _pendingTargetType,
      );

      // Handle lesson data if available
      if (_pendingLessonId != null && _pendingLessonType != null) {
        final lessonTypeNum = int.tryParse(_pendingLessonType!);
        if (lessonTypeNum != null) {
          final lessonData = LessonSectionListResponseData(
            id: _pendingLessonId!, // Use the actual lessonId
            type: lessonTypeNum,
          );
          smartGoal.data = lessonData;
        }
      }

      _handleTargetTypeDeeplink(_pendingTargetType!, smartGoal);

      _pendingTargetType = null;
      _pendingSmartGoalId = null;
      _pendingSurveyId = null;
      _pendingLessonId = null;
      _pendingLessonType = null;
    }
  }

  // Future<void> _onSelectGoal(ScheduleType type,
  //     {SmartGoalList? smartGoal}) async {
  //   switch (type) {
  //     case ScheduleType.blood_sugar:
  //     case ScheduleType.blood_sugar_recommend:
  //       _showGlucoseAddBottomSheet(NavigatorName.add_blood_sugar_new,
  //           smartGoalId: smartGoal?.id);
  //       break;
  //     case ScheduleType.blood_pressure:
  //     case ScheduleType.blood_pressure_recommend:
  //       // check first time open blood pressure intro
  //       // if (!_haveInputBloodpressureAlready) {
  //       //   navigatorKey.currentState?.pushNamed(
  //       //       NavigatorName.blood_pressure_intro_1st_page,
  //       //       arguments: {'goalId': smartGoal?.id});
  //       //   return;
  //       // }
  //       await navigatorKey.currentState?.pushNamed(
  //           NavigatorName.add_blood_pressure,
  //           arguments: {'type': 'input', 'goalId': smartGoal?.id});
  //       // _cubit.refreshData(isRefresh: true);
  //       break;
  //     case ScheduleType.weight_recommend:
  //       _showInputWeightDialog();
  //       break;
  //     case ScheduleType.height_recommend:
  //       _showInputHeightDialog();
  //       break;
  //     case ScheduleType.weight:
  //       await navigatorKey.currentState?.pushNamed(NavigatorName.add_bmi,
  //           arguments: {'type': 'input', 'goalId': smartGoal?.id});
  //       // _cubit.refreshData(isRefresh: true);
  //       break;
  //     case ScheduleType.emotion:
  //       // await Navigator.pushNamed(context, NavigatorName.add_emo,
  //       //     arguments: {'type': 'input', 'goalId': smartGoal?.id});
  //       //    _cubit.refreshData(isRefresh: true);
  //       break;
  //     case ScheduleType.food:
  //     case ScheduleType.food_recommend:
  //       await navigatorKey.currentState?.push(
  //         MaterialPageRoute(
  //             builder: (context) => DailyNutritionPage(
  //                 type: 'input', id: null, goalId: smartGoal?.id)),
  //       );
  //       // _cubit.refreshData(isRefresh: true);
  //       break;
  //     case ScheduleType.exercise:
  //     case ScheduleType.exercise_recommend:
  //       await navigatorKey.currentState?.pushNamed(NavigatorName.add_exercrises,
  //           arguments: {'type': 'input', 'goalId': smartGoal?.id});
  //       // _cubit.refreshData(isRefresh: true);
  //       break;
  //     case ScheduleType.exercise_movement:
  //       if (smartGoal?.exerciseData == null) break;
  //       if (smartGoal?.exerciseData?.exerciseMovementStates == null ||
  //           smartGoal?.state == Const.LESSON_LOCKED) {
  //         _showLockedDialog(
  //           title: R.string.exercise_lesson_locked.tr(),
  //           description: R.string.exercise_lesson_locked_warning.tr(),
  //         );
  //         break;
  //       }
  //       await navigatorKey.currentState?.push(MaterialPageRoute(
  //           builder: (context) =>
  //               ExerciseDetail(exerciseData: smartGoal?.exerciseData)));
  //       // _cubit.refreshData(isRefresh: true);
  //       Observable.instance
  //           .notifyObservers([], notifyName: "refresh_exercise_tab");
  //       Observable.instance.notifyObservers([], notifyName: "refresh_home");
  //       break;
  //     case ScheduleType.custom:
  //       break;
  //     case ScheduleType.book_1_1:
  //       _showCoachingPopup(smartGoal);
  //       break;
  //     case ScheduleType.book_1_n:
  //       _showCoachingPopup(smartGoal);
  //       break;
  //     case ScheduleType.survey:
  //       //_showCoachingPopup();
  //       _showSurveyPopup(survey: smartGoal);
  //       break;
  //     case ScheduleType.lesson_recommend:
  //       Observable.instance
  //           .notifyObservers([], notifyName: Const.NAVIGATE_TO_LESSON_TAB);
  //       break;
  //     case ScheduleType.lesson:
  //     case ScheduleType.infographic:
  //       final LessonSectionListResponseData? lessonDetail =
  //           LessonSectionListResponseData(
  //               id: (smartGoal?.data as LessonSectionListResponseData).id,
  //               type: (smartGoal?.data as LessonSectionListResponseData).type);
  //       if (lessonDetail == null) return;

  //       if (smartGoal?.state == Const.LESSON_LOCKED) {
  //         // if (lessonDetail?.learningStatus == null || lessonDetail?.learningStatus == Const.LESSON_LOCKED) {
  //         _showLockedDialog(
  //             title: R.string.lesson_locked.tr(),
  //             description: R.string.lesson_locked_warning.tr());
  //         return;
  //       }
  //       await navigatorKey.currentState?.push(MaterialPageRoute(
  //           builder: (context) => LessonDetailPage(
  //                 lessonType: lessonDetail.type,
  //                 lessonId: lessonDetail.id ?? '',
  //                 onComplete: (string, int) {},
  //                 smartGoal: smartGoal,
  //               )));
  //       // _cubit.refreshData(isRefresh: true);
  //       Observable.instance
  //           .notifyObservers([], notifyName: "refresh_lesson_tab");
  //       Observable.instance.notifyObservers([], notifyName: "refresh_home");
  //       break;
  //     case ScheduleType.io_evaluate:
  //       _showCoachingPopup(smartGoal);
  //       break;
  //     case ScheduleType.update_profile:
  //     case ScheduleType.update_profile_recommend:
  //       await navigatorKey.currentState
  //           ?.pushNamed(NavigatorName.profile_info, arguments: {
  //         'id': smartGoal?.state != 1 ? smartGoal?.id : null,
  //       });
  //       break;
  //     case ScheduleType.output_assessment:
  //       _showCoachingPopup(smartGoal);
  //       break;
  //     case ScheduleType.hba1c_recommend:
  //       await navigatorKey.currentState?.pushNamed(NavigatorName.add_hba1c,
  //           arguments: {'type': 'input', 'goalId': smartGoal?.id});
  //       break;
  //     case ScheduleType.schedule_glucose_recommend:
  //       await navigatorKey.currentState
  //           ?.pushNamed(NavigatorName.schedule_glucose, arguments: {
  //         'smartGoal': smartGoal,
  //       });
  //       break;
  //     case ScheduleType.food_menu:
  //       await navigatorKey.currentState
  //           ?.pushNamed(NavigatorName.food_menu, arguments: {
  //         'smartGoal': smartGoal,
  //       });
  //       break;
  //     case ScheduleType.goal_setting_recommend:
  //       await navigatorKey.currentState
  //           ?.pushNamed(NavigatorName.goal_setting, arguments: {
  //         'smartGoal': smartGoal,
  //       });
  //       break;
  //     case ScheduleType.schedule_recommend:
  //       await navigatorKey.currentState?.pushNamed(NavigatorName.reminder);
  //       break;
  //     case ScheduleType.peripheral_recommend:
  //       await navigatorKey.currentState
  //           ?.pushNamed(NavigatorName.connect_device_app);
  //       break;
  //     case ScheduleType.completed:
  //       // Do nothing
  //       break;
  //     case ScheduleType.screening_interview:
  //       await _handleInterviewNavigation(
  //           interviewType: 30, smartGoal: smartGoal);
  //       break;
  //     case ScheduleType.evaluate_interview:
  //       await _handleInterviewNavigation(
  //           interviewType: 31, smartGoal: smartGoal);
  //       break;
  //     case ScheduleType.booking_solo:
  //       await _handleInterviewNavigation(
  //           interviewType: 32, smartGoal: smartGoal);
  //       break;
  //   }
  // }

  Future<void> _onSelectGoal(ScheduleType type,
      {SmartGoalList? smartGoal}) async {
    await SmartGoalNavigationUtil.onSelectGoal(
      navigatorKey.currentContext!,
      type,
      smartGoal: smartGoal,
      // No refresh callback needed for deeplinks
    );
  }
}
