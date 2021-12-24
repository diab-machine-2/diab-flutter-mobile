import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/quiz_lesson.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/popup_window_widget.dart';

import 'card_course_quiz.dart';

class CardCourseQuizPage extends StatefulWidget {
  final int index;
  final QuizLesson? quizData;
  final ValueChanged<List<String>> onSubmitAnswer;

  const CardCourseQuizPage(
      {Key? key,
      required this.quizData,
      required this.index,
      required this.onSubmitAnswer})
      : super(key: key);

  @override
  CardCourseQuizPageState createState() => CardCourseQuizPageState();
}

class CardCourseQuizPageState extends State<CardCourseQuizPage>
    with AutomaticKeepAliveClientMixin {
  late CardCourseQuizCubit _cubit;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    final AppRepository repository = AppRepository();
    _cubit = CardCourseQuizCubit(repository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<CardCourseQuizCubit, CardCourseQuizState>(
          listener: (context, state) {
            if (state is CardCourseQuizFailure)
              Message.showToastMessage(context, state.error);
            if (state is ChooseAnswerSuccess) {
              widget.onSubmitAnswer(_cubit.listAnswerChoosing);
            }
          },
          builder: (context, state) {
            if (state is CardCourseQuizLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
            }
            return buildPage(context, state);
          },
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, CardCourseQuizState state) {
    if (widget.quizData == null) return const SizedBox();
    final QuizLesson quizData = widget.quizData!;
    final List<QuizLessonQuizQuizAnswers?> listAnswer = quizData.answers;
    listAnswer.sort((a, b) => (a?.order ?? 0).compareTo(b?.order ?? 0));
    final bool isSingleChoice = quizData.type == '1';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: R.color.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            R.string.question_number.tr(args: [(widget.index + 1).toString()]),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: R.color.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            quizData.name,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: R.color.textDark,
                height: 1.4),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: quizData.answers.length,
                separatorBuilder: (context, indexQuestion) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, indexQuestion) {
                  final QuizLessonQuizQuizAnswers? data =
                      quizData.answers[indexQuestion];
                  return buildQuestion(
                    data: data,
                    isSingleChoice: isSingleChoice,
                  );
                }),
          ),
          const SizedBox(height: 10),
          Visibility(
            visible: _cubit.isShowAnswer,
            child: Center(
              child: GestureDetector(
                  onTap: () {
                    showDescriptionPopup(quizData.quiz?.explain ?? '');
                  },
                  child: Image.asset(
                    R.drawable.ic_help_circle,
                    fit: BoxFit.fill,
                    height: 28,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuestion(
      {required QuizLessonQuizQuizAnswers? data, bool isSingleChoice = true}) {
    final String id = data?.id ?? "";
    final bool isSelected = _cubit.listAnswerChoosing.contains(id);
    final bool isAnswerRight = data?.isCorrect == true;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? R.color.color0xffB1DDDB : R.color.white,
          border: Border.all(
            width: isSelected && !_cubit.isShowAnswer ? 0 : 1,
            color: _cubit.isShowAnswer
                ? (isAnswerRight
                    ? R.color.green
                    : (isSelected ? R.color.red : R.color.grayComponentBorder))
                : (isSelected
                    ? Colors.transparent
                    : R.color.grayComponentBorder),
          )),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _cubit.isShowAnswer
            ? null
            : () => _cubit.checkBox(id, isSingleChoice),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Theme(
              data: ThemeData(
                //here change to your color
                unselectedWidgetColor: R.color.grayBorder,
              ),
              child: Transform.scale(
                scale: 1.3,
                child: isSingleChoice
                    ? Radio<bool>(
                        value: isSelected,
                        activeColor: R.color.accentColor,
                        splashRadius: 20,
                        onChanged: _cubit.isShowAnswer
                            ? null
                            : (value) {
                                _cubit.checkBox(id, isSingleChoice);
                              },
                        groupValue: true,
                      )
                    : Checkbox(
                        value: isSelected,
                        activeColor: R.color.accentColor,
                        splashRadius: 20,
                        onChanged: _cubit.isShowAnswer
                            ? null
                            : (value) {
                                _cubit.checkBox(id, isSingleChoice);
                              }),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  data?.name ?? "",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? R.color.accentColor : R.color.textDark,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: _cubit.isShowAnswer && (isSelected || isAnswerRight),
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Image.asset(
                  isAnswerRight ? R.drawable.ic_check : R.drawable.ic_close,
                  color: isAnswerRight ? R.color.green : R.color.red,
                  height: 20,
                ),
              ),
            )
          ],
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
          padding: const EdgeInsets.all(16),
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
                    child: Text(R.string.explain.tr(),
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
            ],
          ),
        ),
      ),
    );
  }

  void showAnswer() {
    _cubit.showAnswer();
  }

  void clearAllAnswer() {
    _cubit.clearAllAnswer();
  }
}
