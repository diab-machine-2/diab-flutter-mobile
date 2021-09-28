/// code : "bad_client_request"
/// message : "bad client request"
/// data : {"message":["nội dung lời nhắn là thông tin bắt buộc"]}

class ErrorData {
  ErrorData({
    String? code,
    String? message,
    ErrorMessage? data,}){
    _code = code;
    _message = message;
    _data = data;
  }

  ErrorData.fromJson(dynamic json) {
    _code = json['code'];
    _message = json['message'];
    _data = json['data'] != null ? ErrorMessage.fromJson(json['data']) : null;
  }
  String? _code;
  String? _message;
  ErrorMessage? _data;

  String? get code => _code;
  String? get message => _message;
  ErrorMessage? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = _code;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }

}

/// message : ["nội dung lời nhắn là thông tin bắt buộc"]

class ErrorMessage {
  ErrorMessage({
    List<String>? message,}){
    _message = message;
  }

  ErrorMessage.fromJson(dynamic json) {
    _message = json['message'] != null ? json['message'].cast<String>() : [];
  }
  List<String>? _message;

  List<String>? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    return map;
  }

}
