class QuestionAnswerResults {
/*
{
  "surveyQuestionId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "surveyAnswerIdList": [
    "3fa85f64-5717-4562-b3fc-2c963f66afa6"
  ],
  "content": "string"
} 
*/

  String? surveyQuestionId;
  List<String?>? surveyAnswerIdList;
  String? content;

  QuestionAnswerResults({
    this.surveyQuestionId,
    this.surveyAnswerIdList,
    this.content,
  });
  QuestionAnswerResults.fromJson(Map<String, dynamic> json) {
    surveyQuestionId = json['surveyQuestionId']?.toString();
    if (json['surveyAnswerIdList'] != null) {
      final v = json['surveyAnswerIdList'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      surveyAnswerIdList = arr0;
    }
    content = json['content']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['surveyQuestionId'] = surveyQuestionId;
    if (surveyAnswerIdList != null) {
      final v = surveyAnswerIdList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['surveyAnswerIdList'] = arr0;
    }
    data['content'] = content;
    return data;
  }
}

class PostSurveyRequest {
/*
{
  "surveyId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "surveySectionId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "questionAnswerResults": [
    {
      "surveyQuestionId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "surveyAnswerIdList": [
        "3fa85f64-5717-4562-b3fc-2c963f66afa6"
      ],
      "content": "string"
    }
  ]
} 
*/

  String? surveyId;
  String? surveySectionId;
  List<QuestionAnswerResults?>? questionAnswerResults;

  PostSurveyRequest({
    this.surveyId,
    this.surveySectionId,
    this.questionAnswerResults,
  });
  PostSurveyRequest.fromJson(Map<String, dynamic> json) {
    surveyId = json['surveyId']?.toString();
    surveySectionId = json['surveySectionId']?.toString();
    if (json['questionAnswerResults'] != null) {
      final v = json['questionAnswerResults'];
      final arr0 = <QuestionAnswerResults>[];
      v.forEach((v) {
        arr0.add(QuestionAnswerResults.fromJson(v));
      });
      questionAnswerResults = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['surveyId'] = surveyId;
    data['surveySectionId'] = surveySectionId;
    if (questionAnswerResults != null) {
      final v = questionAnswerResults;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['questionAnswerResults'] = arr0;
    }
    return data;
  }
}
