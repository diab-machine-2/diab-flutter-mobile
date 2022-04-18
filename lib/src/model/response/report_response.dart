import 'package:medical/src/model/response/report_model.dart';

class ReportResponseMeta {
/*
{
  "success": true
} 
*/

  bool? success;

  ReportResponseMeta({
    this.success,
  });
  ReportResponseMeta.fromJson(Map<String, dynamic> json) {
    success = json['success'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    return data;
  }
}

class ReportListResponse {
  ReportResponseMeta? meta;
  List<ReportModel>? data;

  ReportListResponse({
    this.meta,
    this.data,
  });
  ReportListResponse.fromJson(Map<String, dynamic> json) {
    meta = (json['meta'] != null)
        ? ReportResponseMeta.fromJson(json['meta'])
        : null;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(ReportModel.fromJson(v));
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
