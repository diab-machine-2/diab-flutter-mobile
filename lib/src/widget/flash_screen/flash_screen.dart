import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class FlashScreenController extends StatefulWidget {
  @override
  _FlashScreenControllerState createState() => _FlashScreenControllerState();
}

class _FlashScreenControllerState extends State<FlashScreenController> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    try {
      final token = await AppSettings.getToken();
      if (token.isNotEmpty) {
        final refreshToken = await AppSettings.getRefreshToken();
        await LoginClient().login({
          "client_id": '4A293E78-4513-4DAF-958E-A04F93978332',
          "client_secret": "oTxBinRm9NpNen3rs++jN9sWXvOkya60nuffhv6x304=",
          "grant_type": "refresh_token",
          "refresh_token": refreshToken
        });
        final user = await UserClient().fetchUser();
        if (user == null) {
          Message.showToastMessage(
              context, 'Phiên đăng nhập hết hạn, vui lòng đăng nhập lại');
          AppSettings.logout();
          Navigator.pushReplacementNamed(context, '/step_list');
        } else {
          Navigator.pushReplacementNamed(context, '/tabbar');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/step_list');
      }

      // Future.delayed(const Duration(milliseconds: 000), () {
      //   if (token.isEmpty) {
      //     Navigator.pushNamed(context, '/step_list');
      //   } else {
      //     Navigator.pushReplacementNamed(context, '/tabbar');
      //   }
      // });
    } catch (e) {
      Message.showToastMessage(
          context, 'Phiên đăng nhập hết hạn, vui lòng đăng nhập lại');
      AppSettings.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.white,
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Color(0xFFFDC798).withOpacity(0.5),
                  Color(0xFFE6F6ED).withOpacity(0.5),
                  Color(0xFFE6F6ED).withOpacity(0.5),
                  Color(0xFFFDC798).withOpacity(0.5),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft, //FractionalOffset(1.0, 0.0),
                stops: [0.0, 0.3, 0.8, 1.0])),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              Center(
                  child: Image.asset('assets/images/logo.png',
                      width: 190, height: 95)),
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: RichText(
                  text: TextSpan(
                    text: 'Công ty cổ phần công nghệ y tế ',
                    style: TextStyle(
                        color: mainColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                    children: <TextSpan>[
                      TextSpan(
                          style: TextStyle(
                              color: mainColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                          text: 'dia-B'),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
