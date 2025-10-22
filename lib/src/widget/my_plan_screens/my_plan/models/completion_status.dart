import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

enum CustomPlayerEventType {
  videoPlay,
  videoPause,
  videoFoward,
  videoPrevious,
  videoCompleted,
  videoReplay,
}

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
        color: R.color.accentColor,
        isSelected: isSelected, // Use the actual isSelected parameter
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
            color: R.color.accentColor,
            isSelected: isSelected, // Use the actual isSelected parameter
          );
        case CompletionStatus.not_completed:
          return _dayIconLayout(
            child: Icon(
              Icons.clear_rounded,
              color: R.color.white,
              size: 16,
            ),
            color: R.color.accentColor,
            isSelected: isSelected, // Use the actual isSelected parameter
          );
        case CompletionStatus.studying:
          return _dayIconLayout(
            child: Image.asset(
              R.drawable.ic_learning,
              width: 16,
              height: 16,
              color: R.color.white,
            ),
            color: R.color.accentColor,
            isSelected: isSelected, // Use the actual isSelected parameter
          );
        case CompletionStatus.not_start_yet:
          return _dayIconLayout(
            child: Container(
              width: 16,
              height: 16,
            ),
            color: R.color.white,
            isSelected: isSelected, // Use the actual isSelected parameter
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
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring when selected: renders outside the 26x26 inner circle
          if (isSelected)
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: R.color.transparent,
                border:
                    Border.all(color: R.color.greenGradientBottom, width: 2),
              ),
            ),
          // White padding between the outer ring and the inner circle
          if (isSelected)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: R.color.white,
              ),
            ),
          // Inner filled circle (26x26)
          Container(
            width: isSelected ? 26 : 32,
            height: isSelected ? 26 : 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: color == R.color.white
                  ? Border.all(color: R.color.color0xffE5E5E5, width: 2)
                  : null,
            ),
            child: Center(child: child),
          ),
        ],
      ),
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
