import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ConfirmPhoneNumberVerifyOTPPage extends StatefulWidget {
  final String phone;
  final bool isPhoneNumberExist;

  const ConfirmPhoneNumberVerifyOTPPage({
    Key? key,
    required this.phone,
    required this.isPhoneNumberExist,
  }) : super(key: key);

  @override
  _ConfirmPhoneNumberVerifyOTPPageState createState() =>
      _ConfirmPhoneNumberVerifyOTPPageState();
}

class _ConfirmPhoneNumberVerifyOTPPageState
    extends State<ConfirmPhoneNumberVerifyOTPPage> {
  String otpCode = '';
  bool error = false;
  int timeCount = 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
        screenName: "confirm_phone_verify_otp",
        screenClass: "ConfirmPhoneNumberVerifyOTPPage");
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
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 140),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(children: [
                    // Illustration
                    Image.asset(
                      R.drawable.img_check_phone,
                      width: 90,
                      height: 74,
                    ),
                    SizedBox(height: 20),

                    // Instructions
                    Text(
                      R.string.nhap_4_so_trong_tin_nhan.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: R.color.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),

                    // Phone Number
                    Text(
                      '+84 ${widget.phone}',
                      style: TextStyle(
                        fontFamily: 'Viga',
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: R.color.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),

                    // OTP Input Fields
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
                          fontWeight: FontWeight.w400,
                        ),
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(8),
                          fieldHeight: 44,
                          fieldWidth: 44,
                          activeFillColor: R.color.white,
                          inactiveFillColor: R.color.white,
                          selectedFillColor: R.color.white,
                          activeColor:
                              error ? R.color.red : R.color.notActiveGreen,
                          selectedColor: R.color.mainColor,
                          disabledColor:
                              error ? R.color.red : R.color.notActiveGreen,
                          inactiveColor:
                              error ? R.color.red : R.color.notActiveGreen,
                        ),
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
                  ]),

                  // Buttons
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        // Resend Button
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
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${R.string.gui_lai_ma.tr()} (Còn ${timeCount}s)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: R.color.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),

                        // Separator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 1,
                              width: 36,
                              color: R.color.color0xffD6D8E0,
                            ),
                            SizedBox(width: 8),
                            Text(
                              R.string.or.tr(),
                              style: TextStyle(color: R.color.color0xff232527),
                            ),
                            SizedBox(width: 8),
                            Container(
                              height: 1,
                              width: 36,
                              color: R.color.color0xffD6D8E0,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),

                        // Change Phone Number Button
                        GestureDetector(
                          onTap: () async {
                            await TrackingManager.trackEvent(
                              'verify_change_phone',
                              'confirm_phone_verify_otp',
                            );
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 48,
                            width: 227,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(200),
                              border: Border.all(
                                  color: R.color.mainColor, width: 1),
                            ),
                            child: Center(
                              child: Text(
                                R.string.thay_doi_so_dien_thoai.tr(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: R.color.mainColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // App Bar
          Positioned(
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
                },
              ),
              title: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  R.string.cap_nhat_so_dien_thoai.tr(),
                  style: TextStyle(fontSize: 20, color: R.color.textDark),
                ),
              ),
              backgroundColor: R.color.transparent,
              elevation: 0.0,
            ),
          ),
        ]),
      ),
    );
  }

  submitOtp() async {
    FocusScope.of(context).unfocus();
    try {
      BotToast.showLoading();

      // Verify OTP
      final result = await LoginClient().verifyOTP(widget.phone, otpCode);

      BotToast.closeAllLoading();

      if (result) {
        await TrackingManager.analytics
            .logEvent(name: 'verify_otp', parameters: {
          "screen_name": 'confirm_phone_verify_otp',
          'status': 'success',
        });

        if (widget.isPhoneNumberExist) {
          // Show sync account dialog
          _showSyncAccountDialog();
        } else {
          // Update phone number
          await _updatePhoneNumber();
        }
      }
    } catch (e, _) {
      await TrackingManager.trackEvent('verify_otp', 'confirm_phone_verify_otp',
          params: {
            'status': 'fail',
          });
      setState(() {
        error = true;
      });
      BotToast.closeAllLoading();
    }
  }

  Future<void> _updatePhoneNumber() async {
    try {
      BotToast.showLoading();

      final userInfo = AppSettings.userInfo!;
      await UserClient().updateUserInfo(
        userInfo.id,
        userInfo.copyWith(phoneNumber: widget.phone),
      );

      await UserClient().fetchUser();

      BotToast.closeAllLoading();

      // Notify back to home
      Observable.instance
          .notifyObservers([], notifyName: "subscription_back_to_home");

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      BotToast.closeAllLoading();
      Message.showToastMessage(context, e.toString());
    }
  }

  void _showSyncAccountDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          content: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(R.drawable.sync_account_theme,
                    width: 120, height: 120),
                const SizedBox(height: 8),
                Text(
                  R.string.ban_muon_dong_bo_so_dien_thoai.tr(),
                  style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        child: Container(
                          height: 43,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(200),
                            color: R.color.grayBorder,
                          ),
                          child: Center(
                            child: Text(
                              R.string.cancel.tr(),
                              style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _syncAccount();
                        },
                        child: Container(
                          height: 43,
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
                              R.string.confirm.tr(),
                              style: TextStyle(
                                color: R.color.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _syncAccount() async {
    try {
     Navigator.pushNamed(context, NavigatorName.sync_screen);

      // // Notify back to home
      // Observable.instance
      //     .notifyObservers([], notifyName: "subscription_back_to_home");

      // Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      BotToast.closeAllLoading();
      Message.showToastMessage(context, e.toString());
    }
  }

  resendOTP() async {
    await TrackingManager.trackEvent(
      'verify_resend',
      'confirm_phone_verify_otp',
    );
    if (timeCount > 0) {
      return;
    }
    startTimer();
    BotToast.showLoading();
    try {
      // Call resend OTP API
      await LoginClient().submitRegister(widget.phone);
      BotToast.closeAllLoading();
      _showDialogSuccess();
    } catch (e, _) {
      BotToast.closeAllLoading();
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
                Text(
                  R.string.da_gui_lai_otp.tr(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
