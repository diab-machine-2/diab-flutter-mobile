import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/components/HomeButton/widget/circular_menu.dart';
import 'package:medical/src/widget/components/HomeButton/widget/circular_menu_item.dart';
import 'package:medical/src/widget/tabbar/tabbar.dart';

class FunkyOverlay extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FunkyOverlayState();
}

class FunkyOverlayState extends State<FunkyOverlay>
    with SingleTickerProviderStateMixin {
  GlobalKey<CircularMenuState> menuKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  onClose() async {
    await menuKey.currentState.animationController.reverse();
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
            child: CircularMenu(
              key: menuKey,
              bottom: bottom,
              alignment: Alignment.bottomCenter,
              startingAngleInRadian: 3.45,
              endingAngleInRadian: 6,
              toggleButtonColor: R.color.mainColor,
              titles: [
                // Text('HbA1C', style: TextStyle(color: R.color.white)),
                // Text('Huyết áp', style: TextStyle(color: R.color.white)),
                // Text('Cảm xúc', style: TextStyle(color: R.color.white)),
                // Text('Cân nặng', style: TextStyle(color: R.color.white)),
                // Text('Dinh dưỡng', style: TextStyle(color: R.color.white)),
                // Text('Vận động', style: TextStyle(color: R.color.white)),
                // Text('Đường huyết', style: TextStyle(color: R.color.white))
              ],
              items: [
                CircularMenuItem(
                    bottom: bottom,
                    icon: Image.asset(R.drawable.icon_a1c,
                        width: 40, height: 40),
                    title: Text('HbA1C', style: TextStyle(color: R.color.white)),
                    color: R.color.white,
                    onTap: () async {
                      await onClose();
                      Navigator.pushNamed(context, '/add_hba1c',
                          arguments: {'type': 'input', 'id': null});
                    }),
                CircularMenuItem(
                    bottom: bottom,
                    icon: Image.asset(R.drawable.icon_huyet_ap,
                        width: 40, height: 40),
                    title:
                        Text('Huyết áp', style: TextStyle(color: R.color.white)),
                    color: R.color.white,
                    onTap: () async {
                      await onClose();
                      Navigator.pushNamed(context, '/add_bloodPressure',
                          arguments: {'type': 'input', 'id': null});
                    }),
                CircularMenuItem(
                    bottom: bottom,
                    icon: Image.asset(R.drawable.icon_cam_xuc,
                        width: 40, height: 40),
                    title:
                        Text('Cảm xúc', style: TextStyle(color: R.color.white)),
                    color: R.color.white,
                    onTap: () async {
                      await onClose();
                      Navigator.pushNamed(context, '/add_emo',
                          arguments: {'type': 'input', 'id': null});
                    }),
                CircularMenuItem(
                    bottom: bottom,
                    icon: Image.asset(R.drawable.icon_can_nang,
                        width: 40, height: 40),
                    title:
                        Text('Cân nặng', style: TextStyle(color: R.color.white)),
                    color: R.color.white,
                    onTap: () async {
                      await onClose();
                      Navigator.pushNamed(context, '/add_bmi',
                          arguments: {'type': 'input', 'id': null});
                    }),
                CircularMenuItem(
                    bottom: bottom,
                    icon: Image.asset(R.drawable.icon_dinh_duong,
                        width: 40, height: 40),
                    title: Text('Dinh dưỡng',
                        style: TextStyle(color: R.color.white)),
                    color: R.color.white,
                    onTap: () async {
                      await onClose();
                      Navigator.pushNamed(context, '/add_food',
                          arguments: {'type': 'input', 'id': null});
                    }),
                CircularMenuItem(
                    bottom: bottom,
                    icon: Image.asset(R.drawable.icon_van_dong,
                        width: 40, height: 40),
                    title:
                        Text('Vận động', style: TextStyle(color: R.color.white)),
                    color: R.color.white,
                    onTap: () async {
                      await onClose();
                      if (AppSettings.userInfo.weight == null ||
                          AppSettings.userInfo.weight == 0) {
                        showPopupWeight();
                      } else {
                        Navigator.pushNamed(context, '/add_exercrises',
                            arguments: {'type': 'input'});
                      }
                    }),
                CircularMenuItem(
                    bottom: bottom,
                    icon: Image.asset(R.drawable.icon_duong_huyet,
                        width: 40, height: 40),
                    title: Text('Đường huyết',
                        style: TextStyle(color: R.color.white)),
                    color: R.color.white,
                    onTap: () async {
                      await onClose();
                      Navigator.pushNamed(context, '/add_bloodSugar',
                          arguments: {'type': 'input'});
                    }),
              ],
            ),
          )),
    );
  }
}
