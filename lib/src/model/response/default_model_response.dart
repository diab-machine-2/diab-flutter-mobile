class DefaultModelResponse {
  late Meta meta;
  late Error error;
  dynamic data;

  DefaultModelResponse.fromJson(Map<String, dynamic> json) {
    meta = Meta.fromJson(json['meta']);
    error = json['error'] != null ? Error.fromJson(json['error']) : Error();
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['meta'] = this.meta.toJson();
    data['error'] = this.error.toJson();
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Meta {
  late bool success;

  Meta.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    return data;
  }
}

class Error {
  late String code;
  late String message;

  Error({this.code = '', this.message = ''});

  Error.fromJson(Map<String, dynamic> json) {
    code = json['code'] ?? "";
    message = json['message'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    return data;
  }
}
