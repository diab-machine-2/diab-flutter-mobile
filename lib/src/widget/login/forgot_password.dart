import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/text_field_custom.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

class ForgotPasswordController extends StatefulWidget {
  @override
  _ForgotPasswordControllerState createState() =>
      _ForgotPasswordControllerState();
}

class _ForgotPasswordControllerState extends State<ForgotPasswordController> {
  final GlobalKey<TextFieldCustomState> phoneKey = GlobalKey();
  String phone = '';

  @override
  void initState() {
    super.initState();
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
        screenName: "forget_password", screenClass: "ForgotPasswordController");
    AppSettings.currentScreenName = 'forget_password';
  }

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
              image: AssetImage(R.drawable.bg_splash),
              fit: BoxFit.cover,
            )),
            child: Padding(
              padding: EdgeInsets.only(top: 120.0, left: 16, right: 16),
              child: Column(children: [
                Text(R.string.phone_number_for_otp.tr(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center),
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 40),
                  child: Image.asset(R.drawable.img_forgot_pass,
                      width: 112, height: 90),
                ),
                TextFieldCustom(
                  key: phoneKey,
                  title: R.string.so_dien_thoai.tr(),
                  placeholder: R.string.nhap_so_dien_thoai.tr(),
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
                        color: R.color.mainColor,
                        borderRadius: BorderRadius.circular(21.5),
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
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: R.color.white))),
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
                    child: Icon(Icons.arrow_back, color: R.color.black)),
                title: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    R.string.quyen_mat_khau.tr(),
                    style: TextStyle(fontSize: 20, color: R.color.textDark),
                  ),
                ),
                backgroundColor: R.color.transparent, //No more green
                elevation: 0.0, //Shadow gone
              )),
        ],
      )),
    );
  }

  verify(BuildContext context) async {
    await TrackingManager.trackEvent(
      'password_submit',
      'forget_password',
    );
    FocusScope.of(context).unfocus();
    if (phone.isEmpty) {
      phoneKey.currentState!
          .validate(R.string.ban_chua_nhap_so_dien_thoai.tr());
      return;
    }
    BotToast.showLoading();
    try {
      final result =
          await LoginClient().requestOTPRecover({"phoneNumber": phone});
      BotToast.closeAllLoading();
      if (result.remainingRequestCount! <= 0) {
        _showDialogError();
        return;
      }
      Navigator.pushNamed(context, NavigatorName.verify, arguments: {
        'type': 'forgot_password',
        'otp': result.token,
        'phone': phone,
        'remainingRequestCount': result.remainingRequestCount
      });
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        if (e.code == 'USER001') {
          phoneKey.currentState!
              .validate(R.string.so_dien_thoai_khong_ton_tai.tr());
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
              Image.asset(R.drawable.ic_check_error, width: 64, height: 64),
              SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: R.string.da_gui_otp_5_lan_cho_so_dien_thoai.tr(),
                  style: TextStyle(color: R.color.textDark, fontSize: 16),
                  children: <TextSpan>[
                    TextSpan(
                        text: phone,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    TextSpan(
                        text: R.string.dang_ky_lai_hom_sau.tr(),
                        style:
                            TextStyle(color: R.color.textDark, fontSize: 16)),
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
