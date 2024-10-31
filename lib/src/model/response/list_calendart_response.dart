import 'package:medical/src/model/response/create_calendar_response.dart';

class CalendarResponseMeta {
/*
{
  "success": true
} 
*/

  bool? success;

  CalendarResponseMeta({
    this.success,
  });
  CalendarResponseMeta.fromJson(Map<String, dynamic> json) {
    success = json['success'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    return data;
  }
}

class CalendarListResponse {
  CalendarResponseMeta? meta;
  List<CreateCalendarResponse>? data;

  CalendarListResponse({
    this.meta,
    this.data,
  });
  CalendarListResponse.fromJson(Map<String, dynamic> json) {
    meta = (json['meta'] != null)
        ? CalendarResponseMeta.fromJson(json['meta'])
        : null;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(CreateCalendarResponse.fromJson(v));
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
