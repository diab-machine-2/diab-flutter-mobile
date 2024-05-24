import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class AppStyle {
  TextStyle get normalTextStyle => TextStyle(
        color: R.color.textDark,
        fontSize: R.dimen.normal_text_size,
        fontWeight: FontWeight.w400,
      );
  TextStyle get appBarTitle => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: R.color.textDark,
      );
  TextStyle get primaryButtonText => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );
  TextStyle get secondaryButtonText => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: R.color.greenGradientBottom,
      );
  TextStyle get alertTitle => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: R.color.textDark,
      );
  TextStyle get alertContent => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: R.color.textDark,
      );
}
