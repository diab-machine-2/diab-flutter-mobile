import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:medical/main.dart';
import 'package:medical/repo/login/login_client.dart';
import 'package:medical/theme/app_theme.dart';
import 'package:medical/widget/base/text_field_custom.dart';
import 'package:medical/widget/helper/show_message.dart';
import 'package:medical/modal/error/error_model.dart';

class ForgotPasswordController extends StatefulWidget {
  @override
  _ForgotPasswordControllerState createState() =>
      _ForgotPasswordControllerState();
}

class _ForgotPasswordControllerState extends State<ForgotPasswordController> {
  final GlobalKey<TextFieldCustomState> phoneKey = GlobalKey();
  String phone = '';
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/background_splash.png'),
              fit: BoxFit.cover,
            )),
            child: Padding(
              padding: EdgeInsets.only(top: 120.0, left: 16, right: 16),
              child: Column(children: [
                Text(
                    'Nhập số điện thoại bạn đã đăng ký trước đó để chúng tôi gửi mã xác nhận đổi mật khẩu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center),
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 40),
                  child: Image.asset('assets/images/forgotPass.png',
                      width: 112, height: 90),
                ),
                TextFieldCustom(
                  key: phoneKey,
                  title: 'Số điện thoại',
                  placeholder: 'Nhập số điện thoại',
                  onChanged: (value) {
                    phone = value;
                  },
                ),
                SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    verify(context);
                  },
                  child: Container(
                    height: 48,
                    width: 195,
                    decoration: BoxDecoration(
                        color: Color(0xff01645A),
                        borderRadius: BorderRadius.circular(21.5),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.centerRight,
                            colors: [greenGradientTop, greenGradientBottom])),
                    child: Center(
                        child: Text('Tiếp tục',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white))),
                  ),
                ),
              ]),
            ),
          ),
          new Positioned(
              //Place it at the top, and not use the entire screen
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                leading: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back, color: Colors.black)),
                title: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Quên mật khẩu',
                    style: TextStyle(fontSize: 20, color: textDark),
                  ),
                ),
                backgroundColor: Colors.transparent, //No more green
                elevation: 0.0, //Shadow gone
              )),
        ],
      )),
    );
  }

  verify(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (phone.isEmpty) {
      phoneKey.currentState.validate('Bạn chưa nhập số điện thoại');
      return;
    }
    BotToast.showLoading();
    try {
      final result =
          await LoginClient().requestOTPRecover({"phoneNumber": phone});
      BotToast.closeAllLoading();
      if (result.remainingRequestCount <= 0) {
        _showDialogError();
        return;
      }
      Navigator.pushNamed(context, '/verify', arguments: {
        'type': 'forgot_password',
        'otp': result.token,
        'phone': phone,
        'remainingRequestCount': result.remainingRequestCount
      });
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        if (e.code == 'USER001') {
          phoneKey.currentState.validate(
              'Số điện thoại không tồn tại. Vui lòng đăng nhập hoặc dùng số điện thoại khác để đăng ký!');
        } else {
          Message.showToastMessage(context, e.message);
        }
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }

  _showDialogError() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            content: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/checkError.png',
                  width: 64, height: 64),
              SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Đã gửi OTP 5 lần cho số điện thoại ',
                  style: TextStyle(color: Color(0xff172823), fontSize: 16),
                  children: <TextSpan>[
                    TextSpan(
                        text: phone,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    TextSpan(
                        text:
                            '.\nVui lòng kiểm tra lại hoặc đăng ký vào ngày hôm sau!',
                        style:
                            TextStyle(color: Color(0xff172823), fontSize: 16)),
                  ],
                ),
              )
            ],
          ),
        ));
      },
    );
  }
}
