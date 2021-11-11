import 'package:medical/src/modal/base/images.dart';

import 'list_quiz_lesson_response.dart';

/// id : "5b002e55-639c-4b0c-0ea7-08d9983c72bb"
/// code : "tieuduongquestion4"
/// name : "B? câu h?i ti?u du?ng"
/// description : "Tr? l?i câu h?i liên quan d?n cá nhân"
/// isBeta : false
/// questionCount : 0
/// status : 2
/// updateDatetime : "10/26/2021 04:52:42"
/// updaterName : null
/// updaterImage : null
/// sections : [{"id":"c2ed3add-31e2-4239-2ee1-08d9983c72d0","name":"Ph?n 2: Ti?u du?ng c?p 2","order":1,"questions":[{"id":"608f01ff-0bde-4e4b-211a-08d9946a7083","code":null,"name":"Câu h?i s? 92","order":1,"type":1,"isScore":true,"isRelatedQuestions":true,"isRelatedPatients":true,"answers":[{"id":"762b477c-4543-44f6-0beb-08d9946a708f","content":"Ðáp án 3","order":0,"point":3,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null},{"id":"ecc972cb-79b5-4aec-0bec-08d9946a708f","content":"Ðáp án 4","order":1,"point":4,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null}]},{"id":"811e61c9-3f87-4349-2761-08d994760864","code":null,"name":"Question 2","order":2,"type":2,"isScore":true,"isRelatedQuestions":false,"isRelatedPatients":false,"answers":[{"id":"3493d4c7-611f-45f0-0ce6-08d994760871","content":"123","order":0,"point":8,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null},{"id":"ce9aa7b3-e340-4f4a-0ce7-08d994760871","content":"3333","order":1,"point":4,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null}]}]},{"id":"db2d854a-7c98-4131-2ee0-08d9983c72d0","name":"Ph?n 1: T?ng quan ti?u du?ng","order":0,"questions":[{"id":"1b3e5a4d-1fd0-4dbc-2119-08d9946a7083","code":null,"name":"Câu h?i s? 9.1","order":1,"type":1,"isScore":true,"isRelatedQuestions":true,"isRelatedPatients":true,"answers":[{"id":"3a1bad82-bf21-4d54-0be9-08d9946a708f","content":"Ðáp án 1","order":0,"point":7,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null},{"id":"ec06dbe9-ef09-4b23-0bea-08d9946a708f","content":"Ðáp án 2","order":1,"point":9,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null}]},{"id":"32396f3a-dfef-44e7-622e-08d98882d94e","code":null,"name":"Câu hỏi 1","order":1,"type":1,"isScore":false,"isRelatedQuestions":false,"isRelatedPatients":false,"answers":[]},{"id":"46b456b4-4b8c-4dd8-3eba-08d993a9e5f5","code":null,"name":"Câu h?i s? 3 updated","order":1,"type":1,"isScore":true,"isRelatedQuestions":true,"isRelatedPatients":true,"answers":[{"id":"4928fed6-0ace-4cb6-1680-08d993aa066e","content":"Ðáp án 1 updated","order":0,"point":2,"rangeBegin":0,"rangeEnd":0,"titleBegin":"string","titleEnd":"string"},{"id":"85fcbbb7-a254-48e3-1681-08d993aa066e","content":"Ðáp án 2 updated","order":1,"point":2,"rangeBegin":0,"rangeEnd":0,"titleBegin":"string","titleEnd":"string"}]},{"id":"5a380642-2058-47d5-31af-08d99444dfde","code":null,"name":"Question 1","order":1,"type":2,"isScore":true,"isRelatedQuestions":false,"isRelatedPatients":false,"answers":[{"id":"49ccada5-d940-4161-76f5-08d9945e4f10","content":"test 2","order":0,"point":6,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null},{"id":"821ed2da-6cfc-4342-76f6-08d9945e4f10","content":"test","order":1,"point":5,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null}]}]}]

class SurveyData {
  SurveyData({
    String? id,
    String? code,
    String? coverId,
    ImagesModel? image,
    String? name,
    String? description,
    bool? isBeta,
    int? questionCount,
    int? status,
    String? updateDatetime,
    String? updaterName,
    ImagesModel? updaterImage,
    List<SectionSurvey>? sections,
  }) {
    _id = id;
    _code = code;
    _coverId = coverId;
    _image = image;
    _name = name;
    _description = description;
    _isBeta = isBeta;
    _questionCount = questionCount;
    _status = status;
    _updateDatetime = updateDatetime;
    _updaterName = updaterName;
    _updaterImage = updaterImage;
    _sections = sections;
  }

  SurveyData.fromJson(dynamic json) {
    _id = json['id'];
    _code = json['code'];
    _coverId = json['coverId'];
    _image = ImagesModel.fromJson(json['image']);
    _name = json['name'];
    _description = json['description'];
    _isBeta = json['isBeta'];
    _questionCount = json['questionCount'];
    _status = json['status'];
    _updateDatetime = json['updateDatetime'];
    _updaterName = json['updaterName'];
    _updaterImage = ImagesModel.fromJson(json['updaterImage']);
    if (json['sections'] != null) {
      _sections = [];
      json['sections'].forEach((v) {
        _sections?.add(SectionSurvey.fromJson(v));
      });
    }
  }
  String? _id;
  String? _code;
  String? _coverId;
  ImagesModel? _image;
  String? _name;
  String? _description;
  bool? _isBeta;
  int? _questionCount;
  int? _status;
  String? _updateDatetime;
  String? _updaterName;
  ImagesModel? _updaterImage;
  List<SectionSurvey>? _sections;

  String? get id => _id;
  String? get code => _code;
  String? get coverId => _coverId;
  ImagesModel? get image => _image;
  String? get name => _name;
  String? get description => _description;
  bool? get isBeta => _isBeta;
  int? get questionCount => _questionCount;
  int? get status => _status;
  String? get updateDatetime => _updateDatetime;
  String? get updaterName => _updaterName;
  ImagesModel? get updaterImage => _updaterImage;
  List<SectionSurvey>? get sections => _sections;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['code'] = _code;
    map['coverId'] = _coverId;
    map['image'] = _image;
    map['name'] = _name;
    map['description'] = _description;
    map['isBeta'] = _isBeta;
    map['questionCount'] = _questionCount;
    map['status'] = _status;
    map['updateDatetime'] = _updateDatetime;
    map['updaterName'] = _updaterName;
    map['updaterImage'] = _updaterImage;
    if (_sections != null) {
      map['sections'] = _sections?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// id : "c2ed3add-31e2-4239-2ee1-08d9983c72d0"
/// name : "Ph?n 2: Ti?u du?ng c?p 2"
/// order : 1
/// questions : [{"id":"608f01ff-0bde-4e4b-211a-08d9946a7083","code":null,"name":"Câu h?i s? 92","order":1,"type":1,"isScore":true,"isRelatedQuestions":true,"isRelatedPatients":true,"answers":[{"id":"762b477c-4543-44f6-0beb-08d9946a708f","content":"Ðáp án 3","order":0,"point":3,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null},{"id":"ecc972cb-79b5-4aec-0bec-08d9946a708f","content":"Ðáp án 4","order":1,"point":4,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null}]},{"id":"811e61c9-3f87-4349-2761-08d994760864","code":null,"name":"Question 2","order":2,"type":2,"isScore":true,"isRelatedQuestions":false,"isRelatedPatients":false,"answers":[{"id":"3493d4c7-611f-45f0-0ce6-08d994760871","content":"123","order":0,"point":8,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null},{"id":"ce9aa7b3-e340-4f4a-0ce7-08d994760871","content":"3333","order":1,"point":4,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null}]}]

class SectionSurvey {
  SectionSurvey({
    String? id,
    String? surveyId,
    String? name,
    String? description,
    int? order,
    List<QuizData>? questions,
  }) {
    _id = id;
    _surveyId = surveyId;
    _name = name;
    _description = description;
    _order = order;
    _questions = questions;
  }

  List<QuizData> get questionList {
    return (questions
            ?.where((element) => element.isRelatedQuestions == false)
            .toList() ??
        [])
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
  }

  SectionSurvey.fromJson(dynamic json) {
    _id = json['id'];
    _surveyId = json['surveyId'];
    _name = json['name'];
    _description = json['description'];
    _order = json['order'];
    if (json['questions'] != null) {
      _questions = [];
      json['questions'].forEach((v) {
        _questions?.add(QuizData.fromJson(v));
      });
    }
  }
  String? _id;
  String? _surveyId;
  String? _name;
  String? _description;
  int? _order;
  List<QuizData>? _questions;

  String? get id => _id;
  String? get surveyId => _surveyId;
  String? get name => _name;
  String? get description => _description;
  int? get order => _order;
  List<QuizData>? get questions => _questions;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['surveyId'] = _surveyId;
    map['name'] = _name;
    map['description'] = _description;
    map['order'] = _order;
    if (_questions != null) {
      map['questions'] = _questions?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// id : "608f01ff-0bde-4e4b-211a-08d9946a7083"
/// code : null
/// name : "Câu h?i s? 92"
/// order : 1
/// type : 1
/// isScore : true
/// isRelatedQuestions : true
/// isRelatedPatients : true
/// answers : [{"id":"762b477c-4543-44f6-0beb-08d9946a708f","content":"Ðáp án 3","order":0,"point":3,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null},{"id":"ecc972cb-79b5-4aec-0bec-08d9946a708f","content":"Ðáp án 4","order":1,"point":4,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null}]

class QuestionSurvey {
  QuestionSurvey({
    String? id,
    String? code,
    String? name,
    int? order,
    int? type,
    bool? isScore,
    bool? isRelatedQuestions,
    bool? isRelatedPatients,
    List<AnswerSurvey>? answers,
  }) {
    _id = id;
    _code = code;
    _name = name;
    _order = order;
    _type = type;
    _isScore = isScore;
    _isRelatedQuestions = isRelatedQuestions;
    _isRelatedPatients = isRelatedPatients;
    _answers = answers;
  }

  QuestionSurvey.fromJson(dynamic json) {
    _id = json['id'];
    _code = json['code'];
    _name = json['name'];
    _order = json['order'];
    _type = json['type'];
    _isScore = json['isScore'];
    _isRelatedQuestions = json['isRelatedQuestions'];
    _isRelatedPatients = json['isRelatedPatients'];
    if (json['answers'] != null) {
      _answers = [];
      json['answers'].forEach((v) {
        _answers?.add(AnswerSurvey.fromJson(v));
      });
    }
  }
  String? _id;
  String? _code;
  String? _name;
  int? _order;
  int? _type;
  bool? _isScore;
  bool? _isRelatedQuestions;
  bool? _isRelatedPatients;
  List<AnswerSurvey>? _answers;

  String? get id => _id;
  String? get code => _code;
  String? get name => _name;
  int? get order => _order;
  int? get type => _type;
  bool? get isScore => _isScore;
  bool? get isRelatedQuestions => _isRelatedQuestions;
  bool? get isRelatedPatients => _isRelatedPatients;
  List<AnswerSurvey>? get answers => _answers;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['code'] = _code;
    map['name'] = _name;
    map['order'] = _order;
    map['type'] = _type;
    map['isScore'] = _isScore;
    map['isRelatedQuestions'] = _isRelatedQuestions;
    map['isRelatedPatients'] = _isRelatedPatients;
    if (_answers != null) {
      map['answers'] = _answers?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// id : "762b477c-4543-44f6-0beb-08d9946a708f"
/// content : "Ðáp án 3"
/// order : 0
/// point : 3
/// rangeBegin : 0
/// rangeEnd : 0
/// titleBegin : null
/// titleEnd : null

class AnswerSurvey {
  AnswerSurvey({
    String? id,
    String? content,
    int? order,
    int? point,
    bool? flag,
  }) {
    _id = id;
    _content = content;
    _order = order;
    _point = point;
    _flag = flag;
  }

  AnswerSurvey.fromJson(dynamic json) {
    _id = json['id'];
    _content = json['content'];
    _order = json['order'];
    _point = json['point'];
    _flag = json['flag'];
  }
  String? _id;
  String? _content;
  int? _order;
  int? _point;
  bool? _flag;

  String? get id => _id;
  String? get content => _content;
  int? get order => _order;
  int? get point => _point;
  bool? get flag => _flag;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['content'] = _content;
    map['order'] = _order;
    map['point'] = _point;
    map['flag'] = _flag;
    return map;
  }
}
