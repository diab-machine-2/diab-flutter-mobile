import 'package:medical/src/modal/learning/learning_post_model.dart';

class LearningPostResponseMeta {
/*
{
  "success": true,
  "total": 2,
  "pageCount": 1,
  "page": 1,
  "size": 10,
  "canNext": false,
  "canPrev": false
} 
*/

  bool? success;
  int? total;
  int? pageCount;
  int? page;
  int? size;
  bool? canNext;
  bool? canPrev;

  LearningPostResponseMeta({
    this.success,
    this.total,
    this.pageCount,
    this.page,
    this.size,
    this.canNext,
    this.canPrev,
  });
  LearningPostResponseMeta.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    total = json['total'];
    pageCount = json['pageCount'];
    page = json['page'];
    size = json['size'];
    canNext = json['canNext'];
    canPrev = json['canPrev'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    data['total'] = total;
    data['pageCount'] = pageCount;
    data['page'] = page;
    data['size'] = size;
    data['canNext'] = canNext;
    data['canPrev'] = canPrev;
    return data;
  }
}

class LearningPostListResponse {
  LearningPostResponseMeta? meta;
  List<LearningPostModel>? data;

  LearningPostListResponse({
    this.meta,
    this.data,
  });
  LearningPostListResponse.fromJson(Map<String, dynamic> json) {
    meta = (json['meta'] != null)
        ? LearningPostResponseMeta.fromJson(json['meta'])
        : null;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(LearningPostModel.fromJson(v));
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

class WebinarDetailResponse {
  LearningPostModel? data;

  WebinarDetailResponse({
    this.data,
  });

  WebinarDetailResponse.fromJson(Map<String, dynamic> json) {
    data = LearningPostModel.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map.addAll(data!.toJson());
    }
    return map;
  }
}

class WebinarListResponse {
  List<WebinarDetailResponse>? data;

  WebinarListResponse({
    this.data,
  });

  WebinarListResponse.fromJson(List<dynamic> json) {
    if (json != null) {
      data = json
          .map((v) => WebinarDetailResponse.fromJson(v as Map<String, dynamic>))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
