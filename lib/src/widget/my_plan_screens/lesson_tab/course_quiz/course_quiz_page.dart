import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/app_sharing.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/response/quiz_lesson.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/widgets/bottom_sheet_share_lesson.dart';
import 'package:medical/src/widgets/custom_bottom_bar_widget.dart';
import 'package:medical/src/widgets/custom_scroll_physics.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../card_course_quiz/card_course_quiz.dart';
import '../lesson_detail/widgets/share_lesson_button.dart';
import 'course_quiz.dart';
import 'widgets/quiz_result_popup.dart';

const Duration duration = Duration(milliseconds: 1);

class CourseQuizPage extends StatefulWidget {
  const CourseQuizPage(
      {Key? key,
      required this.lessonId,
      this.lessonSectionItem,
      this.onDone,
      required this.lessonDetail})
      : super(key: key);

  final String lessonId;
  final LessonSectionItem? lessonSectionItem;
  final LessonSectionListResponseData lessonDetail;
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
    firebaseSetup();
    final AppRepository repository = AppRepository();
    _cubit = CourseQuizCubit(
      repository,
      lessonId: widget.lessonId,
      lessonSectionItem: widget.lessonSectionItem,
      lessonDetail: widget.lessonDetail,
    );
    _cubit.initData();
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

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: "quiz_lession",
      screenClass: "CourseQuizPage",
    );
    AppSettings.currentScreenName = 'quiz_lession';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.color0xffDFF6EC,
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<CourseQuizCubit, CourseQuizState>(
          listener: (context, state) async {
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
              onDoneQuiz(context);
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: R.color.black),
                        onPressed: () {
                          if (_cubit.isShowResult) {
                            onDoneQuiz(context);
                            return;
                          }
                          NavigationUtil.pop(context);
                        },
                      ),
                      Expanded(
                        child: AutoSizeText(
                          R.string.knowledge_test.tr(),
                          maxLines: 1,
                          maxFontSize: 16,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: R.color.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                ShareLessonButton(
                  featureImage: _cubit.lessonDetail.image?.url,
                  lesson: _cubit.lessonSectionItem!,
                  lessonDescription: _cubit.lessonDetail.description,
                ),
              ],
            ),
            showRightCloseButton: true,
          ),
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
                  onTap: () async {
                    QuizLessonQuiz? quiz = _cubit.listQuiz[index]?.quiz;
                    await TrackingManager.analytics.logEvent(
                      name: 'component_clicked',
                      parameters: {
                        "screen_name": 'quiz_lession',
                        'component_name': 'list_quiz_question',
                        'object_id': _cubit.lessonSectionItem?.id,
                        'object_title': widget.lessonDetail.name,
                        'object_index': index,
                      },
                    );
                    _controller.scrollToIndex(index,
                        duration: duration,
                        preferPosition: AutoScrollPosition.begin);
                    _cubit.jumpToIndexCourse(index);
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
                            onAnswerQuestion: (indexAnswer) async {
                              await TrackingManager.analytics.logEvent(
                                name: 'select_quiz_answer',
                                parameters: {
                                  "screen_name": 'quiz_lession',
                                  'object_id': _cubit.lessonSectionItem?.id,
                                  'object_title': _cubit.lessonDetail.name,
                                  'object_index': indexAnswer,
                                },
                              );
                            },
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
                : () async {
                    await TrackingManager.analytics.logEvent(
                      name: 'cta_button_clicked',
                      parameters: {
                        "screen_name": 'quiz_lession',
                        'cta_button_name': 'cta_quiz_previous',
                        'object_id': _cubit.lessonSectionItem?.id,
                        'object_title': _cubit.lessonDetail.name,
                      },
                    );
                    final int newIndex = _cubit.selectedCourseIndex - 1;
                    _controller.scrollToIndex(newIndex,
                        duration: duration,
                        preferPosition: AutoScrollPosition.begin);
                    _cubit.jumpToIndexCourse(newIndex);
                  },
            isNextButtonActive:
                lengthQuiz != 0 && _cubit.selectedCourseIndex < lengthQuiz - 1,
            onTapNext: () async {
              await TrackingManager.analytics.logEvent(
                name: 'cta_button_clicked',
                parameters: {
                  "screen_name": 'quiz_lession',
                  'cta_button_name': 'cta_quiz_next',
                  'object_id': _cubit.lessonSectionItem?.id,
                  'object_title': widget.lessonDetail.name,
                },
              );
              if (lengthQuiz == 0) {
                onDoneQuiz(context);
                return;
              }

              if (_cubit.canComplete == true) {
                if (_cubit.isShowResult) {
                  // onDoneQuiz();
                  return;
                }
                //   if (_cubit.isPassed) {
                _cubit.setCompleteQuiz();
                //   }
                _buildDialogCompleted(seeResultCallback: () async {
                  await TrackingManager.analytics.logEvent(
                    name: 'cta_button_clicked',
                    parameters: {
                      "screen_name": 'quiz_lession',
                      'cta_button_name': 'cta_quiz_answer',
                      'object_id': _cubit.lessonSectionItem?.id,
                      'object_title': _cubit.lessonDetail.name,
                    },
                  );
                  _cubit.showAnswer();
                  _controller.scrollToIndex(0,
                      duration: duration,
                      preferPosition: AutoScrollPosition.begin);
                }, retryCallback: () async {
                  await TrackingManager.analytics.logEvent(
                    name: 'cta_button_clicked',
                    parameters: {
                      "screen_name": 'quiz_lession',
                      'cta_button_name': 'cta_quiz_retry',
                      'object_id': _cubit.lessonSectionItem?.id,
                      'object_title': _cubit.lessonDetail.name,
                    },
                  );
                  _cubit.retryQuiz();
                  _controller.scrollToIndex(0,
                      duration: duration,
                      preferPosition: AutoScrollPosition.begin);
                }, continueLearnCallback: () async {
                  await TrackingManager.analytics.logEvent(
                    name: 'cta_button_clicked',
                    parameters: {
                      "screen_name": 'quiz_lession',
                      'cta_button_name': 'cta_quiz_continue',
                      'object_id': _cubit.lessonSectionItem?.id,
                      'object_title': _cubit.lessonDetail.name,
                    },
                  );
                  onDoneQuiz(context);
                }, skipCallback: () async {
                  await TrackingManager.analytics.logEvent(
                    name: 'cta_button_clicked',
                    parameters: {
                      "screen_name": 'quiz_lession',
                      'cta_button_name': 'cta_quiz_skip',
                      'object_id': _cubit.lessonSectionItem?.id,
                      'object_title': _cubit.lessonDetail.name,
                    },
                  );
                  _buildDialogCompleted(
                      rate: 90,
                      seeResultCallback: () {
                        _cubit.showAnswer();
                        _controller.scrollToIndex(0,
                            duration: duration,
                            preferPosition: AutoScrollPosition.begin);
                      },
                      retryCallback: () {
                        _cubit.retryQuiz();
                        _controller.scrollToIndex(0,
                            duration: duration,
                            preferPosition: AutoScrollPosition.begin);
                      },
                      continueLearnCallback: () {
                        onDoneQuiz(context);
                      },
                      skipCallback: () {});
                });
              } else {
                final int newIndex = _cubit.selectedCourseIndex + 1;
                if (newIndex > lengthQuiz - 1) return;
                _controller.scrollToIndex(newIndex,
                    duration: duration,
                    preferPosition: AutoScrollPosition.begin);
                _cubit.jumpToIndexCourse(newIndex);
              }
            },
            currentPositionTitle: lengthQuiz == 0
                ? '0/0'
                : '${_cubit.selectedCourseIndex + 1}/$lengthQuiz',
            previousButtonTitle: R.string.previous_question.tr(),
            nextButtonTitle: R.string.next_question.tr(),
            isCompleted: _cubit.isShowResult ? null : _cubit.canComplete,
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

    final List<String?> selectedAnswers = _cubit.answer[index] ?? [];
    final List<String?> correctAnswers = quizData?.quiz?.quizAnswers
            ?.where((e) => e?.isCorrect == true)
            .map((e) => e?.id)
            .toList() ??
        [];
    selectedAnswers.sort((a, b) => (a ?? '').compareTo(b ?? ''));
    correctAnswers.sort((a, b) => (a ?? '').compareTo(b ?? ''));
    final bool isRight = listEquals(selectedAnswers, correctAnswers);

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

  Future<void> _buildDialogCompleted({
    required VoidCallback seeResultCallback,
    required VoidCallback retryCallback,
    required VoidCallback continueLearnCallback,
    required VoidCallback skipCallback,
    double? rate,
  }) async {
    await TrackingManager.analytics.logEvent(
      name: 'component_displayed',
      parameters: {
        "screen_name": 'quiz_lession',
        'component_name': 'popup_quiz_complete',
        'object_id': _cubit.lessonSectionItem?.id,
        'object_title': widget.lessonDetail.name,
      },
    );
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => QuizResultWidget(
        rate: rate,
        isQuizLesson: _cubit.isQuizLesson,
        rightAnswer: _cubit.countAnswerRight,
        totalQuiz: _cubit.listQuiz.length,
        minCompletePercent: _cubit.minCompletePercent,
        seeResultCallback: seeResultCallback,
        retryCallback: retryCallback,
        continueLearnCallback: continueLearnCallback,
        skipCallback: skipCallback,
      ),
    );
  }

  Future<void> onDoneQuiz(BuildContext context) async {
    await TrackingManager.analytics.logEvent(
      name: 'quiz_lesson_complete',
      parameters: {
        "screen_name": 'quiz_lession',
        'object_id': _cubit.lessonSectionItem?.id,
        'object_title': _cubit.lessonSectionItem?.name,
      },
    );
    BottomSheetShareLesson.showDialogShareLesson(
      context,
      onShare: () => _onShareLesson(
        context,
        lesson: _cubit.lessonSectionItem!,
      ),
      onCancel: () {
        NavigationUtil.pop(context);
        if (widget.onDone == null) {
          NavigationUtil.pop(context);
          return;
        } else {}
        widget.onDone!(_cubit.isPassed);
      },
    );
  }

  _onShareLesson(
    BuildContext context, {
    required LessonSectionItem lesson,
  }) async {
    String shareLink = await DynamicLinkConfig.instance.createShareLessonLink(
        lesson: lesson,
        featureImage: _cubit.lessonDetail.image?.url,
        lessonDescription: _cubit.lessonDetail.description);
    AppShare.instance.lessonDetail(context, shareLink, lesson.name ?? "");
  }
}
