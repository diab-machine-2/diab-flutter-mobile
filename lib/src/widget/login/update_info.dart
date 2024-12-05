import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/app_setting/firebase_tracking/firebase_tracking.dart';
import 'package:medical/src/modal/base/referral_code_temp.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/user/category_item_user_model.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/service/zalo_service.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/length_limit_text_field.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/text_field_custom.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/login/routing.dart';
import 'package:medical/src/widget/login/rules.dart';
import 'package:medical/src/widgets/custom_checkbox_widget.dart';
import 'package:medical/src/widgets/radio_custom.dart';
import 'package:medical/src/widgets/spacing_row.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../repo/user/user_client.dart';
import '../../widgets/CalendarPicker/custom_date_picker2.dart';

class UpdateInfoController extends StatefulWidget {
  final String? type;
  final GoogleSignInAccount? googleAccount;
  final FacebookLoginResult? facebookAccount;
  final ZaloLoginResult? zaloAccount;
  final AuthorizationCredentialAppleID? appleAccount;
  final dynamic userInfo;
  final String? referalCode;
  final String? phone;
  final List<CategoryItemUserModel>? diabeteStates;

  UpdateInfoController(
      {this.type,
      this.googleAccount,
      this.facebookAccount,
      this.appleAccount,
      this.userInfo,
      this.referalCode,
      this.phone,
      this.diabeteStates,
      this.zaloAccount});
  @override
  _UpdateInfoControllerState createState() => _UpdateInfoControllerState();
}

class _UpdateInfoControllerState extends State<UpdateInfoController> {
  FocusNode nameFocusNode = FocusNode();

  final GlobalKey<TextFieldCustomState> phoneKey = GlobalKey();
  TextEditingController nameController = TextEditingController();

  DateTime? selectedDate;
  int? _choosenGender;
  bool isAcceptPolicy = true;

  void initState() {
    super.initState();
    if (widget.type == 'phone') {
      nameController.text = '';
    } else if (widget.type == 'google') {
      nameController.text = widget.googleAccount?.displayName ?? '';
    } else if (widget.type == 'facebook') {
      nameController.text = widget.userInfo['name'] ?? '';
    } else if (widget.type == 'apple') {
      nameController.text =
          '${widget.appleAccount?.familyName ?? ''} ${widget.appleAccount?.givenName ?? ''}';
    } else if (widget.type == 'zalo') {
      nameController.text = widget.zaloAccount?.name ?? '';
    }
    check();
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
        screenName: "register_information",
        screenClass: "UpdateInfoController");
    AppSettings.currentScreenName = 'register_information';
    nameFocusNode.addListener(() async {
      String nameValue = nameController.text;
      if (nameFocusNode.hasFocus) {
        await TrackingManager.analytics.logEvent(
          name: 'text_field_focus',
          parameters: {
            "screen_name": 'register_information',
            'text_field_name': 'text_field_register_infor_name',
            'object_value': nameValue
          },
        );
      } else {
        String validateState = 'pass';
        String errorMessage = 'none';
        if (nameValue.isEmpty) {
          validateState = 'fail';
          errorMessage = R.string.ban_chua_nhap_ho_ten.tr();
        }
        await TrackingManager.analytics.logEvent(
          name: 'text_field_input',
          parameters: {
            "screen_name": 'register_information',
            'text_field_name': 'text_field_register_infor_name',
            'object_value': nameValue,
            'validate_state': validateState,
            'error_message': errorMessage,
          },
        );
      }
    });
  }

  check() async {
    ReferralCodeTemp? referralCodeData = await AppStorages.getReferralCode();
    if (referralCodeData != null) {
      final _ = referralCodeData.referralCode;
    }
  }

  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    check();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(R.drawable.bg_splash),
              fit: BoxFit.fill,
            ),
          ),
          child: SafeArea(
            child: SpacingColumn(
              spacing: 25,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          'Cập nhật thông tin hồ sơ',
                          style: TextStyle(
                            fontSize: 20,
                            color: R.color.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 15.h),
                        // Align(
                        //   alignment: Alignment.topLeft,
                        //   child: Text(
                        //       widget.type == 'phone'
                        //           ? R.string.hay_de_diab_thau_hieu_ban_hon.tr()
                        //           : '${R.string.chao_mung.tr()} ${widget.type == 'google' ? widget.googleAccount!.displayName!.split(' ').last : widget.type == 'facebook' ? widget.userInfo['name'].split(' ').last : widget.appleAccount?.givenName ?? R.string.ban.tr()},\n${R.string.hay_de_diab_thau_hieu_ban_hon_single_line.tr()}',
                        //       style: TextStyle(
                        //           height: 1.5,
                        //           color: R.color.mainColor,
                        //           fontSize: 20,
                        //           fontWeight: FontWeight.w600)),
                        // ),
                        // SizedBox(height: 20.h),
                        Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    Text(R.string.ho_va_ten.tr(),
                                        style:
                                            TextStyle(color: R.color.textDark)),
                                    Text(" *",
                                        style: TextStyle(color: R.color.red))
                                  ],
                                )),
                            SizedBox(height: 12),
                            Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: R.color.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.only(left: 16, right: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 30,
                                          child: TextField(
                                            focusNode: nameFocusNode,
                                            autofocus: true,
                                            maxLength: 50,
                                            inputFormatters: [
                                              LengthLimitingTextFieldFormatterFixed(
                                                  50),
                                            ],
                                            controller: nameController,
                                            style: TextStyle(
                                                color: R.color.color0xff232527),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.only(top: -16),
                                              hintText:
                                                  R.string.nhap_ho_ten.tr(),
                                              counterText: '',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    Text(R.string.ngay_sinh.tr(),
                                        style:
                                            TextStyle(color: R.color.textDark)),
                                    Text(" *",
                                        style: TextStyle(color: R.color.red))
                                  ],
                                )),
                            SizedBox(height: 12),
                            GestureDetector(
                              onTap: () async {
                                nameFocusNode.unfocus();
                                FirebaseTracking.onClickBirthDay(selectedDate);
                                _showDatePicker(context);
                              },
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: R.color.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.all(12),
                                child: Container(
                                  color: R.color.transparent,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            selectedDate != null
                                                ? convertToUTC(
                                                    selectedDate!
                                                            .millisecondsSinceEpoch ~/
                                                        1000,
                                                    'dd/MM/yyyy')
                                                : R.string.chon_ngay_sinh.tr(),
                                            style: TextStyle(
                                                color: R.color.textDark,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400)),
                                        Image.asset(R.drawable.ic_calendar,
                                            width: 24, height: 24),
                                      ]),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        SpacingRow(
                          spacing: 25,
                          children: [
                            Row(
                              children: [
                                Text(R.string.gioi_tinh.tr(),
                                    style: TextStyle(color: R.color.textDark)),
                                Text(" *", style: TextStyle(color: R.color.red))
                              ],
                            ),
                            Expanded(
                              child: SpacingRow(
                                spacing: 45,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _choosenGender = 1;
                                      });
                                    },
                                    child: SpacingRow(
                                      spacing: 15,
                                      children: [
                                        RadioCustom(
                                            isSelected: _choosenGender == 1),
                                        Text(
                                          R.string.nam.tr(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: R.color.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _choosenGender = 2;
                                      });
                                    },
                                    child: SpacingRow(
                                      spacing: 15,
                                      children: [
                                        RadioCustom(
                                            isSelected: _choosenGender == 2),
                                        Text(
                                          R.string.nu.tr(),
                                          style: TextStyle(
                                            color: R.color.textDark,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: SpacingColumn(
                    spacing: 25,
                    children: [
                      // Bằng cách Đăng nhập, bạn đã đồng ý với Điều khoản sử dụng · Quy định bảo mật
                      CustomCheckboxWidget(
                        isChecked: isAcceptPolicy,
                        child: Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: 'Bằng cách Đăng nhập, bạn đã đồng ý với ',
                              style: TextStyle(
                                color: R.color.textDark,
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => RulesController.showModal(
                                          context,
                                          onConfirm: () {
                                            setState(() {
                                              isAcceptPolicy = true;
                                            });
                                          },
                                        ),
                                  text: 'Điều khoản sử dụng · Quy định bảo mật',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline),
                                )
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            isAcceptPolicy = !isAcceptPolicy;
                          });
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          if (isAcceptPolicy) _submitData();
                        },
                        child: SafeArea(
                          top: false,
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: isAcceptPolicy ? null : Color(0xFFF4F5F6),
                              gradient: isAcceptPolicy
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                          R.color.greenGradientTop,
                                          R.color.greenGradientBottom
                                        ])
                                  : null,
                              borderRadius: BorderRadius.circular(200),
                            ),
                            child: Center(
                              child: Text(
                                'Lưu & Đăng nhập',
                                style: TextStyle(
                                  color: isAcceptPolicy
                                      ? R.color.white
                                      : Color(0xFFB1B5C3),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    CustomCalendarDatePicker2.showDatePicker(context,
        maxTime: DateTime.now(),
        minTime: DateTime.parse('1900-01-01 00:00:00.000Z'),
        showTitleActions: true,
        onChanged: (date) {}, onConfirm: (date) async {
      FirebaseTracking.onSelectBirthDay(date);
      setState(() {
        selectedDate = date;
      });
    },
        currentTime: selectedDate == null
            ? DateTime.parse('1970-01-01 00:00:00.000Z')
            : selectedDate,
        locale: LocaleType.vi);
  }

  _submitData() async {
    final name = nameController.text;

    if (name.isEmpty) {
      Message.showToastMessage(context, R.string.ban_chua_nhap_ho_ten.tr());
      return;
    }
    if (selectedDate == null) {
      Message.showToastMessage(context, R.string.ban_chua_chon_ngay_sinh.tr());
      return;
    }

    if (_choosenGender == null) {
      Message.showToastMessage(context, R.string.ban_chua_chon_gioi_tinh.tr());
      return;
    }
    BotToast.showLoading();

    try {
      Map<String, dynamic> params = {
        'phoneNumber': widget.phone,
        'fullName': name,
        'dateOfBirth': selectedDate!.millisecondsSinceEpoch == 0
            ? '0'
            : (selectedDate!.millisecondsSinceEpoch ~/ 1000).toString(),
        'gender': _choosenGender.toString(),
        'referalCode': widget.referalCode ??
            BranchioLinkConfig.instance.referalCode // initialize
      };

      ReferralCodeTemp? referralCodeData = await AppStorages.getReferralCode();
      if (referralCodeData != null) {
        params['referalCode'] = referralCodeData.referralCode;
      }

      if (widget.type == 'zalo') {
        params['username'] = widget.zaloAccount?.id;
        await LoginClient().registerWithSocial({
          'providerName': 'Zalo',
          'providerKey': widget.zaloAccount?.id,
          'IsHasPatient': false
        });
        await LoginClient().login({
          "client_id": Const.CLIENT_ID,
          "client_secret": Const.CLIENT_SECRET,
          "grant_type": "external",
          "external_token": widget.zaloAccount?.accessToken,
          "provider": 'Zalo',
          "zalo_id": widget.zaloAccount?.id
        });
      } else if (widget.type == 'google') {
        params['username'] = widget.googleAccount!.id;
        if (widget.googleAccount?.email != null) {
          params['email'] = widget.googleAccount!.email;
          params['googleEmail'] = widget.googleAccount!.email;
        }
        await LoginClient().registerWithSocial({
          'providerName': 'Google',
          'providerKey': widget.googleAccount!.id,
          'IsHasPatient': false
        });
        final authen = await widget.googleAccount!.authentication;
        await LoginClient().login({
          "client_id": Const.CLIENT_ID,
          "client_secret": Const.CLIENT_SECRET,
          "grant_type": "external",
          "external_token": authen.accessToken,
          "provider": 'Google'
        });
      } else if (widget.type == 'facebook') {
        params['username'] = widget.facebookAccount!.accessToken?.userId;
        await LoginClient().registerWithSocial({
          'providerName': 'Facebook',
          'providerKey': widget.facebookAccount!.accessToken?.userId,
          'IsHasPatient': false
        });
        await LoginClient().login({
          "client_id": Const.CLIENT_ID,
          "client_secret": Const.CLIENT_SECRET,
          "grant_type": "external",
          "external_token": widget.facebookAccount!.accessToken?.token,
          "provider": 'Facebook'
        });
      } else if (widget.type == 'apple') {
        params['username'] = widget.appleAccount?.userIdentifier;
        if (widget.appleAccount?.email != null) {
          params['email'] = widget.appleAccount!.email!;
          params['googleEmail'] = widget.appleAccount!.email!;
        }
        await LoginClient().registerWithSocial({
          'providerName': 'Apple',
          'providerKey': widget.appleAccount?.userIdentifier,
          'IsHasPatient': false
        });
        await LoginClient().login({
          "client_id": Const.CLIENT_ID,
          "client_secret": Const.CLIENT_SECRET,
          "grant_type": "external",
          "external_token": widget.appleAccount?.identityToken,
          "provider": 'Apple'
        });
      }

      final result = await LoginClient().createPatient(params);
      if (result == true) {
        await TrackingManager.analytics.logEvent(
          name: 'sign_up',
          parameters: {
            "screen_name": 'sign_up',
            'method': widget.type?.toLowerCase(),
          },
        );
        await UserClient().fetchUser();
        LoginRouting().navigateToHome(context);
      }
      BotToast.closeAllLoading();
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        if (e.code == 'USER004') {
          phoneKey.currentState!
              .validate(R.string.so_dien_thoai_da_ton_tai_trong_he_thong.tr());
        } else {
          Message.showToastMessage(context, e.message);
        }
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }
}
