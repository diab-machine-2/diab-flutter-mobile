import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

import 'button_widget.dart';

class CustomBottomBarWidget extends StatelessWidget {
  CustomBottomBarWidget({
    required this.isPreviousButtonActive,
    required this.isNextButtonActive,
    required this.onTapPrevious,
    required this.onTapNext,
    required this.currentPositionTitle,
    this.onTapCenter,
    this.previousButtonTitle,
    this.nextButtonTitle,
    this.isCompleted,
  });

  final bool isPreviousButtonActive;
  final VoidCallback? onTapPrevious;
  final bool isNextButtonActive;
  final VoidCallback? onTapNext;
  final String currentPositionTitle;
  final VoidCallback? onTapCenter;
  final String? previousButtonTitle;
  final String? nextButtonTitle;
  bool? isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: R.color.white,
      padding: EdgeInsets.fromLTRB(
        16,
        14,
        16,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        children: [
          //Previous button
          _buildPreviousButton(),
          SizedBox(width: 4),
          //Center button
          _buildCenterButton(),
          SizedBox(width: 4),
          //Next button
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildPreviousButton() {
    return InkWell(
      onTap: onTapPrevious,
      child: Container(
        width: 135,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isPreviousButtonActive ? R.color.grayBorder : R.color.main_6,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: isPreviousButtonActive ? R.color.textDark : R.color.accentColor,
            ),
            Text(
              previousButtonTitle ?? R.string.back.tr(),
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isPreviousButtonActive ? R.color.textDark : R.color.accentColor,
                  height: 1.43,
                  letterSpacing: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return Expanded(
      child: InkWell(
        onTap: onTapCenter,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 1,
                color: R.color.accentColor,
              )),
          child: Text(
            currentPositionTitle,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: R.color.accentColor,
                height: 1.43,
                letterSpacing: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    if (isCompleted != null) {
      return Container(
        width: 135,
        height: 36,
        child: ButtonWidget(
          title: R.string.complete_lesson.tr(),
          onPressed: isCompleted! ? onTapNext : null,
          textSize: 14,
        ),
      );
    }
    return InkWell(
      onTap: isNextButtonActive ? onTapNext: null,
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isNextButtonActive ? R.color.main_6 : R.color.grayBorder,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              nextButtonTitle ?? R.string.next_lesson.tr(),
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isNextButtonActive ? R.color.accentColor : R.color.textDark,
                  height: 1.43,
                  letterSpacing: 0.4),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isNextButtonActive ? R.color.accentColor : R.color.textDark,
            ),
          ],
        ),
      ),
    );
  }
}
