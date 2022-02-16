import 'package:medical/src/model/response/my_progress_response.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/expert_comment/model/expert_comment_model.dart';

class ExpertCommentResponseMeta {
/*
{
  "success": true
} 
*/

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

class ExpertCommentListResponse {
  ExpertCommentResponseMeta? meta;
  List<ExpertCommentModel>? data;

  ExpertCommentListResponse({
    this.meta,
    this.data,
  });
  ExpertCommentListResponse.fromJson(Map<String, dynamic> json) {
    meta = (json['meta'] != null)
        ? ExpertCommentResponseMeta.fromJson(json['meta'])
        : null;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(ExpertCommentModel.fromJson(v));
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
