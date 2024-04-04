import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class VerifyPhoneController extends StatefulWidget {
  final String? type;
  final String? otp;
  final String? phone;
  final String? password;
  final int? remainingRequestCount;
  final String? referalCode;
  final GoogleSignInAccount? googleAccount;
  final FacebookLoginResult? facebookAccount;
  final AuthorizationCredentialAppleID? appleAccount;
  final dynamic userInfo;
  const VerifyPhoneController(
      {this.type = 'forgot_password',
      this.otp,
      this.phone,
      this.password,
      this.remainingRequestCount,
      this.referalCode,
      this.googleAccount,
      this.facebookAccount,
      this.appleAccount,
      this.userInfo});
  @override
  _VerifyPhoneControllerState createState() => _VerifyPhoneControllerState();
}

class _VerifyPhoneControllerState extends State<VerifyPhoneController> {
  String? otpTemp = '';
  String otpCode = '';
  bool error = false;
  int? otpCount = 0;

  int timeCount = 60;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    otpCount = widget.remainingRequestCount ?? 0;
    otpTemp = widget.otp;

    // if(otpCount == 0 && otpTemp == null){
    //   timeCount = 0;
    //   Future.delayed(Duration.zero, () {
    //     _showDialogError();
    //   });
    // } else {
    startTimer();
    //}
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
        screenName: "otp_verify", screenClass: "VerifyPhoneController");
    AppSettings.currentScreenName = 'otp_verify';
  }

  void startTimer() {
    timeCount = 60;
    timer = Timer.periodic(Duration(seconds: 1), (Timer? timer) {
      if (timeCount > 0) {
        setState(() {
          timeCount -= 1;
        });
      } else {
        timer!.cancel();
        timer = null;
      }
    });
  }

  @override
  void dispose() {
    timer!.cancel();
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // BotToast.closeAllLoading();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(children: [
            Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage(R.drawable.bg_splash),
                  fit: BoxFit.cover,
                )),
                child: Padding(
                  padding: EdgeInsets.only(top: 140),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(children: [
                          Image.asset(R.drawable.img_check_phone,
                              width: 90, height: 74),
                          SizedBox(height: 20),
                          Text(R.string.nhap_otp.tr(),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center),
                          SizedBox(height: 8),
                          Text('+84 ${widget.phone!.split('+84').join()}',
                              style: TextStyle(
                                  fontFamily: 'Viga',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center),
                          SizedBox(height: 32),
                          SizedBox(
                            width: 224,
                            height: 44,
                            child: PinCodeTextField(
                              appContext: context,
                              length: 4,
                              autoFocus: true,
                              keyboardType: TextInputType.number,
                              animationType: AnimationType.none,
                              showCursor: false,
                              textStyle: TextStyle(
                                  fontFamily: 'Viga',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400),
                              pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(8),
                                  fieldHeight: 44,
                                  fieldWidth: 44,
                                  activeFillColor: R.color.white,
                                  inactiveFillColor: R.color.white,
                                  selectedFillColor: R.color.white,
                                  activeColor: error
                                      ? R.color.red
                                      : R.color.notActiveGreen,
                                  selectedColor: R.color.mainColor,
                                  disabledColor: error
                                      ? R.color.red
                                      : R.color.notActiveGreen,
                                  inactiveColor: error
                                      ? R.color.red
                                      : R.color.notActiveGreen),
                              backgroundColor: R.color.transparent,
                              enableActiveFill: true,
                              onCompleted: (value) {
                                setState(() {
                                  error = false;
                                });
                                otpCode = value;
                                submitOtp();
                              },
                              onChanged: (value) {
                                otpCode = value;
                                setState(() {
                                  error = false;
                                });
                              },
                              beforeTextPaste: (text) {
                                return true;
                              },
                            ),
                          ),
                          SizedBox(height: 8),
                          error
                              ? Padding(
                                  padding: EdgeInsets.only(left: 32, right: 32),
                                  child: Text(
                                    R.string.otp_khong_chinh_xac.tr(),
                                    style: TextStyle(color: R.color.red),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : SizedBox(),
                          // Padding(
                          //   padding: const EdgeInsets.all(16),
                          //   child: Text(
                          //       'Số xác thực được nhân viên diaB cung cấp theo chương trình thử nghiệm',
                          //       style: TextStyle(
                          //           fontSize: 16, fontWeight: FontWeight.w400),
                          //       textAlign: TextAlign.center),
                          // ),
                        ]),
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  resendOTP();
                                },
                                child: Container(
                                  height: 48,
                                  width: 227,
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
                                      child: Text(
                                          '${R.string.gui_lai_ma.tr()} (${timeCount}s)',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: R.color.white))),
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        height: 1,
                                        width: 36,
                                        color: R.color.color0xffD6D8E0),
                                    SizedBox(width: 8),
                                    Text(R.string.or.tr(),
                                        style: TextStyle(
                                            color: R.color.color0xff232527)),
                                    SizedBox(width: 8),
                                    Container(
                                        height: 1,
                                        width: 36,
                                        color: R.color.color0xffD6D8E0)
                                  ]),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  await TrackingManager.analytics.logEvent(
                                    name: 'cta_button_clicked',
                                    parameters: {
                                      "screen_name": 'otp_verify',
                                      'cta_button_name':
                                          'cta_otp_verify_change_phone',
                                    },
                                  );
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 48,
                                  width: 227,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(200),
                                      border: Border.all(
                                          color: R.color.mainColor, width: 1)),
                                  child: Center(
                                      child: Text(
                                          R.string.thay_doi_so_dien_thoai.tr(),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: R.color.mainColor))),
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              )
                              // Container(
                              //   height: 48,
                              //   width: 227,
                              //   decoration: BoxDecoration(
                              //       color: main,
                              //       borderRadius: BorderRadius.circular(200)),
                              //   child: Center(
                              //       child: Text('Gửi lại mã (Còn 60s)',
                              //           style: TextStyle(
                              //               fontSize: 16,
                              //               fontWeight: FontWeight.w500,
                              //               color: R.color.white))),
                              // ),
                            ],
                          ),
                        ),
                      ]),
                )),
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
                      R.string.xac_nhan_so_dien_thoai.tr(),
                      style: TextStyle(fontSize: 20, color: R.color.textDark),
                    ),
                  ),
                  backgroundColor: R.color.transparent, //No more green
                  elevation: 0.0, //Shadow gone
                )),
          ])),
    );
  }

  submitOtp() async {
    FocusScope.of(context).unfocus();
    try {
      BotToast.showLoading();
      if (widget.type == 'google') {
        await LoginClient().verifyOTP(widget.phone, otpCode);

        final authen = await widget.googleAccount!.authentication;
        await LoginClient().login({
          "client_id": Const.CLIENT_ID,
          "client_secret": Const.CLIENT_SECRET,
          "grant_type": "external",
          "external_token": authen.accessToken,
          "provider": 'Google'
        });

        final result = await LoginClient().createPatient(widget.userInfo);
        if (result == true) {
          final user = await UserClient().fetchUser();
          BotToast.closeAllLoading();
          Navigator.pushReplacementNamed(context, NavigatorName.rules);
        }
      } else if (widget.type == 'facebook') {
        await LoginClient().verifyOTP(widget.phone, otpCode);
        await LoginClient().login({
          "client_id": Const.CLIENT_ID,
          "client_secret": Const.CLIENT_SECRET,
          "grant_type": "external",
          "external_token": widget.facebookAccount!.accessToken?.token,
          "provider": 'Facebook'
        });
        final result = await LoginClient().createPatient(widget.userInfo);
        if (result == true) {
          await TrackingManager.analytics.logEvent(
            name: 'sign_up',
            parameters: {
              "screen_name": 'otp_verify',
            },
          );
          final user = await UserClient().fetchUser();
          BotToast.closeAllLoading();
          Navigator.pushReplacementNamed(context, NavigatorName.rules);
        }
        BotToast.closeAllLoading();
      } else if (widget.type == 'apple') {
        await LoginClient().verifyOTP(widget.phone, otpCode);
        await LoginClient().login({
          "client_id": Const.CLIENT_ID,
          "client_secret": Const.CLIENT_SECRET,
          "grant_type": "external",
          "external_token": widget.appleAccount?.identityToken,
          "provider": 'Apple'
        });
        final result = await LoginClient().createPatient(widget.userInfo);
        if (result == true) {
          await TrackingManager.analytics.logEvent(
            name: 'sign_up',
            parameters: {
              "screen_name": 'otp_verify',
            },
          );
          final user = await UserClient().fetchUser();
          BotToast.closeAllLoading();
          Navigator.pushReplacementNamed(context, NavigatorName.rules);
        }
      } else if (widget.type == 'linked_google') {
        final result = await LoginClient().linkedAccount({
          'providerName': 'Google',
          'providerKey': widget.googleAccount!.id,
          'phoneNumber': widget.phone,
          'email': widget.googleAccount!.email,
          'token': otpCode
        });
        final refreshToken = await AppSettings.getRefreshToken();
        await LoginClient().login({
          "client_id": Const.CLIENT_ID,
          "client_secret": Const.CLIENT_SECRET,
          "grant_type": "refresh_token",
          "refresh_token": refreshToken
        });
        await UserClient().fetchUser();
        BotToast.closeAllLoading();
        Navigator.pop(context);
      } else if (widget.type == 'linked_facebook') {
        final result = await LoginClient().linkedAccount({
          'providerName': 'Facebook',
          'providerKey': widget.facebookAccount!.accessToken?.userId,
          'phoneNumber': widget.phone,
          'token': otpCode
        });
        final token = await AppSettings.getToken();
        await LoginClient().login({
          "client_id": Const.CLIENT_ID,
          "client_secret": Const.CLIENT_SECRET,
          "grant_type": "refresh_token",
          "refresh_token": token
        });
        await UserClient().fetchUser();
        BotToast.closeAllLoading();
        Navigator.pop(context);
      } else if (widget.type == 'forgot_password') {
        final result =
            await LoginClient().verifyOTPRecover(widget.phone, otpCode);
        print(result);
        Navigator.pushReplacementNamed(context, NavigatorName.new_password,
            arguments: {'phone': widget.phone, 'token': otpCode});
        BotToast.closeAllLoading();
      } else {
        final result = await LoginClient().verifyOTP(widget.phone, otpCode);
        BotToast.closeAllLoading();
        await TrackingManager.analytics.logEvent(
          name: 'sign_up',
          parameters: {
            "screen_name": 'otp_verify',
          },
        );
        if (result) {
          Navigator.pushReplacementNamed(context, NavigatorName.register,
              arguments: {
                'phone': widget.phone,
                'referalCode': widget.referalCode,
              });
        }
        // Remove

        // Navigator.pushReplacementNamed(context, NavigatorName.update_info,
        //     arguments: {'type': widget.type});
        // BotToast.closeAllLoading();
        // getToken();
      }
    } catch (e, _) {
      setState(() {
        error = true;
      });
      BotToast.closeAllLoading();
      // if (e is Error) {
      //   Message.showToastMessage(context, e.message);
      // } else {
      //   Message.showToastMessage(context, e.toString());
      // }
    }
  }

  // getToken() async {
  //   if (widget.type != 'register') {
  //     Navigator.pushReplacementNamed(context, NavigatorName.update_info,
  //         arguments: {
  //           'type': widget.type,
  //           'googleAccount': widget.googleAccount,
  //           'appleAccount': widget.appleAccount,
  //         });
  //   } else {
  //     // BotToast.showLoading();
  //     final result = await LoginClient().login({
  //       "client_id": Const.CLIENT_ID,
  //       "client_secret": Const.CLIENT_SECRET,
  //       "grant_type": "phone_number_password",
  //       "password": widget.password,
  //       "phone_number": widget.phone
  //     });
  //     // BotToast.closeAllLoading();
  //     Navigator.pushReplacementNamed(context, NavigatorName.update_info,
  //         arguments: {
  //           'type': 'phone',
  //           'referalCode': widget.referalCode,
  //         });
  //   }
  // }

  resendOTP() async {
    await TrackingManager.analytics.logEvent(
      name: 'cta_button_clicked',
      parameters: {
        "screen_name": 'otp_verify',
        'cta_button_name': 'cta_otp_verify_resend',
      },
    );
    if (timeCount > 0 || otpCount == null) {
      return;
    }
    if (otpCount! <= 0) {
      _showDialogError();
      return;
    }
    otpCount = otpCount! - 1;
    startTimer();
    BotToast.showLoading();
    try {
      if (widget.type == 'google') {
        final result = await LoginClient().registerWithSocial({
          'providerName': 'Google',
          'providerKey': widget.googleAccount!.id,
          'phoneNumber': widget.phone
        });
        otpCount = result.remainingRequestCount;
        otpTemp = result.token;
      } else if (widget.type == 'facebook') {
        final result = await LoginClient().registerWithSocial({
          'providerName': 'Facebook',
          'providerKey': widget.facebookAccount!.accessToken?.userId,
          'phoneNumber': widget.phone
        });
        otpCount = result.remainingRequestCount;
        otpTemp = result.token;
      } else if (widget.type == 'linked_google') {
        final result = await LoginClient().linkedAccountOTP({
          'providerName': 'Google',
          'providerKey': widget.googleAccount!.id,
          'phoneNumber': widget.phone,
          'email': widget.googleAccount!.email
        });
        otpCount = result.remainingRequestCount;
        otpTemp = result.token;
      } else if (widget.type == 'linked_facebook') {
        final result = await LoginClient().linkedAccountOTP({
          'providerName': 'Facebook',
          'providerKey': widget.facebookAccount!.accessToken?.userId,
          'phoneNumber': widget.phone
        });
        otpCount = result.remainingRequestCount;
        otpTemp = result.token;
      } else if (widget.type == 'forgot_password') {
        final result = await LoginClient()
            .requestOTPRecover({"phoneNumber": widget.phone});
        otpCount = result.remainingRequestCount;
        otpTemp = result.token;
      } else {
        final result = await LoginClient().requestOTP(
            {"password": widget.password, "phoneNumber": widget.phone});
        otpCount = result.remainingRequestCount;
        otpTemp = result.token;
      }
      setState(() {});
      BotToast.closeAllLoading();
      _showDialogSuccess();
    } catch (e, _) {
      BotToast.closeAllLoading();
      // if (e is Error) {
      //   Message.showToastMessage(context, e.message);
      // } else {
      //   Message.showToastMessage(context, e.toString());
      // }
    }
  }

  _showDialogSuccess() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            content: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(R.drawable.ic_check_success, width: 64, height: 64),
              Text(R.string.da_gui_lai_otp.tr(), textAlign: TextAlign.center)
            ],
          ),
        ));
      },
    );
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
                        text: widget.phone,
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
