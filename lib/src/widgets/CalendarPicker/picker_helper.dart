import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class PickerHelper {
    static getTextFontWeightByState({required bool isSelected}) {
    if (isSelected) {
      return FontWeight.w700;
    } else {
      return FontWeight.w400;
    }
  }

  static getTextColorByState({required bool isSelected, required bool hasSlot}) {
    if (isSelected) {
      return R.color.greenGradientBottom;
    } else if (hasSlot) {
      return R.color.color0xff27272A;
    } else {
      return R.color.color0xff888892;
    }
  }

  static getContainerColorByState({required bool isSelected, required bool hasSlot}) {
    if (isSelected || hasSlot) {
      return R.color.white;
    } else {
      return R.color.color0xffF4F4F5;
    }
  }

  static getBorderColorByState({required bool isSelected, required bool hasSlot}) {
    if (isSelected) {
      return R.color.greenGradientBottom;
    } else {
      return R.color.color0xffD4D4D8;
    }
  }
}
