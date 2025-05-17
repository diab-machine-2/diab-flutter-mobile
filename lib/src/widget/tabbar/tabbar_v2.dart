import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
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
import 'package:package_info/package_info.dart';
import 'package:store_redirect/store_redirect.dart';

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
    TabBarType.store,
  ];

  int _initialPage = 0;
  late int _lastIndex = _initialPage;
  bool _initComplete = false;

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
      _buildStoreTab(),
    ];
    Observable.instance.addObserver(this);
    NotificationManager.instance.requestFirebaseToken(context);
    final String? activityId = DynamicLinkConfig.instance.activityId;
    final String? lessonId = DynamicLinkConfig.instance.lessonId;
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

      final activityId = DynamicLinkConfig.instance.activityId ?? '';
      if (activityId.isNotEmpty) {
        _checkExistLessonId();
      }
    }

    Future.delayed(Duration(seconds: 1), () async {
      FlutterNativeSplash.remove();
    });
    _checkUserReferralCode();
    _checkExistZoomId();
    BranchioLinkConfig.instance.tryNavigateBooking(initial: true);

    // Mark initialization as complete
    _initComplete = true;
    print('[ROUTE] TabbarController initialization complete');

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
    }
  }

  void _onChatWithAI() {
    Navigator.pushNamed(context, NavigatorName.conversation_chatbot_ai);
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
    final String? lessonId = DynamicLinkConfig.instance.lessonId;
    final String? activityId = DynamicLinkConfig.instance.activityId;
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
          DynamicLinkConfig.instance.removeActivityId();
        });
      } else {
        _jumpTo(TabBarType.program.index);
        _bottomTabbarKey.currentState?.setPage(TabBarType.program.index);
      }
    }
  }

  void _checkUserReferralCode() async {
    DynamicLinkConfig.instance.createShareReferralLink();
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
      await TrackingManager.analytics.logEvent(
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
      Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == NavigatorName.tabbar);
      _onChatWithAI();
    }
    if (notifyName == Const.NAVIGATE_TO_LESSON_DETAIL ||
        notifyName == Const.NAVIGATE_TO_ACTIVITY_DETAIL) {
      _checkExistLessonId();
    }
    if (notifyName == Const.NAVIGATE_TO_LESSON_TAB) {
      _jumpTo(TabBarType.library.index);
      _bottomTabbarKey.currentState?.setPage(TabBarType.library.index);
    }
    if (notifyName == Const.LANGUAGE_CHANGED) {
      setState(() {
        tabs = [
          HomeController(sharedCode: widget.sharedCode),
          _buildProgramTab(),
          MyPlanPage(index: 0),
          Conversations(),
          _buildStoreTab(),
        ];
      });
    }
  }

  void _jumpTo(int index) {
    if (_lastIndex != TabBarType.home.index && index == TabBarType.home.index) {
      Observable.instance.notifyObservers([], notifyName: "back_to_home");
    }
    _lastIndex = index;
    pageController!.jumpToPage(index);
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
              title: R.string.title_activity.tr(),
              background: R.drawable.bg_welcome,
              appbarColor: R.color.white,
              hideAllBackButton: true,
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

void showPopupWeight({String? nextRoute, dynamic args}) {
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
            Navigator.pushNamed(navigatorKey.currentContext!,
                nextRoute ?? NavigatorName.add_exercrises,
                arguments: args ?? {'type': 'input'});
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
