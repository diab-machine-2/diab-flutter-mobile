
import 'package:flutter/material.dart';
import 'package:medical/res/colors.dart';

extension TextStylesExtension on TextStyle {
  TextStyle get textDark => copyWith(color: AppColors.textDark);
  
  TextStyle get neutral3 => copyWith(color: AppColors.neutral3);
  TextStyle get neutral4 => copyWith(color: AppColors.neutral4);
  TextStyle get neutral5 => copyWith(color: AppColors.neutral5);

  TextStyle get mainColor => copyWith(color: AppColors.mainColor);
}