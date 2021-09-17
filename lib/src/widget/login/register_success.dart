import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/theme/app_theme.dart';

class RegisterSuccess extends StatefulWidget {
  final String phone;
  final String password;
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
          image: AssetImage('assets/images/background_splash.png'),
          fit: BoxFit.cover,
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView(children: [
                Stack(alignment: AlignmentDirectional.center, children: [
                  Image.asset('assets/images/RegisterSuccess.png'),
                  Column(children: [
                    SizedBox(height: 180),
                    Text('Đăng ký thành công!',
                        style: TextStyle(
                            color: mainColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(left: 32, right: 32),
                      child: Text(
                          'Vui lòng cập nhật hồ sơ để\nDiaB có thể hỗ trợ bạn tốt hơn!',
                          style: TextStyle(
                              color: Color(0xff333333),
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
                          color: mainColor,
                          borderRadius: BorderRadius.circular(200),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.centerRight,
                              colors: [greenGradientTop, greenGradientBottom])),
                      child: Center(
                          child: Text('Cập nhật hồ sơ',
                              style: TextStyle(
                                  color: Colors.white,
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
      "client_id": '4A293E78-4513-4DAF-958E-A04F93978332',
      "client_secret": "oTxBinRm9NpNen3rs++jN9sWXvOkya60nuffhv6x304=",
      "grant_type": "phone_number_password",
      "password": widget.password,
      "phone_number": widget.phone
    });
    BotToast.closeAllLoading();
    print(result);
    // if (result.access_token != null) {
    Navigator.pushReplacementNamed(context, '/update_info',
        arguments: {'type': 'phone'});
    // }
  }
}
