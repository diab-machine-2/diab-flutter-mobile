import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/utils/length_limit_text_field.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/HbA1C/widget/CalendarPicker/custom_date_picker2.dart';
import 'package:medical/src/widget/HbA1C/widget/CalendarPicker/custom_year_picker.dart';
import 'package:medical/src/widget/base/text_field_custom.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/profile/widgets/diabetes_status_picker.dart';
import 'package:medical/src/widget/profile/widgets/gender_picker.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class UpdateInfoController extends StatefulWidget {
  final String? type;
  final GoogleSignInAccount? googleAccount;
  final FacebookLoginResult? facebookAccount;
  final AuthorizationCredentialAppleID? appleAccount;
  final dynamic userInfo;
  UpdateInfoController(
      {this.type,
      this.googleAccount,
      this.facebookAccount,
      this.appleAccount,
      this.userInfo});
  @override
  _UpdateInfoControllerState createState() => _UpdateInfoControllerState();
}

class _UpdateInfoControllerState extends State<UpdateInfoController> {
  final GlobalKey<TextFieldCustomState> phoneKey = GlobalKey();
  TextEditingController nameController = TextEditingController();
  FocusNode nameFocus = FocusNode();

  String phone = '';
  DateTime? selectedDate;
  DateTime? selectedYear;
  dynamic diabetesStatus;
  int? _choosenGender;
  void initState() {
    super.initState();
    nameController.text = widget.type == 'phone'
        ? ''
        : (widget.type == 'google'
            ? (widget.googleAccount!.displayName ?? '')
            : widget.type == 'facebook'
                ? widget.userInfo['name']
                : widget.appleAccount!.givenName!);
  }

  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(R.drawable.bg_splash),
                    fit: BoxFit.fill,
                  )),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      //physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 16),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      shrinkWrap: true,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                                alignment: Alignment.topRight,
                                child: Image.asset(R.drawable.img_parent,
                                    height: 175)),
                            SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                    widget.type == 'phone'
                                        ? R.string.hay_de_diab_thau_hieu_ban_hon.tr()
                                        : '${R.string.chao_mung.tr()} ${widget.type == 'google' ? widget.googleAccount!.displayName!.split(' ').last : widget.type == 'facebook' ? widget.userInfo['name'].split(' ').last : widget.appleAccount!.givenName ?? R.string.ban.tr()},\n${R.string.hay_de_diab_thau_hieu_ban_hon_single_line.tr()}',
                                    style: TextStyle(
                                        height: 1.5,
                                        color: R.color.mainColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        widget.type == 'phone'
                                            ? SizedBox()
                                            : Padding(
                                                padding:
                                                    EdgeInsets.only(bottom: 24),
                                                child: TextFieldCustom(
                                                    key: phoneKey,
                                                    title: R.string.so_dien_thoai.tr(),
                                                    placeholder:
                                                        R.string.nhap_so_dien_thoai.tr(),
                                                    autoFocus: false,
                                                    showStar: true,
                                                    onChanged: (value) {
                                                      phone = value;
                                                    }),
                                              ),
                                        Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                Text(R.string.ho_va_ten.tr(),
                                                    style: TextStyle(
                                                        color: R.color.textDark)),
                                                Text(" *",
                                                    style: TextStyle(
                                                        color: R.color.red))
                                              ],
                                            )),
                                        SizedBox(height: 12),
                                        Container(
                                          height: 52,
                                          decoration: BoxDecoration(
                                            color: R.color.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: EdgeInsets.only(
                                              left: 16, right: 16),
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
                                                        focusNode: nameFocus,
                                                        maxLength: 50,
                                                        inputFormatters: [
                                                          LengthLimitingTextFieldFormatterFixed(
                                                              50),
                                                        ],
                                                        controller:
                                                            nameController,
                                                        style: TextStyle(
                                                            color: R.color.color0xff232527),
                                                        decoration: InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    top: -16),
                                                            hintText:
                                                                R.string.nhap_ho_ten.tr(),
                                                            counterText: '',
                                                            hintStyle: TextStyle(
                                                                color: R.color.color0xff232527)),
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
                                                    style: TextStyle(
                                                        color: R.color.textDark)),
                                                Text(" *",
                                                    style: TextStyle(
                                                        color: R.color.red))
                                              ],
                                            )),
                                        SizedBox(height: 12),
                                        GestureDetector(
                                          onTap: () {
                                            nameFocus.unfocus();
                                            showDatePicker(context);
                                          },
                                          child: Container(
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: R.color.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: EdgeInsets.all(12),
                                            child: Container(
                                              color: R.color.transparent,
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
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
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400)),
                                                    Image.asset(
                                                        R.drawable.ic_calendar,
                                                        width: 24,
                                                        height: 24),
                                                  ]),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 24),
                                    Column(
                                      children: [
                                        Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                Text(R.string.gioi_tinh.tr(),
                                                    style: TextStyle(
                                                        color: R.color.textDark)),
                                                Text(" *",
                                                    style: TextStyle(
                                                        color: R.color.red))
                                              ],
                                            )),
                                        SizedBox(height: 12),
                                        GestureDetector(
                                          onTap: () {
                                            nameFocus.unfocus();
                                            _showDialogUpdateGender();
                                          },
                                          child: Container(
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: R.color.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: EdgeInsets.only(
                                                left: 16, right: 16),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      _choosenGender == null
                                                          ? R.string.chon_gioi_tinh.tr()
                                                          : _choosenGender == 1
                                                              ? R.string.nam.tr()
                                                              : R.string.nu.tr(),
                                                      style: TextStyle(
                                                          color: R.color.textDark,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w400)),
                                                  Icon(
                                                    Icons
                                                        .keyboard_arrow_down_rounded,
                                                    color: R.color.mainColor,
                                                    size: 24,
                                                  ),
                                                ]),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 24),
                                    Column(
                                      children: [
                                        Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                Text(
                                                    R.string.tinh_trang_benh_tieu_duong.tr(),
                                                    style: TextStyle(
                                                        color: R.color.textDark)),
                                                Text(" *",
                                                    style: TextStyle(
                                                        color: R.color.red))
                                              ],
                                            )),
                                        SizedBox(height: 12),
                                        GestureDetector(
                                          onTap: () {
                                            nameFocus.unfocus();
                                            _showDialogUpdateDiabetesStatus();
                                          },
                                          child: Container(
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: R.color.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: EdgeInsets.only(
                                                left: 16, right: 16),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      diabetesStatus == null
                                                          ? R.string.chon_tinh_trang_benh.tr()
                                                          : diabetesStatus[
                                                              'value'],
                                                      style: TextStyle(
                                                          color: R.color.textDark,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w400)),
                                                  Icon(
                                                    Icons
                                                        .keyboard_arrow_down_rounded,
                                                    color: R.color.mainColor,
                                                    size: 24,
                                                  ),
                                                ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 18),
                                    Column(
                                      children: [
                                        Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                Text(R.string.nam_phat_hien_benh.tr(),
                                                    style: TextStyle(
                                                        color: R.color.textDark)),
                                                Text(" *",
                                                    style: TextStyle(
                                                        color: R.color.red))
                                              ],
                                            )),
                                        SizedBox(height: 12),
                                        GestureDetector(
                                          onTap: () {
                                            nameFocus.unfocus();
                                            showYearPicker(context);
                                          },
                                          child: Container(
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: R.color.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: EdgeInsets.only(
                                                left: 16, right: 16),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      selectedYear != null
                                                          ? convertToUTC(
                                                              selectedYear!
                                                                      .millisecondsSinceEpoch ~/
                                                                  1000,
                                                              'yyyy')
                                                          : R.string.chon_nam.tr(),
                                                      style: TextStyle(
                                                          color: R.color.textDark,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w400)),
                                                  Icon(
                                                    Icons
                                                        .keyboard_arrow_down_rounded,
                                                    color: R.color.mainColor,
                                                    size: 24,
                                                  ),
                                                ]),
                                          ),
                                        ),
                                      ],
                                    )
                                  ]),
                            ),
                            SizedBox(height: 24),
                            GestureDetector(
                              onTap: () {
                                _submitData();
                              },
                              child: SafeArea(
                                top: false,
                                child: Container(
                                    height: 48,
                                    width: 195,
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              R.color.greenGradientTop,
                                              R.color.greenGradientBottom
                                            ]),
                                        borderRadius:
                                            BorderRadius.circular(200)),
                                    child: Center(
                                        child: Text(R.string.luu_thong_tin.tr(),
                                            style: TextStyle(
                                                color: R.color.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500)))),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ))),
    );
  }

  _showDialogUpdateDiabetesStatus() {
    final width = MediaQuery.of(context).size.width;
    dynamic status = diabetesStatus;
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
              content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(R.string.loai_benh.tr(),
                    style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                GestureDetector(
                    child: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                    onTap: () {
                      Navigator.pop(context);
                    })
              ]),
              SizedBox(height: 16),
              Container(
                  height: 150,
                  width: width - 36,
                  child: DiabetesStatusPicker(
                    state: status == null ? null : status['key'],
                    onChanged: (data) {
                      status = data;
                    },
                  )),
              Container(
                margin: EdgeInsets.only(top: 16),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            height: 48,
                            width: 119,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                color: R.color.grayBorder),
                            child: Center(
                              child: Text(R.string.cancel.tr(),
                                  style: TextStyle(
                                      color: R.color.textDark,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            )),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            diabetesStatus = status;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 48,
                          width: 119,
                          decoration: BoxDecoration(
                              color: R.color.red,
                              borderRadius: BorderRadius.circular(200),
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    R.color.greenGradientTop,
                                    R.color.greenGradientBottom
                                  ])),
                          child: Center(
                            child: Text(R.string.yes.tr(),
                                style: TextStyle(
                                    color: R.color.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ]),
              ),
            ],
          )),
        );
      },
    );
  }

  _showDialogUpdateGender() {
    final width = MediaQuery.of(context).size.width;
    FixedExtentScrollController controller = FixedExtentScrollController(
        initialItem: _choosenGender == null
            ? 1
            : _choosenGender == 1
                ? 0
                : 1);
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
              content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(R.string.gioi_tinh.tr(),
                    style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                GestureDetector(
                    child: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                    onTap: () {
                      Navigator.pop(context);
                    })
              ]),
              SizedBox(height: 16),
              Container(
                  height: 150,
                  width: width - 36,
                  child: GenderPicker(controller: controller)),
              Container(
                margin: EdgeInsets.only(top: 16),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            height: 48,
                            width: 119,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                color: R.color.grayBorder),
                            child: Center(
                              child: Text(R.string.cancel.tr(),
                                  style: TextStyle(
                                      color: R.color.textDark,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            )),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _choosenGender =
                                controller.selectedItem == 0 ? 1 : 2;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 48,
                          width: 119,
                          decoration: BoxDecoration(
                              color: R.color.red,
                              borderRadius: BorderRadius.circular(200),
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    R.color.greenGradientTop,
                                    R.color.greenGradientBottom
                                  ])),
                          child: Center(
                            child: Text(R.string.yes.tr(),
                                style: TextStyle(
                                    color: R.color.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ]),
              ),
            ],
          )),
        );
      },
    );
  }

  showDatePicker(BuildContext context) {
    CustomCalendarDatePicker2.showDatePicker(context,
        maxTime: DateTime.now(),
        minTime: DateTime.parse('1900-01-01 00:00:00.000Z'),
        showTitleActions: true,
        onChanged: (date) {}, onConfirm: (date) {
      setState(() {
        selectedDate = date;
      });
    },
        currentTime: selectedDate == null
            ? DateTime.parse('1970-01-01 00:00:00.000Z')
            : selectedDate,
        locale: LocaleType.vi);
  }

  showYearPicker(BuildContext context) {
    CustomCalendarYearPicker.showDatePicker(context,
        maxTime: DateTime.now(),
        showTitleActions: true,
        onChanged: (year) {}, onConfirm: (year) {
      setState(() {
        selectedYear = year;
      });
    },
        currentTime: selectedYear == null ? DateTime.now() : selectedYear,
        locale: LocaleType.vi);
  }

  _submitData() async {
    final name = nameController.text;
    if (phone.isEmpty && widget.type != 'phone') {
      phoneKey.currentState!.validate(R.string.ban_chua_nhap_so_dien_thoai.tr());
      return;
    }
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

    if (diabetesStatus == null) {
      Message.showToastMessage(
          context, R.string.ban_chua_chon_tinh_trang_benh_tieu_duong.tr());
      return;
    }

    if (selectedYear == null) {
      Message.showToastMessage(context, R.string.ban_chua_chon_nam_phat_hien_benh.tr());
      return;
    }

    BotToast.showLoading();

    try {
      Map<String, String> params = {
        'fullName': name,
        'dateOfBirth': selectedDate!.millisecondsSinceEpoch == 0
            ? '0'
            : (selectedDate!.millisecondsSinceEpoch ~/ 1000).toString(),
        'gender': _choosenGender.toString(),
        'diabetesStatus': diabetesStatus['key'].toString()
      };
      if (selectedYear != null) {
        params['diabetesDate'] =
            (selectedYear!.millisecondsSinceEpoch ~/ 1000).toString();
      }
      if (phone != null) {
        params['phoneNumber'] = phone;
      }

      if (widget.type == 'google') {
        final result = await LoginClient().registerWithSocial({
          'providerName': 'Google',
          'providerKey': widget.googleAccount!.id,
          'phoneNumber': phone
        });
        Navigator.pushNamed(context, NavigatorName.verify, arguments: {
          'type': 'google',
          'otp': result.token,
          'phone': phone,
          'remainingRequestCount': result.remainingRequestCount,
          'googleAccount': widget.googleAccount,
          'userInfo': params
        });
      } else if (widget.type == 'facebook') {
        final result = await LoginClient().registerWithSocial({
          'providerName': 'Facebook',
          'providerKey': widget.facebookAccount!.accessToken?.userId,
          'phoneNumber': phone
        });
        Navigator.pushNamed(context, NavigatorName.verify, arguments: {
          'type': 'facebook',
          'otp': result.token,
          'phone': phone,
          'remainingRequestCount': result.remainingRequestCount,
          'facebookAccount': widget.facebookAccount,
          'userInfo': params
        });
      } else if (widget.type == 'apple') {
        final result = await LoginClient().registerWithSocial({
          'providerName': 'Apple',
          'providerKey': widget.appleAccount!.userIdentifier,
          'phoneNumber': phone
        });
        Navigator.pushNamed(context, NavigatorName.verify, arguments: {
          'type': 'apple',
          'otp': result.token,
          'phone': phone,
          'remainingRequestCount': result.remainingRequestCount,
          'appleAccount': widget.appleAccount,
          'userInfo': params
        });
      } else {
        final result = await LoginClient().createPatient(params);
        if (result == true) {
          Navigator.pushReplacementNamed(context, NavigatorName.rules);
        }
      }
      BotToast.closeAllLoading();
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        if (e.code == 'USER004') {
          phoneKey.currentState!.validate(
              R.string.so_dien_thoai_da_ton_tai_trong_he_thong.tr());
        } else {
          Message.showToastMessage(context, e.message);
        }
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }
}
