import 'package:flutter/material.dart';
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
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: CircularMenu(
              key: menuKey,
              bottom: bottom,
              alignment: Alignment.bottomCenter,
              startingAngleInRadian: 3.45,
              endingAngleInRadian: 6,
              toggleButtonColor: mainColor,
              titles: [
                // Text('HbA1C', style: TextStyle(color: Colors.white)),
                // Text('Huyết áp', style: TextStyle(color: Colors.white)),
                // Text('Cảm xúc', style: TextStyle(color: Colors.white)),
                // Text('Cân nặng', style: TextStyle(color: Colors.white)),
                // Text('Dinh dưỡng', style: TextStyle(color: Colors.white)),
                // Text('Vận động', style: TextStyle(color: Colors.white)),
                // Text('Đường huyết', style: TextStyle(color: Colors.white))
              ],
              items: [
                CircularMenuItem(
                    bottom: bottom,
                    icon: Image.asset('assets/images/icon_a1c.png',
                        width: 40, height: 40),
                    title: Text('HbA1C', style: TextStyle(color: Colors.white)),
                    color: Colors.white,
                    onTap: () async {
                      await onClose();
                      Navigator.pushNamed(context, '/add_hba1c',
                          arguments: {'type': 'input', 'id': null});
                    }),
                CircularMenuItem(
                    bottom: bottom,
                    icon: Image.asset('assets/images/icon_huyet_ap.png',
                        width: 40, height: 40),
                    title:
                        Text('Huyết áp', style: TextStyle(color: Colors.white)),
                    color: Colors.white,
                    onTap: () async {
                      await onClose();
                      Navigator.pushNamed(context, '/add_bloodPressure',
                          arguments: {'type': 'input', 'id': null});
                    }),
                CircularMenuItem(
                    bottom: bottom,
                    icon: Image.asset('assets/images/icon_cam_xuc.png',
                        width: 40, height: 40),
                    title:
                        Text('Cảm xúc', style: TextStyle(color: Colors.white)),
                    color: Colors.white,
                    onTap: () async {
                      await onClose();
                      Navigator.pushNamed(context, '/add_emo',
                          arguments: {'type': 'input', 'id': null});
                    }),
                CircularMenuItem(
                    bottom: bottom,
                    icon: Image.asset('assets/images/icon_can_nang.png',
                        width: 40, height: 40),
                    title:
                        Text('Cân nặng', style: TextStyle(color: Colors.white)),
                    color: Colors.white,
                    onTap: () async {
                      await onClose();
                      Navigator.pushNamed(context, '/add_bmi',
                          arguments: {'type': 'input', 'id': null});
                    }),
                CircularMenuItem(
                    bottom: bottom,
                    icon: Image.asset('assets/images/icon_dinh_duong.png',
                        width: 40, height: 40),
                    title: Text('Dinh dưỡng',
                        style: TextStyle(color: Colors.white)),
                    color: Colors.white,
                    onTap: () async {
                      await onClose();
                      Navigator.pushNamed(context, '/add_food',
                          arguments: {'type': 'input', 'id': null});
                    }),
                CircularMenuItem(
                    bottom: bottom,
                    icon: Image.asset('assets/images/icon_van_dong.png',
                        width: 40, height: 40),
                    title:
                        Text('Vận động', style: TextStyle(color: Colors.white)),
                    color: Colors.white,
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
                    icon: Image.asset('assets/images/icon_duong_huyet.png',
                        width: 40, height: 40),
                    title: Text('Đường huyết',
                        style: TextStyle(color: Colors.white)),
                    color: Colors.white,
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
