import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/list_quiz_lesson_response.dart';
import 'package:medical/src/utils/logger.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/card_course_quiz/card_course_quiz.dart';
import 'package:medical/src/widget/course_feedback/course_feedback.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/custom_scroll_physics.dart';
import 'package:medical/src/widgets/popup_window_widget.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'course_quiz.dart';

class CourseQuizPage extends StatefulWidget {
  final String lessonId;
  final VoidCallback? onDone;

  const CourseQuizPage(
      {Key? key, this.lessonId = "0c8c3920-dd49-41ad-aa1b-08d987ed41f9", this.onDone})
      : super(key: key);

  @override
  _CourseQuizPageState createState() => _CourseQuizPageState();
}

class _CourseQuizPageState extends State<CourseQuizPage> {
  late CourseQuizCubit _cubit;
  List<GlobalKey<CardCourseQuizPageState>> listGlobal = [];
  AutoScrollController _controller =
      AutoScrollController(axis: Axis.horizontal);

  @override
  void initState() {
    // TODO: implement initState
    AppRepository repository = AppRepository();
    _cubit = CourseQuizCubit(repository);
    _cubit.getListQuiz(widget.lessonId);
    Utils.onWidgetDidBuild(() {
      _controller.position.isScrollingNotifier.addListener(() {
        if (!_controller.position.isScrollingNotifier.value) {
          int index =
              (_controller.offset / (ScreenUtil().screenWidth - 80.h)).round();
          _cubit.jumpToIndexCourse(index);
        }
        // int index =
        // (_controller.offset / (ScreenUtil().screenWidth - 80.h)).round();
        // _cubit.jumpToIndexCourse(index);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.color0xffDFF6EC,
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<CourseQuizCubit, CourseQuizState>(
          listener: (context, state) {
            if (state is CourseQuizSuccess) {
              if (listGlobal.isEmpty) {
                _cubit.listQuiz.forEach((element) {
                  listGlobal.add(GlobalKey<CardCourseQuizPageState>());
                });
              }
            }
            if (state is RetryQuizSuccess) {
              listGlobal.forEach((element) {
                element.currentState?.clearAllAnswer();
              });
            }
            if (state is ShowAnswerQuizSuccess) {
              listGlobal.forEach((element) {
                element.currentState?.showAnswer();
              });
            }
            if (state is CourseQuizFailure)
              Message.showToastMessage(context, state.error);
            // TODO: implement listener
          },
          builder: (context, state) {
            if (state is CourseQuizLoading) {
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

  Widget buildPage(BuildContext context, CourseQuizState state) {
    int lengthQuiz = _cubit.listQuiz.length;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [R.color.main_6, R.color.color0xffB1DDDB],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    R.string.knowledge_test.tr(),
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
              R.string.overview_of_diabetes.tr(),
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: R.color.textDark,
                  height: 1.4,
                  letterSpacing: 0.4),
            ),
          ),
          SizedBox(height: 5.h),
          Container(
            height: 40.h,
            alignment: Alignment.center,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: lengthQuiz,
              itemBuilder: (context, index) => buildStep(index: index),
              separatorBuilder: (context, index) => SizedBox(
                width: 14.w,
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
            // padding: EdgeInsets.symmetric(horizontal: 8.h),
            controller: _controller,
            scrollDirection: Axis.horizontal,
            physics: CustomScrollPhysics(
                itemDimension: ScreenUtil().screenWidth - 66.h),
            itemCount: lengthQuiz,
            itemBuilder: (context, index) {
              QuizData data = _cubit.listQuiz[index];
              return AutoScrollTag(
                  key: ValueKey(index),
                  controller: _controller,
                  index: index,
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.h),
                    width: ScreenUtil().screenWidth - 80.h,
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
                      buildDialogCompleted(context,
                          rightAnswer: _cubit.countAnswerRight,
                          totalQuiz: lengthQuiz, seeResultCallback: () {
                        logger.i("seeResultCallback");
                        _cubit.showAnswer();
                      }, retryCallback: () {
                        logger.i("retryCallback");
                        _cubit.retryQuiz();
                        _controller.scrollToIndex(0,
                            duration: Duration(milliseconds: 400),
                            preferPosition: AutoScrollPosition.begin);
                      }, continueLearnCallback: () async {
                        logger.i("continueLearnCallback");
                        await NavigationUtil.navigatePage(context, CourseFeedbackPage(lessonId: widget.lessonId));
                        widget.onDone?.call();
                      });
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

  Widget buildStep({required int index}) {
    QuizData quizData = _cubit.listQuiz[index];
    Color colorBackground = R.color.white;
    Color colorText = R.color.accentColor;
    bool isCurrent = _cubit.selectedCourseIndex == index;
    bool isPass = _cubit.answer.length > index;
    if (isPass) {
      colorText = R.color.white;
      if (_cubit.answer[index].toString() ==
          quizData.answers
              ?.where((e) => e.isCorrect == true)
              .map((e) => e.id)
              .toList()
              .toString()) {
        colorBackground = R.color.green;
      } else {
        colorBackground = R.color.red;
      }
    }
    return Container(
      height: 30.h,
      width: 30.h,
      // padding: EdgeInsets.all(8.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isPass || isCurrent ? colorBackground : Colors.transparent,
        border: Border.all(
          width: 1,
          color: isPass || isCurrent ? colorBackground : R.color.accentColor,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          "${index + 1}",
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: colorText,
              height: 1.37,
              letterSpacing: 0.4),
        ),
      ),
    );
  }

  void buildDialogCompleted(
    BuildContext context, {
    required int rightAnswer,
    required int totalQuiz,
    bool isShowResult = false,
    required VoidCallback seeResultCallback,
    VoidCallback? retryCallback,
    required VoidCallback continueLearnCallback,
  }) {
    double rate = rightAnswer / totalQuiz;
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: R.color.transparent,
        body: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 24.h),
            padding: EdgeInsets.all(20.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.h),
              color: R.color.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    rate < 0.8
                        ? R.drawable.ic_learn_result_medium
                        : R.drawable.ic_learn_result_high,
                    height: 150.h,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    R.string.completed_quiz.tr(),
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: R.color.textDark,
                        height: 1.4),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.all(24.h),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text:
                            "Bạn đã ${rate == 1 ? "xuất sắc" : ""} hoàn tất bài quiz và trả lời đúng ",
                        style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 16.sp,
                          height: 1.375,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: "${rightAnswer}/${totalQuiz}",
                              style: TextStyle(
                                color: R.color.accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                height: 1.375,
                              )),
                          TextSpan(
                              text: " câu!",
                              style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16.sp,
                                height: 1.375,
                              )),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !(rate == 1 || isShowResult),
                    child: Text(
                      R.string.challenge_yourself_again.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: R.color.textDark,
                          height: 1.37,
                      letterSpacing: 0.4),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 128.w,
                        child: ButtonWidget(
                          height: 35.h,
                          title: rate == 1 || isShowResult
                              ? R.string.see_the_answer.tr()
                              : R.string.skip.tr(),
                          textSize: 14.sp,
                          onPressed: () {
                            NavigationUtil.pop(context);
                            if (rate == 1 || isShowResult == true) {
                              seeResultCallback();
                            } else {
                              buildDialogCompleted(context,
                                  rightAnswer: rightAnswer,
                                  totalQuiz: totalQuiz,
                                  isShowResult: true,
                                  seeResultCallback: seeResultCallback,
                                  continueLearnCallback: continueLearnCallback);
                            }
                          },
                          backgroundColor: Colors.transparent,
                          borderColor: R.color.accentColor,
                          textColor: R.color.accentColor,
                        ),
                      ),
                      Container(
                        width: 128.w,
                        child: ButtonWidget(
                            height: 35.h,
                            title: rate == 1 || isShowResult
                                ? R.string.continue_learning.tr()
                                : R.string.accept.tr(),
                            textSize: 14.sp,
                            onPressed: () {
                              NavigationUtil.pop(context);
                              if (rate == 1 || isShowResult) {
                                continueLearnCallback();
                              } else {
                                retryCallback!();
                              }
                            }),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showDescriptionPopup(String? message) {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.9),
      useSafeArea: true,
      barrierDismissible: true,
      context: context,
      builder: (_) => PopupWindowWidget(
          child: Container(
        width: double.infinity,
        // height: ScreenUtil().screenHeight - 150.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Image.asset(
                R.drawable.img_des,
                height: 80.h,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Center(
                  child: Text(R.string.explain,
                      style: TextStyle(
                          color: R.color.black,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold)),
                ),
              )
            ]),
            SizedBox(height: 16.h),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16.h),
                  child: Text(
                    message ?? "",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontWeight: FontWeight.normal,
                      fontSize: 16.sp,
                      letterSpacing: 0.4,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
