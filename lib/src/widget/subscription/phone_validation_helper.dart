// Create a helper class for phone validation
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/text_field_custom.dart';

class PhoneValidationHelper {
  static const String phonePattern = r'(^(?:[+0]9)?[0-9]{9}|\d{10}$)';

  static bool isValidPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('+84')) {
      phoneNumber = '0${phoneNumber.substring(3)}';
    }
    // if (phoneNumber.startsWith('0000')) {
    //   return false;
    // }
    const String pattern = r'(^(?:[+0]9)?[0-9]{9}|\d{10}$)';
    final RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(phoneNumber) &&
        (phoneNumber.length == 9 || phoneNumber.length == 10);
  }

  static Future<String> validatePhoneAndShowDialog(BuildContext context) async {
    var phoneNumber = AppSettings.userInfo?.phoneNumber;

    // Check if phone number is empty or invalid
    if (phoneNumber == null ||
        phoneNumber.isEmpty ||
        !phoneNumber.startsWith('+84') ||
        !isValidPhoneNumber(phoneNumber)) {
      phoneNumber =
          await PhoneValidationHelper.showBottomSheetUpdatePhone(context);
    }

    return phoneNumber;
  }

  static Future<bool> isValidUserPhoneNumber() async {
    var phoneNumber = AppSettings.userInfo?.phoneNumber;

    // Check if phone number is empty or invalid
    if (phoneNumber == null ||
        phoneNumber.isEmpty ||
        !phoneNumber.startsWith('+84') ||
        !isValidPhoneNumber(phoneNumber)) {
      return false;
    }

    return true;
  }

  static Future<String> showDialogUpdatePhone(BuildContext context) async {
    final width = MediaQuery.of(context).size.width;
    final TextEditingController textEditingController = TextEditingController();
    final FocusNode phoneDialogFocusNode = FocusNode();

    textEditingController.text = '';

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(R.string.phone_number.tr(),
                  style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              GestureDetector(
                  child: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                  onTap: () {
                    Navigator.of(context).pop('');
                  })
            ]),
            const SizedBox(height: 16),
            Container(
                height: 54,
                width: width - 36,
                child: TextField(
                    controller: textEditingController,
                    focusNode: phoneDialogFocusNode,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    minLines: 1,
                    maxLines: 1,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                    ],
                    obscureText: false,
                    decoration: InputDecoration(
                      fillColor: R.color.textDark,
                      counterText: '',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: R.color.grayComponentBorder, width: 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: R.color.mainColor, width: 1.0),
                      ),
                      contentPadding:
                          const EdgeInsets.only(top: 0, left: 16, right: 16),
                    ),
                    onChanged: (value) {})),
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context, '');
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
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          String phone = textEditingController.text;
                          if (phone.isEmpty) {
                            Message.showToastMessage(context,
                                R.string.ban_chua_nhap_so_dien_thoai.tr());
                            return;
                          } else {
                            if (!isValidPhoneNumber(phone)) {
                              Message.showToastMessage(
                                  context, R.string.phone_not_valid.tr());
                              return;
                            }

                            // phone = Utils.formatPhoneNumber(phone);

                            Navigator.pop(context, phone);
                          }
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
                            child: Text(
                              R.string.save.tr(),
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
                  ]),
            ),
          ],
        ),
      ),
    );

    return result ?? '';
  }

  // New bottom sheet UI for updating phone number
  static Future<String> showBottomSheetUpdatePhone(BuildContext context) async {
    String phone = '';

    String? result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          final String input = phone.trim();
          final bool hasText = input.isNotEmpty;
          final bool isDigits = RegExp(r'^\d{1,}$').hasMatch(input);
          final bool isValid =
              hasText && isDigits && (input.length == 9 || input.length == 10);

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              top: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      R.string.update_phone_number.tr(),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(''),
                      child: Icon(Icons.close, color: R.color.color0xff5E6566),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      R.drawable.ic_phone_illustration,
                      width: 120,
                      height: 120,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFieldCustom(
                  title: R.string.so_dien_thoai.tr(),
                  placeholder: R.string.nhap_so_dien_thoai.tr(),
                  autoFocus: true,
                  maxLength: 10,
                  onChanged: (value) {
                    // Only digits allowed in this flow
                    phone = value;
                    setState(() {});
                  },
                ),
                const SizedBox(height: 60),
                GestureDetector(
                  onTap: isValid
                      ? () {
                          final String current = phone.trim();
                          if (current.isEmpty) {
                            Message.showToastMessage(context,
                                R.string.ban_chua_nhap_so_dien_thoai.tr());
                            return;
                          }
                          // Format to international +84
                          final formatted = Utils.formatPhoneNumber(current);
                          Navigator.of(ctx).pop(formatted);
                        }
                      : null,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                      gradient: isValid
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.centerRight,
                              colors: [
                                R.color.greenGradientTop,
                                R.color.greenGradientBottom,
                              ],
                            )
                          : null,
                      color: isValid ? null : const Color(0xFFEAEDEE),
                    ),
                    child: Center(
                      child: Text(
                        R.string.confirm.tr(),
                        style: TextStyle(
                          color:
                              isValid ? R.color.white : R.color.color0xff777E90,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        });
      },
    );

    return result ?? '';
  }
}
