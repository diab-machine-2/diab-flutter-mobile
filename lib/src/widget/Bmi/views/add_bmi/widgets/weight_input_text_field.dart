import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/utils/formater.dart';

class WeightInputTextField extends StatelessWidget {
  const WeightInputTextField({
    super.key,
    this.hintText,
    this.suffixText,
    this.controller,
    this.onChanged,
    this.focusNode,
  });

  final String? hintText;
  final String? suffixText;

  final TextEditingController? controller;

  final FocusNode? focusNode;

  final void Function(String value)? onChanged;

  static const _border =
      UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neutral5));

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: R.style.inputHealthIndexStyle
                .copyWith(color: AppColors.neutral4),
            // suffixText: suffixText,
            suffixStyle: R.style.largeTextStyle.neutral3,
            focusedBorder: _border,
            enabledBorder: _border,
          ),
          style: R.style.inputHealthIndexStyle,
          textAlign: TextAlign.center,
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          maxLength: 5,
          inputFormatters: [
            CommaToDotFormatter(),
            DecimalTextInputFormatter(decimalRange: 1),
            FilteringTextInputFormatter.allow(RegExp(r'^\d*([.,]\d{0,1})?$')),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 96),
          child: Text(
            suffixText ?? "",
            style: R.style.normalTextStyle.apply(color: AppColors.neutral4),
          ),
        )
      ],
    );
  }
}
