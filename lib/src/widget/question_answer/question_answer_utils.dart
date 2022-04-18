import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class QuestionAnswerUtils {
  static String getStatus(int status) {
    switch (status) {
      case 0:
        return R.string.closed.tr();
      case 1:
        return R.string.waiting.tr();
      case 2:
        return R.string.replied.tr();
      default:
        return '';
    }
  }

  static Color getColorStatus(int status) {
    switch (status) {
      case 0:
        return R.color.greenGradientBottom;
      case 1:
        return R.color.yellow;
      case 2:
        return R.color.green;
      default:
        return R.color.transparent;
    }
  }
}
