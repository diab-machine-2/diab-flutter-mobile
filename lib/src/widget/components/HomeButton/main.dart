import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Food/daily_nutrition/daily_nutrition.dart';
import 'package:medical/src/widget/components/HomeButton/widget/circular_menu.dart';
import 'package:medical/src/widget/components/HomeButton/widget/circular_menu_item.dart';
import 'package:medical/src/widget/components/HomeButton/widget/horizontal_menu.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/tabbar/tabbar.dart';
import 'package:url_launcher/url_launcher.dart';

class FunkyOverlay extends StatefulWidget {
  bool isCircular;

  FunkyOverlay({this.isCircular = true});

  @override
  State<StatefulWidget> createState() => FunkyOverlayState();
}

class FunkyOverlayState extends State<FunkyOverlay>
    with SingleTickerProviderStateMixin {
  GlobalKey<CircularMenuState> menuKey = GlobalKey();
  var user = AppSettings.userInfo;

  @override
  void initState() {
    super.initState();
  }

  onClose() async {
    await menuKey.currentState!.animationController.reverse();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // final List<String> icons = [
    //   'icon_duong_huyet',
    //   'icon_huyet_ap',
    //   'icon_van_dong',
    //   'icon_can_nang',
    //   'icon_dinh_duong',
    //   'icon_cam_xuc'
    // ];
    double bottom = MediaQuery.of(context).padding.bottom;
    //bottom = bottom < 0 ? 0 : bottom;
    return GestureDetector(
      onTap: onClose,
      child: Scaffold(
          backgroundColor: R.color.transparent,
          body: SafeArea(
            child: widget.isCircular
                ? CircularMenu(
                    key: menuKey,
                    bottom: bottom,
                    alignment: Alignment.bottomCenter,
                    startingAngleInRadian: 3.45,
                    endingAngleInRadian: 6,
                    toggleButtonColor: R.color.mainColor,
                    titles: [
                      // Text(R.string.hba1c.tr(), style: TextStyle(color: R.color.white)),
                      // Text(R.string.huyet_ap.tr(), style: TextStyle(color: R.color.white)),
                      // Text(R.string.cam_xuc.tr(), style: TextStyle(color: R.color.white)),
                      // Text(R.string.can_nang.tr(), style: TextStyle(color: R.color.white)),
                      // Text(R.string.dinh_duong.tr(), style: TextStyle(color: R.color.white)),
                      // Text(R.string.van_dong.tr(), style: TextStyle(color: R.color.white)),
                      // Text(R.string.duong_huyet.tr(), style: TextStyle(color: R.color.white))
                    ],
                    items: [
                      CircularMenuItem(
                          bottom: bottom,
                          icon: Image.asset(R.drawable.ic_a1c,
                              width: 40, height: 40),
                          title: Text(R.string.hba1c.tr(),
                              style: TextStyle(color: R.color.white)),
                          color: R.color.white,
                          onTap: () async {
                            await onClose();
                            Navigator.pushNamed(
                                context, NavigatorName.add_hba1c,
                                arguments: {'type': 'input', 'id': null});
                          }),
                      CircularMenuItem(
                          bottom: bottom,
                          icon: Image.asset(R.drawable.ic_huyet_ap,
                              width: 40, height: 40),
                          title: Text(R.string.huyet_ap.tr(),
                              style: TextStyle(color: R.color.white)),
                          color: R.color.white,
                          onTap: () async {
                            await onClose();
                            Navigator.pushNamed(
                                context, NavigatorName.add_blood_pressure,
                                arguments: {'type': 'input', 'id': null});
                          }),
                      CircularMenuItem(
                          bottom: bottom,
                          icon: Image.asset(R.drawable.ic_cam_xuc,
                              width: 40, height: 40),
                          title: Text(R.string.cam_xuc.tr(),
                              style: TextStyle(color: R.color.white)),
                          color: R.color.white,
                          onTap: () async {
                            await onClose();
                            Navigator.pushNamed(context, NavigatorName.add_emo,
                                arguments: {'type': 'input', 'id': null});
                          }),
                      CircularMenuItem(
                          bottom: bottom,
                          icon: Image.asset(R.drawable.ic_can_nang,
                              width: 40, height: 40),
                          title: Text(R.string.can_nang.tr(),
                              style: TextStyle(color: R.color.white)),
                          color: R.color.white,
                          onTap: () async {
                            await onClose();
                            Navigator.pushNamed(context, NavigatorName.add_bmi,
                                arguments: {'type': 'input', 'id': null});
                          }),
                      CircularMenuItem(
                          bottom: bottom,
                          icon: Image.asset(R.drawable.ic_dinh_duong,
                              width: 40, height: 40),
                          title: Text(R.string.dinh_duong.tr(),
                              style: TextStyle(color: R.color.white)),
                          color: R.color.white,
                          onTap: () async {
                            await onClose();
                            NavigationUtil.navigatePage(
                              context,
                              DailyNutritionPage(
                                type: 'input',
                                id: null,
                              ),
                            );
                          }),
                      CircularMenuItem(
                          bottom: bottom,
                          icon: Image.asset(R.drawable.ic_van_dong,
                              width: 40, height: 40),
                          title: Text(R.string.van_dong.tr(),
                              style: TextStyle(color: R.color.white)),
                          color: R.color.white,
                          onTap: () async {
                            await onClose();
                            if (AppSettings.userInfo!.weight == null ||
                                AppSettings.userInfo!.weight == 0) {
                              showPopupWeight();
                            } else {
                              Navigator.pushNamed(
                                  context, NavigatorName.add_exercrises,
                                  arguments: {'type': 'input'});
                            }
                          }),
                      CircularMenuItem(
                          bottom: bottom,
                          icon: Image.asset(R.drawable.ic_duong_huyet,
                              width: 40, height: 40),
                          title: Text(R.string.duong_huyet.tr(),
                              style: TextStyle(color: R.color.white)),
                          color: R.color.white,
                          onTap: () async {
                            await onClose();
                            Navigator.pushNamed(
                                context, NavigatorName.add_blood_sugar_new,
                                arguments: {'type': 'input'});
                          }),
                    ],
                  )
                : HorizontalMenu(
                    fabColor: R.color.greenGradientBottom,
                    iconColor: R.color.white,
                    icon: Icons.clear,
                    items: [
                      HorizontalMenuItem(
                        label: 'Chat với huấn luyện viên',
                        ontap: () async {
                          if (user?.trainingGroups != null &&
                              user!.trainingGroups!.isNotEmpty) {
                            if (user!.trainingGroups!.first.coachPhoneNumber !=
                                    null &&
                                user!.trainingGroups!.first.coachPhoneNumber!
                                    .isNotEmpty) {
                              goToZaloCoach(user!
                                  .trainingGroups!.first.coachPhoneNumber!);
                              return;
                            }
                          }
                          Message.showToastMessage(
                              context, R.string.phone_not_available.tr());
                        },
                        icon: Image.asset(R.drawable.ic_chat_coach,
                            width: 32, height: 32),
                        labelColor: Colors.white,
                        labelBackgroundColor: Colors.transparent,
                      ),
                      HorizontalMenuItem(
                        label: R.string.chat_with_group.tr(),
                        ontap: () {
                          if (user?.trainingGroups != null &&
                              user!.trainingGroups!.isNotEmpty) {
                            if (user!.trainingGroups!.first.zaloUrl != null &&
                                user!.trainingGroups!.first.zaloUrl!
                                    .isNotEmpty) {
                              goToZaloGroup(
                                  user!.trainingGroups!.first.zaloUrl!);
                              return;
                            }
                          }
                          Message.showToastMessage(
                              context, R.string.group_not_available.tr());
                        },
                        icon: Image.asset(R.drawable.ic_chat_group,
                            width: 32, height: 32),
                        labelColor: Colors.white,
                        labelBackgroundColor: Colors.transparent,
                      ),
                    ],
                    body: Container(),
                  ),
          )),
    );
  }

  goToZaloCoach(String phone) async {
    var isZaloAppExisted = await checkZaloAppExisted();
    if (isZaloAppExisted) {
      try {
        // await LaunchApp.openApp(
        //   androidPackageName: 'com.zing.zalo',
        //   iosUrlScheme: 'zalo://',
        //   appStoreLink: 'https://apps.apple.com/vn/app/zalo/id579523206',
        //   // openStore: false
        // );
        Navigator.pop(context);
        phone = phone.replaceAll('+84', '0');
        launchUrl(Uri.parse("https://zalo.me/" + phone));
      } on PlatformException catch (e) {
        Message.showToastMessage(context, R.string.error_redirect_zalo.tr());
      }
    } else {
      showDialogConfirmZalo();
    }
  }

  goToZaloGroup(String linkZalo) async {
    var isZaloAppExisted = await checkZaloAppExisted();
    if (isZaloAppExisted) {
      try {
        Navigator.pop(context);
        linkZalo = linkZalo.replaceAll('+84', '0');
        launch(linkZalo);
      } on PlatformException catch (e) {
        Message.showToastMessage(context, R.string.error_redirect_zalo.tr());
      }
    } else {
      showDialogConfirmZalo();
    }
  }

  showDialogConfirmZalo() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            contentPadding: const EdgeInsets.all(0),
            content: Stack(children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(R.string.install_zalo.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 24),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    height: 43,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        color: R.color.grayBorder),
                                    child: Center(
                                      child: Text(R.string.close.tr(),
                                          style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    )),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  goToStore();
                                },
                                child: Container(
                                  height: 43,
                                  decoration: BoxDecoration(
                                      color: R.color.red,
                                      borderRadius: BorderRadius.circular(200),
                                      gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            R.color.greenGradientTop,
                                            R.color.greenGradientBottom
                                          ])),
                                  child: Center(
                                    child: Text(R.string.tiep_tuc.tr(),
                                        style: TextStyle(
                                            color: R.color.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
            ])));
  }

  Future<bool> checkZaloAppExisted() async {
    var isInstalled = await LaunchApp.isAppInstalled(
      androidPackageName: 'com.zing.zalo',
      iosUrlScheme: 'zalo://',
    );
    if (isInstalled is bool) return isInstalled;
    if (isInstalled is int) {
      //  Message.showToastMessage(context, 'isInstalled = $isInstalled');
      return isInstalled == 1 ? true : false;
    }
    return false;
  }

  goToStore() {
    if (Platform.isIOS) {
      try {
        launch('https://apps.apple.com/vn/app/zalo/id579523206');
      } on PlatformException catch (e) {}
    } else {
      try {
        launch("https://play.google.com/store/apps/details?id=com.zing.zalo");
      } on PlatformException catch (e) {}
    }
  }
}
