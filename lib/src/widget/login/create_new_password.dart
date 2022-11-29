import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/widget/base/text_field_custom.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

class NewPasswordController extends StatefulWidget {
  final String? phone;
  final String? token;
  NewPasswordController({this.phone, this.token});
  @override
  _NewPasswordControllerState createState() => _NewPasswordControllerState();
}

class _NewPasswordControllerState extends State<NewPasswordController> {
  final GlobalKey<TextFieldCustomState> passwordKey = GlobalKey();
  final GlobalKey<TextFieldCustomState> confirmPasswordKey = GlobalKey();

  String password = '';
  String newPassword = '';

  @override
  void initState() {
    super.initState();
    // TrackingManager.analytics.setCurrentScreen(screenName: "New Password");
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: "new_password", 
      screenClass: "NewPasswordController"
    );
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
                Row(
                  children: [
                    Text(R.string.mat_khau_moi_it_nhat_6_ky_tu.tr(),
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400)),
                  ],
                ),
                SizedBox(height: 24),
                TextFieldCustom(
                  key: passwordKey,
                  title: R.string.mat_khau_moi.tr(),
                  placeholder: R.string.nhap_mat_khau_moi.tr(),
                  isPassword: true,
                  onChanged: (value) {
                    password = value;
                  },
                ),
                SizedBox(height: 16),
                TextFieldCustom(
                  key: confirmPasswordKey,
                  title: R.string.xac_nhan_mat_khau_moi.tr(),
                  placeholder: R.string.nhap_lai_mat_khau_moi.tr(),
                  isPassword: true,
                  onChanged: (value) {
                    newPassword = value;
                  },
                ),
                SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    submit();
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
                            colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
                    child: Center(
                        child: Text(R.string.luu_mat_khau.tr(),
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
                    R.string.tao_mat_khau_moi.tr(),
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

  submit() async {
    FocusScope.of(context).unfocus();
    if (password.isEmpty || password.length < 6) {
      passwordKey.currentState!.validate(R.string.password_least_character.tr());
      return;
    }
    if (password.contains(' ')) {
      passwordKey.currentState!.validate(R.string.mat_khau_khong_chua_khoang_trang.tr());
      return;
    }
    if (password != newPassword) {
      confirmPasswordKey.currentState!.validate(R.string.mat_khau_khong_trung_khop.tr());
      return;
    }

    BotToast.showLoading();
    try {
      await LoginClient().resetPassword(widget.phone, password, widget.token);
      Message.showToastMessage(context,
          R.string.reset_mat_khau_thanh_cong.tr());
      BotToast.closeAllLoading();
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }
}
