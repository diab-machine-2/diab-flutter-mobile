// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';

LessonModuleDataResponse lessModuleDataResponseromJson(String str) =>
    LessonModuleDataResponse.fromJson(json.decode(str));

String lessModuleDataResponseToJson(LessonModuleDataResponse data) => json.encode(data.toJson());

class LessonModuleDataResponse {
  LessonModuleDataResponse({
    this.total,
    this.page,
    this.size,
    this.items,
  });

  int? total;
  int? page;
  int? size;
  List<LessonModuleItem>? items;

  factory LessonModuleDataResponse.fromJson(Map<String, dynamic> json) => LessonModuleDataResponse(
        total: json["total"],
        page: json["page"],
        size: json["size"],
        items: List<LessonModuleItem>.from(json["items"].map((x) => LessonModuleItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "page": page,
        "size": size,
        "items": items == null ? null : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class LessonModuleItem extends Equatable {
  LessonModuleItem({
    this.id,
    this.code,
    this.name,
    this.updateDate,
    this.updaterName,
    this.updaterUsername,
    this.updaterCode,
    this.updaterImage,
  });

  String? id;
  String? code;
  String? name;
  String? updateDate;
  String? updaterName;
  String? updaterUsername;
  String? updaterCode;
  UpdaterImage? updaterImage;

  factory LessonModuleItem.fromJson(Map<String, dynamic> json) => LessonModuleItem(
        id: json["id"],
        code: json["code"],
        name: json["name"],
        updateDate: json["updateDate"],
        updaterName: json["updaterName"],
        updaterUsername: json["updaterUsername"],
        updaterCode: json["updaterCode"],
        updaterImage: json["updaterImage"] == null ? null : UpdaterImage.fromJson(json["updaterImage"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "name": name,
        "updateDate": updateDate,
        "updaterName": updaterName,
        "updaterUsername": updaterUsername,
        "updaterCode": updaterCode,
        "updaterImage": updaterImage == null ? updaterImage : updaterImage!.toJson(),
      };

  @override
  List<String> get props => [id ?? ''];
}

class UpdaterImage {
  UpdaterImage({
    this.id,
    this.url,
  });

  String? id;
  String? url;

  factory UpdaterImage.fromJson(Map<String, dynamic> json) => UpdaterImage(
        id: json["id"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "url": url,
      };
}

class LessonModuleResponse {
  LessonModuleMetaReponse? meta;
  LessonModuleDataResponse? data;

  LessonModuleResponse({
    this.meta,
    this.data,
  });

  LessonModuleResponse.fromJson(Map<String, dynamic> json) {
    meta = (json['meta'] != null) ? LessonModuleMetaReponse.fromJson(json['meta']) : null;
    data = (json['data'] != null) ? LessonModuleDataResponse.fromJson(json['data']) : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class LessonModuleMetaReponse {
  bool? success;

  LessonModuleMetaReponse({
    this.success,
  });
  LessonModuleMetaReponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    return data;
  }
}
