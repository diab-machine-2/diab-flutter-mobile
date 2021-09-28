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
  });
  final int questionKey;
  final String question;
  final List<String> answers;
  int? selectedAnswer;

  void clearSelection() => selectedAnswer = null;

  factory Question.question_1() {
    return Question(
      questionKey: questionKey1,
      question: R.string.survey_question_1.tr(),
      answers: [
        R.string.survey_answer_1_a.tr(),
        R.string.survey_answer_1_b.tr(),
        R.string.survey_answer_1_c.tr(),
        R.string.survey_answer_1_d.tr(),
      ]
    );
  }

  factory Question.question_2() {
    return Question(
      questionKey: questionKey2,
      question: R.string.survey_question_2.tr(),
      answers: [
        R.string.survey_answer_2_a.tr(),
        R.string.survey_answer_2_b.tr(),
      ]
    );
  }

  factory Question.question_3() {
    return Question(
      questionKey: questionKey3,
      question: R.string.survey_question_3.tr(),
      answers: [
        R.string.survey_answer_3_a.tr(),
        R.string.survey_answer_3_b.tr(),
        R.string.survey_answer_3_c.tr(),
      ]
    );
  }

  factory Question.question_4_1() {
    return Question(
      questionKey: questionKey4_1,
      question: R.string.survey_question_4_1.tr(),
      answers: [
        R.string.survey_answer_4_1_a.tr(),
        R.string.survey_answer_4_1_b.tr(),
        R.string.survey_answer_4_1_c.tr(),
      ]
    );
  }

    factory Question.question_4_2() {
    return Question(
      questionKey: questionKey4_2,
      question: R.string.survey_question_4_2.tr(),
      answers: [
        R.string.survey_answer_4_2_a.tr(),
        R.string.survey_answer_4_2_b.tr(),
      ]
    );
  }

  String getAnswer(int index) {
    return '${_convertIndexToHeader(index)}. ${answers[index]}';
  }

  String _convertIndexToHeader(int index) {
    if(index == 0) return 'A';
    if(index == 1) return 'B';
    if(index == 2) return 'C';
    if(index == 3) return 'D';
    return '';
  }
}