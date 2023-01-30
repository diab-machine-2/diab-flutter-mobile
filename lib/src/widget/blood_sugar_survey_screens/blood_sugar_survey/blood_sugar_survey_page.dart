import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

import '../blood_sugar_schedule_template/blood_sugar_schedule_template.dart';
import '../models/question_data.dart';
import 'blood_sugar_survey.dart';

class BloodSugarSurveyPage extends StatefulWidget {
  const BloodSugarSurveyPage({this.comeFromBloodSugarScreen = false});
  final bool comeFromBloodSugarScreen;

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
              if (state is BloodSugarSurveyLoading) {
                BotToast.showLoading();
              }
              if (state is BloodSugarSurveyFailure) {
                Message.showToastMessage(context, state.error ?? '');
                BotToast.closeAllLoading();
              }
              if (state is BloodSugarSurveySuccess) {
                BotToast.closeAllLoading();
              }
              if (state is BloodSugarSurveyNavigate) {
                NavigationUtil.navigatePage(
                  context,
                  BloodSugarScheduleTemplatePage(
                      templateCode: state.templateCode!,
                      comeFromBloodSugarScreen:
                          widget.comeFromBloodSugarScreen),
                );
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
                            padding: const EdgeInsets.fromLTRB(16, 36, 16, 32),
                            child: Column(
                              children: [
                                Visibility(
                                  visible: _cubit.isFirstQuestionScreen,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        67, 0, 67, 50),
                                    child: Image.asset(R.drawable
                                        .img_blood_sugar_survey_question_1),
                                  ),
                                ),
                                ...List.generate(
                                  _cubit.questions.length,
                                  (index) => _buildQuestion(
                                      question: _cubit.questions[index],
                                      onSelectAnswer: (answerIndex) {
                                        _cubit.questions[index].selectedAnswer =
                                            answerIndex;
                                        _cubit.onSelectedAnswer(_cubit
                                            .questions[index].questionKey);
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 27),
                      Container(
                        width: 195,
                        child: ButtonWidget(
                          title: !_cubit.canSurveyDone &&
                                  _cubit.isFirstQuestionScreen
                              ? R.string.text_continue.tr()
                              : R.string.show_result.tr(),
                          onPressed: () {
                            _cubit.onSubmitAnswer();
                          },
                          backgroundColor:
                              _cubit.buttonEnabled ? null : R.color.white,
                          borderColor: _cubit.buttonEnabled
                              ? R.color.greenGradientBottom
                              : R.color.gray,
                          textColor: _cubit.buttonEnabled
                              ? R.color.white
                              : R.color.gray,
                        ),
                      ),
                      const SizedBox(height: 24),
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
      padding: const EdgeInsets.only(bottom: 32),
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
          if (containImageAnswer)
            Column(
              children: answerList,
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: answerList,
            ),
          if (question.hasExtendDetail && _cubit.hba1c != -1)
            _buildExtendDetail(_cubit.hba1c)
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
        answerList.add(const SizedBox(height: 8));
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
          const SizedBox(height: 8),
          Text(
            answerData.answer,
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
        ],
      ),
    );
  }

  Widget _buildExtendDetail(double hba1c) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: R.color.greenbg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 8, right: 6),
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
                style: R.style.normalTextStyle,
                children: [
                  TextSpan(
                    text: ' ${R.string.unit_percent.tr(args: ['$hba1c'])}',
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
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}
