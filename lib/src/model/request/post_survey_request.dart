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
  String? surveySectionId;

  QuestionAnswerResults({
    this.surveyQuestionId,
    this.surveyAnswerIdList,
    this.content,
    this.surveySectionId,
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
    surveySectionId = json['surveySectionId']?.toString();
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
    data['surveySectionId'] = surveySectionId;
    return data;
  }
}

class PostSurveyRequest {
/*
{
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

  QuestionAnswerResults? questionAnswerResults;

  PostSurveyRequest({
    this.questionAnswerResults,
  });
  PostSurveyRequest.fromJson(Map<String, dynamic> json) {
    if (json['questionAnswerResults'] != null) {
      questionAnswerResults = QuestionAnswerResults.fromJson(json['questionAnswerResults']);
    }
  }
  Map<String, dynamic> toJson() {
    return questionAnswerResults!.toJson();
  }
}
