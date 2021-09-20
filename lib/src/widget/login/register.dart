import 'dart:convert';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/text_field_custom.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;

class RegisterController extends StatefulWidget {
  @override
  _RegisterControllerState createState() => _RegisterControllerState();
}

class _RegisterControllerState extends State<RegisterController> {
  final GlobalKey<TextFieldCustomState> phoneKey = GlobalKey();
  final GlobalKey<TextFieldCustomState> passwordKey = GlobalKey();
  final GlobalKey<TextFieldCustomState> confirmPasswordKey = GlobalKey();

  String phone = '';
  String password = '';
  String confirmPassword = '';

  bool checked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: R.color.lightBlue100,
          body: Stack(children: [
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage(R.drawable.bg_splash),
                fit: BoxFit.cover,
              )),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(children: [
                      Padding(
                        padding: EdgeInsets.only(top: 30),
                      ),
                    ]),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(children: [
                              TextFieldCustom(
                                  key: phoneKey,
                                  title: 'Số điện thoại',
                                  placeholder: 'Nhập số điện thoại',
                                  autoFocus: true,
                                  onChanged: (value) {
                                    phone = value;
                                  }),
                              SizedBox(height: 20),
                              TextFieldCustom(
                                  key: passwordKey,
                                  title: 'Mật khẩu',
                                  placeholder: 'Mật khẩu ít nhất 6 ký tự',
                                  isPassword: true,
                                  onChanged: (value) {
                                    password = value;
                                  }),
                              SizedBox(height: 20),
                              TextFieldCustom(
                                  key: confirmPasswordKey,
                                  title: 'Xác nhận mật khẩu',
                                  placeholder: 'Nhập lại mật khẩu',
                                  isPassword: true,
                                  onChanged: (value) {
                                    confirmPassword = value;
                                  }),
                              SizedBox(height: 20),
                              GestureDetector(
                                onTap: () {
                                  phoneKey.currentState.focusNode
                                      .requestFocus();

                                  verify();
                                },
                                child: Stack(children: [
                                  Container(
                                      height: 48,
                                      width: 195,
                                      decoration: BoxDecoration(
                                          color: R.color.mainColor,
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                R.color.greenGradientTop,
                                                R.color.greenGradientBottom
                                              ])),
                                      child: Center(
                                        child: Text('Tiếp tục',
                                            style: TextStyle(
                                                color: R.color.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      )),
                                  // Positioned.fill(
                                  //     child: Container(
                                  //         color: R.color.white.withOpacity(0.5)))
                                ]),
                              )
                            ])
                          ]),
                    ),
                    SafeArea(
                      child: Column(
                        children: [
                          Text('Hoặc đăng nhập bằng',
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
                                          padding: EdgeInsets.only(
                                              left: 8, right: 8),
                                          child: Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                  color: R.color.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25)),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                        R.drawable.icon_login_apple,
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
                                                  R.drawable.icon_gg,
                                                  width: 26,
                                                  height: 26),
                                            ])),
                                  ),
                                )
                              ]),
                          SizedBox(height: 16)
                        ],
                      ),
                    )
                  ]),
            ),
            // new Positioned(
            //   //Place it at the top, and not use the entire screen
            //   top: 0,
            //   left: 0,
            //   right: 0,
            //   child: AppBar(
            //       leading: SizedBox(),
            //       backgroundColor: R.color.transparent, //No more green
            //       elevation: 0.0, //Shadow gone
            //       actions: [
            //         IconButton(
            //             padding: EdgeInsets.only(right: 30),
            //             icon: Icon(Icons.close, color: R.color.black),
            //             onPressed: () {
            //               Navigator.pop(context);
            //             })
            //       ]),
            // ),
            new Positioned(
                //Place it at the top, and not use the entire screen
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(
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
                      "Tạo tài khoản",
                      style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 24,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  backgroundColor: R.color.transparent, //No more green
                  elevation: 0.0, //Shadow gone
                )),
          ])),
    );
  }

  verify() async {
    if (phone.isEmpty) {
      phoneKey.currentState.validate('Bạn chưa nhập số điện thoại');
      return;
    }
    if (password.isEmpty) {
      passwordKey.currentState.validate('Bạn chưa nhập mật khẩu');
      return;
    }
    if (password.contains(' ')) {
      passwordKey.currentState.validate('Mật khẩu không chứa khoảng trắng');
      return;
    }
    if (password.length < 6) {
      passwordKey.currentState.validate('Mật khẩu ít nhất 06 ký tự');
      return;
    }
    if (confirmPassword.isEmpty) {
      confirmPasswordKey.currentState.validate('Bạn chưa nhập lại mật khẩu');
      return;
    }
    if (confirmPassword != password) {
      confirmPasswordKey.currentState
          .validate('Nhập lại mật khẩu không chính xác');
      return;
    }

    String pattern = r'(^(?:[+0]9)?[0-9]{9}|\d{10}$)';
    RegExp regExp = new RegExp(pattern);
    final isCorrect = regExp.hasMatch(phone);
    if (!isCorrect) {
      phoneKey.currentState.validate('Số điện thoại không hợp lệ');
      return;
    }

    BotToast.showLoading();
    try {
      print(phone);
      final result = await LoginClient()
          .requestOTP({"password": password, "phoneNumber": phone});
      BotToast.closeAllLoading();
      if (result.remainingRequestCount <= 0) {
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
          phoneKey.currentState.validate(
              'Số điện thoại đã tồn tại. Vui lòng đăng nhập hoặc dùng số điện thoại khác để đăng ký!');
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
              Image.asset(R.drawable.checkError,
                  width: 64, height: 64),
              SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Đã gửi OTP 5 lần cho số điện thoại ',
                  style: TextStyle(color: R.color.color0xff172823, fontSize: 16),
                  children: <TextSpan>[
                    TextSpan(
                        text: phone,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    TextSpan(
                        text:
                            '.\nVui lòng kiểm tra lại hoặc đăng ký vào ngày hôm sau!',
                        style:
                            TextStyle(color: R.color.color0xff172823, fontSize: 16)),
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
    final result = await facebookLogin.logIn(['email']);
    dynamic profile;
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        try {
          BotToast.showLoading();
          final token = result.accessToken.token;
          final graphResponse = await http.get(Uri.parse(
              'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token'));
          profile = jsonDecode(graphResponse.body);
          await LoginClient().login({
            "client_id": '4A293E78-4513-4DAF-958E-A04F93978332',
            "client_secret": "oTxBinRm9NpNen3rs++jN9sWXvOkya60nuffhv6x304=",
            "grant_type": "external",
            "external_token": result.accessToken.token,
            "provider": 'Facebook'
          });
          final user = await UserClient().fetchUser();
          BotToast.closeAllLoading();
          if (user == null) {
            registerAccount(result.accessToken.userId, result.accessToken.token,
                'Facebook', profile['name'] ?? 'Tài khoản nguời dùng', true);
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
                  result.accessToken.userId,
                  result.accessToken.token,
                  'Facebook',
                  profile['name'] ?? 'Tài khoản nguời dùng',
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
    GoogleSignInAccount account;
    GoogleSignInAuthentication authen;
    try {
      account = await _googleSignIn.signIn();
      authen = await account.authentication;
      print(authen.accessToken);
      BotToast.showLoading();

      await LoginClient().login({
        "client_id": '4A293E78-4513-4DAF-958E-A04F93978332',
        "client_secret": "oTxBinRm9NpNen3rs++jN9sWXvOkya60nuffhv6x304=",
        "grant_type": "external",
        "external_token": authen.accessToken,
        "provider": 'Google'
      });
      final user = await UserClient().fetchUser();
      BotToast.closeAllLoading();
      if (user == null) {
        registerAccount(account.id, authen.accessToken, 'Google',
            account.displayName ?? 'Tài khoản nguời dùng', true);
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
              account.displayName ?? 'Tài khoản nguời dùng', false);
        }
      } else {
        BotToast.closeAllLoading();
        Message.showToastMessage(context, error.toString());
      }
    }
  }

  loginApple() async {
    AuthorizationCredentialAppleID credential;
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
        "client_id": '4A293E78-4513-4DAF-958E-A04F93978332',
        "client_secret": "oTxBinRm9NpNen3rs++jN9sWXvOkya60nuffhv6x304=",
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
            'Apple', credential.givenName ?? 'Tài khoản nguời dùng', true);
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
              'Apple', credential.givenName ?? 'Tài khoản nguời dùng', false);
        }
      } else {
        Message.showToastMessage(context, error.toString());
      }
    }
  }

  registerAccount(String providerKey, String externalToken, String provider,
      String userName, bool update) async {
    try {
      BotToast.showLoading();
      if (!update) {
        await LoginClient().registerWithSocial(
            {'providerName': provider, 'providerKey': providerKey});

        await LoginClient().login({
          "client_id": '4A293E78-4513-4DAF-958E-A04F93978332',
          "client_secret": "oTxBinRm9NpNen3rs++jN9sWXvOkya60nuffhv6x304=",
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
        'diabetesStatus': diabeteStates.length == 0
            ? '1'
            : diabeteStates.first['key'].toString(),
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
