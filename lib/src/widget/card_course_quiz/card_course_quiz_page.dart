import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/list_quiz_lesson_response.dart';
import 'package:medical/src/utils/logger.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/popup_window_widget.dart';
import 'package:medical/src/widgets/text_field_widget.dart';

import 'card_course_quiz.dart';

enum SurveyQuestionTypes {
  SingleChoice,
  MultipleChoice,
  Text,
  Range
}

class CardCourseQuizPage extends StatefulWidget {
  final int index;
  final QuizData quizData;
  final ValueChanged<List<String>> onSubmitAnswer;
  final bool isQuiz;
  final ValueChanged<bool>? onChoseAnswer;

  const CardCourseQuizPage(
      {Key? key,
      required this.quizData,
      required this.index,
      required this.onSubmitAnswer,
        this.onChoseAnswer,
      this.isQuiz = true})
      : super(key: key);

  @override
  CardCourseQuizPageState createState() => CardCourseQuizPageState();
}

class CardCourseQuizPageState extends State<CardCourseQuizPage>
    with AutomaticKeepAliveClientMixin {
  late CardCourseQuizCubit _cubit;
  TextEditingController _textController = TextEditingController();


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    AppRepository repository = AppRepository();
    _cubit = CardCourseQuizCubit(repository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<CardCourseQuizCubit, CardCourseQuizState>(
          listener: (context, state) {
            if (state is CardCourseQuizFailure)
              Message.showToastMessage(context, state.error);
            if (state is ChooseAnswerSuccess) {
              if (widget.onChoseAnswer != null) {
                widget.onChoseAnswer!(!Utils.isEmpty(_cubit.listAnswerChoosing));
              }
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

  SurveyQuestionTypes getTypeQuestion(int? type) {
    switch (type) {
      case 1:
        return SurveyQuestionTypes.SingleChoice;
      case 2:
        return SurveyQuestionTypes.MultipleChoice;
      case 3:
        return SurveyQuestionTypes.Text;
      case 3:
        return SurveyQuestionTypes.Range;
      default:
        return SurveyQuestionTypes.SingleChoice;
    }
  }

  Widget buildPage(BuildContext context, CardCourseQuizState state) {
    QuizData quizData = widget.quizData;
    List<AnswerData> listAnswer = quizData.answers ?? [];
    listAnswer.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    bool isAnswering =
        !_cubit.isAnswered && _cubit.listAnswerChoosing.isNotEmpty;
    bool isAnswerRight = _cubit.isAnswered &&
        _cubit.listAnswerApply.toString() ==
            quizData.answers
                ?.where((e) => e.isCorrect == true)
                .map((e) => e.id)
                .toList()
                .toString();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 20.h),
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
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: R.color.textDark,
            ),
          ),
          SizedBox(height: 2),
          Text(
            quizData.name ?? "",
            style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: R.color.textDark,
                height: 1.4),
            maxLines: 2,
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: buildAnswerByType(quizData),
          ),
          SizedBox(height: 10.h),
          _cubit.isAnswered
              ? Column(
                  children: [
                    Center(
                      child: Image.asset(
                        isAnswerRight
                            ? R.drawable.ic_congratulation
                            : R.drawable.ic_regret,
                        height: 60.h,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Center(
                      child: SizedBox(
                        // width: 200.w,
                        child: Text(
                          isAnswerRight
                              ? R.string.congratulations_your_reply_is_correct
                                  .tr()
                              : R.string.regret_answer.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: R.color.textDark,
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                  ],
                )
              : Container(),
          Visibility(
            visible:  widget.isQuiz && !_cubit.isShowAnswer,
            child: Center(
              child: Container(
                alignment: Alignment.center,
                width: 128.w,
                child: ButtonWidget(
                  height: 35.h,
                  title: R.string.check.tr(),
                  onPressed: !isAnswering
                      ? null
                      : () {
                          _cubit.applyAnswer();
                          widget.onSubmitAnswer(_cubit.listAnswerApply);
                        },
                  backgroundColor: Colors.transparent,
                  borderColor:
                      !isAnswering ? R.color.grayBorder : R.color.accentColor,
                  textColor:
                      !isAnswering ? R.color.grayBorder : R.color.accentColor,
                ),
              ),
            ),
          ),
          Visibility(
            visible: widget.isQuiz && _cubit.isShowAnswer,
            child: Center(
              child: GestureDetector(
                  onTap: () {
                    showDescriptionPopup(quizData.explain);
                  },
                  child: Image.asset(
                    R.drawable.ic_help_circle,
                    color: R.color.accentColor,
                    fit: BoxFit.fill,
                    height: 28.h,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAnswerByType(QuizData quizData) {
    SurveyQuestionTypes type = getTypeQuestion(quizData.type);
    if (type == SurveyQuestionTypes.Text) {
      return TextFieldWidget(
        controller: _textController,
        borderColor: R.color.accentColor,
        onChanged: (text) {
          if (widget.onChoseAnswer != null) {
            widget.onChoseAnswer!(!Utils.isEmpty(text));
          }
        },
      );
    } else if (type == SurveyQuestionTypes.Range) {
      return ListView.separated(
          padding: EdgeInsets.zero,
          // physics: CustomScrollPhysics(itemDimension: height(850) + 10),
          shrinkWrap: true,
          itemCount: quizData.answers?.length ?? 0,
          separatorBuilder: (context, indexQuestion) => SizedBox(
            height: 10.h,
          ),
          itemBuilder: (context, indexQuestion) {
            AnswerData data = (quizData.answers ?? [])[indexQuestion];
            return buildRange(indexQuestion, data);
          });
    } else {
      return ListView.separated(
          padding: EdgeInsets.zero,
          // physics: CustomScrollPhysics(itemDimension: height(850) + 10),
          shrinkWrap: true,
          itemCount: quizData.answers?.length ?? 0,
          separatorBuilder: (context, indexQuestion) => SizedBox(
            height: 10.h,
          ),
          itemBuilder: (context, indexQuestion) {
            AnswerData data = (quizData.answers ?? [])[indexQuestion];
            return buildQuestion(data: data, isSingleChoice: getTypeQuestion(quizData.type) == SurveyQuestionTypes.SingleChoice);
          });
    }
  }

  Widget buildQuestion({required AnswerData data, bool isSingleChoice = true}) {
    String id = data.id ?? "";
    bool isSelected = _cubit.listAnswerChoosing.contains(id);
    bool isAnswerRight = data.isCorrect == true;
    return Container(
      padding: EdgeInsets.all(4.h),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.h),
          color: isSelected ? R.color.color0xffB1DDDB : R.color.white,
          border: Border.all(
            width: isSelected && !_cubit.isShowAnswer ? 0 : 1,
            color: _cubit.isShowAnswer
                ? (isAnswerRight ? R.color.accentColor : R.color.red)
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
                        onChanged: (value) {
                          _cubit.checkBox(id, isSingleChoice);
                        },
                        groupValue: true,
                      )
                    : Checkbox(
                        value: isSelected,
                        activeColor: R.color.accentColor,
                        splashRadius: 20,
                        onChanged: (value) {
                          _cubit.checkBox(id, isSingleChoice);
                        }),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  data.name ?? "",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? R.color.accentColor : R.color.textDark,
                  ),
                ),
              ),
            ),
            Visibility(
                visible: _cubit.isShowAnswer,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Image.asset(
                    isAnswerRight ? R.drawable.ic_check : R.drawable.ic_close,
                    color: isAnswerRight ? R.color.accentColor : R.color.red,
                    height: 20.h,
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget buildRange(int index, AnswerData data) {
    String id = data.id ?? "";
    bool isSelected = _cubit.listAnswerChoosing.contains(id);
    bool isAnswerRight = data.isCorrect == true;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(16.h),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.h),
              color: isSelected ? R.color.color0xffB1DDDB : R.color.white,
              border: Border.all(
                width: isSelected && !_cubit.isShowAnswer ? 0 : 1,
                color: _cubit.isShowAnswer
                    ? (isAnswerRight ? R.color.accentColor : R.color.red)
                    : (isSelected
                    ? R.color.accentColor
                    : R.color.grayComponentBorder),
              )),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _cubit.isShowAnswer
                ? null
                : () => _cubit.checkBox(id, true),
            child: Text(
              index.toString()/* ?? ""*/,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? R.color.accentColor : R.color.textDark,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h,),
        Expanded(
          child: Text(
            data.name ?? "",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: R.color.textDark,
            ),
            maxLines: 1,
            textAlign: TextAlign.start,
          ),
        )
      ],
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
        padding: EdgeInsets.all(16.h),
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
          ],
        ),
      )),
    );
  }

  void showAnswer() {
    _cubit.showAnswer();
  }

  void clearAllAnswer() {
    _cubit.clearAllAnswer();
  }
}
