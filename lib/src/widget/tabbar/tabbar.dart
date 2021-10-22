import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Bmi/widget/add_bmi.dart';
import 'package:medical/src/widget/components/HomeButton/main.dart';
import 'package:medical/src/widget/helper/notification_manager.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/version.dart';
import 'package:medical/src/widget/tabbar/bottom_tabbar.dart';
import 'package:medical/src/widget/home/home.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class TabbarController extends StatefulWidget {
  final _TabbarControllerState currentTabbar = _TabbarControllerState();
  @override
  _TabbarControllerState createState() => currentTabbar;
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

  final List<Widget> tabs = [
    HomeController(),
  ];

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    NotificationManager.instance.requestFirebaseToken();
    pageController = PageController();
    _bottomTabbar = BottomTabbar(callback: (index) {
      if (index == -1) {
        _showMaterialDialog();
      } else {
        jumpTo(index);
      }
    });

    // DartNotificationCenter.subscribe(
    //     channel: 'unauthorized',
    //     observer: this,
    //     onNotification: (_) {
    //       Message.showToastMessage(
    //           context, R.string.phien_dang_nhap_het_han_vui_long_dang_nhap_lai.tr());
    //       AppSettings.logout();
    //     });

    getNewVersion();
  }

  // @override
  // void dispose() {
  //   Observable.instance.removeObserver(this);
  //   super.dispose();
  // }

  @override
  void update(Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    // TODO: implement update
    if (notifyName == 'unauthorized') {
      Message.showToastMessage(
          context, R.string.phien_dang_nhap_het_han_vui_long_dang_nhap_lai.tr());
      AppSettings.logout();
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
          physics: NeverScrollableScrollPhysics(),
          controller: pageController,
          children: tabs),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showMaterialDialog();
          },
          child: Image.asset(
            R.drawable.ic_button_plus_home,
            width: 82,
            height: 82,
          )),
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

  getNewVersion() async {
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
            builder: (BuildContext context) => CupertinoAlertDialog(
                  title: Text(R.string.cap_nhat.tr()),
                  content: Text(
                    R.string.mes_new_version_available.tr(args: ['${status.storeVersion}']),
                      textAlign: TextAlign.center),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text(R.string.cancel.tr()),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
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
            userInfo = UserModel(
                id: userInfo.id,
                username: userInfo.username,
                fullName: userInfo.fullName,
                age: userInfo.age,
                phoneNumber: userInfo.phoneNumber,
                secondPhoneNumber: userInfo.secondPhoneNumber,
                gender: userInfo.gender,
                genderType: userInfo.genderType,
                createDatetime: userInfo.createDatetime,
                isActive: userInfo.isActive,
                province: userInfo.province,
                district: userInfo.district,
                height: userInfo.height,
                weight: number?.toDouble(),
                ward: userInfo.ward,
                dateOfBirth: userInfo.dateOfBirth,
                diabetesStatus: userInfo.diabetesStatus,
                diabetesName: userInfo.diabetesName,
                diabetesDate: userInfo.diabetesDate,
                imageUrl: userInfo.imageUrl,
                code: userInfo.code,
                email: userInfo.email,
                address: userInfo.address,
                goalWaist: userInfo.goalWaist,
                goalWeight: userInfo.goalWeight,
                isLinkedFacebook: userInfo.isLinkedFacebook,
                isLinkedGoogle: userInfo.isLinkedGoogle,
                isMobileAccount: userInfo.isMobileAccount,
                firstLinkedAccount: userInfo.firstLinkedAccount,
                googleEmail: userInfo.googleEmail,
                glucoseUnit: userInfo.glucoseUnit,
                activityLevelRate: userInfo.activityLevelRate);
            await UserClient()
                .updateUserInfo(AppSettings.userInfo!.id, userInfo);
            await UserClient().fetchUser();
            Navigator.pushNamed(navigatorKey.currentContext!, NavigatorName.add_exercrises,
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
        subTitle:
            R.string.update_weight_description.tr(),
        max: 200,
        numberDefault: 50,
        unit: R.string.kg.tr()),
  );
}
