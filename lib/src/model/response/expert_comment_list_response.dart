import 'package:medical/src/widget/my_plan_screens/activity_tab/expert_comment/model/expert_comment_model.dart';

class ExpertCommentResponseMeta {

  bool? success;

  ExpertCommentResponseMeta({
    this.success,
  });
  ExpertCommentResponseMeta.fromJson(Map<String, dynamic> json) {
    success = json['success'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    return data;
  }
}

class ExpertCommentResponseData {

  List<ExpertCommentModel>? items;

  ExpertCommentResponseData({
    this.items,
  });
  ExpertCommentResponseData.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items!.add(ExpertCommentModel.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (items != null) {
      map['items'] = items!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class ExpertCommentListResponse {
  ExpertCommentResponseMeta? meta;

  ExpertCommentResponseData? data;

  ExpertCommentListResponse({
    this.meta,
    this.data,
  });
  ExpertCommentListResponse.fromJson(Map<String, dynamic> json) {
    meta = (json['meta'] != null)
        ? ExpertCommentResponseMeta.fromJson(json['meta'])
        : null;
    data = (json['data'] != null)
        ? ExpertCommentResponseData.fromJson(json['data'])
        : null;
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
