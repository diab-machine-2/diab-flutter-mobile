import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/response/quiz_lesson.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/custom_bottom_bar_widget.dart';
import 'package:medical/src/widgets/custom_scroll_physics.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../card_course_quiz/card_course_quiz.dart';
import 'course_quiz.dart';
import 'widgets/quiz_result_popup.dart';

class CourseQuizPage extends StatefulWidget {
  const CourseQuizPage(
      {Key? key, required this.lessonId, this.lessonSectionItem, this.onDone})
      : super(key: key);

  final String lessonId;
  final LessonSectionItem? lessonSectionItem;
  final Function(bool isPassed)? onDone;

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
    _cubit.initData(
      lessonId: widget.lessonId,
      lessonSectionItem: widget.lessonSectionItem,
    );
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
              onDoneQuiz();
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
              _cubit.quizName,
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
              itemBuilder: (context, index) => buildStep(
                  index: index,
                  onTap: () {
                    _controller.scrollToIndex(index,
                        duration: const Duration(milliseconds: 200),
                        preferPosition: AutoScrollPosition.middle);
                  }),
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
                    child: listGlobal.isNotEmpty
                        ? CardCourseQuizPage(
                            key: listGlobal[index],
                            index: index,
                            quizData: data,
                            onSubmitAnswer: (listAnswer) =>
                                _cubit.recordAnswer(index, listAnswer),
                          )
                        : const SizedBox(),
                  ),
                );
              },
            ),
          ),
          CustomBottomBarWidget(
            isPreviousButtonActive: _cubit.selectedCourseIndex == 0,
            onTapPrevious: _cubit.selectedCourseIndex == 0
                ? null
                : () {
                    final int newIndex = _cubit.selectedCourseIndex - 1;
                    _controller.scrollToIndex(newIndex,
                        duration: const Duration(milliseconds: 200),
                        preferPosition: AutoScrollPosition.middle);
                    _cubit.jumpToIndexCourse(newIndex);
                  },
            isNextButtonActive:
                lengthQuiz != 0 && _cubit.selectedCourseIndex < lengthQuiz - 1,
            onTapNext: () {
              if (lengthQuiz == 0) {
                onDoneQuiz();
                return;
              }
              if (_cubit.canComplete == true) {
                if (_cubit.isShowResult) {
                  onDoneQuiz();
                  return;
                }
                _buildDialogCompleted(seeResultCallback: () {
                  _cubit.showAnswer();
                  _controller.scrollToIndex(0,
                      duration: const Duration(milliseconds: 200),
                      preferPosition: AutoScrollPosition.begin);
                }, retryCallback: () {
                  _cubit.retryQuiz();
                  _controller.scrollToIndex(0,
                      duration: const Duration(milliseconds: 200),
                      preferPosition: AutoScrollPosition.begin);
                }, continueLearnCallback: () {
                  onDoneQuiz();
                });
              } else {
                final int newIndex = _cubit.selectedCourseIndex + 1;
                if (newIndex > lengthQuiz - 1) return;
                _controller.scrollToIndex(newIndex,
                    duration: const Duration(milliseconds: 200),
                    preferPosition: AutoScrollPosition.middle);
                _cubit.jumpToIndexCourse(newIndex);
              }
            },
            currentPositionTitle: lengthQuiz == 0
                ? '0/0'
                : '${_cubit.selectedCourseIndex + 1}/$lengthQuiz',
            previousButtonTitle: R.string.previous_question.tr(),
            nextButtonTitle: R.string.next_question.tr(),
            isCompleted: _cubit.canComplete,
          ),
        ],
      ),
    );
  }

  Widget buildStep({required int index, required VoidCallback onTap}) {
    final QuizLesson? quizData = _cubit.listQuiz[index];

    Color colorBackground = R.color.white;
    Color colorText = R.color.accentColor;
    Color? borderColor = R.color.mainColor;

    final bool isCurrent = _cubit.selectedCourseIndex == index;
    final bool isAnswered = _cubit.answer[index]?.isNotEmpty == true;
    final bool isRight = _cubit.answer[index].toString() ==
        quizData?.quiz?.quizAnswers
            ?.where((e) => e?.isCorrect == true)
            .map((e) => e?.name)
            .toList()
            .toString();

    if (_cubit.isShowResult) {
      colorText = R.color.white;
      borderColor = null;
      if (isRight) {
        colorBackground = R.color.green;
      } else {
        colorBackground = R.color.red;
      }
    } else {
      if (isCurrent) {
        colorText = R.color.main_1;
        colorBackground = R.color.white;
        borderColor = null;
      } else if (isAnswered) {
        colorBackground = R.color.greenGradientBottom;
        colorText = R.color.white;
        borderColor = null;
      } else {
        colorText = R.color.main_1;
        colorBackground = R.color.transparent;
      }
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 30,
        width: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorBackground,
          border: borderColor == null
              ? null
              : Border.all(
                  width: 1,
                  color: borderColor,
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
      ),
    );
  }

  void _buildDialogCompleted({
    required VoidCallback seeResultCallback,
    required VoidCallback retryCallback,
    required VoidCallback continueLearnCallback,
  }) {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => QuizResultWidget(
        rightAnswer: _cubit.countAnswerRight,
        totalQuiz: _cubit.listQuiz.length,
        minCompletePercent: _cubit.minCompletePercent,
        seeResultCallback: seeResultCallback,
        retryCallback: retryCallback,
        continueLearnCallback: continueLearnCallback,
      ),
    );
  }

  void onDoneQuiz() {
    if (widget.onDone != null) {
      widget.onDone!(_cubit.isPassed);
    }
  }
}
