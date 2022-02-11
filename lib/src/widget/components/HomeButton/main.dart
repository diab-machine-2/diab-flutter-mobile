import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Food/daily_nutrition/daily_nutrition.dart';
import 'package:medical/src/widget/components/HomeButton/widget/circular_menu.dart';
import 'package:medical/src/widget/components/HomeButton/widget/circular_menu_item.dart';
import 'package:medical/src/widget/components/HomeButton/widget/horizontal_menu.dart';
import 'package:medical/src/widget/tabbar/tabbar.dart';

class FunkyOverlay extends StatefulWidget {
  bool isCircular;

  FunkyOverlay({this.isCircular = true});

  @override
  State<StatefulWidget> createState() => FunkyOverlayState();
}

class FunkyOverlayState extends State<FunkyOverlay> with SingleTickerProviderStateMixin {
  GlobalKey<CircularMenuState> menuKey = GlobalKey();

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
                          icon: Image.asset(R.drawable.ic_a1c, width: 40, height: 40),
                          title: Text(R.string.hba1c.tr(), style: TextStyle(color: R.color.white)),
                          color: R.color.white,
                          onTap: () async {
                            await onClose();
                            Navigator.pushNamed(context, NavigatorName.add_hba1c,
                                arguments: {'type': 'input', 'id': null});
                          }),
                      CircularMenuItem(
                          bottom: bottom,
                          icon: Image.asset(R.drawable.ic_huyet_ap, width: 40, height: 40),
                          title: Text(R.string.huyet_ap.tr(), style: TextStyle(color: R.color.white)),
                          color: R.color.white,
                          onTap: () async {
                            await onClose();
                            Navigator.pushNamed(context, NavigatorName.add_blood_pressure,
                                arguments: {'type': 'input', 'id': null});
                          }),
                      CircularMenuItem(
                          bottom: bottom,
                          icon: Image.asset(R.drawable.ic_cam_xuc, width: 40, height: 40),
                          title: Text(R.string.cam_xuc.tr(), style: TextStyle(color: R.color.white)),
                          color: R.color.white,
                          onTap: () async {
                            await onClose();
                            Navigator.pushNamed(context, NavigatorName.add_emo,
                                arguments: {'type': 'input', 'id': null});
                          }),
                      CircularMenuItem(
                          bottom: bottom,
                          icon: Image.asset(R.drawable.ic_can_nang, width: 40, height: 40),
                          title: Text(R.string.can_nang.tr(), style: TextStyle(color: R.color.white)),
                          color: R.color.white,
                          onTap: () async {
                            await onClose();
                            Navigator.pushNamed(context, NavigatorName.add_bmi,
                                arguments: {'type': 'input', 'id': null});
                          }),
                      CircularMenuItem(
                          bottom: bottom,
                          icon: Image.asset(R.drawable.ic_dinh_duong, width: 40, height: 40),
                          title: Text(R.string.dinh_duong.tr(), style: TextStyle(color: R.color.white)),
                          color: R.color.white,
                          onTap: () async {
                            await onClose();
                            NavigationUtil.navigatePage(
                              context,
                              const DailyNutritionPage(
                                type: 'input',
                                id: null,
                              ),
                            );
                          }),
                      CircularMenuItem(
                          bottom: bottom,
                          icon: Image.asset(R.drawable.ic_van_dong, width: 40, height: 40),
                          title: Text(R.string.van_dong.tr(), style: TextStyle(color: R.color.white)),
                          color: R.color.white,
                          onTap: () async {
                            await onClose();
                            if (AppSettings.userInfo!.weight == null || AppSettings.userInfo!.weight == 0) {
                              showPopupWeight();
                            } else {
                              Navigator.pushNamed(context, NavigatorName.add_exercrises, arguments: {'type': 'input'});
                            }
                          }),
                      CircularMenuItem(
                          bottom: bottom,
                          icon: Image.asset(R.drawable.ic_duong_huyet, width: 40, height: 40),
                          title: Text(R.string.duong_huyet.tr(), style: TextStyle(color: R.color.white)),
                          color: R.color.white,
                          onTap: () async {
                            await onClose();
                            Navigator.pushNamed(context, NavigatorName.add_blood_sugar, arguments: {'type': 'input'});
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
                        ontap: () {
                          print('1');
                        },
                        icon: Image.asset(R.drawable.ic_chat_coach, width: 32, height: 32),
                        labelColor: Colors.white,
                        labelBackgroundColor: Colors.transparent,
                      ),
                      HorizontalMenuItem(
                        label: 'Chat nhóm',
                        ontap: () {
                          print('2');
                        },
                        icon: Image.asset(R.drawable.ic_chat_group, width: 32, height: 32),
                        labelColor: Colors.white,
                        labelBackgroundColor: Colors.transparent,
                      ),
                    ],
                    body: Container(),
                  ),
          )),
    );
  }
}
