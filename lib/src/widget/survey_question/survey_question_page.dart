import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/src/model/response/list_quiz_lesson_response.dart';
import 'package:medical/src/model/response/survey_data.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/card_course_quiz/card_course_quiz.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/custom_scroll_physics.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'survey_question.dart';

class SurveyQuestionPage extends StatefulWidget {
  final int index;
  final SurveyData surveyData;
  const SurveyQuestionPage({Key? key, required this.index, required this.surveyData}) : super(key: key);

  @override
  _SurveyQuestionPageState createState() => _SurveyQuestionPageState();
}

class _SurveyQuestionPageState extends State<SurveyQuestionPage> {
  late SurveyQuestionCubit _cubit;
  SectionSurvey? _sectionSurvey;
  List<GlobalKey<CardCourseQuizPageState>> listGlobal = [];
  AutoScrollController _controller =
  AutoScrollController(axis: Axis.horizontal);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppRepository repository = AppRepository();
    _cubit = SurveyQuestionCubit(repository);
    if (widget.surveyData.sections != null) {
      _sectionSurvey = widget.surveyData.sections![widget.index];
    }
    Utils.onWidgetDidBuild(() {
      _controller.position.isScrollingNotifier.addListener(() {
        if (!_controller.position.isScrollingNotifier.value) {
          int index =
          (_controller.offset / ScreenUtil().screenWidth).round();
          _cubit.jumpToIndexCourse(index);
        }
        // int index =
        // (_controller.offset / (ScreenUtil().screenWidth - 80.h)).round();
        // _cubit.jumpToIndexCourse(index);
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    int lengthQuiz = _sectionSurvey?.questions?.length ?? 0;
    return Container(
        decoration: BoxDecoration(
          color: R.color.color0xffB1DDDB
        ),
        child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.h),
              shrinkWrap: true,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          R.string.survey.tr(),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: R.color.textDark,
                              height: 1.4,
                              letterSpacing: 0.4),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          NavigationUtil.pop(context);
                        },
                        child: Icon(
                          Icons.close,
                          size: 30.h,
                          color: R.color.textDark,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 16.h),
                  child: Text(
                    _sectionSurvey?.name ?? "",
                    style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: R.color.textDark,
                        height: 1.4,
                        letterSpacing: 0.4),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          Expanded(
              child: lengthQuiz == 0 ? Container() : ListView.builder(
                // padding: EdgeInsets.symmetric(horizontal: 8.h),
                controller: _controller,
                scrollDirection: Axis.horizontal,
                physics: NeverScrollableScrollPhysics(),
                itemCount: lengthQuiz,
                itemBuilder: (context, index) {
                  QuizData data = _sectionSurvey!.questions![index];
                  return AutoScrollTag(
                      key: ValueKey(index),
                      controller: _controller,
                      index: index,
                      child: Container(
                        margin:
                        EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.h),
                        width: ScreenUtil().screenWidth,
                        child: CardCourseQuizPage(
                          key: listGlobal[index],
                          index: index,
                          quizData: data,
                          onSubmitAnswer: (listAnswer) =>
                              _cubit.recordAnswer(index, listAnswer),
                        ),
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
                    int newIndex = _cubit.selectedCourseIndex - 1;
                    _controller.scrollToIndex(newIndex,
                        duration: Duration(milliseconds: 500),
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
                InkWell(
                  onTap: () {
                    if (_cubit.selectedCourseIndex == lengthQuiz - 1) {

                    } else {
                      int newIndex = _cubit.selectedCourseIndex + 1;
                      _controller.scrollToIndex(newIndex,
                          duration: Duration(milliseconds: 400),
                          preferPosition: AutoScrollPosition.middle);
                      _cubit.jumpToIndexCourse(newIndex);
                    }
                  },
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 20.h, vertical: 8.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: R.color.main_6,
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
                              color: R.color.accentColor,
                              height: 1.43,
                              letterSpacing: 0.4),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 20.h,
                          color: R.color.accentColor,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
