// Create a helper class for phone validation
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class PhoneValidationHelper {
  static const String phonePattern = r'(^(?:[+0]9)?[0-9]{9}|\d{10}$)';

  static bool isValidPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return false;

    final RegExp regExp = RegExp(phonePattern);
    return regExp.hasMatch(phoneNumber) &&
        (phoneNumber.length == 9 || phoneNumber.length == 10);
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
                          Navigator.pop(context, false);
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
}
