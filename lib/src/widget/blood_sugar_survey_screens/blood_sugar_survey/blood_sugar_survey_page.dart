import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/blood_sugar_survey_screens/blood_sugar_schedule_templete/blood_sugar_schedule_templete_page.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

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
                Utils.showErrorSnackBar(context, state.error ?? '');
              }
              if (state is BloodSugarSurveyNavigate) {
                if (state.listBloodSugarTemplateCategory.length == 1) {
                  NavigationUtil.navigatePage(
                    context,
                    BloodSugarScheduleTempletePage(
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
                background: R.drawable.bg_blood_sugar_survey,
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
                      const SizedBox(height: 27),
                      Container(
                        width: 195,
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
      answerList.add(const SizedBox(height: 8));
    }
  }
  return Padding(
    padding: const EdgeInsets.only(bottom: 32.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}
