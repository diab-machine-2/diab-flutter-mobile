import 'dart:convert';
import 'dart:io' show Platform;

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/modal/base/referral_code_temp.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/user_info_referral_code_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/text_field_custom.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/qr_scan_widget.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class RegisterController extends StatefulWidget {
  const RegisterController(this.sharedCode);
  final String sharedCode;
  @override
  _RegisterControllerState createState() => _RegisterControllerState();
}

class _RegisterControllerState extends State<RegisterController> {
  FocusNode phoneFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();
  FocusNode referralCodeFocusNode = FocusNode();

  final AppRepository _appRepository = AppRepository();

  final GlobalKey<TextFieldCustomState> phoneKey = GlobalKey();
  final GlobalKey<TextFieldCustomState> passwordKey = GlobalKey();
  final GlobalKey<TextFieldCustomState> confirmPasswordKey = GlobalKey();
  final GlobalKey<TextFieldCustomState> referralCodeKey = GlobalKey();

  String phone = '';
  String password = '';
  String confirmPassword = '';
  late String referralCode;

  bool checked = false;

  @override
  void initState() {
    super.initState();
    final String? referalCode = DynamicLinkConfig.instance.referalCode;
    referralCode = referalCode ?? "";
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
        screenName: "sign_up", screenClass: "RegisterController");
    AppSettings.currentScreenName = 'sign_up';
    phoneFocusNode.addListener(() async {
      if (phoneFocusNode.hasFocus) {
        await TrackingManager.analytics.logEvent(
          name: 'text_field_focus',
          parameters: {
            "screen_name": 'sign_up',
            'text_field_name': 'text_field_sign_up_phone',
            'object_value': phone
          },
        );
      } else {
        bool isValid = phone.length == 9 || phone.length == 10;
        await TrackingManager.analytics.logEvent(
          name: 'text_field_input',
          parameters: {
            "screen_name": 'sign_up',
            'text_field_name': 'text_field_sign_up_phone',
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
            "screen_name": 'sign_up',
            'text_field_name': 'text_field_sign_up_password',
            'object_value': password
          },
        );
      } else {
        bool isValid = password.length >= 6;
        await TrackingManager.analytics.logEvent(
          name: 'text_field_input',
          parameters: {
            "screen_name": 'sign_up',
            'text_field_name': 'text_field_sign_up_password',
            'object_value': password.length,
            'validate_state': isValid ? 'pass' : 'fail',
            'error_message':
                isValid ? 'none' : R.string.password_least_character.tr()
          },
        );
      }
    });
    confirmPasswordFocusNode.addListener(() async {
      if (passwordFocusNode.hasFocus) {
        await TrackingManager.analytics.logEvent(
          name: 'text_field_focus',
          parameters: {
            "screen_name": 'sign_up',
            'text_field_name': 'text_field_sign_up_confirm',
            'object_value': confirmPassword
          },
        );
      } else {
        String validateState = 'pass';
        String errorMessage = 'none';
        if (confirmPassword.isEmpty) {
          errorMessage = R.string.ban_chua_nhap_lai_mat_khau.tr();
          validateState = 'fail';
        }
        if (confirmPassword != password) {
          errorMessage = R.string.nhap_lai_mat_khau_khong_chinh_xac.tr();
          validateState = 'fail';
        }
        await TrackingManager.analytics.logEvent(
          name: 'text_field_input',
          parameters: {
            "screen_name": 'sign_up',
            'text_field_name': 'text_field_sign_up_confirm',
            'object_value': confirmPassword.length,
            'validate_state': validateState,
            'error_message': errorMessage
          },
        );
      }
    });
    referralCodeFocusNode.addListener(() async {
      if (passwordFocusNode.hasFocus) {
        await TrackingManager.analytics.logEvent(
          name: 'text_field_focus',
          parameters: {
            "screen_name": 'sign_up',
            'text_field_name': 'text_field_sign_up_referral',
            'object_value': referralCode
          },
        );
      } else {
        String validateState = 'pass';
        String errorMessage = 'none';
        bool isValid = valideReferralCode(referralCode);
        if (!isValid) {
          errorMessage = R.string.data_input_not_valid.tr();
          validateState = 'fail';
        }
        await TrackingManager.analytics.logEvent(
          name: 'text_field_input',
          parameters: {
            "screen_name": 'sign_up',
            'text_field_name': 'text_field_sign_up_referral',
            'object_value': referralCode,
            'validate_state': validateState,
            'error_message': errorMessage
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
          height: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  R.drawable.bg_splash,
                  fit: BoxFit.fill,
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppBar(
                      leading: IconButton(
                          splashColor: R.color.transparent,
                          highlightColor: R.color.transparent,
                          icon: Icon(Icons.arrow_back, color: R.color.black),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      title: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          R.string.tao_tai_khoan.tr(),
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 24,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      backgroundColor: R.color.transparent, //No more green
                      elevation: 0.0, //Shadow gone
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextFieldCustom(
                              focusNode: phoneFocusNode,
                              key: phoneKey,
                              title: R.string.so_dien_thoai.tr(),
                              placeholder: R.string.nhap_so_dien_thoai.tr(),
                              onChanged: (value) {
                                phone = value;
                              }),
                          const SizedBox(height: 20),
                          TextFieldCustom(
                              focusNode: passwordFocusNode,
                              key: passwordKey,
                              title: R.string.password.tr(),
                              placeholder:
                                  R.string.password_least_character.tr(),
                              isPassword: true,
                              onChanged: (value) {
                                password = value;
                              }),
                          const SizedBox(height: 20),
                          TextFieldCustom(
                              focusNode: confirmPasswordFocusNode,
                              key: confirmPasswordKey,
                              title: R.string.xac_nhan_mat_khau.tr(),
                              placeholder: R.string.nhap_lai_mat_khau.tr(),
                              isPassword: true,
                              onChanged: (value) {
                                confirmPassword = value;
                              }),
                          const SizedBox(height: 20),
                          TextFieldCustom(
                              key: referralCodeKey,
                              initText: referralCode,
                              maxLength: 6,
                              title: R.string.references_code.tr(),
                              placeholder: R.string.input_references_code.tr(),
                              hintTextSize: 15,
                              isSharedCode: true,
                              rightIcon: R.drawable.ic_qr_scan,
                              onRightWidgetClick: () async {
                                await TrackingManager.analytics.logEvent(
                                  name: 'component_clicked',
                                  parameters: {
                                    "screen_name": 'sign_up',
                                    'component_name': 'icon_sign_up_scan',
                                  },
                                );
                                final dynamic scanResult =
                                    await NavigationUtil.navigatePage(
                                        context, const QRScanWidget());
                                if (scanResult is String) {
                                  referralCode = scanResult;
                                  referralCodeKey
                                      .currentState
                                      ?.textEditingController
                                      .text = referralCode;
                                  referralCodeKey.currentState
                                      ?.valideReferralCode(referralCode);
                                  await TrackingManager.analytics.logEvent(
                                    name: 'scan_qr_success',
                                    parameters: {
                                      "screen_name": 'sign_up',
                                      'object_title': scanResult,
                                    },
                                  );
                                }
                              },
                              onChanged: (value) {
                                referralCode = value.trim();
                              }),
                          const SizedBox(height: 32),
                          GestureDetector(
                            onTap: () {
                              verify();
                            },
                            child: Container(
                              height: 48,
                              width: 195,
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
                                  R.string.tiep_tuc.tr(),
                                  style: TextStyle(
                                      color: R.color.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     InkWell(
                    //       onTap: () async {
                    //         final dynamic scanResult = await NavigationUtil.navigatePage(context, const QRScanWidget());
                    //         if (scanResult is String) {
                    //           referralCode = scanResult;
                    //           referralCodeKey.currentState?.textEditingController.text = referralCode;
                    //           referralCodeKey.currentState?.valideReferralCode(referralCode);
                    //         }
                    //       },
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           Image.asset(
                    //             R.drawable.ic_qr_scan,
                    //             width: 26,
                    //             height: 26,
                    //           ),
                    //           const SizedBox(width: 12),
                    //           Text(
                    //             R.string.scan_references_code.tr(),
                    //             style: TextStyle(
                    //               color: R.color.mainColor,
                    //               fontSize: 16,
                    //               fontWeight: FontWeight.w700,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    SafeArea(
                      child: Column(
                        children: [
                          Text(R.string.hoac_dang_nhap_bang.tr(),
                              style: TextStyle(
                                  color: R.color.textDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400)),
                          const SizedBox(height: 16),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (Platform.isIOS)
                                  GestureDetector(
                                    onTap: () {
                                      loginApple();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8),
                                      child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: R.color.white,
                                              borderRadius:
                                                  BorderRadius.circular(25)),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                    R.drawable.ic_login_apple,
                                                    width: 26,
                                                    height: 26),
                                              ])),
                                    ),
                                  )
                                else
                                  const SizedBox(),
                                GestureDetector(
                                  onTap: () {
                                    loginGG();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    child: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                            color: R.color.white,
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(R.drawable.ic_google,
                                                  width: 26, height: 26),
                                            ])),
                                  ),
                                )
                              ]),
                          const SizedBox(height: 16)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _isReferralCodeExist(String code) async {
    BotToast.showLoading();
    bool isReferralCodeExist = false;
    final ApiResult<UserInfoReferralCodeResponse> apiResult =
        await _appRepository.getUserFromReferralCode(code);
    apiResult.when(success: (UserInfoReferralCodeResponse response) {
      isReferralCodeExist = response.isUserExists;
      if (!isReferralCodeExist) {
        Message.showToastMessage(
            context, R.string.referral_code_not_exist.tr());
      }
    }, failure: (NetworkExceptions error) {
      Message.showToastMessage(
          context, NetworkExceptions.getErrorMessage(error));
      BotToast.closeAllLoading();
    });
    if (!isReferralCodeExist) BotToast.closeAllLoading();
    return isReferralCodeExist;
  }

  verify() async {
    await TrackingManager.analytics.logEvent(
      name: 'cta_button_clicked',
      parameters: {
        "screen_name": 'sign_up',
        'cta_button_name': 'cta_sign_up_phone',
      },
    );
    if (phone.isEmpty) {
      phoneKey.currentState!
          .validate(R.string.ban_chua_nhap_so_dien_thoai.tr());
      return;
    }
    if (password.isEmpty) {
      passwordKey.currentState!.validate(R.string.ban_chua_nhap_mat_khau.tr());
      return;
    }
    if (password.contains(' ')) {
      passwordKey.currentState!
          .validate(R.string.mat_khau_khong_chua_khoang_trang.tr());
      return;
    }
    if (password.length < 6) {
      passwordKey.currentState!
          .validate(R.string.password_least_character.tr());
      return;
    }
    if (confirmPassword.isEmpty) {
      confirmPasswordKey.currentState!
          .validate(R.string.ban_chua_nhap_lai_mat_khau.tr());
      return;
    }
    if (confirmPassword != password) {
      confirmPasswordKey.currentState!
          .validate(R.string.nhap_lai_mat_khau_khong_chinh_xac.tr());
      return;
    }

    if (referralCode.isNotEmpty) {
      if (!referralCodeKey.currentState!.isCorrect) {
        return;
      }
    }

    const String pattern = r'(^(?:[+0]9)?[0-9]{9}|\d{10}$)';
    final RegExp regExp = RegExp(pattern);
    final isCorrect = regExp.hasMatch(phone);
    if (!isCorrect) {
      phoneKey.currentState!.validate(R.string.phone_not_valid.tr());
      return;
    }

    if (referralCode.isNotEmpty) {
      final bool isReferralCodeExist = await _isReferralCodeExist(referralCode);
      if (!isReferralCodeExist) return;
    }
    try {
      final result = await LoginClient()
          .requestOTP({"password": password, "phoneNumber": phone});
      BotToast.closeAllLoading();
      if (result.remainingRequestCount! <= 0) {
        _showDialogError();
        return;
      }

      if (referralCode != "") {
        ReferralCodeTemp referralCodeData =
            ReferralCodeTemp(referralCode: referralCode, phoneNumber: phone);
        AppStorages.setReferralCode(referralCodeData);
      }

      Navigator.pushNamed(context, NavigatorName.verify, arguments: {
        'type': 'register',
        'otp': result.token,
        'phone': phone,
        'password': password,
        'remainingRequestCount': result.remainingRequestCount,
        'referalCode': referralCode,
      });
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        if (e.code == 'USER002') {
          phoneKey.currentState!
              .validate(R.string.so_dien_thoai_da_ton_tai.tr());
        } else {
          Message.showToastMessage(
              context, R.string.error_can_not_connect_to_server.tr());
        }
      } else {
        Message.showToastMessage(
            context, R.string.error_can_not_connect_to_server.tr());
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

  loginFB() async {
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn([R.string.email.tr()]);
    dynamic profile;
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        try {
          BotToast.showLoading();
          final token = result.accessToken?.token;
          final graphResponse = await http.get(Uri.parse(
              'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token'));
          profile = jsonDecode(graphResponse.body);
          await LoginClient().login({
            "client_id": Const.CLIENT_ID,
            "client_secret": Const.CLIENT_SECRET,
            "grant_type": "external",
            "external_token": token,
            "provider": 'Facebook'
          });
          final user = await UserClient().fetchUser();
          BotToast.closeAllLoading();
          if (user == null) {
            registerAccount(
                result.accessToken?.userId,
                result.accessToken?.token,
                'Facebook',
                profile['name'] ?? R.string.user_name_default.tr(),
                true);
            // Navigator.pushReplacementNamed(context, NavigatorName.update_info, arguments: {
            //   'type': 'facebook',
            //   'facebookAccount': result,
            //   'userInfo': profile
            // });
          } else {
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacementNamed(context, NavigatorName.tabbar);
          }
        } catch (error) {
          BotToast.closeAllLoading();
          if (error is Error) {
            if (error.code == '5' && profile != null) {
              registerAccount(
                  result.accessToken?.userId,
                  result.accessToken?.token,
                  'Facebook',
                  profile['name'] ?? R.string.user_name_default.tr(),
                  false);
              // Navigator.pushReplacementNamed(context, NavigatorName.update_info,
              //     arguments: {
              //       'type': 'facebook',
              //       'facebookAccount': result,
              //       'userInfo': profile
              //     });
            }
          } else {
            Message.showToastMessage(context, error.toString());
          }
        }

        break;
      case FacebookLoginStatus.cancelledByUser:
        break;
      case FacebookLoginStatus.error:
        Message.showToastMessage(context, result.errorMessage);
        break;
    }
  }

  loginGG() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        R.string.email.tr(),
        'profile',
      ],
    );
    GoogleSignInAccount? account;
    late GoogleSignInAuthentication authen;
    try {
      account = await _googleSignIn.signIn();
      if (account == null) return;
      authen = await account.authentication;
      print(authen.accessToken);
      BotToast.showLoading();

      await LoginClient().login({
        "client_id": Const.CLIENT_ID,
        "client_secret": Const.CLIENT_SECRET,
        "grant_type": "external",
        "external_token": authen.accessToken,
        "provider": 'Google'
      });
      final user = await UserClient().fetchUser();
      BotToast.closeAllLoading();
      if (user == null) {
        registerAccount(account.id, authen.accessToken, 'Google',
            account.displayName ?? R.string.user_name_default.tr(), true,
            googleAccount: account, appleCredential: null);
        // Navigator.pushReplacementNamed(context, NavigatorName.update_info,
        //     arguments: {'type': 'google', 'googleAccount': account});
      } else {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacementNamed(context, NavigatorName.tabbar);
      }
    } catch (error) {
      if (error is Error && error.code == '5' && account != null) {
        registerAccount(account.id, authen.accessToken, 'Google',
            account.displayName ?? R.string.user_name_default.tr(), false,
            googleAccount: account, appleCredential: null);
      } else if (error is PlatformException && error.code == 'network_error') {
        Message.showToastMessage(
            context, R.string.error_can_not_connect_to_server.tr());
      } else {
        BotToast.closeAllLoading();
        Message.showToastMessage(context, error.toString());
      }
    }
  }

  loginApple() async {
    AuthorizationCredentialAppleID? credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.cactusoftware.diab.service', //'com.vbhc.diab',
          redirectUri: Uri.parse(
              'https://is.stg.diab.cptech.vn/External/Challenge?scheme=Apple' //'https://is.stg.diab.cptech.vn/signin-apple' //'https://is.diab.com.vn/callbacks/sign_in_with_apple', //
              ),
        ),
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      print(credential.identityToken);

      BotToast.showLoading();

      await LoginClient().login({
        "client_id": Const.CLIENT_ID,
        "client_secret": Const.CLIENT_SECRET,
        "grant_type": "external",
        "external_token": credential.identityToken ?? '',
        "provider": 'Apple'
      });
      final user = await UserClient().fetchUser();
      BotToast.closeAllLoading();
      if (user == null) {
        // Navigator.pushReplacementNamed(context, NavigatorName.update_info,
        //     arguments: {'type': 'apple', 'appleAccount': credential});
        registerAccount(
            credential.userIdentifier,
            credential.identityToken,
            'Apple',
            credential.givenName ?? R.string.user_name_default.tr(),
            true,
            googleAccount: null,
            appleCredential: credential);
      } else {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacementNamed(context, NavigatorName.tabbar);
      }
    } catch (error) {
      BotToast.closeAllLoading();
      if (error is Error && error.code == '5' && credential != null) {
        registerAccount(
            credential.userIdentifier,
            credential.identityToken,
            'Apple',
            credential.givenName ?? R.string.user_name_default.tr(),
            false,
            googleAccount: null,
            appleCredential: credential);
      } else if (error is PlatformException && error.code == 'network_error') {
        Message.showToastMessage(
            context, R.string.error_can_not_connect_to_server.tr());
      } else {
        // Message.showToastMessage(context, error.toString());
      }
    }
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
    try {
      BotToast.showLoading();
      // if (!update) {
      //   await LoginClient().registerWithSocial({'providerName': provider, 'providerKey': providerKey ?? ''});

      //   await LoginClient().login({
      //     "client_id": Const.CLIENT_ID,
      //     "client_secret": Const.CLIENT_SECRET,
      //     "grant_type": "external",
      //     "external_token": externalToken ?? '',
      //     "provider": provider
      //   });
      // }

      final diabeteStates = await UserClient().fetchDiabeteStatesNoHeader();

      // final result = await LoginClient().createPatient({
      //   'fullName': userName,
      //   'dateOfBirth': '0',
      //   'gender': '1',
      //   'diabetesStatus': diabeteStates?.isEmpty ?? true ? '1' : diabeteStates?.first.key.toString().toString() ?? '1',
      //   //  'diabetesStatus': '1',
      //   'diabetesDate': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString()
      // });
      // if (result == true) {
      // Navigator.pushReplacementNamed(context, NavigatorName.rules,
      //     arguments: {'googleAccount': googleAccount, 'appleCredential': appleCredential});
      //}

      // Message.showToastMessage(context, 'Name: ${appleCredential?.givenName}, ${appleCredential?.familyName}\n userIdentifier: ${appleCredential?.userIdentifier}\n identityToken: ${appleCredential?.identityToken}');

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

  bool valideReferralCode(String code) {
    const String pattern = r'^[a-zA-Z0-9\+]*$';
    final RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(code);
  }
}
