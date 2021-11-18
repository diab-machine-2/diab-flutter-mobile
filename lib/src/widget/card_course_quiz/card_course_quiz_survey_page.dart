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
  final ValueChanged<QuestionAnswerResults> onSubmitAnswer;

  const CardCourseQuizSurveyPage(
      {Key? key,
      required this.quizData,
      required this.index,
      required this.onSubmitAnswer})
      : super(key: key);

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
              if (state is CardCourseQuizFailure)
                Message.showToastMessage(context, state.error);
              if (state is ChooseAnswerSuccess) {
                if (widget.onSubmitAnswer != null) {
                  widget.onSubmitAnswer(
                    QuestionAnswerResults(
                      surveyQuestionId: widget.quizData.id,
                      surveyAnswerIdList: _cubit.listAnswerChoosing,
                    ),
                  );
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
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: R.color.textDark,
                height: 1.4),
            maxLines: 2,
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
    if (type == SurveyQuestionTypes.Text) {
      return Container(
        alignment: Alignment.topCenter,
        child: TextFieldWidget(
          controller: _textController,
          borderColor: R.color.accentColor,
          maxLength: 1000,
          onChanged: (text) {
            if (widget.onSubmitAnswer != null && text != null) {
              widget.onSubmitAnswer(QuestionAnswerResults(
                  surveyQuestionId: quizData.id, content: text.trim()));
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
            return buildRange(indexQuestion, data);
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
                data: data,
                isSingleChoice: getTypeQuestion(quizData.type) ==
                    SurveyQuestionTypes.SingleChoice);
          });
    }
  }

  Widget buildQuestion({required AnswerData data, bool isSingleChoice = true}) {
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
          _cubit.checkBox(id, isSingleChoice);
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

  Widget buildRange(int index, AnswerData data) {
    final String id = data.id ?? "";
    final bool isSelected = _cubit.listAnswerChoosing.contains(id);
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => _cubit.checkBox(id, true),
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
              index.toString() /* ?? ""*/,
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
            style: TextStyle(
              fontSize: 14,
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
}
