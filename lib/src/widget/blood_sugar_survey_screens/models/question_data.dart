import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

const int questionKey1 = 1;
const int questionKey2 = 2;
const int questionKey3 = 3;
const int questionKey4_1 = 4;
const int questionKey4_2 = 5;

class Question {
  Question({
    required this.questionKey,
    required this.question,
    required this.answers,
    this.selectedAnswer,
    this.hasExtendDetail = false,
  });
  final int questionKey;
  final String question;
  final List<AnswerData> answers;
  int? selectedAnswer;
  bool hasExtendDetail;

  void clearSelection() => selectedAnswer = null;

  factory Question.question_1() {
    return Question(
      questionKey: questionKey1,
      question: R.string.survey_question_1.tr(),
      answers: [
        AnswerData(
          answer: R.string.survey_answer_1_a.tr(),
        ),
        AnswerData(
          answer: R.string.survey_answer_1_b.tr(),
        ),
        AnswerData(
          answer: R.string.survey_answer_1_c.tr(),
        ),
        AnswerData(
          answer: R.string.survey_answer_1_d.tr(),
        ),
      ],
    );
  }

  factory Question.question_2() {
    return Question(
        questionKey: questionKey2,
        question: R.string.survey_question_2.tr(),
        hasExtendDetail: true,
        answers: [
          AnswerData(
            answer: R.string.survey_answer_2_a.tr(),
            image: R.drawable.ic_answer_yes,
          ),
          AnswerData(
            answer: R.string.survey_answer_2_b.tr(),
            image: R.drawable.ic_answer_no,
          ),
        ]);
  }

  factory Question.question_3() {
    return Question(
        questionKey: questionKey3,
        question: R.string.survey_question_3.tr(),
        answers: [
          AnswerData(
            answer: R.string.survey_answer_3_a.tr(),
            image: R.drawable.ic_answer_insulin,
          ),
          AnswerData(
            answer: R.string.survey_answer_3_b.tr(),
            image: R.drawable.ic_answer_pill,
          ),
          AnswerData(
            answer: R.string.survey_answer_3_c.tr(),
            image: R.drawable.ic_answer_no_pill,
          ),
        ]);
  }

  factory Question.question_4_1() {
    return Question(
        questionKey: questionKey4_1,
        question: R.string.survey_question_4_1.tr(),
        answers: [
          AnswerData(
            answer: R.string.survey_answer_4_1_a.tr(),
            image: R.drawable.ic_answer_one,
          ),
          AnswerData(
            answer: R.string.survey_answer_4_1_b.tr(),
            image: R.drawable.ic_answer_two,
          ),
          AnswerData(
            answer: R.string.survey_answer_4_1_c.tr(),
            image: R.drawable.ic_answer_three,
          ),
        ]);
  }

  factory Question.question_4_2() {
    return Question(
        questionKey: questionKey4_2,
        question: R.string.survey_question_4_2.tr(),
        answers: [
          AnswerData(
            answer: R.string.survey_answer_4_2_a.tr(),
            image: R.drawable.ic_answer_yes,
          ),
          AnswerData(
            answer: R.string.survey_answer_4_2_b.tr(),
            image: R.drawable.ic_answer_no,
          ),
        ]);
  }

  String getAnswer(int index) {
    return '${_convertIndexToHeader(index)}. ${answers[index].answer}';
  }

  String _convertIndexToHeader(int index) {
    if (index == 0) return 'A';
    if (index == 1) return 'B';
    if (index == 2) return 'C';
    if (index == 3) return 'D';
    return '';
  }
}

class AnswerData {
  AnswerData({
    required this.answer,
    this.image,
  });
  final String answer;
  final String? image;
}
