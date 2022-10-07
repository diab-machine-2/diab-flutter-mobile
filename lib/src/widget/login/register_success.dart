import 'package:easy_localization/easy_localization.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/user/category_item_user_model.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class RegisterSuccess extends StatefulWidget {
  final String? phone;
  final String? password;
  final String? referalCode;
  final GoogleSignInAccount? googleAccount;
  final AuthorizationCredentialAppleID? appleAccount;
  final String? type;
  final List<CategoryItemUserModel>? diabeteStates;

  RegisterSuccess({
    this.phone,
    this.password,
    this.referalCode,
    this.type,
    this.googleAccount,
    this.appleAccount,
    this.diabeteStates,
  });
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
                    Text(R.string.sign_up_success,
                        style: TextStyle(color: R.color.mainColor, fontSize: 20, fontWeight: FontWeight.w600)),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(left: 32, right: 32),
                      child: Text('Vui lòng cập nhật hồ sơ để\nDiaB có thể hỗ trợ bạn tốt hơn!',
                          style: TextStyle(color: R.color.color0xff333333, fontSize: 16, fontWeight: FontWeight.w400),
                          textAlign: TextAlign.center),
                    )
                  ])
                ])
              ]),
            ),
            Container(
              child: GestureDetector(
                onTap: () async {
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
                          child: Text(R.string.update_profile_type.tr(),
                              style: TextStyle(color: R.color.white, fontSize: 16, fontWeight: FontWeight.w600)))),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  getToken() async {
    if (widget.type != null) {
      Navigator.pushReplacementNamed(context, NavigatorName.update_info, arguments: {
        'type': widget.type,
        'googleAccount': widget.googleAccount,
        'appleAccount': widget.appleAccount,
        'diabeteStates': widget.diabeteStates
      });
    } else {
      BotToast.showLoading();
      final result = await LoginClient().login({
        "client_id": Const.CLIENT_ID,
        "client_secret": Const.CLIENT_SECRET,
        "grant_type": "phone_number_password",
        "password": widget.password,
        "phone_number": widget.phone
      });
      List<CategoryItemUserModel>? diabeteStates;
      try {
        diabeteStates = await UserClient().fetchDiabeteStatesNoHeader();
      } catch (e) {
        BotToast.closeAllLoading();
        //   return;
      }
      BotToast.closeAllLoading();
      print(result);

      // if (result.access_token != null) {
      Navigator.pushReplacementNamed(context, NavigatorName.update_info,
          arguments: {'type': 'phone', 'referalCode': widget.referalCode, 'diabeteStates': diabeteStates});
      // }
    }
  }
}
