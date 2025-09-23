import 'package:flutter/material.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/dimens.dart';

class AppDecorationStyles {
  AppDecorationStyles();

  final BoxDecoration mediumRadiusCardStyles = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(
        Radius.circular(AppDimens.mediumRadius),
      ),
      boxShadow: [
        BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2))
      ]);
}
