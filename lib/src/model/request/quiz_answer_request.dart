class QuizAnswerRequest {

  String? quizId;
  String? quizAnswerId;

  QuizAnswerRequest({
    this.quizId,
    this.quizAnswerId,
  });
  QuizAnswerRequest.fromJson(Map<String, dynamic> json) {
    quizId = json['quizId']?.toString();
    quizAnswerId = json['quizAnswerId']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['quizId'] = quizId;
    data['quizAnswerId'] = quizAnswerId;
    return data;
  }
}
