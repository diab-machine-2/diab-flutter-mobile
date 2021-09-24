import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

class BloodSugarSurvey extends StatelessWidget {
  const BloodSugarSurvey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonPage(
        title: 'Gợi ý lịch đo đường huyết',
        background: R.drawable.bg_blood_sugar_survey,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 36.h, 16.w, 32.h),
                    child: Column(
                      children: [
                        _buildSurveyQuestionItem(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 27),
              Container(
                width: 195,
                child: ButtonWidget(
                  title: R.string.text_continue.tr(),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildSurveyQuestionItem() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '1. Bạn đang mắc đái tháo đường loại nào?',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 12),
      _buildSurveyAnswerItem(
          answer: 'A. The selected answer', isSelected: true),
      const SizedBox(height: 8),
      _buildSurveyAnswerItem(answer: 'B. The not selected answer'),
    ],
  );
}

Widget _buildSurveyAnswerItem({
  required String answer,
  bool isSelected = false,
}) {
  return GestureDetector(
    onTap: () {},
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? null
            : Border.all(
                color: R.color.grayComponentBorder,
                width: 1,
              ),
        color: isSelected ? R.color.color0xffB1DDDB : R.color.white,
      ),
      child: Text(
        answer,
        style: isSelected
            ? TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: R.color.main_1,
              )
            : TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: R.color.grey_2,
              ),
      ),
    ),
  );
}
