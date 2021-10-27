import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/utils.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget(
      {required this.controller,
//      this.key,
      this.textInputAction: TextInputAction.next,
      this.isEnable = true,
      this.autoFocus = true,
      this.isRequired = false,
        this.borderColor,
      this.border: 10,
      this.onChanged,
      this.padding = const EdgeInsets.all(20),
      this.isPassword: false,
      this.icon,
      this.errorText,
      this.labelText,
      this.hintText,
      this.inputFormatters,
      this.minLines,
      this.maxLines,
      this.keyboardType: TextInputType.text,
      this.focusNode,
      this.readOnly: false,
      this.onTap,
      this.suffixIcon,
      this.onTapRightIcon,
      this.onSubmitted});

//  final GlobalKey key;
  final TextEditingController controller;
  final bool isEnable;
  final bool autoFocus;
  final EdgeInsets padding;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction textInputAction;
  final FormFieldSetter<String>? onChanged;
  final bool isPassword;
  final bool isRequired;
  final String? errorText;
  final String? labelText;
  final String? hintText;
  final int? minLines;
  final int? maxLines;
  final Color? borderColor;
  final double border;
  final TextInputType keyboardType;
  final FocusNode? focusNode;
  final FormFieldSetter<String>? onSubmitted;
  final dynamic icon;
  final bool readOnly;
  final Function? onTap;
  final Widget? suffixIcon;
  final Function? onTapRightIcon;

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late bool _obscureText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
//      key: widget.key,
      enabled: widget.isEnable,
      autofocus: widget.autoFocus,
      focusNode: widget.focusNode,
      controller: widget.controller,
      obscureText: _obscureText,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      readOnly: widget.readOnly,
      //onTap: widget.onTap,
      decoration: InputDecoration(
          hintText: widget.hintText,
          fillColor: R.color.white,
          filled: true,
          isDense: true,
          contentPadding: widget.padding,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: widget.borderColor ?? R.color.gray, width: 0.0),
            borderRadius: BorderRadius.circular(widget.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: widget.borderColor ?? R.color.gray, width: 0.0),
            borderRadius: BorderRadius.circular(widget.border),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: widget.borderColor ?? R.color.gray, width: 0.0),
            borderRadius: BorderRadius.circular(widget.border),
          ),
          errorText: widget.errorText,
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: R.color.red, width: 0.0),
            borderRadius: BorderRadius.circular(widget.border),
          ),
          // prefixText: widget.isRequired  "*" : "",
          prefixStyle: TextStyle(
            color: R.color.red,
          ),
          prefixIcon: widget.icon == null
              ? null
              : (widget.icon is String
                  ? Padding(
                      child: Image.asset(
                        widget.icon,
                        fit: BoxFit.fitHeight,
                        height: 5,
                        color: R.color.textDark,
                      ),
                      padding: EdgeInsets.all(12),
                    )
                  : Icon(
                      widget.icon,
                      size: 30,
                      color: R.color.textDark,
                    )),
          suffixIcon: widget.suffixIcon != null
              ? GestureDetector(
                  onTap: () => widget.onTapRightIcon == null
                      ? null
                      : widget.onTapRightIcon!(),
                  child: Padding(
                      padding: EdgeInsets.only(right: 15),
                      child: widget.suffixIcon),
                )
              : Utils.isEmpty(widget.controller.text) ||
                      (!widget.isPassword && !Utils.isEmpty(widget.errorText))
                  ? null
                  : (widget.isPassword
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Icon(
                                _obscureText
                                    ? CupertinoIcons.eye_slash
                                    : CupertinoIcons.eye,
                                semanticLabel: _obscureText
                                    ? 'show password'
                                    : 'hide password',
                                color: R.color.gray,
                              )),
                        )
                      : null),
          labelStyle: TextStyle(
              fontSize: 16.sp,
              color: widget.isEnable ? R.color.textDark : R.color.gray),
          hintStyle: TextStyle(
            fontSize: 16.sp,
            color: R.color.gray,
          ),
          errorStyle: TextStyle(
            fontSize: 15.sp,
            color: R.color.red,
          )),
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      minLines: widget.minLines,
      maxLines: widget.isPassword == true ? 1 : widget.maxLines,
      textAlign: TextAlign.start,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(
        fontSize: 16.sp,
        color: widget.isEnable ? R.color.textDark : R.color.gray,
      ),
    );
  }
}
