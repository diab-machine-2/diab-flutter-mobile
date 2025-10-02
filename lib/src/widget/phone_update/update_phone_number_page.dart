import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/text_field_custom.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

class UpdatePhoneNumberPage extends StatefulWidget {
  const UpdatePhoneNumberPage({Key? key}) : super(key: key);

  @override
  _UpdatePhoneNumberPageState createState() => _UpdatePhoneNumberPageState();
}

class _UpdatePhoneNumberPageState extends State<UpdatePhoneNumberPage> {
  FocusNode phoneFocusNode = FocusNode();
  final GlobalKey<TextFieldCustomState> phoneKey = GlobalKey();
  String phone = '';
  bool isPhoneValid = false;

  @override
  void initState() {
    super.initState();
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
        screenName: "update_phone_number",
        screenClass: "UpdatePhoneNumberPage");
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
            child: Column(
              children: [
                // App Bar
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back,
                          size: 24, color: R.color.textDark),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      R.string.cap_nhat_so_dien_thoai.tr(),
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Illustration
                Image.asset(
                  R.drawable.ic_phone_illustration,
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 16),

                // Phone Number Input
                TextFieldCustom(
                  key: phoneKey,
                  focusNode: phoneFocusNode,
                  autoFocus: true,
                  title: R.string.so_dien_thoai.tr(),
                  placeholder: R.string.nhap_so_dien_thoai.tr(),
                  onChanged: (value) {
                    phone = value;
                    validatePhoneNumber();
                  },
                ),
                const SizedBox(height: 32),

                // Continue Button
                GestureDetector(
                  onTap: () {
                    if (isPhoneValid) {
                      checkExistPhoneNumber();
                    }
                  },
                  child: Container(
                    height: 52,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          isPhoneValid ? R.color.mainColor : R.color.grayBorder,
                      borderRadius: BorderRadius.circular(200),
                      gradient: isPhoneValid
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.centerRight,
                              colors: [
                                R.color.greenGradientTop,
                                R.color.greenGradientBottom
                              ],
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        R.string.tiep_tuc.tr(),
                        style: TextStyle(
                          color: isPhoneValid
                              ? R.color.white
                              : R.color.captionColorGray,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void validatePhoneNumber() {
    setState(() {
      isPhoneValid = phone.length == 9 || phone.length == 10;
    });
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

      // Call submitRegister to send OTP before navigating
      await LoginClient().submitRegister(phone, isSyncAccount: isExist);

      BotToast.closeAllLoading();

      Navigator.pushNamed(context, NavigatorName.confirm_phone_verify_otp,
          arguments: {
            'phone': phone,
            'isPhoneNumberExist': isExist,
          });
    } catch (e) {
      BotToast.closeAllLoading();
      Message.showToastMessage(context, e.toString());
    }
  }
}
