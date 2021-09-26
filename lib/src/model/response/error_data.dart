/// code : "exception"
/// message : "Object reference not set to an instance of an object."

class ErrorData {
  ErrorData({
      String? code, 
      String? message,}){
    _code = code;
    _message = message;
}

  ErrorData.fromJson(dynamic json) {
    _code = json['code'];
    _message = json['message'];
  }
  String? _code;
  String? _message;

  String? get code => _code;
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = _code;
    map['message'] = _message;
    return map;
  }

}