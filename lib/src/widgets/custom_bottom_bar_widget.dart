import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';

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
  var userInfo = AppSettings.userInfo;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row for buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button
              _buildPreviousButton(),
              SizedBox(width: 4),
              // Center button
              // _buildCenterButton(),
              // Expanded(
              //     child: Image.network(
              //         "https://res.cloudinary.com/dzgugrqxz/image/upload/v1716280100/xpripzukgihaokrhntzj.png")),
              if (AppSettings.isOwnPackage)
                _buildCenter()
              else
                _buildCenterButton(),
              SizedBox(width: 4),
              // Next button
              _buildNextButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCenter() {
    int target = 0;
    try {
      target = int.parse(currentPositionTitle.split('/')[0]) - 1;
    } catch (e) {}

    return InkWell(
      onTap: onTapCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(
            height: 50,
            AppSettings.userInfo?.ownPackage?.logo ?? "",
            errorBuilder: (context, error, stackTrace) {
              return SizedBox();
            },
          ),
          SizedBox(height: 10),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  int.parse(currentPositionTitle.split('/')[1]), (index) {
                bool isTarget = index == target;
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  width: isTarget ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: isTarget
                        ? BorderRadius.all(Radius.circular(10))
                        : BorderRadius.circular(8),
                    color: isTarget
                        ? Colors.green
                        : Colors
                            .grey, // Replace Colors.green with your custom color if needed
                  ),
                );
              }),
            ),
          ),
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
              color: isPreviousButtonActive
                  ? AppSettings.isOwnPackage
                      ? R.color.main_1
                      : R.color.textDark
                  : R.color.accentColor,
            ),
            Text(
              previousButtonTitle ?? R.string.back.tr(),
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isPreviousButtonActive
                      ? AppSettings.isOwnPackage
                          ? R.color.main_1
                          : R.color.textDark
                      : R.color.accentColor,
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
            ),
            color: Colors.white,
          ),
          child: Text(
            currentPositionTitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: R.color.accentColor,
              height: 1.43,
              letterSpacing: 0.4,
            ),
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
      onTap: isNextButtonActive ? onTapNext : null,
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
                  color: isNextButtonActive
                      ? R.color.accentColor
                      : AppSettings.isOwnPackage
                          ? R.color.main_1
                          : AppSettings.isOwnPackage
                              ? R.color.main_6
                              : R.color.textDark,
                  height: 1.43,
                  letterSpacing: 0.4),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isNextButtonActive
                  ? R.color.accentColor
                  : AppSettings.isOwnPackage
                      ? R.color.main_1
                      : AppSettings.isOwnPackage
                          ? R.color.main_6
                          : R.color.textDark,
            ),
          ],
        ),
      ),
    );
  }
}
