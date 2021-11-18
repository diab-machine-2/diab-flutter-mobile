import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/list_quiz_lesson_response.dart';
import 'package:medical/src/model/response/survey_data.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/card_course_quiz/card_course_quiz.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../survey/survey.dart';
import '../survey_result/survey_result_page.dart';
import 'survey_question.dart';
import 'widgets/custom_progress_bar_widget.dart';

class SurveyQuestionPage extends StatefulWidget {
  final int index;
  final SurveyData surveyData;

  const SurveyQuestionPage(
      {Key? key, required this.index, required this.surveyData})
      : super(key: key);

  @override
  _SurveyQuestionPageState createState() => _SurveyQuestionPageState();
}

class _SurveyQuestionPageState extends State<SurveyQuestionPage> {
  late SurveyQuestionCubit _cubit;
  List<GlobalKey<CardCourseQuizPageState>> listGlobal = [];
  final AutoScrollController _controller =
      AutoScrollController(axis: Axis.horizontal);

  @override
  void initState() {
    super.initState();
    final AppRepository repository = AppRepository();
    final SectionSurvey? _sectionSurvey =
        widget.surveyData.sections?[widget.index];
    _cubit = SurveyQuestionCubit(repository, _sectionSurvey);
    if (widget.surveyData.sections != null) {
      _sectionSurvey?.questions?.forEach((element) {
        listGlobal.add(GlobalKey<CardCourseQuizPageState>());
      });
    }
    Utils.onWidgetDidBuild(() {
      _controller.position.isScrollingNotifier.addListener(() {
        if (!_controller.position.isScrollingNotifier.value) {
          final int index =
              (_controller.offset / ScreenUtil().screenWidth).round();
          _cubit.jumpToIndexCourse(index);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: R.color.color0xffB1DDDB,
        body: BlocProvider(
          create: (context) => _cubit,
          child: BlocConsumer<SurveyQuestionCubit, SurveyQuestionState>(
            listener: (context, state) {
              if (state is SurveyQuestionFailure) {
                Message.showToastMessage(context, state.error);
              }
            },
            builder: (context, state) {
              if (state is SurveyQuestionLoading) {
                BotToast.showLoading();
              } else {
                BotToast.closeAllLoading();
              }
              return SafeArea(
                  top: true, bottom: false, child: buildPage(context, state));
            },
          ),
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, SurveyQuestionState state) {
    return Container(
      decoration: BoxDecoration(color: R.color.color0xffB1DDDB),
      child: Column(
        children: [
          CustomAppBar(
            backgroundColor: R.color.transparent,
            title: Text(
              R.string.survey.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: R.color.textDark,
              ),
            ),
            showRightCloseButton: true,
            actions: [
              IconButton(
                icon: Icon(Icons.close, color: R.color.black),
                onPressed: () {
                  NavigationUtil.pop(context);
                },
              )
            ],
          ),
          const SizedBox(height: 5),
          Expanded(
            child: ListView.builder(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cubit.lengthQuiz,
              itemBuilder: (context, index) {
                final QuizData data = _cubit.questions[index];
                return AutoScrollTag(
                  key: ValueKey(index),
                  controller: _controller,
                  index: index,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    width: ScreenUtil().screenWidth - 32,
                    child: CardCourseQuizSurveyPage(
                      key: listGlobal[index],
                      index: index,
                      quizData: data,
                      onSubmitAnswer: (listAnswer) {
                        _cubit.recordAnswer(
                          questionId: data.id!,
                          answerResult: listAnswer,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const CustomProgressBarWidget(),
          Container(
            color: R.color.white,
            padding: EdgeInsets.only(
                left: 16, right: 16, top: 14, bottom: Platform.isIOS ? 30 : 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: _cubit.selectedCourseIndex == 0
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          final int newIndex = _cubit.selectedCourseIndex - 1;
                          _controller.scrollToIndex(newIndex,
                              duration: const Duration(milliseconds: 500),
                              preferPosition: AutoScrollPosition.middle);
                          _cubit.jumpToIndexCourse(newIndex);
                        },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _cubit.selectedCourseIndex == 0
                          ? R.color.grayBorder
                          : R.color.main_6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: _cubit.selectedCourseIndex == 0
                              ? R.color.textDark
                              : R.color.accentColor,
                        ),
                        Text(
                          R.string.back.tr(),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _cubit.selectedCourseIndex == 0
                                  ? R.color.textDark
                                  : R.color.accentColor,
                              height: 1.43,
                              letterSpacing: 0.4),
                        ),
                      ],
                    ),
                  ),
                ),
                buildNextButton()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildNextButton() {
    final bool isEnable = _cubit.nextButtonEnable;
    final VoidCallback? onTap = isEnable
        ? () {
            if (widget.surveyData.id != null &&
                _cubit.sectionSurvey?.id != null)
              _cubit.submitAnswer(
                surveyId: widget.surveyData.id!,
                sectionId: _cubit.sectionSurvey!.id!,
                questionId: _cubit.currentQuestion?.id ?? '',
              );
            FocusScope.of(context).unfocus();
            if (_cubit.selectedCourseIndex == _cubit.lengthQuiz - 1) {
              final bool isLastPart =
                  widget.index + 1 == (widget.surveyData.sections?.length ?? 0);
              _cubit.emit(SurveyQuestionHideProgressMessage());
              if (isLastPart) {
                NavigationUtil.navigatePage(context, SurveyResultPage());
              } else {
                NavigationUtil.navigatePage(
                    context,
                    SurveyPage(
                      index: widget.index + 1,
                      surveyData: widget.surveyData,
                    ));
              }
            } else {
              final int newIndex = _cubit.selectedCourseIndex + 1;
              _controller.scrollToIndex(newIndex,
                  duration: const Duration(milliseconds: 400),
                  preferPosition: AutoScrollPosition.middle);
              _cubit.jumpToIndexCourse(newIndex);
            }
          }
        : null;
    return _cubit.selectedCourseIndex == _cubit.lengthQuiz - 1
        ? Container(
            height: 36,
            width: 117,
            child: ButtonWidget(
              title: R.string.next.tr(),
              onPressed: onTap ?? () {},
              textSize: 14,
              backgroundColor:
                  isEnable ? R.color.greenGradientBottom : R.color.white,
              borderColor: isEnable ? null : R.color.gray,
              textColor: isEnable ? R.color.white : R.color.gray,
            ),
          )
        : InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isEnable ? R.color.main_6 : R.color.grayBorder,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _cubit.selectedCourseIndex == _cubit.lengthQuiz - 1
                        ? R.string.completed.tr()
                        : R.string.next_question.tr(),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color:
                            isEnable ? R.color.accentColor : R.color.textDark,
                        height: 1.43,
                        letterSpacing: 0.4),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: isEnable ? R.color.accentColor : R.color.textDark,
                  ),
                ],
              ),
            ),
          );
  }
}
