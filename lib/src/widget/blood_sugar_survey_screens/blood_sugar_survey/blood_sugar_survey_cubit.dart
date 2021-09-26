import 'package:bloc/bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/blood_sugar_template_category_response.dart';
import 'package:medical/src/model/response/diabetes_status_response.dart';
import 'package:medical/src/model/response/latest_hba1c_input.dart';
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

  void initSurvey() {
    questions.add(question1);
    selectDefaultAnswerForQuestion1();
  }

  void refreshState() {
    emit(const BloodSugarSurveySuccess());
    emit(const BloodSugarSurveyInitial());
  }

  Future<void> selectDefaultAnswerForQuestion1() async {
    //TODO: Tuyen call Api to get DiabetesStatus
    //Fake Data
    await Future.delayed(const Duration(seconds: 1));
    final DiabetesStatusResponse diabetesStatusResponse =
        DiabetesStatusResponse.fromJson(
            {"status": 2, "date": 0, "name": "string"});
    if (diabetesStatusResponse.status != null &&
        diabetesStatusResponse.status! >= 0 &&
        diabetesStatusResponse.status! < 4) {
      question1.selectedAnswer = diabetesStatusResponse.status;
      onSelectedAnswer(question1.questionKey);
    }
  }

  Future<void> selectDefaultAnswerForQuestion2() async {
    //TODO: Tuyen call Api to get LatestHbA1CInput
    //Fake Data
    await Future.delayed(const Duration(seconds: 1));
    final LatestHba1cInput latestHba1cInput = LatestHba1cInput.fromJson({
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "date": 0,
      "type": "string",
      "hbA1C": 0,
      "glucose": 0,
      "unit": "string",
      "description": "string",
      "color": "string",
      "fontColor": "string",
      "backgroundColor": "string",
      "borderColor": "string",
      "percentColor": "string",
      "images": [
        {"id": "3fa85f64-5717-4562-b3fc-2c963f66afa6", "url": "string"}
      ]
    });
    if (latestHba1cInput.hbA1C == null) return;
    if (latestHba1cInput.hbA1C! <= 7) {
      question2.selectedAnswer = 1;
    } else {
      question2.selectedAnswer = 0;
    }
    onSelectedAnswer(question2.questionKey);
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
          //TODO: Tuyen call API to get templete D
          showResult(templeteName: 'D');
        }
        if (question1.selectedAnswer == 2) {
          //TODO: Tuyen call API to get templete OP
          showResult(templeteName: 'OP');
        }
        if (question1.selectedAnswer == 3) {
          //TODO: Tuyen NoSample
          showResult();
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
            //TODO: Tuyen call API to get templete A1
            showResult(templeteName: 'A1');
          }
          if (question4_1.selectedAnswer == 1) {
            //TODO: Tuyen call API to get templete B
            showResult(templeteName: 'B');
          }
          if (question4_1.selectedAnswer == 2) {
            //TODO: Tuyen call API to get templete D
            showResult(templeteName: 'D');
          }
        } else {
          if (question4_2.selectedAnswer == 0) {
            //TODO: Tuyen call API to get templete FGHI
            showResult(templeteName: 'FGHI');
          }
          if (question4_2.selectedAnswer == 1) {
            //TODO: Tuyen call API to get templete K
            showResult(templeteName: 'K');
          }
        }
      }
      if (question2.selectedAnswer == 1) {
        if (question3.selectedAnswer == 0) {
          if (question4_1.selectedAnswer == 0) {
            //TODO: Tuyen call API to get templete A2
            showResult(templeteName: 'A2');
          }
          if (question4_1.selectedAnswer == 1) {
            //TODO: Tuyen call API to get templete B
            showResult(templeteName: 'B');
          }
          if (question4_1.selectedAnswer == 2) {
            //TODO: Tuyen call API to get templete D
            showResult(templeteName: 'D');
          }
        } else {
          if (question4_2.selectedAnswer == 0 ||
              question4_2.selectedAnswer == 1) {
            //TODO: Tuyen call API to get templete FGHI
            showResult(templeteName: 'FGHI');
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

  void showResult({String? templeteName}) {
    print('LOG templete $templeteName');
    //TODO: Tuyen call Api to get List BloodSugarTemplateCategory
    //Fake Data
    final List<BloodSugarTemplateCategory> response = [
      BloodSugarTemplateCategory.fromJson({
        "id": "3049535b-1caf-488a-b890-2deac27def8c",
        "name": "Mẫu D1",
        "description":
            "Cơ sở y tế khuyến nghị của việc đo đường huyết?\r\nGlucose (còn gọi là đường) là nguồn năng lượng chính đi nuôi cơ thể, được chuyển hóa từ các loại thực phẩm mà chúng ta cung cấp cho bản thân mỗi ngày. Trong máu của con người luôn có một lượng Glucose nhất định để đảm bảo việc cung cấp năng lượng cho các hoạt động thường ngày:\r\n90 - 130 mg/dl (tức 5 - 7,2 mmol/l) ở thời điểm trước bữa ăn.\r\nDưới 180 mg/dl (tức 10 mmol/l) ở thời điểm sau ăn khoảng 1 - 2 tiếng.\r\n100 - 150 mg/l (tức 6 - 8,3 mmol/l) ở thời điểm trước khi đi ngủ.\r\nĐo chỉ số Glucose của mình ở những khoảng thời gian đo này và đối chiếu chỉ số cho phù hợp để biết mình có mắc bệnh tiểu đường hay không."
      }),
      // BloodSugarTemplateCategory.fromJson({
      //   "id": "447581b4-a59b-4ad5-8331-2f98d492d4d7",
      //   "name": "Mẫu D2",
      //   "description":
      //       "Cơ sở y tế khuyến nghị của việc đo đường huyết?\r\nGlucose (còn gọi là đường) là nguồn năng lượng chính đi nuôi cơ thể, được chuyển hóa từ các loại thực phẩm mà chúng ta cung cấp cho bản thân mỗi ngày. Trong máu của con người luôn có một lượng Glucose nhất định để đảm bảo việc cung cấp năng lượng cho các hoạt động thường ngày:\r\n90 - 130 mg/dl (tức 5 - 7,2 mmol/l) ở thời điểm trước bữa ăn.\r\nDưới 180 mg/dl (tức 10 mmol/l) ở thời điểm sau ăn khoảng 1 - 2 tiếng.\r\n100 - 150 mg/l (tức 6 - 8,3 mmol/l) ở thời điểm trước khi đi ngủ.\r\nĐo chỉ số Glucose của mình ở những khoảng thời gian đo này và đối chiếu chỉ số cho phù hợp để biết mình có mắc bệnh tiểu đường hay không."
      // }),
    ];
    emit(BloodSugarSurveyNavigate(response));
    refreshState();
  }
}
