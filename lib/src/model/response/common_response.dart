import 'error_data.dart';
import 'meta.dart';

/// meta : {"success":false}
/// error : {"code":"bad_client_request","message":"bad client request","data":{"message":["nội dung lời nhắn là thông tin bắt buộc"]}}

class CommonResponse {
  CommonResponse({
    String? message,
    int? statusCode,
    Meta? meta,
    ErrorData? error,
  }) {
    _meta = meta;
    _error = error;
    _statusCode = statusCode;
    _message = message;
  }

  CommonResponse.fromJson(dynamic json) {
    _meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    _error = json['error'] != null ? ErrorData.fromJson(json['error']) : null;
    _statusCode = json['statusCode'];
    _message = json['message'];
  }

  Meta? _meta;
  ErrorData? _error;
  String? _message;
  int? _statusCode;

  Meta? get meta => _meta;

  ErrorData? get error => _error;

  String? get message => _message;

  int? get statusCode => _statusCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_meta != null) {
      map['meta'] = _meta?.toJson();
    }
    if (_error != null) {
      map['error'] = _error?.toJson();
    }
    if (_message != null) {
      map['message'] = _message;
    }
    if (_statusCode != null) {
      map['statusCode'] = _statusCode;
    }
    return map;
  }
}
