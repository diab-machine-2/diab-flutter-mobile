class SurveyTarget {
  String? id;
  String? code;
  String? coverId;
  Image? image;
  String? name;
  String? description;
  int? status;
  int? questionCount;
  String? updateDatetime;
  List<Sections>? sections;
  String? updateDate;
  String? updaterName;
  String? updaterUsername;
  String? updaterCode;
  Image? updaterImage;

  SurveyTarget(
      {this.id,
      this.code,
      this.coverId,
      this.image,
      this.name,
      this.description,
      this.status,
      this.questionCount,
      this.updateDatetime,
      this.sections,
      this.updateDate,
      this.updaterName,
      this.updaterUsername,
      this.updaterCode,
      this.updaterImage});

  SurveyTarget.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    coverId = json['coverId'];
    image = json['image'] != null ? new Image.fromJson(json['image']) : null;
    name = json['name'];
    description = json['description'];
    status = json['status'];
    questionCount = json['questionCount'];
    updateDatetime = json['updateDatetime'];
    if (json['sections'] != null) {
      sections = <Sections>[];
      json['sections'].forEach((v) {
        sections!.add(new Sections.fromJson(v));
      });
    }
    updateDate = json['updateDate'];
    updaterName = json['updaterName'];
    updaterUsername = json['updaterUsername'];
    updaterCode = json['updaterCode'];
    updaterImage = json['updaterImage'] != null
        ? new Image.fromJson(json['updaterImage'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['coverId'] = this.coverId;
    if (this.image != null) {
      data['image'] = this.image!.toJson();
    }
    data['name'] = this.name;
    data['description'] = this.description;
    data['status'] = this.status;
    data['questionCount'] = this.questionCount;
    data['updateDatetime'] = this.updateDatetime;
    if (this.sections != null) {
      data['sections'] = this.sections!.map((v) => v.toJson()).toList();
    }
    data['updateDate'] = this.updateDate;
    data['updaterName'] = this.updaterName;
    data['updaterUsername'] = this.updaterUsername;
    data['updaterCode'] = this.updaterCode;
    if (this.updaterImage != null) {
      data['updaterImage'] = this.updaterImage!.toJson();
    }
    return data;
  }
}

class Image {
  String? id;
  String? url;

  Image({this.id, this.url});

  Image.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['url'] = this.url;
    return data;
  }
}

class Sections {
  String? id;
  String? surveyId;
  String? code;
  String? name;
  String? description;
  int? order;
  List<Questions>? questions;
  int? modelStatus;

  Sections(
      {this.id,
      this.surveyId,
      this.code,
      this.name,
      this.description,
      this.order,
      this.questions,
      this.modelStatus});

  Sections.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    surveyId = json['surveyId'];
    code = json['code'];
    name = json['name'];
    description = json['description'];
    order = json['order'];
    if (json['questions'] != null) {
      questions = <Questions>[];
      json['questions'].forEach((v) {
        questions!.add(new Questions.fromJson(v));
      });
    }
    modelStatus = json['modelStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['surveyId'] = this.surveyId;
    data['code'] = this.code;
    data['name'] = this.name;
    data['description'] = this.description;
    data['order'] = this.order;
    if (this.questions != null) {
      data['questions'] = this.questions!.map((v) => v.toJson()).toList();
    }
    data['modelStatus'] = this.modelStatus;
    return data;
  }
}

class Questions {
  String? id;
  String? code;
  String? name;
  int? order;
  int? type;
  bool? isScore;
  bool? isRelatedQuestions;
  bool? isRelatedPatients;
  String? mappedQuestionId;
  String? mappedAnswerId;
  List<Answers>? answers;
  List<Results>? results;
  int? modelStatus;

  Questions(
      {this.id,
      this.code,
      this.name,
      this.order,
      this.type,
      this.isScore,
      this.isRelatedQuestions,
      this.isRelatedPatients,
      this.mappedQuestionId,
      this.mappedAnswerId,
      this.answers,
      this.results,
      this.modelStatus});

  Questions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    order = json['order'];
    type = json['type'];
    isScore = json['isScore'];
    isRelatedQuestions = json['isRelatedQuestions'];
    isRelatedPatients = json['isRelatedPatients'];
    mappedQuestionId = json['mappedQuestionId'];
    mappedAnswerId = json['mappedAnswerId'];
    if (json['answers'] != null) {
      answers = <Answers>[];
      json['answers'].forEach((v) {
        answers!.add(new Answers.fromJson(v));
      });
    }
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(new Results.fromJson(v));
      });
    }
    modelStatus = json['modelStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    data['order'] = this.order;
    data['type'] = this.type;
    data['isScore'] = this.isScore;
    data['isRelatedQuestions'] = this.isRelatedQuestions;
    data['isRelatedPatients'] = this.isRelatedPatients;
    data['mappedQuestionId'] = this.mappedQuestionId;
    data['mappedAnswerId'] = this.mappedAnswerId;
    if (this.answers != null) {
      data['answers'] = this.answers!.map((v) => v.toJson()).toList();
    }
    if (this.results != null) {
      data['results'] = this.results!.map((v) => v.toJson()).toList();
    }
    data['modelStatus'] = this.modelStatus;
    return data;
  }
}

class Answers {
  String? id;
  String? content;
  int? order;
  int? point;
  int? flag;
  bool? isMappedToSurvey;
  String? surveyQuestionId;
  String? mappedQuestionId;
  bool? isCorrectAnswer;
  String? textAnswer;
  int? modelStatus;

  Answers(
      {this.id,
      this.content,
      this.order,
      this.point,
      this.flag,
      this.isMappedToSurvey,
      this.surveyQuestionId,
      this.mappedQuestionId,
      this.isCorrectAnswer,
      this.textAnswer,
      this.modelStatus});

  Answers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    content = json['content'];
    order = json['order'];
    point = json['point'];
    flag = json['flag'];
    isMappedToSurvey = json['isMappedToSurvey'];
    surveyQuestionId = json['surveyQuestionId'];
    mappedQuestionId = json['mappedQuestionId'];
    isCorrectAnswer = json['isCorrectAnswer'];
    textAnswer = json['textAnswer'];
    modelStatus = json['modelStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['content'] = this.content;
    data['order'] = this.order;
    data['point'] = this.point;
    data['flag'] = this.flag;
    data['isMappedToSurvey'] = this.isMappedToSurvey;
    data['surveyQuestionId'] = this.surveyQuestionId;
    data['mappedQuestionId'] = this.mappedQuestionId;
    data['isCorrectAnswer'] = this.isCorrectAnswer;
    data['textAnswer'] = this.textAnswer;
    data['modelStatus'] = this.modelStatus;
    return data;
  }
}

class Results {
  String? id;
  String? accountId;
  String? surveyQuestionId;
  String? surveyAnswerId;
  String? content;

  Results(
      {this.id,
      this.accountId,
      this.surveyQuestionId,
      this.surveyAnswerId,
      this.content});

  Results.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    accountId = json['accountId'];
    surveyQuestionId = json['surveyQuestionId'];
    surveyAnswerId = json['surveyAnswerId'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['accountId'] = this.accountId;
    data['surveyQuestionId'] = this.surveyQuestionId;
    data['surveyAnswerId'] = this.surveyAnswerId;
    data['content'] = this.content;
    return data;
  }
}