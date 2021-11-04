/// surveyId : "3fa85f64-5717-4562-b3fc-2c963f66afa6"
/// surveySectionId : "3fa85f64-5717-4562-b3fc-2c963f66afa6"
/// questionAnswerResults : [{"surveyQuestionId":"3fa85f64-5717-4562-b3fc-2c963f66afa6","surveyAnswerIdList":["3fa85f64-5717-4562-b3fc-2c963f66afa6"]}]

class PostSurveyRequest {
  PostSurveyRequest({
      String? surveyId, 
      String? surveySectionId, 
      List<QuestionAnswerResults>? questionAnswerResults,}){
    _surveyId = surveyId;
    _surveySectionId = surveySectionId;
    _questionAnswerResults = questionAnswerResults;
}

  PostSurveyRequest.fromJson(dynamic json) {
    _surveyId = json['surveyId'];
    _surveySectionId = json['surveySectionId'];
    if (json['questionAnswerResults'] != null) {
      _questionAnswerResults = [];
      json['questionAnswerResults'].forEach((v) {
        _questionAnswerResults?.add(QuestionAnswerResults.fromJson(v));
      });
    }
  }
  String? _surveyId;
  String? _surveySectionId;
  List<QuestionAnswerResults>? _questionAnswerResults;

  String? get surveyId => _surveyId;
  String? get surveySectionId => _surveySectionId;
  List<QuestionAnswerResults>? get questionAnswerResults => _questionAnswerResults;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['surveyId'] = _surveyId;
    map['surveySectionId'] = _surveySectionId;
    if (_questionAnswerResults != null) {
      map['questionAnswerResults'] = _questionAnswerResults?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// surveyQuestionId : "3fa85f64-5717-4562-b3fc-2c963f66afa6"
/// surveyAnswerIdList : ["3fa85f64-5717-4562-b3fc-2c963f66afa6"]

class QuestionAnswerResults {
  QuestionAnswerResults({
      String? surveyQuestionId, 
      List<String>? surveyAnswerIdList,}){
    _surveyQuestionId = surveyQuestionId;
    _surveyAnswerIdList = surveyAnswerIdList;
}

  QuestionAnswerResults.fromJson(dynamic json) {
    _surveyQuestionId = json['surveyQuestionId'];
    _surveyAnswerIdList = json['surveyAnswerIdList'] != null ? json['surveyAnswerIdList'].cast<String>() : [];
  }
  String? _surveyQuestionId;
  List<String>? _surveyAnswerIdList;

  String? get surveyQuestionId => _surveyQuestionId;
  List<String>? get surveyAnswerIdList => _surveyAnswerIdList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['surveyQuestionId'] = _surveyQuestionId;
    map['surveyAnswerIdList'] = _surveyAnswerIdList;
    return map;
  }

}