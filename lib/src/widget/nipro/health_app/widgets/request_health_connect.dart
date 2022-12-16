import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/health_setting.dart';
import 'package:medical/src/widgets/block_bottom_sheet.dart';
import 'package:medical/src/widgets/button_widget.dart';

class RequestHealthConnect extends StatelessWidget {
  const RequestHealthConnect({Key? key}) : super(key: key);

  showModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RequestHealthConnect(),
    );
  }

  @override
  Widget build(BuildContext context) {
    String appTitle = Platform.isIOS ? 'Apple Health' : 'Google Fit';
    return BlockBottomSheet(
      title: '',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      R.drawable.logo_diab,
                      width: 72,
                    ),
                    SizedBox(width: 15),
                    Image.asset(
                      R.drawable.logo_healthkit,
                      width: 72,
                    )
                  ],
                ),
                SizedBox(height: 30),
                Text(
                  "Kết nối diaB với $appTitle",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: R.color.mainColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Chúng tôi sẽ tự động lấy dữ liệu từ $appTitle để giúp bạn theo dõi sức khỏe và hoạt động thể dục của mình.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1.4,
                      fontSize: 16,
                      color: R.color.textDark,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 105),
            SizedBox(height: 25),
            ButtonWidget(
              title: "Để sau",
              textColor: R.color.textDark,
              backgroundColor: R.color.grayBorder,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 15),
            ButtonWidget(
              title: "Kết nỗi với $appTitle",
              onPressed: () async {
                bool result = await HealthSetting.instance.requestConnect();
                if (result == true) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
