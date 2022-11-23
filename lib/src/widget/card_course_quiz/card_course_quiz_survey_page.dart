import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/post_survey_request.dart';
import 'package:medical/src/model/response/list_quiz_lesson_response.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/text_field_widget.dart';

import 'card_course_quiz.dart';

enum SurveyQuestionTypes { SingleChoice, MultipleChoice, Text, Range }

class CardCourseQuizSurveyPage extends StatefulWidget {
  final int index;
  final QuizData quizData;
  final Function(QuestionAnswerResults, bool) onSubmitAnswer;
  final String surveySectionId;
  final int? status;

  const CardCourseQuizSurveyPage({
    Key? key,
    required this.quizData,
    required this.index,
    required this.onSubmitAnswer,
    required this.surveySectionId,
    this.status = 0,
  }) : super(key: key);

  @override
  CardCourseQuizSurveyPageState createState() =>
      CardCourseQuizSurveyPageState();
}

class CardCourseQuizSurveyPageState extends State<CardCourseQuizSurveyPage>
    with AutomaticKeepAliveClientMixin {
  late CardCourseQuizCubit _cubit;
  final TextEditingController _textController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    final AppRepository repository = AppRepository();
    _cubit = CardCourseQuizCubit(repository);
    _cubit.fillAnswer(widget.quizData);
    widget.onSubmitAnswer(
      QuestionAnswerResults(
        surveyQuestionId: widget.quizData.id,
        surveySectionId: widget.surveySectionId,
        surveyAnswerIdList: _cubit.listAnswerChoosing,
      ),
      false,
    );
    if (widget.quizData.results != null &&
        widget.quizData.answers?.isEmpty == true) {
      String text = widget.quizData.results!.isNotEmpty
          ? widget.quizData.results!.last.content ?? ''
          : '';
      _textController.text = text;
      if (text.isNotEmpty) {
        widget.onSubmitAnswer(
            QuestionAnswerResults(
              surveyQuestionId: widget.quizData.id,
              surveySectionId: widget.surveySectionId,
              content: text.trim(),
            ),
            false);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocProvider(
          create: (context) => _cubit,
          child: BlocConsumer<CardCourseQuizCubit, CardCourseQuizState>(
            listener: (context, state) {
              print("state: $state");
              if (state is CardCourseQuizFailure) {
                Message.showToastMessage(context, state.error);
              }
              if (state is CardCourseQuizFillText) {
                _textController.text = state.text;
                if (widget.onSubmitAnswer != null && state.text != null) {
                  widget.onSubmitAnswer(
                      QuestionAnswerResults(
                          surveyQuestionId: widget.quizData.id,
                          surveySectionId: widget.surveySectionId,
                          content: state.text.trim()),
                      false);
                }
              }
              if (state is CardCourseQuizFillTextField) {
                _textController.text = state.text;
                if (widget.onSubmitAnswer != null && state.text != null) {
                  widget.onSubmitAnswer(
                      QuestionAnswerResults(
                          surveyQuestionId: widget.quizData.id,
                          surveySectionId: widget.surveySectionId,
                          content: state.text.trim()),
                      false);
                }
              }
              if (state is ChooseAnswerSuccess) {
                if (widget.onSubmitAnswer != null) {
                  widget.onSubmitAnswer(
                      QuestionAnswerResults(
                        surveyQuestionId: widget.quizData.id,
                        surveySectionId: widget.surveySectionId,
                        surveyAnswerIdList: _cubit.listAnswerChoosing,
                      ),
                      false);
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
      case 4:
        return SurveyQuestionTypes.Range;
      default:
        return SurveyQuestionTypes.SingleChoice;
    }
  }

  Widget buildPage(BuildContext context, CardCourseQuizState state) {
    final QuizData quizData = widget.quizData;
    final List<AnswerData> listAnswer = quizData.answers ?? [];
    listAnswer.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
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
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: R.color.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            quizData.name ?? "",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: R.color.textDark,
                height: 1.4),
            //    maxLines: 2,
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: buildAnswerByType(quizData),
          ),
        ],
      ),
    );
  }

  Widget buildAnswerByType(QuizData quizData) {
    final SurveyQuestionTypes type = getTypeQuestion(quizData.type);
//    bool isAnsweredQuestion = quizData.hasUserAnswer;
    bool isCompletedSurvey = widget.status == 1;

    if (type == SurveyQuestionTypes.Text) {
      return Container(
        alignment: Alignment.topCenter,
        child: TextFieldWidget(
          autoFocus: false,
          // controller: _textController,
          borderColor: R.color.accentColor,
          maxLength: 1000,
          readOnly: isCompletedSurvey,
          onSubmitted: (text) {
            if (text != null) {
              widget.onSubmitAnswer(
                QuestionAnswerResults(
                  surveyQuestionId: quizData.id,
                  surveySectionId: widget.surveySectionId,
                  content: text.trim(),
                  isTyping: true,
                ),
                true,
              );
            }
          },
        ),
      );
    } else if (type == SurveyQuestionTypes.Range) {
      return ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: quizData.answers?.length ?? 0,
          separatorBuilder: (context, indexQuestion) => SizedBox(
                height: 10.h,
              ),
          itemBuilder: (context, indexQuestion) {
            final AnswerData data = (quizData.answers ?? [])[indexQuestion];
            return buildRange(isCompletedSurvey, indexQuestion, data);
          });
    } else {
      return ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: quizData.answers?.length ?? 0,
          separatorBuilder: (context, indexQuestion) => SizedBox(
                height: 10.h,
              ),
          itemBuilder: (context, indexQuestion) {
            final AnswerData data = (quizData.answers ?? [])[indexQuestion];
            return buildQuestion(
                isCompletedSurvey: isCompletedSurvey,
                data: data,
                //          isAnsweredQuestion: isAnsweredQuestion,
                isSingleChoice: getTypeQuestion(quizData.type) ==
                    SurveyQuestionTypes.SingleChoice);
          });
    }
  }

  Widget buildQuestion(
      {required AnswerData data,
      bool isCompletedSurvey = false,
      // bool isAnsweredQuestion = false,
      bool isSingleChoice = true}) {
    final String id = data.id ?? "";
    final bool isSelected = _cubit.listAnswerChoosing.contains(id);
    return Container(
      padding: EdgeInsets.all(4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.h),
        color: isSelected ? R.color.color0xffB1DDDB : R.color.white,
        border: Border.all(
          width: isSelected && !_cubit.isShowAnswer ? 0 : 1,
          color: isSelected ? Colors.transparent : R.color.grayComponentBorder,
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (!isCompletedSurvey) {
            _cubit.checkBox(id, isSingleChoice);
          }
        },
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
                          if (!isCompletedSurvey) {
                            _cubit.checkBox(id, isSingleChoice);
                          }
                        },
                        groupValue: true,
                      )
                    : Checkbox(
                        value: isSelected,
                        activeColor: R.color.accentColor,
                        splashRadius: 20,
                        onChanged: (value) {
                          if (!isCompletedSurvey) {
                            _cubit.checkBox(id, isSingleChoice);
                          }
                        }),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  data.content ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? R.color.accentColor : R.color.textDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRange(bool isCompletedSurvey, int index, AnswerData data) {
    final String id = data.id ?? "";
    final bool isSelected = _cubit.listAnswerChoosing.contains(id);
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => isCompletedSurvey ? null : _cubit.checkBox(id, true),
          child: Container(
            padding: EdgeInsets.all(16.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.h),
              color: isSelected ? R.color.color0xffB1DDDB : R.color.white,
              border: Border.all(
                width: isSelected && !_cubit.isShowAnswer ? 0 : 1,
                color: isSelected
                    ? R.color.accentColor
                    : R.color.grayComponentBorder,
              ),
            ),
            child: Text(
              '${data.flag ?? ''}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? R.color.accentColor : R.color.textDark,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            data.content ?? '',
            style: R.style.normalTextStyle,
            maxLines: 1,
            textAlign: TextAlign.start,
          ),
        )
      ],
    );
  }
}
