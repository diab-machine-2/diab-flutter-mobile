import 'dart:convert';
import 'dart:io' show Platform;

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/text_field_custom.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginController extends StatefulWidget {
  @override
  _LoginControllerState createState() => _LoginControllerState();
}

class _LoginControllerState extends State<LoginController> {
  final GlobalKey<TextFieldCustomState> phoneKey = GlobalKey();
  final GlobalKey<TextFieldCustomState> passwordKey = GlobalKey();
  String phone = '';
  String password = '';
  TextEditingController userNameController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: R.color.white,
        body: Stack(children: [
          Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage(R.drawable.bg_splash),
                fit: BoxFit.cover,
              )),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 30),
                      ),
                      Column(children: [
                        Row(children: [
                          Text(
                            R.string.login.tr(),
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 28,
                                fontWeight: FontWeight.w600),
                          ),
                        ]),
                        SizedBox(height: 28),
                        TextFieldCustom(
                            key: phoneKey,
                            title: R.string.so_dien_thoai.tr(),
                            placeholder: R.string.nhap_so_dien_thoai.tr(),
                            autoFocus: true,
                            onChanged: (value) {
                              phone = value;
                            }),
                        SizedBox(height: 20),
                        TextFieldCustom(
                            key: passwordKey,
                            title: R.string.password.tr(),
                            placeholder: R.string.nhap_mat_khau.tr(),
                            isPassword: true,
                            onChanged: (value) {
                              password = value;
                            }),
                        SizedBox(height: 30),
                        GestureDetector(
                          onTap: () {
                            login();
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
                                      ])),
                              child: Center(
                                child: Text(R.string.login.tr(),
                                    style: TextStyle(
                                        color: R.color.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              )),
                        ),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, NavigatorName.forgot_password);
                          },
                          child: Container(
                              height: 48,
                              color: R.color.transparent,
                              child: Center(
                                child: Text(R.string.forgot_password.tr(),
                                    style: TextStyle(
                                        color: R.color.mainColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              )),
                        )
                      ]),
                      Column(children: [
                        Text(R.string.hoac_dang_nhap_bang.tr(),
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w400)),
                        SizedBox(height: 16),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Platform.isIOS
                                  ? GestureDetector(
                                      onTap: () {
                                        loginApple();
                                      },
                                      child: Padding(
                                        padding:
                                            EdgeInsets.only(left: 8, right: 8),
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
                                  : SizedBox(),
                              GestureDetector(
                                onTap: () {
                                  loginGG();
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8, right: 8),
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
                                                R.drawable.ic_google,
                                                width: 26,
                                                height: 26),
                                          ])),
                                ),
                              )
                            ]),
                        SizedBox(height: 30),
                        Text(R.string.chua_co_tai_khoan.tr(),
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w400)),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, NavigatorName.register);
                          },
                          child: Container(
                              height: 48,
                              width: 195,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color: R.color.white,
                                  border:
                                      Border.all(color: R.color.mainColor, width: 1)),
                              child: Center(
                                child: Text(R.string.tao_tai_khoan_moi.tr(),
                                    style: TextStyle(
                                        color: R.color.mainColor,
                                        fontWeight: FontWeight.w600)),
                              )),
                        ),
                        SizedBox(height: 30),
                      ])
                    ]),
              )),
          new Positioned(
            //Place it at the top, and not use the entire screen
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
                leading: SizedBox(),
                backgroundColor: R.color.transparent, //No more green
                actions: [
                  IconButton(
                      padding: EdgeInsets.only(right: 30),
                      icon: Icon(Icons.close, color: R.color.black),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ]),
          )
        ]),
      ),
    );
  }

  login() async {
    FocusScope.of(context).unfocus();
    if (phone.isEmpty) {
      phoneKey.currentState!.validate(R.string.ban_chua_nhap_so_dien_thoai.tr());
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
        Navigator.pushReplacementNamed(context, NavigatorName.update_info,
            arguments: {'type': 'phone'});
      } else {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacementNamed(context, NavigatorName.tabbar);
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
          phoneKey.currentState!.validate(
              R.string.tai_khoan_het_hieu_luc.tr());
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
        'remainingRequestCount': result.remainingRequestCount
      });
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        if (e.code == 'USER002') {
          phoneKey.currentState!.validate(
              R.string.so_dien_thoai_da_ton_tai.tr());
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
              Image.asset(R.drawable.ic_check_error,
                  width: 64, height: 64),
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
                        text:
                            R.string.dang_ky_lai_hom_sau.tr(),
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
            registerAccount(result.accessToken?.userId, result.accessToken?.token,
                'Facebook', profile['name'] ?? R.string.user_name_default.tr(), true);
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
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
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
            account.displayName ?? R.string.user_name_default.tr(), true);
        // Navigator.pushReplacementNamed(context, NavigatorName.update_info,
        //     arguments: {'type': 'google', 'googleAccount': account});
      } else {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacementNamed(context, NavigatorName.tabbar);
      }
    } catch (error) {
      if (error is Error) {
        if (error.code == '5' && account != null) {
          // Navigator.pushReplacementNamed(context, NavigatorName.update_info,
          //     arguments: {'type': 'google', 'googleAccount': account});

          registerAccount(account.id, authen.accessToken, 'Google',
              account.displayName ?? R.string.user_name_default.tr(), false);
        }
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
        "external_token": credential.identityToken,
        "provider": 'Apple'
      });
      final user = await UserClient().fetchUser();
      BotToast.closeAllLoading();
      if (user == null) {
        // Navigator.pushReplacementNamed(context, NavigatorName.update_info,
        //     arguments: {'type': 'apple', 'appleAccount': credential});
        registerAccount(credential.userIdentifier, credential.identityToken,
            'Apple', credential.givenName ?? R.string.user_name_default.tr(), true);
      } else {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacementNamed(context, NavigatorName.tabbar);
      }
    } catch (error) {
      BotToast.closeAllLoading();
      if (error is Error) {
        if (error.code == '5' && credential != null) {
          // Navigator.pushReplacementNamed(context, NavigatorName.update_info,
          //     arguments: {'type': 'apple', 'appleAccount': credential});
          registerAccount(credential.userIdentifier, credential.identityToken,
              'Apple', credential.givenName ?? R.string.user_name_default.tr(), false);
        }
      } else {
        // Message.showToastMessage(context, error.toString());
      }
    }
  }

  registerAccount(String? providerKey, String? externalToken, String provider,
      String userName, bool update) async {
    try {
      BotToast.showLoading();
      if (!update) {
        await LoginClient().registerWithSocial(
            {'providerName': provider, 'providerKey': providerKey});

        await LoginClient().login({
          "client_id": Const.CLIENT_ID,
          "client_secret": Const.CLIENT_SECRET,
          "grant_type": "external",
          "external_token": externalToken,
          "provider": provider
        });
      }

      final diabeteStates = await UserClient().fetchDiabeteStates();

      final result = await LoginClient().createPatient({
        'fullName': userName,
        'dateOfBirth': '0',
        'gender': '1',
        'diabetesStatus': diabeteStates?.isEmpty ?? true
            ? '1'
            : diabeteStates?.first['key'].toString() ?? '',
        'diabetesDate':
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString()
      });
      if (result == true) {
        Navigator.pushReplacementNamed(context, NavigatorName.rules);
      }
      BotToast.closeAllLoading();
    } catch (error) {
      BotToast.closeAllLoading();
      Message.showToastMessage(context, error.toString());
    }
  }
}
