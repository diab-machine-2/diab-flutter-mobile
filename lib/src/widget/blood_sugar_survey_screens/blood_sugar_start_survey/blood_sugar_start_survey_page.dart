import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/my_package/my_package.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

import '../blood_sugar_survey/blood_sugar_survey.dart';
import 'blood_sugar_start_survey.dart';

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
        return R.drawable.img_blood_sugar_start_survey;
      case SurveyStatus.not_done:
        return R.drawable.img_blood_sugar_start_survey;
      case SurveyStatus.upgrade_require:
        return R.drawable.img_upgrade_package;
    }
  }
}

class BloodSugarStartSurveyPage extends StatefulWidget {
  const BloodSugarStartSurveyPage();

  @override
  State<BloodSugarStartSurveyPage> createState() =>
      _BloodSugarStartSurveyPageState();
}

class _BloodSugarStartSurveyPageState extends State<BloodSugarStartSurveyPage> {
  late final BloodSugarStartSurveyCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository repository = AppRepository();
    _cubit = BloodSugarStartSurveyCubit(repository);
    _cubit.getOwnPackageCode();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child:
          BlocConsumer<BloodSugarStartSurveyCubit, BloodSugarStartSurveyState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is BloodSugarStartSurveyLoading) {
            BotToast.showLoading();
          } else {
            BotToast.closeAllLoading();
          }
          return Scaffold(
            body: CommonPage(
              title: R.string.blood_sugar_testing_schedule_suggest.tr(),
              background: R.drawable.bg_detail_pro,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(28.w, 51.h, 28.h, 32.h),
                  child: Column(
                    children: [
                      SizedBox(height: 51.h),
                      Image.asset(_cubit.surveyStatus.image),
                      Padding(
                        padding: EdgeInsets.only(top: 51.h, bottom: 24.h),
                        child: Text(
                          _cubit.surveyStatus.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      _buildActiveButton(
                        context: context,
                        surveyStatus: _cubit.surveyStatus,
                      ),
                      SizedBox(height: 16.h),
                      Visibility(
                        visible: _cubit.surveyStatus == SurveyStatus.done,
                        child: Container(
                          width: 195.w,
                          child: ButtonWidget(
                            title: R.string.survey_again.tr(),
                            onPressed: () {
                              NavigationUtil.navigatePage(
                                  context, const BloodSugarSurveyPage());
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
        },
      ),
    );
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
              NavigationUtil.navigatePage(
                  context, const BloodSugarSurveyPage());
            },
          ),
        );
      case SurveyStatus.upgrade_require:
        return Container(
          width: 245.w,
          child: ButtonWidget(
            title: R.string.upgrade_to_diab_pro.tr(),
            onPressed: () {
              NavigationUtil.navigatePage(context, MyPackagePage());
            },
          ),
        );
    }
  }
}
