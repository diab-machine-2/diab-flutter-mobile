import 'package:medical/src/widget/question_answer/all_question_answer/model/question_model.dart';

class QuestionAnswerResponse {
  QuestionAnswerReponseMeta? meta;
  List<QuestionModel>? data;

  QuestionAnswerResponse({
    this.meta,
    this.data,
  });

  QuestionAnswerResponse.fromJson(Map<String, dynamic> json) {
    meta = (json['meta'] != null) ? QuestionAnswerReponseMeta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(QuestionModel.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (meta != null) {
      map['meta'] = meta!.toJson();
    }
    if (data != null) {
      map['data'] = data!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class QuestionAnswerReponseMeta {
  bool? success;

  QuestionAnswerReponseMeta({
    this.success,
  });
  QuestionAnswerReponseMeta.fromJson(Map<String, dynamic> json) {
    success = json['success'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    return data;
  }
}

class QuestionResponse {
  QuestionAnswerReponseMeta? meta;
  QuestionModel? data;

  QuestionResponse({
    this.meta,
    this.data,
  });

  QuestionResponse.fromJson(Map<String, dynamic> json) {
    meta = (json['meta'] != null) ? QuestionAnswerReponseMeta.fromJson(json['meta']) : null;
    data = json['data'] != null ? QuestionModel.fromJson(json['data']) : null;
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (meta != null) {
      map['meta'] = meta!.toJson();
    }
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}
