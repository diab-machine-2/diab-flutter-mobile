import 'package:flutter/material.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/utils/const.dart';

class BmiUtils {
  BmiUtils._();

  static Color getAvgBmiThresholdColor(double currentValue) {
    // đảm bảo thresholds đã sort
    final sortedThresholds = List<double>.from(Const.bmiThreshold)..sort();
    final colors = [
      AppColors.bmiUnderThresholdColor,
      AppColors.bmiNormalColor,
      AppColors.bmiOverThreshold1Color,
      AppColors.bmiOverThreshold2Color,
      AppColors.bmiOverThreshold3Color,
    ];

    // trường hợp nhỏ hơn mốc đầu
    if (currentValue < sortedThresholds.first) {
      return colors.isNotEmpty ? colors.first : Colors.grey;
    }

    // duyệt để tìm khoảng
    for (int i = 0; i < sortedThresholds.length; i++) {
      final threshold = sortedThresholds[i];
      if (currentValue < threshold) {
        // màu index i
        if (i < colors.length) {
          return colors[i];
        } else {
          return Colors.grey; // màu mặc định nếu thiếu
        }
      }
    }

    // trường hợp lớn hơn mốc cuối
    final lastIndex = sortedThresholds.length;
    if (lastIndex < colors.length) {
      return colors[lastIndex];
    } else {
      return Colors.grey;
    }
  }
}
