import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:flutter/services.dart';

class BmiInputTextField extends StatelessWidget {
  const BmiInputTextField({
    super.key,
    this.hintText,
    this.suffixText,
    this.controller,
    this.onChanged,
  });

  final String? hintText;
  final String? suffixText;

  final TextEditingController? controller;

  final void Function(String value)? onChanged;

  static const _border =
      UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neutral5));

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
            R.style.inputHealthIndexStyle.copyWith(color: AppColors.neutral4),
        suffixText: suffixText,
        suffixStyle: R.style.largeTextStyle.neutral3,
        focusedBorder: _border,
        enabledBorder: _border,
      ),
      style: R.style.inputHealthIndexStyle,
      textAlign: TextAlign.center,
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
    );
  }
}
