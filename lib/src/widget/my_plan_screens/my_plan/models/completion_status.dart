import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/utils.dart';

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
        return _weekIconLayout(
          child: Icon(
            Icons.check_rounded,
            color: R.color.white,
            size: 12,
          ),
          color: R.color.greenGradientBottom,
        );
      case CompletionStatus.not_completed:
        return _weekIconLayout(
          child: Icon(
            Icons.clear_rounded,
            color: R.color.white,
            size: 12,
          ),
          color: R.color.orange_1,
        );
      case CompletionStatus.studying:
        return _weekIconLayout(
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

  Widget dayStatusIcon(bool isSelected, bool isToday) {
    if (isToday) {
      return _dayIconLayout(
        child: Image.asset(
          R.drawable.ic_learning,
          width: 16,
          height: 16,
          color: R.color.white,
        ),
        color: R.color.green,
        isSelected: isSelected,
      );
    } else {
      switch (this) {
        case CompletionStatus.completed:
          return _dayIconLayout(
            child: Icon(
              Icons.check_rounded,
              color: R.color.white,
              size: 16,
            ),
            color: R.color.greenGradientBottom,
            isSelected: isSelected,
          );
        case CompletionStatus.not_completed:
          return _dayIconLayout(
            child: Icon(
              Icons.clear_rounded,
              color: R.color.white,
              size: 16,
            ),
            color: R.color.orange_1,
            isSelected: isSelected,
          );
        case CompletionStatus.studying:
          return _dayIconLayout(
            child: Image.asset(
              R.drawable.ic_learning,
              width: 16,
              height: 16,
              color: R.color.white,
            ),
            color: R.color.green,
            isSelected: isSelected,
          );
        case CompletionStatus.not_start_yet:
          return _dayIconLayout(
            child: Container(
              width: 16,
              height: 16,
            ),
            color: R.color.gray,
            isSelected: isSelected,
          );
      }
    }
  }

  Color get statusIconColor {
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

  Color get statusBackgroundColor {
    switch (this) {
      case CompletionStatus.completed:
        return R.color.main_6;
      case CompletionStatus.not_completed:
        return R.color.orange_6;
      case CompletionStatus.studying:
        return R.color.greenbg;
      case CompletionStatus.not_start_yet:
        return R.color.grey_6;
    }
  }

  Widget _weekIconLayout({
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

  Widget _dayIconLayout({
    required Widget child,
    required Color color,
    required bool isSelected,
  }) {
    return Stack(
      children: [
        Positioned(
          top: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              //  color: color,
            ),
            child: child,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: R.color.transparent,
            border: Border.all(color: isSelected ? R.color.green : R.color.transparent, width: 2),
          ),
          child: SizedBox(width: 26, height: 26),
        ),
      ],
    );
  }

  Color getColorBorderSelected(Color color) {
    if (color == R.color.green) {
      return R.color.green;
    } else if (color == R.color.orange_1) {
      return R.color.orange_1;
    } else if (color == R.color.greenGradientBottom) {
      return R.color.greenGradientBottom;
    } else if (color == R.color.gray) {
      return R.color.gray;
    } else {
      return R.color.green;
    }
  }
}
