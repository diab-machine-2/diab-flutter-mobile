
class ContentWelcomeResponse {
  ContentWelcomeResponseMeta? meta;
  ContentWelcomeResponseData? data;

  ContentWelcomeResponse.fromJson(Map<String, dynamic> json) {
    meta = (json['meta'] != null)
        ? ContentWelcomeResponseMeta.fromJson(json['meta'])
        : null;
    data = (json['data'] != null)
        ? ContentWelcomeResponseData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    if (data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ContentWelcomeResponseMeta {
/*
{
  "success": true
} 
*/

  bool? success;

  ContentWelcomeResponseMeta({
    this.success,
  });

  ContentWelcomeResponseMeta.fromJson(Map<String, dynamic> json) {
    success = json['success'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    return data;
  }
}


class ContentWelcomeResponseData {
  String? accountId;
  String? packageId;
  String? packageName;
  String? hotLine;
  String? fullName;
  int? gender;

  ContentWelcomeResponseData({
    this.accountId,
    this.packageId,
    this.packageName,
    this.hotLine,
    this.fullName,
    this.gender,
  });

  ContentWelcomeResponseData.fromJson(Map<String, dynamic> json) {
    accountId = json["accountId"]?.toString();
    packageId = json["packageId"]?.toString();
    packageName = json["packageName"]?.toString();
    hotLine = json["hotLine"]?.toString();
    fullName = json["fullName"]?.toString();
    gender = json["gender"]?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["accountId"] = accountId;
    data["packageId"] = packageId;
    data["packageName"] = packageName;
    data["hotLine"] = hotLine;
    data["fullName"] = fullName;
    data["gender"] = gender;
    return data;
  }
}