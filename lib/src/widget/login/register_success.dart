import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';

class RegisterSuccess extends StatefulWidget {
  final String? phone;
  final String? password;
  RegisterSuccess({this.phone, this.password});
  @override
  _RegisterSuccessState createState() => _RegisterSuccessState();
}

class _RegisterSuccessState extends State<RegisterSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage(R.drawable.bg_splash),
          fit: BoxFit.cover,
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView(children: [
                Stack(alignment: AlignmentDirectional.center, children: [
                  Image.asset(R.drawable.img_register_success),
                  Column(children: [
                    SizedBox(height: 180),
                    Text('Đăng ký thành công!',
                        style: TextStyle(
                            color: R.color.mainColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(left: 32, right: 32),
                      child: Text(
                          'Vui lòng cập nhật hồ sơ để\nDiaB có thể hỗ trợ bạn tốt hơn!',
                          style: TextStyle(
                              color: R.color.color0xff333333,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                          textAlign: TextAlign.center),
                    )
                  ])
                ])
              ]),
            ),
            Container(
              child: GestureDetector(
                onTap: () {
                  getToken();
                },
                child: SafeArea(
                  top: false,
                  child: Container(
                      height: 48,
                      width: 195,
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: R.color.mainColor,
                          borderRadius: BorderRadius.circular(200),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.centerRight,
                              colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
                      child: Center(
                          child: Text('Cập nhật hồ sơ',
                              style: TextStyle(
                                  color: R.color.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)))),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  getToken() async {
    BotToast.showLoading();
    final result = await LoginClient().login({
      "client_id": Const.CLIENT_ID,
      "client_secret": Const.CLIENT_SECRET,
      "grant_type": "phone_number_password",
      "password": widget.password,
      "phone_number": widget.phone
    });
    BotToast.closeAllLoading();
    print(result);
    // if (result.access_token != null) {
    Navigator.pushReplacementNamed(context, NavigatorName.update_info,
        arguments: {'type': 'phone'});
    // }
  }
}
