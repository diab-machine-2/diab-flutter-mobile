import 'quiz_answer_request.dart';

class UpdateQuizLessonRequest {
  String? lessonId;
  List<QuizAnswerRequest>? quizAnswers;

  UpdateQuizLessonRequest({
    this.lessonId,
    this.quizAnswers,
  });
  UpdateQuizLessonRequest.fromJson(Map<String, dynamic> json) {
    lessonId = json['lessonId']?.toString();
    if (json['quizAnswers'] != null) {
      final v = json['quizAnswers'];
      final arr0 = <QuizAnswerRequest>[];
      if (v is List && v.isNotEmpty) {
        v.forEach((v) {
          arr0.add(QuizAnswerRequest.fromJson(v));
        });
        quizAnswers = arr0;
      }
    }

  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['lessonId'] = lessonId;
    if (quizAnswers != null) {
      final v = quizAnswers;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v.toJson());
      });
      data['quizAnswers'] = arr0;
    }
    return data;
  }
}
