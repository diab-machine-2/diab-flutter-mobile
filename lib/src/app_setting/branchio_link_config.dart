import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
import 'package:medical/src/service/zoom_service.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/calendar/calendar_model.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:medical/src/utils/smart_goal_navigation_util.dart';
import '../model/response/lesson_section_list_response.dart';

class BranchioLinkConfig {
  BranchioLinkConfig._privateConstructor();
  static final BranchioLinkConfig instance =
      BranchioLinkConfig._privateConstructor();

  StreamSubscription? _subLink;
  String? _courseId;
  String? _endTime;
  int? _interviewType;
  String? _referalCode;
  String? _lessonId;
  String? _activityId;
  String? _zoomId;
  String? _meetingId;
  String? _meetingPassword;
  String? _shareLink;
  DateTime? lastMeetingEndTime;

  // Tracking pending deep link navigation
  bool _hasPendingDeeplink = false;
  int? _pendingClinicId;
  int? _pendingMode; // 0 = online, 1 = offline
  String? _pendingType; // dsmes, clinic, doctor
  bool _hasPendingLoginDeeplink = false;
  Timer? _navigationTimer;
  String? _pendingMeasurementScreen;

  // Getters
  String? get referalCode => _referalCode;
  String? get lessonId => _lessonId;
  String? get activityId => _activityId;
  String? get zoomId => _zoomId;
  String? get shareLink => _shareLink;
  String? get meetingId => _meetingId;
  String? get meetingPassword => _meetingPassword;
  int? _pendingTargetType;
  String? _pendingSmartGoalId;
  String? _pendingSurveyId;
  String? _pendingLessonId;
  String? _pendingLessonType;

  // Getter to check pending deeplinks
  bool get hasPendingDeeplink => _hasPendingDeeplink;
  bool get hasPendingLoginDeeplink => _hasPendingLoginDeeplink;
  int? get pendingClinicId => _pendingClinicId;
  int? get pendingMode => _pendingMode;
  String? get pendingType => _pendingType;

  // Tracking map for booking feature pages
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
        if (AppSettings.splashScreenInitDone) {
          executeLoginDeeplinkNavigation();
        }
        return;
      }

      // Handle lesson deeplink
      if (data['+clicked_branch_link'] == true &&
          data.containsKey("\$lessonId")) {
        _lessonId = data['\$lessonId'] as String;
        if (data.containsKey("\$referralCode")) {
          _referalCode = data['\$referralCode'] as String;
        }
        print('[ROUTE] Lesson deeplink detected: $_lessonId');
        if (AppSettings.splashScreenInitDone && AppSettings.userInfo != null) {
          Observable.instance
              .notifyObservers([], notifyName: Const.NAVIGATE_TO_LESSON_DETAIL);
        }
        return;
      }

      // Handle activity deeplink
      if (data['+clicked_branch_link'] == true &&
          data.containsKey("\$activityId")) {
        _activityId = data['\$activityId'] as String;
        if (data.containsKey("\$referralCode")) {
          _referalCode = data['\$referralCode'] as String;
        }
        print('[ROUTE] Activity deeplink detected: $_activityId');
        if (AppSettings.splashScreenInitDone && AppSettings.userInfo != null) {
          Observable.instance.notifyObservers([],
              notifyName: Const.NAVIGATE_TO_ACTIVITY_DETAIL);
        }
        return;
      }

      // Handle subscription deeplink
      if (data['+clicked_branch_link'] == true &&
          data.containsKey("\$subscription")) {
        isActivatedSubscription = true;
        Observable.instance
            .notifyObservers([], notifyName: Const.UPDATE_SUBSCRIPTION);
        return;
      }

      // Handle course deeplink
      if (data['+clicked_branch_link'] == true &&
          data.containsKey("\$course")) {
        _processBookingCourseLink(data['\$course'] as String,
            data['\$end_time'] as String?, data['\$type'] as String?);
        return;
      }

      // Handle Zoom meeting deeplink
      if (data['+clicked_branch_link'] == true &&
          data.containsKey("\$meetingId") &&
          data.containsKey("\$meetingPassword")) {
        String meetingId = data['\$meetingId'] as String;
        String meetingPassword = data['\$meetingPassword'] as String;
        if (AppSettings.userInfo == null) {
          _meetingId = meetingId;
          _meetingPassword = meetingPassword;
          return;
        }
        if (lastMeetingEndTime != null) {
          final timeSinceLastMeeting =
              DateTime.now().difference(lastMeetingEndTime!);
          if (timeSinceLastMeeting.inSeconds < 5) return;
        }
        ZoomService().launchZoomMeeting(meetingId, meetingPassword);
        return;
      }

      // Handle referral code deeplink
      if (data['+clicked_branch_link'] == true &&
          data.containsKey("\$referralCode")) {
        _referalCode = data['\$referralCode'] as String;
        return;
      }

      // Handle news deeplink
      if (data['+clicked_branch_link'] == true &&
          data.containsKey("\$newsDetail")) {
        String newsDetailId = data['\$newsDetail'] as String;
        if (data.containsKey("\$referralCode")) {
          _referalCode = data['\$referralCode'] as String;
        }
        if (AppSettings.splashScreenInitDone && AppSettings.userInfo != null) {
          Navigator.pushNamed(
              navigatorKey.currentState!.context, NavigatorName.news_detail,
              arguments: {'id': newsDetailId});
        }
        return;
      }

      // Handle generic deeplinks with mode, id, type
      if (data['+clicked_branch_link'] == true) {
        int? mode;
        int? id;
        String? type;
        if (data.containsKey('\$mode'))
          mode = int.tryParse(data['\$mode'] as String);
        if (data.containsKey('\$id')) id = int.tryParse(data['\$id'] as String);
        if (data.containsKey('\$type')) type = data['\$type'] as String;
        print('[ROUTE] Deeplink params - mode: $mode, id: $id, type: $type');
        if (id != null && type == null) type = 'dsmes';
        if (mode != null || id != null || type != null) {
          _hasPendingDeeplink = true;
          _pendingMode = mode;
          _pendingClinicId = id;
          _pendingType = type;
          if (AppSettings.splashScreenInitDone &&
              AppSettings.userInfo != null) {
            executeDeeplinkNavigation();
          }
          return;
        }
      }

      // Handle measurement deeplink
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
        print('InitSession error: ${error.code} - ${error.message}');
      } else {
        print('InitSession error: $error');
      }
      TrackingManager.recordError(error, null);
    });
  }

  Future<void> createShareReferralLink() async {
    final user = AppSettings.userInfo!;
    final BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: 'referral/${user.shareRefCode}',
      title: 'Tải ngay ứng dụng diaB',
      contentDescription:
          'Ứng dụng hoàn toàn miễn phí giúp kiểm soát bệnh đái tháo đường và kết nối với chuyên gia.',
      imageUrl:
          'https://api.diab.com.vn/App/Image/a95ed12f-3880-4588-378f-08dbc2ecc277',
      contentMetadata: BranchContentMetaData()
        ..addCustomMetadata('\$referralCode', user.shareRefCode ?? ''),
    );

    final BranchLinkProperties linkProperties = BranchLinkProperties(
      feature: 'referral',
      channel: 'app_share',
      campaign: 'referral_program',
    );

    final BranchResponse response = await FlutterBranchSdk.getShortUrl(
      buo: buo,
      linkProperties: linkProperties,
    );

    if (response.success) {
      _shareLink = response.result;
      _referalCode = null;
    } else {
      throw Exception(
          'Failed to create referral link: ${response.errorMessage}');
    }
  }

  Future<String> createShareLessonLink({
    required LessonSectionItem lesson,
    required String? featureImage,
    required String? lessonDescription,
  }) async {
    final user = AppSettings.userInfo!;
    String lessonImage = featureImage ??
        'https://diab.com.vn/wp-content/uploads/2022/02/hinh-1-banner-trang-chu.png';
    String lessonName = lesson.name ??
        'Tải ngay DiaB để xem bài học trên và còn nhiều hướng dẫn về chế độ dinh dưỡng, vận động, nghỉ ngơi cho người đái tháo đường!';

    final BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: 'lesson/${lesson.lessonId}',
      title: lessonName,
      contentDescription: lessonDescription ?? 'Bài học từ ứng dụng DiaB',
      imageUrl: lessonImage,
      contentMetadata: BranchContentMetaData()
        ..addCustomMetadata('lessonName', lesson.name ?? 'Lesson Name')
        ..addCustomMetadata('lessonCode', lesson.code ?? 'Lesson Code')
        ..addCustomMetadata('\$lessonId', lesson.lessonId ?? '')
        ..addCustomMetadata('\$referralCode', user.shareRefCode ?? ''),
    );

    final BranchLinkProperties linkProperties = BranchLinkProperties(
      feature: 'lesson_share',
      channel: 'app_share',
      campaign: 'lesson_share',
      stage: "${Const.ENVIRONMENT_DEFAULT} ${lesson.code ?? 'missing_lesson_code'}",
      tags: ['${user.accountId}'],
    );

    final BranchResponse response = await FlutterBranchSdk.getShortUrl(
      buo: buo,
      linkProperties: linkProperties,
    );

    if (response.success) {
      return response.result;
    } else {
      throw Exception('Failed to create lesson link: ${response.errorMessage}');
    }
  }

  static Future<String?> createShareNewsLink(
      LearningPostModel newsDetail) async {
    String shareTitle = newsDetail.title;
    String shareDescription = newsDetail.content ?? '';
    String shareBanner = newsDetail.imageUrl.url ??
        'https://diab.com.vn/wp-content/uploads/2022/02/hinh-1-banner-trang-chu.png';

    final BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: 'news/${newsDetail.id}',
      title: shareTitle,
      contentDescription: shareDescription,
      imageUrl: shareBanner,
      contentMetadata: BranchContentMetaData()
        ..addCustomMetadata('\$newsDetail', newsDetail.id ?? ''),
    );

    final BranchLinkProperties linkProperties = BranchLinkProperties(
      feature: 'news_share',
      channel: 'app_share',
      campaign: 'news_share',
    );

    final BranchResponse response = await FlutterBranchSdk.getShortUrl(
      buo: buo,
      linkProperties: linkProperties,
    );

    if (response.success) {
      return response.result;
    } else {
      throw Exception('Failed to create news link: ${response.errorMessage}');
    }
  }

  void _processMeasurementDeepLink(String screenValue) async {
    if (!AppSettings.splashScreenInitDone || AppSettings.userInfo == null) {
      _pendingMeasurementScreen = screenValue;
      return;
    }

    navigatorKey.currentState?.popUntil((route) {
      return route.settings.name == NavigatorName.tabbar;
    });

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

    if (measurementRoutes.containsKey(screenValue)) {
      final routeInfo = measurementRoutes[screenValue]!;
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
      if (screenValue.isNotEmpty) {
        _processMeasurementDeepLink(screenValue);
      }
    }
  }

  Future<void> executeLoginDeeplinkNavigation() async {
    print('[ROUTE] Executing login deeplink navigation');
    try {
      await navigatorKey.currentState?.pushNamed(NavigatorName.login);
      clearPendingLoginData();
    } catch (e) {
      print('[ROUTE] Error executing login deeplink navigation: $e');
      clearPendingLoginData();
    }
  }

  Future<void> executeDeeplinkNavigation() async {
    print(
        '[ROUTE] Executing deeplink navigation - mode: $_pendingMode, id: $_pendingClinicId, type: $_pendingType');
    _navigationTimer?.cancel();
    final String? pendingType = _pendingType;
    final int? pendingMode = _pendingMode;
    final int? pendingClinicId = _pendingClinicId;
    _clearPendingData();

    try {
      final String navigationType = pendingType ?? 'dsmes';
      bool hasConflictingPageOpen = false;
      String? openPageType;
      _openBookingPages.forEach((type, isOpen) {
        if (isOpen && type != navigationType) {
          hasConflictingPageOpen = true;
          openPageType = type;
        }
      });

      if (hasConflictingPageOpen && openPageType != null) {
        print(
            '[ROUTE] Conflicting page open: $openPageType, closing before opening $navigationType');
        navigatorKey.currentState?.popUntil((route) {
          return route.settings.name == NavigatorName.tabbar;
        });
        _openBookingPages.updateAll((key, value) => false);
        await Future.delayed(Duration(milliseconds: 100));
      }

      if (_openBookingPages[navigationType] == true) {
        print(
            '[ROUTE] $navigationType page already open, updating parameters only');
        Observable.instance.notifyObservers([], map: {
          'pendingMode': pendingMode,
          'pendingClinicId': pendingClinicId,
          'pendingOnlineDeeplink': true
        }, notifyName: "update_${navigationType}_parameters");
        return;
      }

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
          print('[ROUTE] Doctor navigation not yet implemented');
          break;
        default:
          print('[ROUTE] Unknown navigation type: $navigationType');
      }
    } catch (e) {
      print('[ROUTE] Error executing deeplink navigation: $e');
    }
  }

  Future<void> _navigateToDsmesPage(int? mode, int? clinicId) async {
    _openBookingPages['dsmes'] = true;
    Map<String, dynamic> args = {'pendingOnlineDeeplink': true};
    if (mode != null) args['pendingMode'] = mode;
    if (clinicId != null) args['pendingClinicId'] = clinicId;
    await navigatorKey.currentState
        ?.pushNamed(NavigatorName.dsmes_booking, arguments: args);
  }

  Future<void> _navigateToClinicDetailPage(int clinicId) async {
    print('[ROUTE] Navigating to clinic detail page with clinicId: $clinicId');
    _openBookingPages['dsmes'] = true;
    Map<String, dynamic> args = {
      'pendingClinicId': clinicId,
      'pendingOnlineDeeplink': true
    };
    await navigatorKey.currentState
        ?.pushNamed(NavigatorName.dsmes_booking, arguments: args);
    Future.delayed(Duration(milliseconds: 300), () {
      Observable.instance.notifyObservers([],
          map: {'pendingClinicId': clinicId, 'pendingOnlineDeeplink': true},
          notifyName: "update_dsmes_parameters");
    });
  }

  Future<void> _navigateToClinicPage(int? mode, int? clinicId) async {
    _openBookingPages['clinic'] = true;
    Map<String, dynamic> args = {};
    if (mode != null) args['pendingMode'] = mode;
    if (clinicId != null) args['pendingClinicId'] = clinicId;
    // TODO: Implement clinic page navigation
    // await navigatorKey.currentState?.pushNamed(NavigatorName.booking_clinic, arguments: args);
  }

  void notifyPageClosed(String pageType) {
    if (_openBookingPages.containsKey(pageType)) {
      _openBookingPages[pageType] = false;
      print('[ROUTE] $pageType page marked as closed');
    }
  }

  void resetPageTracking() {
    _openBookingPages.updateAll((key, value) => false);
  }

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

  void clearPendingLoginData() {
    _hasPendingLoginDeeplink = false;
  }

  void scheduleDeeplinkNavigation() {
    _navigationTimer?.cancel();
    _navigationTimer = Timer(Duration(seconds: 2), () {
      if (_hasPendingDeeplink) executeDeeplinkNavigation();
      checkPendingContentNavigation();
    });
  }

  void tryNavigateBooking({bool initial = false}) async {
    if (_courseId == null) return;
    bool isExist = await UserClient().IsExistCourse(_courseId!);
    if (!isExist) return;

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
        _resetDataLink();
        return;
      }
    }, failure: (NetworkExceptions error) {
      // emit(CalendarBookingFailure("Lỗi hệ thống trong quá trình tạo lịch"));
      return;
    });

    if (bookingQuantity == 0) {
      bool isCalendarBookingPage =
          _isCurrentRoute(NavigatorName.calendar_booking);
      if (isCalendarBookingPage) {
        navigatorKey.currentState
            ?.pushReplacementNamed(NavigatorName.calendar_booking, arguments: {
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

  void removeLessonId() {
    _lessonId = null;
    print('[ROUTE] Lesson ID cleared');
  }

  void removeActivityId() {
    _activityId = null;
    print('[ROUTE] Activity ID cleared');
  }

  void removeZoomId() {
    _zoomId = null;
  }

  void removeMeetingId() {
    _meetingId = null;
  }

  void setZoomId(String zoomId) {
    _zoomId = zoomId;
  }

  void _processBookingCourseLink(
      String courseId, String? endTime, String? type) {
    _courseId = courseId;
    _endTime = endTime;
    _interviewType = int.tryParse(type ?? '30');
    if (AppSettings.userInfo != null) tryNavigateBooking();
  }

  void _resetDataLink() {
    _courseId = null;
    _endTime = null;
    _interviewType = null;
  }

  bool _isCurrentRoute(String routeName) {
    bool result = false;
    navigatorKey.currentState?.popUntil((route) {
      result = route.settings.name == routeName;
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

  void dispose() {
    _navigationTimer?.cancel();
    _subLink?.cancel();
  }

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
