import 'package:medical/src/model/response/my_progress_response.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/expert_comment/model/calendar_training_group.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/expert_comment/model/expert_comment_model.dart';

class CalendarTrainingResponseMeta {
/*
{
  "success": true
} 
*/

  bool? success;

  CalendarTrainingResponseMeta({
    this.success,
  });
  CalendarTrainingResponseMeta.fromJson(Map<String, dynamic> json) {
    success = json['success'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    return data;
  }
}

class CalendarTrainingListResponse {
  CalendarTrainingResponseMeta? meta;
  List<CalendarTrainingGroup>? data;

  CalendarTrainingListResponse({
    this.meta,
    this.data,
  });
  CalendarTrainingListResponse.fromJson(Map<String, dynamic> json) {
    meta = (json['meta'] != null)
        ? CalendarTrainingResponseMeta.fromJson(json['meta'])
        : null;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(CalendarTrainingGroup.fromJson(v));
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
