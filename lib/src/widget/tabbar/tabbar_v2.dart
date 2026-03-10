import 'dart:developer';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/app_setting/firebase_remote_config.dart';
import 'package:medical/src/modal/base/referral_code_temp.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/model/response/user_info_response.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/service/zoom_service.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Bmi/widget/add_bmi.dart';
import 'package:medical/src/widget/conversation/conversations.dart';
import 'package:medical/src/widget/helper/notification_manager.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/widget/home_support_functions.dart';
import 'package:medical/src/widget/phone_update/phone_update_bottom_sheet.dart';
import 'package:medical/src/widget/subscription/phone_validation_manager.dart';
import 'package:medical/src/widget/home/home_v2.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/activity_tab.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/my_plan.dart';
import 'package:medical/src/widget/subscription/pages/subscription_page.dart';
import 'package:medical/src/widget/subscription/subscription_cubit.dart';
import 'package:medical/src/widget/survey_screens/introduce_survey/introduce_survey.dart';
// import 'package:medical/src/widget/question_answer/question_answer_page.dart';
import 'package:medical/src/widget/tabbar/tabbar_v2_data.dart';
import 'package:medical/src/widget/voucher/presentation/widgets/webview_store.dart';
import 'package:medical/curved_navigation_bar/curved_navigation_bar.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:store_redirect/store_redirect.dart';

// Lightweight global accessor for current tab index
class TabbarRouteState {
  static int currentIndex = 0;
}

bool isHomeTabActive() {
  return TabbarRouteState.currentIndex == TabBarType.home.index;
}

class TabbarController extends StatefulWidget {
  const TabbarController(
      {this.sharedCode, this.isRedirectFromNotification = false});
  final String? sharedCode;
  final bool isRedirectFromNotification;

  @override
  State<TabbarController> createState() => _TabbarControllerState();
}

class _TabbarControllerState extends State<TabbarController> with Observer {
  PageController? pageController;
  // BottomTabbar? _bottomTabbar;
  late List<Widget> tabs;
  bool isNavigateToStepList = false;
  // final _checker = AppVersionChecker();
  final GlobalKey<CurvedNavigationBarState> _bottomTabbarKey = GlobalKey();

  final SubscriptionCubit _subscriptionCubit =
      SubscriptionCubit(AppRepository());

  final List<TabBarType> _bottomTabs = [
    TabBarType.home,
    TabBarType.program,
    TabBarType.library,
    TabBarType.chat,
    // TabBarType.store,
  ];

  int _initialPage = 0;
  late int _lastIndex = _initialPage;
  bool _pendingPhoneValidation = false;

  @override
  void initState() {
    print('[ROUTE] TabbarController initState');
    initData();
    super.initState();
  }

  void initData() async {
    _trackUserVisit();
    tabs = [
      HomeController(sharedCode: widget.sharedCode),
      _buildProgramTab(),
      MyPlanPage(index: 0),
      Conversations(),
      // _buildStoreTab(),
    ];
    Observable.instance.addObserver(this);
    NotificationManager.instance.requestFirebaseToken(context);
    final String? activityId = BranchioLinkConfig.instance.activityId;
    final String? lessonId = BranchioLinkConfig.instance.lessonId;
    final String? meetingId = BranchioLinkConfig.instance.meetingId;

    if (activityId != null || meetingId != null) {
      _initialPage = TabBarType.program.index;
    } else if (lessonId != null || widget.isRedirectFromNotification) {
      _initialPage = TabBarType.library.index;
    }
    pageController = PageController(initialPage: _initialPage);

    if (Const.ENVIRONMENT_DEFAULT == 'product') {
      await _getNewVersion();
    }

    if (AppSettings.userInfo?.packageType == PackageType.free) {
      await _subscriptionCubit.getSubscriptionBanners();
    }

    Future.delayed(Duration(seconds: 1), () async {
      FlutterNativeSplash.remove();
    });
    _checkUserReferralCode();
    _checkExistZoomId();
    BranchioLinkConfig.instance.tryNavigateBooking(initial: true);

    print('[ROUTE] TabbarController initialization complete');

    // Check for lesson/activity deeplinks after initialization is complete
    // Use observer pattern for activity deeplinks, direct call for lesson deeplinks
    final String? pendingLessonId = BranchioLinkConfig.instance.lessonId;
    final String? pendingActivityId = BranchioLinkConfig.instance.activityId;

    if (pendingLessonId != null) {
      _checkExistLessonId();
    } else if (pendingActivityId != null) {
      // Use observer pattern for activity deeplinks to ensure proper timing
      Observable.instance
          .notifyObservers([], notifyName: Const.NAVIGATE_TO_ACTIVITY_DETAIL);
    }

    // Check if we have any pending deeplinks to navigate to
    _checkPendingDeeplinks();
    BranchioLinkConfig.instance.checkPendingMeasurementScreen();
  }

  // Check for pending deeplinks after initialization
  void _checkPendingDeeplinks() {
    if (BranchioLinkConfig.instance.hasPendingDeeplink) {
      print(
          "[ROUTE] TabbarController found pending deeplink, scheduling navigation");
      BranchioLinkConfig.instance.scheduleDeeplinkNavigation();
    }
  }

  void _trackUserVisit() async {
    final clickedBranchLink = await AppSettings.getClickedBranchLink();
    print('[TRACKING] ${clickedBranchLink == true ? 'deeplink' : 'organic'}');
    TrackingManager.trackEvent(
      'home_app_open',
      'home',
      params: {
        'source': clickedBranchLink == true ? 'deeplink' : 'organic',
      },
    );
  }

  String getComponentName(int index) {
    return _bottomTabs.elementAt(index).title;
  }

  void _onBottomNavigationBarTap(int index) async {
    await TrackingManager.trackEvent(
      'home_select_tabbar',
      'home',
      params: {
        'component_name': getComponentName(index),
      },
    );
    if (index == TabBarType.store.index) {
      BotToast.showLoading();
      Future.delayed(Duration(seconds: 1), () async {
        TrackingManager.trackEvent(
          'component_clicked',
          'StoreInApp',
          params: {
            'cta_button_name': 'cta_btn_store',
          },
        );
      });
      _jumpTo(index);
    } else if (index == TabBarType.chat.index) {
      // _jumpTo(index);
      // _lastIndex = index;
      _onChatWithAI();
    } else if (index == -1) {
      // _showMaterialDialog();
    } else {
      _jumpTo(index);
      TabbarRouteState.currentIndex = index;

      // Check phone validation when switching to home tab
      if (index == TabBarType.home.index) {
        if (_pendingPhoneValidation) {
          // Ensure we are at the tabbar route before showing
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _checkPhoneValidationOnHomeTab();
          });
        }
      }
    }
  }

  void _onChatWithAI() {
    Navigator.pushNamed(context, NavigatorName.conversation_chatbot_ai);
  }

  /// Check phone validation when home tab becomes active
  Future<void> _checkPhoneValidationOnHomeTab() async {
    try {
      // Ensure this tabbar route is the top-most
      final route = ModalRoute.of(context);
      if (route == null || route.isCurrent != true) return;

      final isHomeRoute = route.settings.name == NavigatorName.tabbar;

      // Ensure we are at tabbar route and Home tab
      log('isHomeRoute: $isHomeRoute');
      log('isHomeTabActive: ${isHomeTabActive()}');
      if (!isHomeRoute) return;
      if (!isHomeTabActive()) return;

      // Check if we're actually on the app's root (not on a detail page)
      // by checking if there are any routes pushed on top of the tabbar
      // IMPORTANT: use rootNavigator to detect routes above the tabbar
      final rootNavigator = Navigator.of(context, rootNavigator: true);
      final canPop = rootNavigator.canPop();

      // Only show phone validation if we're truly on the home screen
      // (no routes pushed on top of tabbar)
      if (canPop) {
        log('Phone validation skipped - user is on detail page');
        return;
      }

      final shouldShow =
          await PhoneValidationManager.shouldShowAndResetPhoneValidation();

      if (shouldShow) {
        // Show phone update bottom sheet
        PhoneUpdateBottomSheet.show(context);
        _pendingPhoneValidation = false; // consume pending flag
      }
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    }
  }

  void _checkExistZoomId() async {
    final String? meetingId = BranchioLinkConfig.instance.meetingId;
    if (meetingId != null) {
      await Future.delayed(Duration(seconds: 1));
      ZoomService().launchZoomMeeting(
          meetingId, BranchioLinkConfig.instance.meetingPassword!);
    }
  }

  void _checkExistLessonId() async {
    final String? lessonId = BranchioLinkConfig.instance.lessonId;
    final String? activityId = BranchioLinkConfig.instance.activityId;
    if (lessonId != null) {
      _jumpTo(TabBarType.library.index);
      _bottomTabbarKey.currentState?.setPage(TabBarType.library.index);
    } else if (activityId != null) {
      if (AppSettings.userInfo?.packageType == PackageType.free) {
        SmartGoalList smartGoal = SmartGoalList(surveyId: activityId, state: 0);
        await Future.delayed(Duration(milliseconds: 500));
        NavigationUtil.navigatePage(navigatorKey.currentState!.context,
            IntroduceSurveyPage(survey: smartGoal));
        Future.delayed(Duration(seconds: 1), () {
          BranchioLinkConfig.instance.removeActivityId();
        });
      } else {
        _jumpTo(TabBarType.program.index);
        _bottomTabbarKey.currentState?.setPage(TabBarType.program.index);
      }
    }
  }

  void _checkUserReferralCode() async {
    BranchioLinkConfig.instance.createShareReferralLink();
    ReferralCodeTemp? referralCodeData = await AppStorages.getReferralCode();
    if (referralCodeData != null) {
      AppStorages.removeReferralCode();
    }
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> update(Observable observable, String? notifyName,
      Map<dynamic, dynamic>? map) async {
    if (notifyName == 'unauthorized') {
      await TrackingManager.logEvent(
        name: 'login_session_end',
        parameters: {
          "screen_name": AppSettings.currentScreenName,
          'error_message':
              R.string.phien_dang_nhap_het_han_vui_long_dang_nhap_lai.tr(),
        },
      );
      if (!isNavigateToStepList) {
        Message.showToastMessage(context,
            R.string.phien_dang_nhap_het_han_vui_long_dang_nhap_lai.tr());
        AppSettings.logout();
        isNavigateToStepList = true;
      }
    }
    if (notifyName == Const.NAVIGATE_TO_MY_PLAN_TAB) {
      int position = 0;
      if (map != null) {
        position = map['position'] ?? 0;
      }
      NavigationUtil.popToFirst(context);
      if (position == 0) {
        _jumpTo(TabBarType.program.index);
        _bottomTabbarKey.currentState?.setPage(TabBarType.program.index);
      } else {
        _jumpTo(TabBarType.library.index);
        _bottomTabbarKey.currentState?.setPage(TabBarType.library.index);
        await Future.delayed(
          const Duration(milliseconds: 10),
        );

        if (position == 1) {
          Observable.instance
              .notifyObservers([], notifyName: Const.NAVIGATE_TO_LESSON_TAB);
        } else if (position == 2) {
          Observable.instance
              .notifyObservers([], notifyName: Const.NAVIGATE_TO_EXERCISE_TAB);
        }
      }
    }
    if (notifyName == Const.NAVIGATE_TO_PROFILE_TAB) {
      _jumpTo(TabBarType.home.index);
    }
    if (notifyName == Const.NAVIGATE_TO_CHAT_TAB) {
      Navigator.of(context).popUntil((route) =>
          route.isFirst || route.settings.name == NavigatorName.tabbar);
      _onChatWithAI();
    }
    if (notifyName == Const.NAVIGATE_TO_LESSON_DETAIL ||
        notifyName == Const.NAVIGATE_TO_ACTIVITY_DETAIL) {
      _checkExistLessonId();
    }
    if (notifyName == Const.NAVIGATE_TO_LESSON_TAB) {
      final targetIndex = TabBarType.library.index;

      _jumpTo(targetIndex);

      Future.delayed(Duration(milliseconds: 100), () {
        if (_bottomTabbarKey.currentState != null && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _bottomTabbarKey.currentState != null) {
              _bottomTabbarKey.currentState!.setPage(targetIndex);
            }
          });
        }
      });
    }
    if (notifyName == Const.UPDATE_SUBSCRIPTION) {
      BotToast.showLoading();
      await UserClient().fetchUser().then((value) {
        BotToast.closeAllLoading();
        // Rebuild tabs with updated user info
        setState(() {
          tabs = [
            HomeController(sharedCode: widget.sharedCode),
            _buildProgramTab(),
            MyPlanPage(index: 0),
            Conversations(),
            _buildStoreTab(),
          ];
        });
      });

      NavigationUtil.popToFirst(context);

      _jumpTo(TabBarType.program.index);
      _bottomTabbarKey.currentState?.setPage(TabBarType.program.index);

      // _jumpTo(TabBarType.home.index);
      // _bottomTabbarKey.currentState?.setPage(TabBarType.home.index);
    }

    if (notifyName == Const.UPDATE_SUBSCRIPTION_WITHOUT_NAVIGATE_PROGRAM) {
      NavigationUtil.popToFirst(context);

      await UserClient().fetchUser().then((value) {
        // Rebuild tabs with updated user info
        setState(() {
          tabs = [
            HomeController(sharedCode: widget.sharedCode),
            _buildProgramTab(),
            MyPlanPage(index: 0),
            Conversations(),
            _buildStoreTab(),
          ];
        });
      });
    }

    if (notifyName == 'subscription_back_to_home') {
      BotToast.showLoading();
      await UserClient().fetchUser().then((value) {
        BotToast.closeAllLoading();
        // Rebuild tabs with updated user info
        setState(() {
          tabs = [
            HomeController(sharedCode: widget.sharedCode),
            _buildProgramTab(),
            MyPlanPage(index: 0),
            Conversations(),
            _buildStoreTab(),
          ];
        });
      });

      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        NavigatorName.tabbar,
        (route) => false, // This removes all routes from stack
      );
    }

    if (notifyName == Const.LANGUAGE_CHANGED) {
      setState(() {
        tabs = [
          HomeController(sharedCode: widget.sharedCode),
          _buildProgramTab(),
          MyPlanPage(index: 0),
          Conversations(),
          // _buildStoreTab(),
        ];
      });
    }

    if (notifyName == Const.NAVIGATE_TO_MY_PLAN_TAB_AUTO_TRIGGER_SUBSCRIPTION) {
      _jumpTo(TabBarType.program.index);
      _bottomTabbarKey.currentState?.setPage(TabBarType.program.index);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Observable.instance
            .notifyObservers([], notifyName: 'auto_trigger_paywall');
      });
    }
  }

  void _jumpTo(int index) async {
    if (_lastIndex != TabBarType.home.index && index == TabBarType.home.index) {
      Observable.instance.notifyObservers([], notifyName: "back_to_home");
      // Check phone validation when programmatically navigating to home tab
      final shouldShow =
          await PhoneValidationManager.shouldShowPhoneValidation();
      if (index == TabBarType.home.index && shouldShow) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _checkPhoneValidationOnHomeTab();
        });
      }
    }
    _lastIndex = index;
    pageController!.jumpToPage(index);
    TabbarRouteState.currentIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFE8F3F3),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: tabs,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomTabbarKey,
        index: _initialPage,
        backgroundColor: Colors.transparent,
        color: Colors.white,
        buttonBackgroundColor: const Color(0xFF008479),
        normalButtonColor: const Color(0xFF9C9C9C),
        activeButtonColor: Colors.white,
        activeButtonBorderColor: const Color(0xFFE1FAF8),
        height: 56.0,
        assetPaths: _bottomTabs.map((e) => e.iconPath).toList(),
        tabTitles: _bottomTabs.map((e) => e.title).toList(),
        activeIconReplacement: (path) {
          return path.replaceAll(".png", "_active.png");
        },
        onTap: _onBottomNavigationBarTap,
      ),
    );
  }

  int _stringToInt(String versionStr) {
    List<String> versionParts = versionStr.split('.');
    int versionInt = 0;

    for (String part in versionParts) {
      versionInt = versionInt * 100 + int.parse(part);
    }

    return versionInt;
  }

  Widget _buildProgramTab() {
    // log('[ACTIVE] userPackageType: ${jsonEncode(AppSettings.userInfo)}');
    print('[ACTIVE] userPackageType: ${AppSettings.userInfo?.packageType}');
    print('[ACTIVE] ownPackage: ${AppSettings.userInfo?.ownPackage}');
    print('[ACTIVE] isOwnPackage: ${AppSettings.isOwnPackage}');
    if (AppSettings.userInfo?.packageType == PackageType.free) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<MyPlanCubit>(
            create: (context) => MyPlanCubit(AppRepository(), 0),
          ),
          BlocProvider<SubscriptionCubit>.value(
            value: _subscriptionCubit,
          ),
        ],
        child: SubscriptionPage(),
      );
    } else {
      return BlocProvider(
        create: (context) => MyPlanCubit(AppRepository(), 0),
        child: BlocBuilder<MyPlanCubit, MyPlanState>(
          builder: (context, state) {
            return CommonPage(
              title: R.string.program.tr(),
              // background: R.drawable.bg_welcome,
              backgroundColor: R.color.backgroundColorNew,
              appbarColor: R.color.greenGradientBottom,
              textColor: R.color.white,
              hideAllBackButton: true,
              appBarAction: InkWell(
                onTap: () async {
                  HomeSupportFunctions.showModalAddData(context);
                },
                child: Container(
                  height: 36,
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  margin: EdgeInsets.fromLTRB(0, 12, 16, 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: R.color.color0xffCAFAF5,
                    border: Border.all(
                      color: R.color.color0xff8FEBE0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        R.icons.ic_telephone,
                        width: 16,
                        height: 16,
                        color: R.color.greenGradientBottom,
                        fit: BoxFit.scaleDown,
                      ),
                      GapW(8),
                      MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          textScaler: MediaQuery.of(context)
                              .textScaler
                              .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
                        ),
                        child: Text(
                          R.string.contact.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'sfpro',
                            fontWeight: FontWeight.w700,
                            color: R.color.greenGradientBottom,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              child: ActivityTabPage(extendTabbar: true),
            );
          },
        ),
      );
    }
  }

  Widget _buildStoreTab() {
    if (FirebaseRemoteSetting.instance.storeNavigationUrl.isNotEmpty) {
      return WebviewStore(
          urlStore: FirebaseRemoteSetting.instance.storeNavigationUrl,
          rootPage: true);
    } else {
      return SizedBox();
    }
  }

  Future<void> _getNewVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final _currentVersion = packageInfo.version;
    late String storeVersion;
    if (Platform.isAndroid) {
      storeVersion = FirebaseRemoteSetting.instance.playStoreVersion;
    } else if (Platform.isIOS) {
      storeVersion = FirebaseRemoteSetting.instance.appStoreVersion;
    }
    bool hasNewVersion =
        _stringToInt(storeVersion) > _stringToInt(_currentVersion);
    if (hasNewVersion) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(R.string.cap_nhat.tr()),
          content: Text(
              R.string.mes_new_version_available.tr(args: ['$storeVersion']),
              textAlign: TextAlign.center),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(R.string.cap_nhat.tr()),
              onPressed: () => StoreRedirect.redirect(
                androidAppId: "com.vbhc.diab",
                iOSAppId: "1569353448",
              ),
            )
          ],
        ),
      );
    }
  }
}

void showPopupWeight({String? nextRoute, dynamic args, bool? hasExerciseData}) {
  showDialog(
    barrierColor: R.color.color0xff003F38.withOpacity(0.5),
    context: navigatorKey.currentContext!,
    builder: (_) => CustomNumPicker(
        callback: (number) async {
          try {
            BotToast.showLoading();
            UserModel userInfo = AppSettings.userInfo!;
            userInfo = userInfo.copyWith(weight: number?.toDouble());
            await UserClient()
                .updateUserInfo(AppSettings.userInfo!.id, userInfo);
            await UserClient().fetchUser();

            if (hasExerciseData != null && hasExerciseData) {
              Navigator.pushNamed(navigatorKey.currentContext!,
                  NavigatorName.exercrise_dashboard);
            } else {
              Navigator.pushNamed(navigatorKey.currentContext!,
                  nextRoute ?? NavigatorName.exercrise_add_v2,
                  arguments: args ?? {'type': 'input'});
            }
            BotToast.closeAllLoading();
          } catch (e, _) {
            BotToast.closeAllLoading();
            if (e is Error) {
              Message.showToastMessage(navigatorKey.currentContext!, e.message);
            } else {
              Message.showToastMessage(
                  navigatorKey.currentContext!, e.toString());
            }
          }
        },
        title: R.string.update_weight.tr(),
        subTitle: R.string.update_weight_description.tr(),
        max: 200,
        numberDefault: 50,
        unit: R.string.kg.tr()),
  );
}
