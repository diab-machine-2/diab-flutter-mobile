import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class EmailValidate extends StatefulWidget {
  final TextEditingController? controller;
  final Function(String)? completion;
  const EmailValidate({this.controller, this.completion});
  @override
  _EmailValidateState createState() => _EmailValidateState();
}

class _EmailValidateState extends State<EmailValidate> {
  bool showValidate = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return AlertDialog(
        content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(R.string.email.tr(),
              style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
          GestureDetector(
              child: Icon(Icons.close, color: R.color.color0xffBEC0C8),
              onTap: () {
                Navigator.pop(context);
              })
        ]),
        const SizedBox(height: 16),
        Container(
            height: 54,
            width: width - 36,
            child: TextField(
                controller: widget.controller,
                keyboardType: TextInputType.emailAddress,
                minLines: 1,
                maxLines: 1,
                obscureText: false,
                decoration: InputDecoration(
                  counterText: '',
                  fillColor: R.color.textDark,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: R.color.grayComponentBorder, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: R.color.mainColor, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.only(top: 0, left: 16, right: 16),
                  hintText: R.string.enter_your_email.tr(),
                ),
                onChanged: (email) {
                  const String pattern = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

                  final RegExp regExp = RegExp(pattern);
                  final isCorrect = regExp.hasMatch(email);
                  if (!isCorrect) {
                    setState(() {
                      showValidate = true;
                    });
                  } else {
                    setState(() {
                      showValidate = false;
                    });
                  }
                })),
        if (showValidate)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(R.string.mes_invalid_email.tr(),
                style: TextStyle(color: R.color.color0xffFF5756, fontSize: 14, fontWeight: FontWeight.w400)),
          )
        else
          const SizedBox(),
        Container(
          margin: const EdgeInsets.only(top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                      height: 48,
                      width: 119,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(200), color: R.color.grayBorder),
                      child: Center(
                        child: Text(R.string.cancel.tr(),
                            style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
                      )),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    final email = widget.controller!.text;
                    if (email.isEmpty) {
                      Message.showToastMessage(context, 'Bạn chưa nhập email');
                      return;
                    }
                    const String pattern = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

                    final RegExp regExp = RegExp(pattern);
                    final isCorrect = regExp.hasMatch(email);
                    if (!isCorrect) {
                      Message.showToastMessage(context, R.string.mes_invalid_email.tr());
                      return;
                    }

                    widget.completion!(email);
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
                            colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
                    child: Center(
                      child: Text(R.string.save.tr(),
                          style: TextStyle(color: R.color.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
