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

class ExpertCommentResponse {
  ExpertCommentResponseMeta? meta;
  ExpertCommentModel? data;

  ExpertCommentResponse({
    this.meta,
    this.data,
  });
  ExpertCommentResponse.fromJson(Map<String, dynamic> json) {
    meta = (json['meta'] != null)
        ? ExpertCommentResponseMeta.fromJson(json['meta'])
        : null;
    data = (json['data'] != null)
        ? ExpertCommentModel.fromJson(json['data'])
        : null;
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (meta != null) {
      map['meta'] = meta!.toJson();
    }
     if (data != null) {
      map['data'] = this.data!.toJson();
    }
    return map;
  }
}
