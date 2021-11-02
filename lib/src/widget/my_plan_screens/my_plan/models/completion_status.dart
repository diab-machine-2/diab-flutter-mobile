import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

enum CompletionStatus {
  completed,
  not_completed,
  studying,
  not_start_yet,
}

extension WeekStatus on CompletionStatus {
  Widget get weekStatusIcon {
    switch (this) {
      case CompletionStatus.completed:
        return _buildIconLayout(
          child: Icon(
            Icons.check_rounded,
            color: R.color.white,
            size: 12,
          ),
          color: R.color.greenGradientBottom,
        );
      case CompletionStatus.not_completed:
        return _buildIconLayout(
          child: Icon(
            Icons.clear_rounded,
            color: R.color.white,
            size: 12,
          ),
          color: R.color.orange_1,
        );
      case CompletionStatus.studying:
        return _buildIconLayout(
          child: Image.asset(
            R.drawable.ic_learning,
            width: 12,
            height: 12,
            color: R.color.white,
          ),
          color: R.color.green,
        );
      case CompletionStatus.not_start_yet:
        return const SizedBox.shrink();
    }
  }

  Color get statusColor {
    switch (this) {
      case CompletionStatus.completed:
        return R.color.greenGradientBottom;
      case CompletionStatus.not_completed:
        return R.color.orange_1;
      case CompletionStatus.studying:
        return R.color.green;
      case CompletionStatus.not_start_yet:
        return R.color.captionColorGray;
    }
  }

  Widget _buildIconLayout({
    required Widget child,
    required Color color,
  }) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(left: 6),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}
