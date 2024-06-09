import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/app_setting/firebase_remote_config.dart';
import 'package:medical/src/modal/base/referral_code_temp.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/service/zoom_service.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi_view/widgets/custom_height_picker.dart';
import 'package:medical/src/widget/components/HomeButton/main.dart';
import 'package:medical/src/widget/helper/notification_manager.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/home_v2.dart';
import 'package:medical/src/widget/incoming_feature/incoming_feature.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/my_plan_page.dart';
import 'package:medical/src/widget/question_answer/question_answer_page.dart';
import 'package:medical/src/widget/tabbar/tabbar_v2_data.dart';
import 'package:medical/src/widget/voucher/presentation/widgets/webview_store.dart';
import 'package:package_info/package_info.dart';
import 'package:store_redirect/store_redirect.dart';

class TabbarController extends StatefulWidget {
  const TabbarController({this.sharedCode, this.isRedirectFromNotification = false});
  final String? sharedCode;
  final bool isRedirectFromNotification;

  @override
  State<TabbarController> createState() => _TabbarControllerState();
}

class _TabbarControllerState extends State<TabbarController>
    with SingleTickerProviderStateMixin, Observer {
  PageController? pageController;
  // BottomTabbar? _bottomTabbar;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey<CurvedNavigationBarState>();
  late List<Widget> tabs;
  bool isNavigateToStepList = false;
  // final _checker = AppVersionChecker();

  @override
  void initState() {
    initData();
    super.initState();
  }

  void initData() async {
    tabs = [
      HomeController(sharedCode: widget.sharedCode),
      IncomingFeature(),
      MyPlanPage(index: 0),
      QuestionAnswerPage(),
      SizedBox(), // <<= this store page
    ];
    Observable.instance.addObserver(this);
    NotificationManager.instance.requestFirebaseToken(context);
    final String? activityId = DynamicLinkConfig.instance.activityId;
    final String? lessonId = DynamicLinkConfig.instance.lessonId;
    final String? zoomId = DynamicLinkConfig.instance.zoomId;

    int initialPage = 0;
    if (lessonId != null ||
        activityId != null ||
        widget.isRedirectFromNotification ||
        zoomId != null) {
      initialPage = 1;
    }
    pageController = PageController(initialPage: initialPage);

    if (Const.ENVIRONMENT_DEFAULT == 'product') {
      await getNewVersion();
    }

    Future.delayed(Duration(seconds: 1), () async {
      FlutterNativeSplash.remove();
    });
    _checkUserReferralCode();
    _checkExistZoomId();
  }

  void _onBottomNavigationBarTap(index) {
    // TODO: More check
    if (index == MainTabEnum.store.index) {
      BotToast.showLoading();
      Future.delayed(Duration(seconds: 1), () async {
        FirebaseAnalytics.instance.logEvent(
          name: 'component_clicked',
          parameters: {
            "screen_name": 'StoreInApp',
            'cta_button_name': 'cta_btn_store',
          },
        );
      });
      // TODO: check why need to delay
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WebviewStore(urlStore: FirebaseRemoteSetting.instance.storeNavigationUrl),
          ));
    } else if (index == -1) {
      // _showMaterialDialog();
    } else {
      // jumpTo(index);
    }
  }

  void _checkExistZoomId() async {
    final String? zoomId = DynamicLinkConfig.instance.zoomId;
    if (zoomId != null) {
      await Future.delayed(Duration(seconds: 1));
      ZoomService().launchZoom(
        zoomId,
        AppSettings.userInfo?.fullName ?? 'Người dùng',
        context,
        userId: AppSettings.userInfo?.id,
      );
    }
  }

  void _checkExistLessonId() async {
    final String? lessonId = DynamicLinkConfig.instance.lessonId;
    final String? activityId = DynamicLinkConfig.instance.activityId;
    if (lessonId != null || activityId != null) {
      jumpTo(1);
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
  Future<void> update(Observable observable, String? notifyName, Map<dynamic, dynamic>? map) async {
    if (notifyName == 'unauthorized') {
      await TrackingManager.analytics.logEvent(
        name: 'login_session_end',
        parameters: {
          "screen_name": AppSettings.currentScreenName,
          'error_message': R.string.phien_dang_nhap_het_han_vui_long_dang_nhap_lai.tr(),
        },
      );
      if (!isNavigateToStepList) {
        Message.showToastMessage(
            context, R.string.phien_dang_nhap_het_han_vui_long_dang_nhap_lai.tr());
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
      jumpTo(MainTabEnum.library.index);
      await Future.delayed(
        const Duration(milliseconds: 10),
      );

      if (position == 0) {
        Observable.instance.notifyObservers([], notifyName: Const.NAVIGATE_TO_ACTIVITY_TAB);
      } else if (position == 1) {
        Observable.instance.notifyObservers([], notifyName: Const.NAVIGATE_TO_LESSON_TAB);
      } else if (position == 2) {
        Observable.instance.notifyObservers([], notifyName: Const.NAVIGATE_TO_EXERCISE_TAB);
      }
    }
    if (notifyName == Const.NAVIGATE_TO_PROFILE_TAB) {
      jumpTo(MainTabEnum.home.index);
    }
    if (notifyName == Const.NAVIGATE_TO_LESSON_DETAIL ||
        notifyName == Const.NAVIGATE_TO_ACTIVITY_DETAIL) {
      _checkExistLessonId();
    }
    if (notifyName == Const.NAVIGATE_TO_LESSON_TAB ||
        notifyName == Const.NAVIGATE_TO_ACTIVITY_TAB) {
      jumpTo(MainTabEnum.library.index);
    }
    if (notifyName == Const.LANGUAGE_CHANGED) {
      setState(() {
        tabs = [
          HomeController(sharedCode: widget.sharedCode),
          IncomingFeature(),
          MyPlanPage(index: 0),
          QuestionAnswerPage(),
          SizedBox(), // <<= this store page
        ];
      });
    }
  }

  void jumpTo(int index) {
    _bottomNavigationKey.currentState?.setPage(index);
    pageController!.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      backgroundColor: R.color.white,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: tabs,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        backgroundColor: Color(0xFFEAF4F4),
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        height: 75.0,
        items: [
          R.drawable.ic_home,
          R.drawable.ic_tab_program,
          R.drawable.ic_tab_library,
          R.drawable.ic_tab_faq,
          R.drawable.ic_tab_store
        ].map((e) => Image.asset(e, width: 24, height: 24, color: R.color.mainColor)).toList(),
        onTap: _onBottomNavigationBarTap,
      ),
    );
  }

  void _showMaterialDialog() {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.8),
      useSafeArea: false,
      context: context,
      builder: (_) => FunkyOverlay(),
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

  Future<void> getNewVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final _currentVersion = packageInfo.version;
    late String storeVersion;
    if (Platform.isAndroid) {
      storeVersion = FirebaseRemoteSetting.instance.playStoreVersion;
    } else if (Platform.isIOS) {
      storeVersion = FirebaseRemoteSetting.instance.appStoreVersion;
    }
    bool hasNewVersion = _stringToInt(storeVersion) > _stringToInt(_currentVersion);
    if (hasNewVersion) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(R.string.cap_nhat.tr()),
          content: Text(R.string.mes_new_version_available.tr(args: ['$storeVersion']),
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

void showPopupWeight() {
  showDialog(
    barrierColor: R.color.color0xff003F38.withOpacity(0.5),
    context: navigatorKey.currentContext!,
    builder: (_) => CustomNumPicker(
      callback: (number) async {
        try {
          BotToast.showLoading();
          UserModel userInfo = AppSettings.userInfo!;
          userInfo = userInfo.copyWith(height: number?.toDouble());
          await UserClient().updateUserInfo(AppSettings.userInfo!.id, userInfo);
          await UserClient().fetchUser();
          Navigator.pushNamed(navigatorKey.currentContext!, NavigatorName.add_exercrises,
              arguments: {'type': 'input'});
          BotToast.closeAllLoading();
        } catch (e, _) {
          BotToast.closeAllLoading();
          if (e is Error) {
            Message.showToastMessage(navigatorKey.currentContext!, e.message);
          } else {
            Message.showToastMessage(navigatorKey.currentContext!, e.toString());
          }
        }
      },
      title: R.string.update_weight.tr(),
      subTitle: R.string.update_weight_description.tr(),
      max: 200,
      numberDefault: 50,
      unit: R.string.kg.tr(),
    ),
  );
}
