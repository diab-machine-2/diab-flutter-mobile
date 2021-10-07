import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/update_required_widget.dart';

import '../blood_sugar_survey/blood_sugar_survey.dart';
import 'blood_sugar_start_survey.dart';

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
          return _cubit.isBasicUser
              ? UpdateRequiredWidget(
                  title: R.string.blood_sugar_testing_schedule_suggest.tr(),
                  description: R.string.blood_sugar_survey_update_require.tr())
              : Scaffold(
                  body: CommonPage(
                    title: R.string.blood_sugar_testing_schedule_suggest.tr(),
                    background: R.drawable.bg_detail_pro,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(28.w, 51.h, 28.h, 32.h),
                        child: Column(
                          children: [
                            SizedBox(height: 51.h),
                            Image.asset(
                                R.drawable.img_blood_sugar_start_survey),
                            Padding(
                              padding: EdgeInsets.only(top: 51.h, bottom: 24.h),
                              child: Text(
                                _cubit.didSurvey
                                    ? R.string
                                        .blood_sugar_survey_done_description
                                        .tr()
                                    : R.string.blood_sugar_survey_description
                                        .tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            _buildButton(
                              onTakeSurvey: () {
                                NavigationUtil.navigatePage(
                                    context, const BloodSugarSurveyPage());
                              },
                              onShowResult: () {
                                //TODO: Tuyen show survey result
                              },
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

  Widget _buildButton(
      {VoidCallback? onTakeSurvey, VoidCallback? onShowResult}) {
    return !_cubit.didSurvey
        ? Container(
            width: 195.w,
            child: ButtonWidget(
              title: R.string.start.tr(),
              onPressed: onTakeSurvey,
            ),
          )
        : Column(
            children: [
              Container(
                width: 195.w,
                child: ButtonWidget(
                  title: R.string.show_result.tr(),
                  onPressed: onShowResult,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                width: 195.w,
                child: ButtonWidget(
                  title: R.string.survey_again.tr(),
                  onPressed: onTakeSurvey,
                  backgroundColor: R.color.white,
                  borderColor: R.color.accentColor,
                  textColor: R.color.accentColor,
                ),
              ),
            ],
          );
  }
}
