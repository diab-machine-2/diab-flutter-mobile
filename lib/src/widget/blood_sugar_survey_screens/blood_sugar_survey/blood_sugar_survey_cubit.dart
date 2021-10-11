import 'package:bloc/bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/diabetes_status_response.dart';
import 'package:medical/src/model/response/latest_hba1c_input_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import '../models/question_data.dart';

import 'blood_sugar_survey_state.dart';

class BloodSugarSurveyCubit extends Cubit<BloodSugarSurveyState> {
  BloodSugarSurveyCubit(this.repository)
      : super(const BloodSugarSurveyInitial());

  final AppRepository repository;

  final Question question1 = Question.question_1();
  final Question question2 = Question.question_2();
  final Question question3 = Question.question_3();
  final Question question4_1 = Question.question_4_1();
  final Question question4_2 = Question.question_4_2();

  bool canSurveyDone = false;

  List<Question> questions = [];

  double hba1c = -1;

  bool get isFirstQuestionScreen => questions.contains(question1);

  void initSurvey() {
    questions.add(question1);
    selectDefaultAnswerForQuestion1();
  }

  void refreshState() {
    emit(const BloodSugarSurveySuccess());
    emit(const BloodSugarSurveyInitial());
  }

  Future<void> selectDefaultAnswerForQuestion1() async {
    await Future.delayed(Duration.zero);
    emit(const BloodSugarSurveyLoading());
    final ApiResult<DiabetesStatusResponse> apiResult =
        await repository.getDiabetesStatus();
    apiResult.when(success: (DiabetesStatusResponse response) {
      if (response.data != null) {
        final DiabetesStatusResponseData data = response.data!;
        if (data.status != null && data.status! > 0 && data.status! <= 4) {
          if (data.status == 1) question1.selectedAnswer = 3;
          if (data.status == 2) question1.selectedAnswer = 0;
          if (data.status == 3) question1.selectedAnswer = 1;
          if (data.status == 4) question1.selectedAnswer = 2;
          onSelectedAnswer(question1.questionKey);
        }
      }
      emit(const BloodSugarSurveySuccess());
    }, failure: (NetworkExceptions error) {
      emit(BloodSugarSurveyFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const BloodSugarSurveyInitial());
  }

  Future<void> selectDefaultAnswerForQuestion2() async {
    await Future.delayed(Duration.zero);
    emit(const BloodSugarSurveyLoading());
    final ApiResult<LatestHba1cInputResponse> apiResult =
        await repository.getLatestHbA1CInput();
    apiResult.when(success: (LatestHba1cInputResponse response) {
      if (response.data == null || response.data == -1) return;
      hba1c = response.data!;
      if (hba1c < 7) {
        question2.selectedAnswer = 0;
      } else {
        question2.selectedAnswer = 1;
      }
      onSelectedAnswer(question2.questionKey);
      emit(const BloodSugarSurveySuccess());
    }, failure: (NetworkExceptions error) {
      emit(BloodSugarSurveyFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

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
    refreshState();
  }

  void onSubmitAnswer() {
    if (questions.contains(question1)) {
      if (question1.selectedAnswer == null) {
        return;
      }
      if (canSurveyDone) {
        if (question1.selectedAnswer == 0) {
          //Template D
          showTemplate(templateCode: 'D');
        }
        if (question1.selectedAnswer == 2) {
          //Template OP
          showTemplate(templateCode: 'OP');
        }
        if (question1.selectedAnswer == 3) {
          //No Template
          showTemplate(templateCode: 'NONE');
        }
      } else {
        //Continue Survey from question 2
        questions.clear();
        questions.add(question2);
        selectDefaultAnswerForQuestion2();
      }
    } else {
      if (question2.selectedAnswer == 0) {
        if (question3.selectedAnswer == 0) {
          if (question4_1.selectedAnswer == 0) {
            //Template A1
            showTemplate(templateCode: 'A1');
          }
          if (question4_1.selectedAnswer == 1) {
            //Template B
            showTemplate(templateCode: 'B');
          }
          if (question4_1.selectedAnswer == 2) {
            //Template D
            showTemplate(templateCode: 'D');
          }
        } else {
          if (question4_2.selectedAnswer == 0) {
            //Template FGHI
            showTemplate(templateCode: 'FGHI');
          }
          if (question4_2.selectedAnswer == 1) {
            //Template K
            showTemplate(templateCode: 'K');
          }
        }
      }
      if (question2.selectedAnswer == 1) {
        if (question3.selectedAnswer == 0) {
          if (question4_1.selectedAnswer == 0) {
            //Template A2
            showTemplate(templateCode: 'A2');
          }
          if (question4_1.selectedAnswer == 1) {
            //Template B
            showTemplate(templateCode: 'B');
          }
          if (question4_1.selectedAnswer == 2) {
            //Template D
            showTemplate(templateCode: 'D');
          }
        } else {
          if (question4_2.selectedAnswer == 0 ||
              question4_2.selectedAnswer == 1) {
            //Template FGHI
            showTemplate(templateCode: 'FGHI');
          }
        }
      }
    }
    refreshState();
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
    refreshState();
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

  void showTemplate({required String templateCode}) {
    emit(BloodSugarSurveyNavigate(templateCode: templateCode));
    refreshState();
  }
}
