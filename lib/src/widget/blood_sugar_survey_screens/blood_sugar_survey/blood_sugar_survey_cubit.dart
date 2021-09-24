import 'package:bloc/bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import '../models/question_data.dart';

import 'blood_sugar_survey_state.dart';

class BloodSugarSurveyCubit extends Cubit<BloodSugarSurveyState> {
  BloodSugarSurveyCubit(this.repository)
      : super(const BloodSugarSurveyInitial()) {
    questions.add(question1);
  }

  AppRepository repository;

  final Question question1 = Question.question_1();
  final Question question2 = Question.question_2();
  final Question question3 = Question.question_3();
  final Question question4_1 = Question.question_4_1();
  final Question question4_2 = Question.question_4_2();

  bool canSurveyDone = false;

  List<Question> questions = [];

  void onSelectedAnswer(int? questionNumber) {
    if (questionNumber == question1.questionKey) {
      handleAnswerForQuestion1();
    }
    if (questionNumber == question2.questionKey) {
      handleAnswerForQuestion2();
    }
    if (questionNumber == question3.questionKey) {
      handleAnswerForQuestion3();
    }
    if (questionNumber == question4_1.questionKey) {
      handleAnswerForQuestion4_1();
    }
    if (questionNumber == question4_2.questionKey) {
      handleAnswerForQuestion4_2();
    }
    emit(const BloodSugarSurveyLoading());
    emit(const BloodSugarSurveyInitial());
  }

  void onSubmitAnswer() {
    if (questions.contains(question1)) {
      if (canSurveyDone) {
        if (question1.selectedAnswer == 0) {
          //TODO: Tuyen call API to get sample D
          print('LOG sample D');
        }
        if (question1.selectedAnswer == 2) {
          //TODO: Tuyen call API to get sample OP
          print('LOG sample OP');
        }
        if (question1.selectedAnswer == 3) {
          //TODO: Tuyen NoSample
          print('LOG NoSample ');
        }
      } else {
        //Continue Survey from question 2
        questions.clear();
        questions.add(question2);
      }
    } else {
      if (question2.selectedAnswer == 0) {
        if (question3.selectedAnswer == 0) {
          if (question4_1.selectedAnswer == 0) {
            //TODO: Tuyen call API to get sample A1
            print('LOG sample A1');
          }
          if (question4_1.selectedAnswer == 1) {
            //TODO: Tuyen call API to get sample B
            print('LOG sample B');
          }
          if (question4_1.selectedAnswer == 2) {
            //TODO: Tuyen call API to get sample D
            print('LOG sample D');
          }
        } else {
          if (question4_2.selectedAnswer == 0) {
            //TODO: Tuyen call API to get sample FGHI
            print('LOG sample FGHI');
          }
          if (question4_2.selectedAnswer == 1) {
            //TODO: Tuyen call API to get sample K
            print('LOG sample K');
          }
        }
      }
      if (question2.selectedAnswer == 1) {
        if (question3.selectedAnswer == 0) {
          if (question4_1.selectedAnswer == 0) {
            //TODO: Tuyen call API to get sample A2
            print('LOG sample A2');
          }
          if (question4_1.selectedAnswer == 1) {
            //TODO: Tuyen call API to get sample B
            print('LOG sample B');
          }
          if (question4_1.selectedAnswer == 2) {
            //TODO: Tuyen call API to get sample D
            print('LOG sample D');
          }
        } else {
          if (question4_2.selectedAnswer == 0 ||
              question4_2.selectedAnswer == 1) {
            //TODO: Tuyen call API to get sample FGHI
            print('LOG sample FGHI');
          }
        }
      }
    }
    emit(const BloodSugarSurveyLoading());
    emit(const BloodSugarSurveyInitial());
  }

  bool onBack() {
    if (questions.contains(question1) && questions.length == 1) {
      return true;
    }
    questions.clear();
    question2.clearSelection();
    question3.clearSelection();
    question4_1.clearSelection();
    question4_2.clearSelection();
    questions.add(question1);
    onSelectedAnswer(question1.selectedAnswer);
    emit(const BloodSugarSurveyLoading());
    emit(const BloodSugarSurveyInitial());
    return false;
  }

  void handleAnswerForQuestion1() {
    if (question1.selectedAnswer == 1) {
      canSurveyDone = false;
    } else {
      canSurveyDone = true;
    }
  }

  void handleAnswerForQuestion2() {
    if (questions.contains(question2) && questions.length == 1) {
      questions.add(question3);
    }
  }

  void handleAnswerForQuestion3() {
    if (question3.selectedAnswer == 0) {
      questions = questions.sublist(0, 2);
      question4_2.clearSelection();
      questions.add(question4_1);
      if (question4_1.selectedAnswer == null) {
        canSurveyDone = false;
      }
    } else {
      questions = questions.sublist(0, 2);
      question4_1.clearSelection();
      questions.add(question4_2);
      if (question4_2.selectedAnswer == null) {
        canSurveyDone = false;
      }
    }
  }

  void handleAnswerForQuestion4_1() {
    canSurveyDone = true;
  }

  void handleAnswerForQuestion4_2() {
    canSurveyDone = true;
  }
}
