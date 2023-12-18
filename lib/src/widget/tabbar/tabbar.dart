import 'dart:async';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_version_checker/flutter_app_version_checker.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Bmi/widget/add_bmi.dart';
import 'package:medical/src/widget/components/HomeButton/main.dart';
import 'package:medical/src/widget/helper/notification_manager.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/helper/version.dart';
// import 'package:medical/src/widget/helper/version.dart';
import 'package:medical/src/widget/home/home.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/my_plan.dart';
import 'package:medical/src/widget/profile/profile_controller.dart';
import 'package:medical/src/widget/question_answer/question_answer_page.dart';
import 'package:medical/src/widget/tabbar/bottom_tabbar.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';
import '../my_plan_screens/lesson_tab/lesson_detail/lesson_detail_page.dart';
import '../my_plan_screens/my_plan/models/plan_type.dart';
import 'package:medical/src/widget/voucher/presentation/widgets/voucher_popup.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:medical/src/widget/voucher/presentation/widgets/webview_store.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class TabbarController extends StatefulWidget {
  const TabbarController(
      {this.sharedCode, this.isRedirectFromNotification = false});
  final String? sharedCode;
  final bool isRedirectFromNotification;

  @override
  _TabbarControllerState createState() => _TabbarControllerState();
  static _TabbarControllerState? of(BuildContext context) {
    final _TabbarControllerState? navigator =
        context.findAncestorStateOfType<_TabbarControllerState>();
    return navigator;
  }
}

class _TabbarControllerState extends State<TabbarController>
    with SingleTickerProviderStateMixin, Observer {
  PageController? pageController;
  BottomTabbar? _bottomTabbar;
  late List<Widget> tabs;
  bool isNavigateToStepList = false;
  final _checker = AppVersionChecker();

  @override
  void initState() {
    initData();
    super.initState();
  }

  initData() async {
    tabs = [
      HomeController(sharedCode: widget.sharedCode),
      MyPlanPage(index: 0),
      QuestionAnswerPage(),
      SizedBox(),
      // const ProfileController(hideAllBackButton: true),
    ];
    Observable.instance.addObserver(this);
    NotificationManager.instance.requestFirebaseToken(context);
    final String? activityId = DynamicLinkConfig.instance.activityId;
    final String? lessonId = DynamicLinkConfig.instance.lessonId;
    final String? zoomId = DynamicLinkConfig.instance.zoomId;
    final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

    int initialPage = 0;
    if (lessonId != null ||
        activityId != null ||
        widget.isRedirectFromNotification ||
        zoomId != null) {
      initialPage = 1;
    }
    pageController = PageController(initialPage: initialPage);
    _bottomTabbar = BottomTabbar(
        index: initialPage,
        callback: (index) {
          if (index == 3) {
            BotToast.showLoading();
            Future.delayed(Duration(seconds: 1), () async {
              _analytics.logEvent(
                name: 'component_clicked',
                parameters: {
                  "screen_name": 'StoreInApp',
                  'cta_button_name': 'cta_btn_store',
                },
              );
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebviewStore(
                        urlStore:
                            FirebaseRemoteSetting.instance.storeNavigationUrl),
                  ));
            });
          } else if (index == -1) {
            _showMaterialDialog();
          } else {
            jumpTo(index);
          }
        });

    await FirebaseRemoteSetting.instance.init();

    if (Const.ENVIRONMENT_DEFAULT == 'product') {
      await getNewVersion();
    }

    Future.delayed(Duration(seconds: 1), () async {
      FlutterNativeSplash.remove();
    });
    _checkUserReferralCode();
    _checkExistZoomId();
  }

  _checkExistZoomId() async {
    final String? zoomId = DynamicLinkConfig.instance.zoomId;
    if (zoomId != null) {
      PermissionStatus statusMicrophone = await Permission.microphone.status;
      if (statusMicrophone.isDenied) {
        await Permission.microphone.request();
      }
      PermissionStatus statusCamera = await Permission.camera.request();
      if (statusCamera.isDenied) {
        await Permission.camera.request();
      }
      Navigator.pushNamed(
          navigatorKey.currentState!.context, NavigatorName.zoom,
          arguments: {'id': zoomId});
    }
  }

  _checkExistLessonId() async {
    final String? lessonId = DynamicLinkConfig.instance.lessonId;
    final String? activityId = DynamicLinkConfig.instance.activityId;
    if (lessonId != null || activityId != null) {
      jumpTo(1);
    }
  }

  _checkUserReferralCode() async {
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
      jumpTo(1);
      await Future.delayed(
        const Duration(milliseconds: 10),
      );

      if (position == 0) {
        Observable.instance
            .notifyObservers([], notifyName: Const.NAVIGATE_TO_ACTIVITY_TAB);
      } else if (position == 1) {
        Observable.instance
            .notifyObservers([], notifyName: Const.NAVIGATE_TO_LESSON_TAB);
      } else if (position == 2) {
        Observable.instance
            .notifyObservers([], notifyName: Const.NAVIGATE_TO_EXERCISE_TAB);
      }
    }
    if (notifyName == Const.NAVIGATE_TO_PROFILE_TAB) {
      jumpTo(0);
    }
    if (notifyName == Const.NAVIGATE_TO_LESSON_DETAIL ||
        notifyName == Const.NAVIGATE_TO_ACTIVITY_DETAIL) {
      _checkExistLessonId();
    }
    if (notifyName == Const.NAVIGATE_TO_LESSON_TAB ||
        notifyName == Const.NAVIGATE_TO_ACTIVITY_TAB) {
      jumpTo(1);
    }
    if (notifyName == Const.LANGUAGE_CHANGED) {
      setState(() {
        tabs = [
          HomeController(sharedCode: widget.sharedCode),
          MyPlanPage(index: 0),
          QuestionAnswerPage(),
          const ProfileController(hideAllBackButton: true),
        ];
      });
    }
  }

  jumpTo(int index) {
    _bottomTabbar!.state.jumpToIndex(index);
    pageController!.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: R.color.white,
      body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          children: tabs),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Observable.instance
              .notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
          _showMaterialDialog();
        },
        child: Image.asset(
          R.drawable.ic_button_plus_home,
          width: 82,
          height: 82,
        ),
      ),
      bottomNavigationBar: _bottomTabbar,
    );
  }

  _showMaterialDialog() {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.8),
      useSafeArea: false,
      context: context,
      builder: (_) => FunkyOverlay(),
    );
  }

  int stringToInt(String versionStr) {
    List<String> versionParts = versionStr.split('.');
    int versionInt = 0;

    for (String part in versionParts) {
      versionInt = versionInt * 100 + int.parse(part);
    }

    return versionInt;
  }

  getNewVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final _currentVersion = packageInfo.version;
    late String storeVersion;
    if (Platform.isAndroid) {
      storeVersion = FirebaseRemoteSetting.instance.playStoreVersion;
    } else if (Platform.isIOS) {
      storeVersion = FirebaseRemoteSetting.instance.appStoreVersion;
    }
    bool hasNewVersion =
        stringToInt(storeVersion) > stringToInt(_currentVersion);
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

  getNewVersion1() async {
    if (Platform.isAndroid) {
      _checker.checkUpdate().then((value) {
        if (value.canUpdate) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(R.string.cap_nhat.tr()),
              content: Text(
                  R.string.mes_new_version_available
                      .tr(args: ['${value.newVersion}']),
                  textAlign: TextAlign.center),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text(R.string.cap_nhat.tr()),
                  onPressed: () async {
                    final _url = value.appURL!;
                    await canLaunch(_url)
                        ? await launch(_url)
                        : throw 'Could not launch $_url';
                  },
                )
              ],
            ),
          );
        }
      });
      return;
    }

    try {
      final newVersion = NewVersion(context: context);
      final status = await newVersion.getVersionStatus();
      if (status == null) return;
      final localVersion = status.localVersion!.split('.');
      final storeVersion = status.storeVersion!.split('.');
      if (localVersion.length == 3 && storeVersion.length == 3) {
        if (int.parse(storeVersion[0]) < int.parse(localVersion[0])) {
          return;
        } else if (int.parse(storeVersion[0]) == int.parse(localVersion[0])) {
          if (int.parse(storeVersion[1]) < int.parse(localVersion[1])) {
            return;
          } else if (int.parse(storeVersion[1]) == int.parse(localVersion[1])) {
            if (int.parse(storeVersion[2]) <= int.parse(localVersion[2])) {
              return;
            }
          }
        }
      } else {
        return;
      }

      if (status.storeVersion != 'Varies with device') {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => CupertinoAlertDialog(
                  title: Text(R.string.cap_nhat.tr()),
                  content: Text(
                      R.string.mes_new_version_available
                          .tr(args: ['${status.storeVersion}']),
                      textAlign: TextAlign.center),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text(R.string.cap_nhat.tr()),
                      onPressed: () async {
                        final _url = status.appStoreLink!;
                        await canLaunch(_url)
                            ? await launch(_url)
                            : throw 'Could not launch $_url';
                      },
                    )
                  ],
                ));
      }
    } catch (e) {
      print(e.toString());
    }
  }
}

showPopupWeight() {
  showDialog(
    barrierColor: R.color.color0xff003F38.withOpacity(0.5),
    context: navigatorKey.currentContext!,
    builder: (_) => CustomNumPicker(
        callback: (number) async {
          try {
            BotToast.showLoading();
            UserModel userInfo = AppSettings.userInfo!;
            userInfo = userInfo.copyWith(height: number?.toDouble());
            await UserClient()
                .updateUserInfo(AppSettings.userInfo!.id, userInfo);
            await UserClient().fetchUser();
            Navigator.pushNamed(
                navigatorKey.currentContext!, NavigatorName.add_exercrises,
                arguments: {'type': 'input'});
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
