import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/quiz_lesson.dart';
import 'package:medical/src/utils/logger.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/card_course_quiz/card_course_quiz.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/custom_bottom_bar_widget.dart';
import 'package:medical/src/widgets/custom_scroll_physics.dart';
import 'package:medical/src/widgets/popup_window_widget.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'course_quiz.dart';

class CourseQuizPage extends StatefulWidget {
  final String lessonId;
  final VoidCallback? onDone;

  const CourseQuizPage({Key? key, required this.lessonId, this.onDone})
      : super(key: key);

  @override
  _CourseQuizPageState createState() => _CourseQuizPageState();
}

class _CourseQuizPageState extends State<CourseQuizPage> {
  late CourseQuizCubit _cubit;
  List<GlobalKey<CardCourseQuizPageState>> listGlobal = [];
  final AutoScrollController _controller =
      AutoScrollController(axis: Axis.horizontal);

  @override
  void initState() {
    final AppRepository repository = AppRepository();
    _cubit = CourseQuizCubit(repository);
    _cubit.getListQuiz(widget.lessonId);
    Utils.onWidgetDidBuild(() {
      _controller.position.isScrollingNotifier.addListener(() {
        if (!_controller.position.isScrollingNotifier.value) {
          final int index =
              (_controller.offset / (ScreenUtil().screenWidth - 80)).round();
          _cubit.jumpToIndexCourse(index);
        }
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
            if (state is CourseQuizDone) {
              widget.onDone?.call();
            }
          },
          builder: (context, state) {
            if (state is CourseQuizLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
            }
            return SafeArea(
              top: true,
              bottom: false,
              child: buildPage(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, CourseQuizState state) {
    final int lengthQuiz = _cubit.listQuiz.length;
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
          CustomAppBar(
              backgroundColor: R.color.transparent,
              title: Text(
                R.string.knowledge_test.tr(),
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
              ]),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              R.string.overview_of_diabetes.tr(),
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: R.color.textDark,
                  height: 1.4,
                  letterSpacing: 0.4),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 40,
            alignment: Alignment.center,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: lengthQuiz,
              itemBuilder: (context, index) => buildStep(index: index),
              separatorBuilder: (context, index) => const SizedBox(width: 14),
            ),
          ),
          Expanded(
              child: ListView.builder(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            physics: CustomScrollPhysics(
                itemDimension: ScreenUtil().screenWidth - 66),
            itemCount: lengthQuiz,
            itemBuilder: (context, index) {
              final QuizLesson? data = _cubit.listQuiz[index];
              return AutoScrollTag(
                  key: ValueKey(index),
                  controller: _controller,
                  index: index,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    width: ScreenUtil().screenWidth - 80,
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
          CustomBottomBarWidget(
            isPreviousButtonActive: _cubit.selectedCourseIndex == 0,
            onTapPrevious: _cubit.selectedCourseIndex == 0
                ? null
                : () {
                    final int newIndex = _cubit.selectedCourseIndex - 1;
                    _controller.scrollToIndex(newIndex,
                        duration: const Duration(milliseconds: 500),
                        preferPosition: AutoScrollPosition.middle);
                    _cubit.jumpToIndexCourse(newIndex);
                  },
            isNextButtonActive:
                lengthQuiz != 0 && _cubit.selectedCourseIndex == lengthQuiz - 1,
            onTapNext: () {
              if (lengthQuiz == 0) return;
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
                      duration: const Duration(milliseconds: 400),
                      preferPosition: AutoScrollPosition.begin);
                }, continueLearnCallback: () async {
                  logger.i("continueLearnCallback");
                  widget.onDone?.call();
                });
              } else {
                final int newIndex = _cubit.selectedCourseIndex + 1;
                _controller.scrollToIndex(newIndex,
                    duration: const Duration(milliseconds: 400),
                    preferPosition: AutoScrollPosition.middle);
                _cubit.jumpToIndexCourse(newIndex);
              }
            },
            currentPositionTitle: lengthQuiz == 0
                ? '0/0'
                : '${_cubit.selectedCourseIndex + 1}/$lengthQuiz',
            previousButtonTitle: R.string.previous_question.tr(),
            nextButtonTitle: R.string.next_question.tr(),
          ),
        ],
      ),
    );
  }

  Widget buildStep({required int index}) {
    final QuizLesson? quizData = _cubit.listQuiz[index];
    Color colorBackground = R.color.white;
    Color colorText = R.color.accentColor;
    final bool isCurrent = _cubit.selectedCourseIndex == index;
    final bool isPass = _cubit.answer.length > index;
    if (isPass) {
      colorText = R.color.white;
      if (_cubit.answer[index].toString() ==
          quizData?.quiz?.quizAnswers
              ?.where((e) => e?.isCorrect == true)
              .map((e) => e?.quizId)
              .toList()
              .toString()) {
        colorBackground = R.color.green;
      } else {
        colorBackground = R.color.red;
      }
    }
    return Container(
      height: 30,
      width: 30,
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
              fontSize: 16,
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
    final double rate = rightAnswer / totalQuiz;
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: R.color.transparent,
        body: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: R.color.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    rate < 0.8
                        ? R.drawable.ic_learn_result_medium
                        : R.drawable.img_learn_result_high,
                    height: 150,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    R.string.completed_quiz.tr(),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: R.color.textDark,
                        height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text:
                            "Bạn đã ${rate == 1 ? "xuất sắc" : ""} hoàn tất bài quiz và trả lời đúng ",
                        style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 16,
                          height: 1.375,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: "$rightAnswer/$totalQuiz",
                              style: TextStyle(
                                color: R.color.accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                height: 1.375,
                              )),
                          TextSpan(
                              text: " câu!",
                              style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: R.color.textDark,
                          height: 1.37,
                          letterSpacing: 0.4),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 128,
                        child: ButtonWidget(
                          height: 35,
                          title: rate == 1 || isShowResult
                              ? R.string.see_the_answer.tr()
                              : R.string.skip.tr(),
                          textSize: 14,
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
                        width: 128,
                        child: ButtonWidget(
                            height: 35,
                            title: rate == 1 || isShowResult
                                ? R.string.continue_learning.tr()
                                : R.string.accept.tr(),
                            textSize: 14,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Image.asset(
                R.drawable.img_des,
                height: 80,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Center(
                  child: Text(R.string.explain,
                      style: TextStyle(
                          color: R.color.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              )
            ]),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    message ?? "",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
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
