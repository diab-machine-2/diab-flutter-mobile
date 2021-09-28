import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

import '../blood_sugar_schedule_template/blood_sugar_schedule_template.dart';
import '../blood_sugar_survey_result/blood_sugar_survey_result.dart';
import '../models/question_data.dart';
import 'blood_sugar_survey.dart';

class BloodSugarSurveyPage extends StatefulWidget {
  const BloodSugarSurveyPage();

  @override
  State<BloodSugarSurveyPage> createState() => _BloodSugarSurveyPageState();
}

class _BloodSugarSurveyPageState extends State<BloodSugarSurveyPage> {
  late BloodSugarSurveyCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository repository = AppRepository();
    _cubit = BloodSugarSurveyCubit(repository);
    _cubit.initSurvey();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return _cubit.onBack();
      },
      child: Scaffold(
        body: BlocProvider(
          create: (context) => _cubit,
          child: BlocConsumer<BloodSugarSurveyCubit, BloodSugarSurveyState>(
            listener: (context, state) {
              if (state is BloodSugarSurveyFailure) {
                BotToast.closeAllLoading();
                Utils.showErrorSnackBar(context, state.error ?? '');
              }
              if (state is BloodSugarSurveyNavigate) {
                if (state.listBloodSugarTemplateCategory.length == 1) {
                  NavigationUtil.navigatePage(
                    context,
                    BloodSugarScheduleTemplatePage(
                        state.listBloodSugarTemplateCategory.first),
                  );
                } else {
                  NavigationUtil.navigatePage(
                    context,
                    BloodSugarSurveyResultPage(
                        state.listBloodSugarTemplateCategory),
                  );
                }
              }
              if (state is BloodSugarSurveyLoading) {
                BotToast.showLoading();
              }
              if (state is BloodSugarSurveySuccess) {
                BotToast.closeAllLoading();
              }
            },
            builder: (context, state) {
              return CommonPage(
                title: R.string.blood_sugar_testing_schedule_suggest.tr(),
                background: R.drawable.bg_detail_pro,
                onTapBack: () {
                  if (_cubit.onBack()) {
                    NavigationUtil.pop(context);
                  }
                },
                child: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding:
                                EdgeInsets.fromLTRB(16.w, 36.h, 16.w, 32.h),
                            child: Column(
                              children: List.generate(
                                _cubit.questions.length,
                                (index) => _buildSurveyQuestionItem(
                                    question: _cubit.questions[index],
                                    onSelectAnswer: (answerIndex) {
                                      print(answerIndex);
                                      _cubit.questions[index].selectedAnswer =
                                          answerIndex;
                                      _cubit.onSelectedAnswer(
                                          _cubit.questions[index].questionKey);
                                    }),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 27.h),
                      Container(
                        width: 195.w,
                        child: ButtonWidget(
                          title: _cubit.canSurveyDone
                              ? R.string.show_result.tr()
                              : R.string.text_continue.tr(),
                          onPressed: () {
                            _cubit.onSubmitAnswer();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

Widget _buildSurveyQuestionItem({
  required Question question,
  required Function(int answerIndex) onSelectAnswer,
}) {
  final List<Widget> answerList = [];
  for (int index = 0; index < question.answers.length; index++) {
    answerList.add(
      _buildSurveyAnswerItem(
          answer: question.getAnswer(index),
          isSelected: index == question.selectedAnswer,
          onTap: () {
            onSelectAnswer(index);
          }),
    );
    if (index != question.answers.length - 1) {
      answerList.add(SizedBox(height: 8.h));
    }
  }
  return Padding(
    padding: EdgeInsets.only(bottom: 32.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.question,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h),
        ...answerList,
      ],
    ),
  );
}

Widget _buildSurveyAnswerItem({
  required String answer,
  required bool isSelected,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: R.color.main_1,
              )
            : TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: R.color.grey_2,
              ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}
