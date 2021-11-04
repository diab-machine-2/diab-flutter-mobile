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
import 'package:medical/src/widget/survey/survey_page.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../survey_result/survey_result_page.dart';
import 'survey_question.dart';

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
  SectionSurvey? _sectionSurvey;
  List<GlobalKey<CardCourseQuizPageState>> listGlobal = [];
  final AutoScrollController _controller =
      AutoScrollController(axis: Axis.horizontal);

  @override
  void initState() {
    super.initState();
    final AppRepository repository = AppRepository();
    _cubit = SurveyQuestionCubit(repository);
    if (widget.surveyData.sections != null) {
      _sectionSurvey = widget.surveyData.sections![widget.index];
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
    return Scaffold(
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
    );
  }

  Widget buildPage(BuildContext context, SurveyQuestionState state) {
    final int lengthQuiz = _sectionSurvey?.questions?.length ?? 0;
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
          SizedBox(height: 5.h),
          Expanded(
              child: lengthQuiz == 0
                  ? Container()
                  : ListView.builder(
                      controller: _controller,
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: lengthQuiz,
                      itemBuilder: (context, index) {
                        final QuizData data = _sectionSurvey!.questions![index];
                        return AutoScrollTag(
                            key: ValueKey(index),
                            controller: _controller,
                            index: index,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 16.h, horizontal: 16.h),
                              width: ScreenUtil().screenWidth - 32.h,
                              child: CardCourseQuizPage(
                                  key: listGlobal[index],
                                  index: index,
                                  //TODO fix model
                                  quizData: null,
                                  isQuiz: false,
                                  onChoseAnswer: (isChoseAnswer) {
                                    _cubit.enableNextButton(isChoseAnswer);
                                  },
                                  onSubmitAnswer: (listAnswer) {
                                    _cubit.recordAnswer(
                                        data.id!,
                                        listAnswer,
                                        (data.answers ?? [])
                                            .map((e) => e.id.toString())
                                            .toList());
                                  }),
                            ));
                      },
                    )),
          Container(
            color: R.color.white,
            padding: EdgeInsets.only(
                left: 16.h,
                right: 16.h,
                top: 14.h,
                bottom: Platform.isIOS ? 30.h : 14.h),
            child: Row(
              children: [
                InkWell(
                  onTap: _cubit.selectedCourseIndex == 0
                      ? null
                      : () {
                          final int newIndex = _cubit.selectedCourseIndex - 1;
                          _controller.scrollToIndex(newIndex,
                              duration: const Duration(milliseconds: 500),
                              preferPosition: AutoScrollPosition.middle);
                          _cubit.jumpToIndexCourse(newIndex);
                        },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.h, vertical: 8.h),
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
                          size: 20.h,
                          color: _cubit.selectedCourseIndex == 0
                              ? R.color.textDark
                              : R.color.accentColor,
                        ),
                        Text(
                          R.string.back.tr(),
                          style: TextStyle(
                              fontSize: 14.sp,
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
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10.h),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 1,
                          color: R.color.accentColor,
                        )),
                    child: Text(
                      "${_cubit.selectedCourseIndex + 1}/$lengthQuiz",
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: R.color.accentColor,
                          height: 1.43,
                          letterSpacing: 0.4),
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
    final int lengthQuiz = _sectionSurvey?.questions?.length ?? 0;
    final bool isEnable = _cubit.isEnableNext;
    return InkWell(
      onTap: isEnable
          ? () {
              if (_cubit.selectedCourseIndex == lengthQuiz - 1) {
                final bool isLastPart = widget.index + 1 ==
                    (widget.surveyData.sections?.length ?? 0);
                if (widget.surveyData.id != null && _sectionSurvey?.id != null)
                  _cubit.submitAnswer(
                      widget.surveyData.id!, _sectionSurvey!.id!);
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
                _cubit.enableNextButton(false);
              }
            }
          : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isEnable ? R.color.main_6 : R.color.grayBorder,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _cubit.selectedCourseIndex == lengthQuiz - 1
                  ? R.string.completed.tr()
                  : R.string.next_question.tr(),
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isEnable ? R.color.accentColor : R.color.textDark,
                  height: 1.43,
                  letterSpacing: 0.4),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 20.h,
              color: isEnable ? R.color.accentColor : R.color.textDark,
            ),
          ],
        ),
      ),
    );
  }
}
