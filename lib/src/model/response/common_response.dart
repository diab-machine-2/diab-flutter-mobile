import 'error_data.dart';
import 'meta.dart';

/// meta : {"success":false}
/// error : {"code":"bad_client_request","message":"bad client request","data":{"message":["nội dung lời nhắn là thông tin bắt buộc"]}}

class CommonResponse {
  CommonResponse({
      Meta? meta, 
      ErrorData? error,}){
    _meta = meta;
    _error = error;
}

  CommonResponse.fromJson(dynamic json) {
    _meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    _error = json['error'] != null ? ErrorData.fromJson(json['error']) : null;
  }
  Meta? _meta;
  ErrorData? _error;

  Meta? get meta => _meta;
  ErrorData? get error => _error;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_meta != null) {
      map['meta'] = _meta?.toJson();
    }
    if (_error != null) {
      map['error'] = _error?.toJson();
    }
    return map;
  }

}

