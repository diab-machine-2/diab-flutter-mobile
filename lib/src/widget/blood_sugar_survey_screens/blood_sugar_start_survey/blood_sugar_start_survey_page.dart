import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/blood_sugar_survey_screens/blood_sugar_survey/blood_sugar_survey.dart';
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

class BloodSugarStartSurveyPage extends StatelessWidget {
  const BloodSugarStartSurveyPage({this.surveyStatus = SurveyStatus.not_done});
  final SurveyStatus surveyStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonPage(
        title: R.string.blood_sugar_testing_schedule_suggest.tr(),
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
                _buildActiveButton(
                  context: context,
                  surveyStatus: surveyStatus,
                ),
                SizedBox(height: 16.h),
                Visibility(
                  visible: surveyStatus == SurveyStatus.done,
                  child: Container(
                    width: 195.w,
                    child: ButtonWidget(
                      title: R.string.survey_again.tr(),
                      onPressed: () {
                        //TODO: Tuyen survey again
                      },
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

Widget _buildActiveButton({
  required BuildContext context,
  required SurveyStatus surveyStatus,
}) {
  switch (surveyStatus) {
    case SurveyStatus.done:
      return Container(
        width: 195.w,
        child: ButtonWidget(
          title: R.string.show_result.tr(),
          onPressed: () {
            //TODO: Tuyen show survey result
          },
        ),
      );
    case SurveyStatus.not_done:
      return Container(
        width: 195.w,
        child: ButtonWidget(
          title: R.string.start.tr(),
          onPressed: () {
            NavigationUtil.navigatePage(context, const BloodSugarSurveyPage());
          },
        ),
      );
    case SurveyStatus.upgrade_require:
      return Container(
        width: 245.w,
        child: ButtonWidget(
          title: R.string.upgrade_to_pro.tr(),
          onPressed: () {
            //TODO: Tuyen open update page
          },
        ),
      );
  }
}
