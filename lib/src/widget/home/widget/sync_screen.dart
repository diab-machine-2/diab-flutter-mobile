import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/register/register_model.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/text_field_custom.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/login/widgets/social_login_section.dart';
import 'package:medical/src/widgets/spacing_row.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SyncScreenController extends StatefulWidget {
  const SyncScreenController();

  @override
  _SyncScreenControllerState createState() => _SyncScreenControllerState();
}

class _SyncScreenControllerState extends State<SyncScreenController> {
  FocusNode phoneFocusNode = FocusNode();
  final GlobalKey<TextFieldCustomState> phoneKey = GlobalKey();
  String phone = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: R.color.white,
        body: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(R.drawable.bg_splash),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: SpacingColumn(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SpacingColumn(
                  spacing: 30,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: SpacingRow(
                        spacing: 20,
                        children: [
                          Icon(Icons.west, size: 24),
                          Text(
                            "Đồng bộ số điện thoại",
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1),
                    TextFieldCustom(
                      key: phoneKey,
                      focusNode: phoneFocusNode,
                      autoFocus: true,
                      title: R.string.so_dien_thoai.tr(),
                      placeholder: R.string.nhap_so_dien_thoai.tr(),
                      onChanged: (value) {
                        phone = value;
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        sendOtpRegister(phone);
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: R.color.mainColor,
                          borderRadius: BorderRadius.circular(200),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF4BB2AB),
                              Color(0xFF01857A),
                              Color(0xFF008479)
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(R.string.tiep_tuc.tr(),
                              style: TextStyle(
                                  color: R.color.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  sendOtpRegister(String phone) async {
    RegisterModel? result;
    try {
      result = await LoginClient().submitRegister(phone, isSyncAccount: true);
      if (result.remainingRequestCount! <= 0) {
        _showDialogError();
        return;
      }
      Navigator.pushNamed(context, NavigatorName.verify, arguments: {
        'type': 'register',
        'otp': result.token,
        'phone': phone,
        'remainingRequestCount': result.remainingRequestCount,
        'isCompleted': true,
        'syncAccount': true
      });
    } catch (e) {
      if (e is Error) {
        if (e.code == 'USER001') {
          phoneKey.currentState!
              .validate("Số điện thoại chưa tồn tại trên hệ thống!");
        }
      }
    }
  }

  _showDialogError() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            content: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(R.drawable.ic_check_error, width: 64, height: 64),
              const SizedBox(height: 8),
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

  loginSuccess(String loginFrom) async {
    await TrackingManager.logEvent(
      name: 'login',
      parameters: {
        "screen_name": 'login',
        'method': loginFrom.toLowerCase(),
      },
    );
  }
}
