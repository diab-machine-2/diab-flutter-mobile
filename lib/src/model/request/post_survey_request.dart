/// surveyId : "string"
/// surveySectionId : "string"
/// questionAnswerResults : [{"surveyQuestionId":"string","surveyAnswerId":"string"}]

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

/// surveyQuestionId : "string"
/// surveyAnswerId : "string"

class QuestionAnswerResults {
  QuestionAnswerResults({
      String? surveyQuestionId, 
      String? surveyAnswerId,}){
    _surveyQuestionId = surveyQuestionId;
    _surveyAnswerId = surveyAnswerId;
}

  QuestionAnswerResults.fromJson(dynamic json) {
    _surveyQuestionId = json['surveyQuestionId'];
    _surveyAnswerId = json['surveyAnswerId'];
  }
  String? _surveyQuestionId;
  String? _surveyAnswerId;

  String? get surveyQuestionId => _surveyQuestionId;
  String? get surveyAnswerId => _surveyAnswerId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['surveyQuestionId'] = _surveyQuestionId;
    map['surveyAnswerId'] = _surveyAnswerId;
    return map;
  }

}