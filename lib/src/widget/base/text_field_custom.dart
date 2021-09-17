import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/theme/app_theme.dart';

typedef OnChangeCallback = Function(String);

class TextFieldCustom extends StatefulWidget {
  final String title;
  final String placeholder;
  final bool isPassword;
  final bool autoFocus;
  final bool showStar;
  final OnChangeCallback onChanged;

  TextFieldCustom(
      {Key key,
      this.title = '',
      this.placeholder = '',
      this.isPassword = false,
      this.autoFocus = false,
      this.showStar = false,
      this.onChanged})
      : super(key: key);

  @override
  TextFieldCustomState createState() => TextFieldCustomState();
}

class TextFieldCustomState extends State<TextFieldCustom> {
  bool showValidate = false;
  bool isCorrect = false;
  String validateText = '';
  bool showPassword = false;

  TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();

  validate(String text) {
    setState(() {
      validateText = text;
      showValidate = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Row(
            children: [
              Text(widget.title,
                  style: TextStyle(color: R.color.textDark, fontSize: 16)),
              widget.showStar
                  ? Text(" *", style: TextStyle(color: R.color.red))
                  : SizedBox()
            ],
          ),
          SizedBox(height: 10),
        ]),
        Container(
            height: 54,
            padding: EdgeInsets.only(left: 16, right: 8),
            decoration: BoxDecoration(
              color: R.color.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  width: 2,
                  color: isCorrect
                      ? Color(0xff008479)
                      : (showValidate ? Color(0xffFF5756) : R.color.white)),
            ),
            child: Row(children: [
              Image.asset(
                  widget.isPassword
                      ? 'assets/images/icon_lock.png'
                      : 'assets/images/icon_phone.png',
                  width: 20,
                  height: 20,
                  color: R.color.mainColor),
              SizedBox(width: 16),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.isPassword
                        ? Container(
                            height: 25,
                            width: width - 167,
                            child: Center(
                              child: TextField(
                                  controller: textEditingController,
                                  //keyboardType: TextInputType,
                                  autofocus: widget.autoFocus,
                                  obscureText: !showPassword,
                                  style: TextStyle(
                                      fontFamily: 'Viga',
                                      color: R.color.textDark,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                      fillColor: R.color.textDark,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(top: -22),
                                      hintText: widget.placeholder,
                                      hintStyle: TextStyle(
                                          fontFamily: 'roboto',
                                          color: R.color.textDark,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300)),
                                  onChanged: (value) {
                                    isCorrect =
                                        value.length != 0 && value.length >= 6;
                                    if (value.length < 6) {
                                      showValidate = true;
                                      validateText =
                                          'Mật khẩu ít nhất 06 ký tự';
                                    } else if (value.length != 0 &&
                                        showValidate) {
                                      showValidate = false;
                                    }
                                    setState(() {});
                                    widget.onChanged(value);
                                  }),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Text('+84',
                                    style: TextStyle(
                                        fontFamily: 'Viga',
                                        color: R.color.textDark,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500)),
                                SizedBox(width: 8),
                                Container(
                                    height: 20, width: 1, color: R.color.textDark),
                                SizedBox(width: 8),
                                Container(
                                  height: 25,
                                  width: width - 217,
                                  child: Center(
                                    child: TextField(
                                        focusNode: focusNode,
                                        keyboardType: TextInputType.number,
                                        autofocus: widget.autoFocus,
                                        style: TextStyle(
                                            fontFamily: 'Viga',
                                            color: R.color.textDark,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.only(top: -22),
                                            hintText: widget.placeholder,
                                            hintStyle: TextStyle(
                                                fontFamily: 'roboto',
                                                color: R.color.textDark,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w300),
                                            fillColor: R.color.textDark),
                                        onChanged: (value) {
                                          String pattern =
                                              r'(^(?:[+0]9)?[0-9]{9}|\d{10}$)';
                                          RegExp regExp = new RegExp(pattern);
                                          isCorrect = regExp.hasMatch(value);
                                          if (value.length != 9 &&
                                              value.length != 10) {
                                            showValidate = true;
                                            validateText =
                                                'Số điện thoại không đúng định dạng';
                                          } else if (value.length != 0 &&
                                              showValidate) {
                                            showValidate = false;
                                          }
                                          setState(() {});
                                          widget.onChanged(value);
                                        }),
                                  ),
                                )
                              ])
                  ]),
              SizedBox(
                width: 70,
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  widget.isPassword && textEditingController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                          child: Container(
                              color: R.color.transparent,
                              child: Text(!showPassword ? 'Hiện' : 'Ẩn',
                                  style: TextStyle(color: Color(0xff787A7D)))))
                      : SizedBox(),
                  isCorrect
                      ? Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Image.asset('assets/images/icon_correct.png',
                              width: 24, height: 24),
                        )
                      : showValidate
                          ? Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Image.asset(
                                  'assets/images/icon_warning.png',
                                  width: 24,
                                  height: 24),
                            )
                          : SizedBox()
                ]),
              )
            ])),
        showValidate
            ? Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(validateText,
                    style: TextStyle(
                        color: Color(0xffFF5756),
                        fontSize: 14,
                        fontWeight: FontWeight.w400)),
              )
            : SizedBox()
      ],
    );
  }
}
