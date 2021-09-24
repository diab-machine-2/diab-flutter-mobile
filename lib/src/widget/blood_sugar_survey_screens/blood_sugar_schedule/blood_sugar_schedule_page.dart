import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

enum SurveyStatus {
  done,
  not_done,
  upgrade_require,
}

extension SurveyStatusDetail on SurveyStatus {
  String get text {
    switch (this) {
      case SurveyStatus.done:
        return R.string.blood_sugar_survey_done_description.tr();
      case SurveyStatus.not_done:
        return R.string.blood_sugar_survey_description.tr();
      case SurveyStatus.upgrade_require:
        return R.string.blood_sugar_survey_update_require.tr();
    }
  }

  String get image {
    switch (this) {
      case SurveyStatus.done:
        return R.drawable.im_blood_sugar_start_survey;
      case SurveyStatus.not_done:
        return R.drawable.im_blood_sugar_start_survey;
      case SurveyStatus.upgrade_require:
        return R.drawable.im_upgrade_to_take_survey;
    }
  }
}

class BloodSugarSchedule extends StatelessWidget {
  const BloodSugarSchedule({this.surveyStatus = SurveyStatus.done});
  final SurveyStatus surveyStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonPage(
        title: 'Gợi ý lịch đo đường huyết',
        background: R.drawable.bg_blood_sugar_survey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(28.w, 51.h, 28.h, 32.h),
            child: Column(
              children: [
                SizedBox(height: 51.h),
                Image.asset(surveyStatus.image),
                Padding(
                  padding: EdgeInsets.only(top: 51.h, bottom: 24.h),
                  child: Text(
                    surveyStatus.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (surveyStatus == SurveyStatus.upgrade_require)
                  Container(
                    width: 245.w,
                    child: ButtonWidget(
                      title: R.string.upgrade_to_pro.tr(),
                      onPressed: () {},
                    ),
                  )
                else
                  Container(
                    width: 195.w,
                    child: ButtonWidget(
                      title: R.string.start.tr(),
                      onPressed: () {},
                    ),
                  ),
                SizedBox(height: 16.h),
                Visibility(
                  visible: surveyStatus == SurveyStatus.done,
                  child: Container(
                    width: 195.w,
                    child: ButtonWidget(
                      title: R.string.survey_again.tr(),
                      onPressed: () {},
                      backgroundColor: R.color.white,
                      borderColor: R.color.accentColor,
                      textColor: R.color.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
