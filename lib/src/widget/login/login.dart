import 'dart:convert';
import 'dart:io' show Platform;

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
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

import '../../app_setting/firebase_remote_config.dart';

class LoginController extends StatefulWidget {
  const LoginController(this.sharedCode);

  final String sharedCode;

  @override
  _LoginControllerState createState() => _LoginControllerState();
}

class _LoginControllerState extends State<LoginController> {
  FocusNode phoneFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  final GlobalKey<TextFieldCustomState> phoneKey = GlobalKey();
  final GlobalKey<TextFieldCustomState> passwordKey = GlobalKey();
  String phone = '';
  String password = '';
  bool isLogin = false;
  TextEditingController userNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    firebaseSetup();
  }

  Future firebaseRemoteConfig() async {
    bool isRetry = await AppSettings.getIsRetryFetchFirebaseRemoteConfig();
    // if retry true fetch againt onetime and set retry to false
    if (isRetry) {
      FirebaseRemoteSetting.instance.init(timeout: Duration(minutes: 5));
      await AppSettings.setIsRetryFetchFirebaseRemoteConfig(false);
    }
  }

  Future firebaseSetup() async {
    firebaseRemoteConfig();
    await TrackingManager.analytics
        .logScreenView(screenName: "login", screenClass: "LoginController");
    AppSettings.currentScreenName = 'login';
    phoneFocusNode.addListener(() async {
      if (phoneFocusNode.hasFocus) {
        await TrackingManager.analytics.logEvent(
          name: 'text_field_focus',
          parameters: {
            "screen_name": 'login',
            'text_field_name': 'text_field_login_phone',
            'object_value': phone
          },
        );
      } else {
        bool isValid = phone.length == 9 || phone.length == 10;
        await TrackingManager.analytics.logEvent(
          name: 'text_field_input',
          parameters: {
            "screen_name": 'login',
            'text_field_name': 'text_field_login_phone',
            'object_value': phone,
            'validate_state': isValid ? 'pass' : 'fail',
            'error_message': isValid ? 'none' : R.string.phone_not_valid.tr(),
          },
        );
      }
    });
    passwordFocusNode.addListener(() async {
      if (passwordFocusNode.hasFocus) {
        await TrackingManager.analytics.logEvent(
          name: 'text_field_focus',
          parameters: {
            "screen_name": 'login',
            'text_field_name': 'text_field_login_password',
            'object_value': password
          },
        );
      } else {
        bool isValid = password.length >= 6;
        await TrackingManager.analytics.logEvent(
          name: 'text_field_input',
          parameters: {
            "screen_name": 'login',
            'text_field_name': 'text_field_login_password',
            'object_value': password.length,
            'validate_state': isValid ? 'pass' : 'fail',
            'error_message':
                isValid ? 'none' : R.string.password_least_character.tr()
          },
        );
      }
    });
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
                            R.string.login.tr(),
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 28,
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
                    if (isLogin) ...[
                      TextFieldCustom(
                        key: passwordKey,
                        focusNode: passwordFocusNode,
                        title: R.string.password.tr(),
                        placeholder: R.string.nhap_mat_khau.tr(),
                        isPassword: true,
                        onChanged: (value) {
                          password = value;
                        },
                      ),
                      Container(
                        height: 48,
                        alignment: Alignment.centerRight,
                        color: R.color.transparent,
                        child: InkWell(
                          onTap: () async {
                            await TrackingManager.analytics.logEvent(
                              name: 'cta_button_clicked',
                              parameters: {
                                "screen_name": 'login',
                                'cta_button_name': 'cta_login_forget_password',
                              },
                            );
                            Navigator.pushNamed(
                                context, NavigatorName.forgot_password);
                          },
                          child: Text(
                            R.string.forgot_password.tr(),
                            style: TextStyle(
                              color: R.color.mainColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                    GestureDetector(
                      onTap: () {
                        if (isLogin) {
                          login();
                        } else {
                          checkExistPhoneNumber();
                        }
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
                              R.color.greenGradientTop,
                              R.color.greenGradientBottom
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                              isLogin
                                  ? R.string.login.tr()
                                  : R.string.tiep_tuc.tr(),
                              style: TextStyle(
                                  color: R.color.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
                SocialLoginSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  checkExistPhoneNumber() async {
    if (phone.isEmpty) {
      phoneKey.currentState!
          .validate(R.string.ban_chua_nhap_so_dien_thoai.tr());
      return;
    }
    if (!(phone.length == 9 || phone.length == 10)) {
      return;
    }
    try {
      BotToast.showLoading();
      List<bool> resultIsExits =
          await LoginClient().checkExistPhoneNumber(phone);
      bool isExistAccount = resultIsExits[0];
      bool isActive = resultIsExits[1];
      bool phoneNumberConfirmed = resultIsExits[2];
      bool isExist = isExistAccount && isActive && phoneNumberConfirmed;
      if (isExist) {
        setState(() {
          isLogin = true;
        });
        FocusScope.of(context).requestFocus(passwordFocusNode);
      } else {
        sendOtpRegister(phone, phoneNumberConfirmed);
      }
      BotToast.closeAllLoading();
    } catch (e) {}
  }

  sendOtpRegister(String phone, bool phoneNumberConfirmed) async {
    RegisterModel? result;
    // if (phoneNumberConfirmed) {
    //   Navigator.pushReplacementNamed(context, NavigatorName.register,
    //       arguments: {
    //         'phone': phone,
    //         'referalCode': null,
    //       });
    //   return;
    // }
    try {
      result = await LoginClient().submitRegister(phone);
      if (result.remainingRequestCount! <= 0) {
        _showDialogError();
        return;
      }
      Navigator.pushNamed(context, NavigatorName.verify, arguments: {
        'type': 'register',
        'otp': result.token,
        'phone': phone,
        'password': password,
        'remainingRequestCount': result.remainingRequestCount,
        'isCompleted': true,
        // 'referalCode': referralCode,
      });
    } catch (e) {
      if (e is Error) {
        if (e.code == 'USER002') {
          Navigator.pushNamed(context, NavigatorName.verify, arguments: {
            'type': 'register',
            'otp': result?.token,
            'phone': phone,
            'password': password,
            'remainingRequestCount': result?.remainingRequestCount,
            'isCompleted': true,
            // 'referalCode': referralCode,
          });
        }
      }
    }
  }

  login() async {
    await TrackingManager.analytics
        .logEvent(name: 'cta_button_clicked', parameters: {
      "screen_name": 'login',
      'cta_button_name': 'cta_login_phone',
    });
    FocusScope.of(context).unfocus();
    if (phone.isEmpty) {
      phoneKey.currentState!
          .validate(R.string.ban_chua_nhap_so_dien_thoai.tr());
      return;
    }
    if (password.isEmpty) {
      passwordKey.currentState!.validate(R.string.ban_chua_nhap_mat_khau.tr());
      return;
    }
    BotToast.showLoading();
    try {
      await LoginClient().login({
        "client_id": Const.CLIENT_ID,
        "client_secret": Const.CLIENT_SECRET,
        "grant_type": "phone_number_password",
        "password": password,
        "phone_number": phone
      });
      final user = await UserClient().fetchUser();
      BotToast.closeAllLoading();
      if (user == null) {
        final diabeteStates = await UserClient().fetchDiabeteStatesNoHeader();
        Navigator.pushReplacementNamed(context, NavigatorName.update_info,
            arguments: {'type': 'phone', 'diabeteStates': diabeteStates});
      } else {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacementNamed(
          context,
          NavigatorName.tabbar,
          arguments: widget.sharedCode,
        );
      }
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        if (e.code == '1') {
          passwordKey.currentState!
              .validate(R.string.mat_khau_khong_chinh_xac.tr());
        } else if (e.code == '2') {
          phoneKey.currentState!
              .validate(R.string.so_dien_thoai_khong_chinh_xac.tr());
        } else if (e.code == '3') {
          verifyPhone();
        } else if (e.code == '4') {
          phoneKey.currentState!.validate(R.string.tai_khoan_het_hieu_luc.tr());
        } else {
          Message.showToastMessage(context, e.message);
        }
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }

  verifyPhone() async {
    BotToast.showLoading();
    try {
      final result = await LoginClient()
          .requestOTP({"password": password, "phoneNumber": phone});
      BotToast.closeAllLoading();
      if (result.remainingRequestCount! <= 0) {
        _showDialogError();
        return;
      }
      Navigator.pushNamed(context, NavigatorName.verify, arguments: {
        'type': 'register',
        'otp': result.token,
        'phone': phone,
        'password': password,
        'remainingRequestCount': result.remainingRequestCount,
        'isCompleted': true,
      });
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        if (e.code == 'USER002') {
          phoneKey.currentState!
              .validate(R.string.so_dien_thoai_da_ton_tai.tr());
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
                        text: phone,
                        style: const TextStyle(
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
    await TrackingManager.analytics.logEvent(
      name: 'login',
      parameters: {
        "screen_name": 'login',
        'method': loginFrom.toLowerCase(),
      },
    );
  }

  registerAccount(
    String? providerKey,
    String? externalToken,
    String provider,
    String userName,
    bool update, {
    GoogleSignInAccount? googleAccount,
    AuthorizationCredentialAppleID? appleCredential,
  }) async {
    loginSuccess(provider);
    try {
      BotToast.showLoading();
      // if (!update) {
      //   await LoginClient().registerWithSocial({'providerName': provider, 'providerKey': providerKey});

      //   await LoginClient().login({
      //     "client_id": Const.CLIENT_ID,
      //     "client_secret": Const.CLIENT_SECRET,
      //     "grant_type": "external",
      //     "external_token": externalToken,
      //     "provider": provider
      //   });
      // }

      final diabeteStates = await UserClient().fetchDiabeteStatesNoHeader();

      // final result = await LoginClient().createPatient({
      //   'fullName': userName,
      //   'dateOfBirth': '0',
      //   'gender': '1',
      //   'diabetesStatus': diabeteStates?.isEmpty ?? true ? '1' : diabeteStates?.first.key.toString() ?? '1',
      //   // 'diabetesStatus': '1',
      //   'diabetesDate': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString()
      // });
      // if (result == true) {
      // Navigator.pushReplacementNamed(context, NavigatorName.rules,
      //     arguments: {'googleAccount': googleAccount, 'appleCredential': appleCredential});
      //}
      Navigator.pushReplacementNamed(context, NavigatorName.register_success,
          arguments: {
            'type': provider.toLowerCase(),
            'googleAccount': googleAccount,
            'appleAccount': appleCredential,
            'diabeteStates': diabeteStates
          });
      BotToast.closeAllLoading();
    } catch (error) {
      BotToast.closeAllLoading();
      Message.showToastMessage(context, error.toString());
    }
  }
}
