import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
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
                Message.showToastMessage(context, state.error ?? '');
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
            },
            builder: (context, state) {
              if (state is BloodSugarSurveyLoading) {
                BotToast.showLoading();
              } else {
                BotToast.closeAllLoading();
              }
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
                                (index) => _buildQuestion(
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

  Widget _buildQuestion({
    required Question question,
    required Function(int answerIndex) onSelectAnswer,
  }) {
    final bool containImageAnswer = question.questionKey == 1;
    final List<Widget> answerList = containImageAnswer
        ? _buildListOfTextAnswer(
            question: question, onSelectAnswer: onSelectAnswer)
        : _buildListOfImageAnswer(
            question: question, onSelectAnswer: onSelectAnswer);
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
          if (containImageAnswer)
            Column(
              children: answerList,
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: answerList,
            ),
          if (question.hasExtendDetail && _cubit.hba1c != null)
            _builddExtendDetail(_cubit.hba1c!)
        ],
      ),
    );
  }

  List<Widget> _buildListOfTextAnswer({
    required Question question,
    required Function(int answerIndex) onSelectAnswer,
  }) {
    final List<Widget> answerList = [];
    for (int index = 0; index < question.answers.length; index++) {
      answerList.add(
        _buildTextAnswerItem(
          answer: question.getAnswer(index),
          isSelected: index == question.selectedAnswer,
          onTap: () {
            onSelectAnswer(index);
          },
        ),
      );
      if (index != question.answers.length - 1) {
        answerList.add(SizedBox(height: 8.h));
      }
    }
    return answerList;
  }

  List<Widget> _buildListOfImageAnswer({
    required Question question,
    required Function(int answerIndex) onSelectAnswer,
  }) {
    final List<Widget> answerList = [];
    for (int index = 0; index < question.answers.length; index++) {
      answerList.add(
        _buildImageAnswerItem(
          answerData: question.answers[index],
          isSelected: index == question.selectedAnswer,
          onTap: () {
            onSelectAnswer(index);
          },
        ),
      );
    }
    return answerList;
  }

  Widget _buildTextAnswerItem({
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

  Widget _buildImageAnswerItem({
    required AnswerData answerData,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSelected ? R.color.greenbg : R.color.white,
              border: isSelected
                  ? Border.all(width: 2, color: R.color.main_1)
                  : null,
              shape: BoxShape.circle,
            ),
            width: 54,
            height: 54,
            child: Image.asset(answerData.image ?? ''),
          ),
          SizedBox(height: 8.h),
          Text(
            answerData.answer,
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
        ],
      ),
    );
  }

  Widget _builddExtendDetail(double hba1c) {
    return Container(
      margin: EdgeInsets.only(top: 20.h),
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: R.color.greenbg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(left: 8.w, right: 6.w),
            width: 20,
            height: 20,
            child: Image.asset(
              R.drawable.ic_info,
              color: R.color.green,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: R.string.latest_hba1c_is.tr(),
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                    text: ' ${R.string.unit_percent.tr(args: ['${hba1c}'])}',
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(width: 14.w),
        ],
      ),
    );
  }
}
