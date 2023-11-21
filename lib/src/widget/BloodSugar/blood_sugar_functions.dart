import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/nipro/health_app/widgets/request_health_connect.dart';
import 'package:medical/src/widget/nipro/roche_connection/roche_connection_view.dart';
import 'package:medical/src/widgets/button_widget.dart';

class BloodSugarFunctions {
  static Future<void> showModalAddData(BuildContext context) async {
    String healthIcon =
        Platform.isIOS ? R.drawable.logo_healthkit : R.drawable.logo_googleFit;
    String healthTitle =
        Platform.isIOS ? 'Kết nối từ Apple Health' : 'Kết nối từ Google Fit';
    bool? hasHealthConnection = await AppStorages.getHealthAppPermission();
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      backgroundColor: R.color.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: hasHealthConnection == true ? 290 : 350,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xffF2F2F2)))),
              child: Text(
                'Chọn cách nhập',
                style: TextStyle(
                  fontSize: 16,
                  color: R.color.textDark,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  if (hasHealthConnection == false)
                    ButtonWidget(
                      isIconSvg: false,
                      icon: healthIcon,
                      backgroundColor: Color(0xFFE4FCF3),
                      textColor: Color(0xff249B92),
                      title: healthTitle,
                      onPressed: () => RequestHealthConnect.showModal(context,
                          callback: () => Navigator.pop(context)),
                    ),
                  SizedBox(height: 15),
                  ButtonWidget(
                    icon: R.icons.ic_bluetooth,
                    backgroundColor: Color(0xFFE4FCF3),
                    textColor: Color(0xff249B92),
                    title: 'Kết nối từ thiết bị',
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                RocheConnectionView())),
                  ),
                  SizedBox(height: 15),
                  ButtonWidget(
                    icon: R.icons.ic_tap,
                    backgroundColor: Color(0xFFE4FCF3),
                    textColor: Color(0xff249B92),
                    title: 'Nhập thủ công',
                    onPressed: () {
                      // if (isGestationalDiabetes) {
                      Navigator.pushNamed(
                          context, NavigatorName.add_blood_sugar_new,
                          arguments: {'type': 'input'});
                      // } else {
                      //   Navigator.pushNamed(
                      //       context, NavigatorName.add_blood_sugar,
                      //       arguments: {'type': 'input'});
                      // }
                    },
                  ),
                  SizedBox(height: 15),
                  ButtonWidget(
                    backgroundColor: Color(0xFFF4F4F4),
                    textColor: Color(0xff172823),
                    title: 'Đóng',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
