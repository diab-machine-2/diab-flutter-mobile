import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

typedef OnChangeCallback = Function(String);

class TextFieldCustom extends StatefulWidget {
  final String title;
  final String placeholder;
  final bool isPassword;
  final bool autoFocus;
  final bool showStar;
  final OnChangeCallback? onChanged;

  const TextFieldCustom(
      {Key? key,
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
  late final String icon;
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
  void initState() {
    super.initState();
    icon = widget.isPassword ? R.drawable.ic_lock : R.drawable.ic_phone;
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
              if (widget.showStar)
                Text(" *", style: TextStyle(color: R.color.red))
              else
                const SizedBox()
            ],
          ),
          const SizedBox(height: 10),
        ]),
        Container(
            height: 54,
            padding: const EdgeInsets.only(left: 16, right: 8),
            decoration: BoxDecoration(
              color: R.color.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  width: 2,
                  color: isCorrect
                      ? R.color.greenGradientBottom
                      : (showValidate
                          ? R.color.color0xffFF5756
                          : R.color.white)),
            ),
            child: Row(children: [
              Image.asset(icon,
                  width: 20, height: 20, color: R.color.mainColor),
              const SizedBox(width: 16),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isPassword)
                      Container(
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
                                  contentPadding:
                                      const EdgeInsets.only(top: -22),
                                  hintText: widget.placeholder,
                                  hintStyle: TextStyle(
                                      fontFamily: 'roboto',
                                      color: R.color.textDark,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300)),
                              onChanged: (value) {
                                isCorrect =
                                    value.isNotEmpty && value.length >= 6;
                                if (value.length < 6) {
                                  showValidate = true;
                                  validateText =
                                      R.string.password_least_character.tr();
                                } else if (value.isNotEmpty && showValidate) {
                                  showValidate = false;
                                }
                                setState(() {});
                                widget.onChanged!(value);
                              }),
                        ),
                      )
                    else
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('+84',
                                style: TextStyle(
                                    fontFamily: 'Viga',
                                    color: R.color.textDark,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(width: 8),
                            Container(
                                height: 20, width: 1, color: R.color.textDark),
                            const SizedBox(width: 8),
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
                                            const EdgeInsets.only(top: -22),
                                        hintText: widget.placeholder,
                                        hintStyle: TextStyle(
                                            fontFamily: 'roboto',
                                            color: R.color.textDark,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w300),
                                        fillColor: R.color.textDark),
                                    onChanged: (value) {
                                      const String pattern =
                                          r'(^(?:[+0]9)?[0-9]{9}|\d{10}$)';
                                      final RegExp regExp = RegExp(pattern);
                                      isCorrect = regExp.hasMatch(value);
                                      if (value.length != 9 &&
                                          value.length != 10) {
                                        showValidate = true;
                                        validateText =
                                            R.string.phone_not_valid.tr();
                                      } else if (value.isNotEmpty &&
                                          showValidate) {
                                        showValidate = false;
                                      }
                                      setState(() {});
                                      widget.onChanged!(value);
                                    }),
                              ),
                            )
                          ])
                  ]),
              SizedBox(
                width: 70,
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  if (widget.isPassword &&
                      textEditingController.text.isNotEmpty)
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        child: Container(
                            color: R.color.transparent,
                            child: Text(
                                !showPassword
                                    ? R.string.show.tr()
                                    : R.string.hide.tr(),
                                style: TextStyle(color: R.color.grey_2))))
                  else
                    const SizedBox(),
                  if (isCorrect)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Image.asset(R.drawable.ic_correct,
                          width: 24, height: 24),
                    )
                  else
                    showValidate
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Image.asset(R.drawable.ic_warning,
                                width: 24, height: 24),
                          )
                        : const SizedBox()
                ]),
              )
            ])),
        if (showValidate)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(validateText,
                style: TextStyle(
                    color: R.color.color0xffFF5756,
                    fontSize: 14,
                    fontWeight: FontWeight.w400)),
          )
        else
          const SizedBox()
      ],
    );
  }
}
