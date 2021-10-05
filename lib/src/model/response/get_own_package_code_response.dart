import 'meta.dart';

/// meta : {"success":true}
/// data : ""

class GetOwnPackageCodeResponse {
  GetOwnPackageCodeResponse({
      Meta? meta, 
      String? data,}){
    _meta = meta;
    _data = data;
}

  GetOwnPackageCodeResponse.fromJson(dynamic json) {
    _meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    _data = json['data'];
  }
  Meta? _meta;
  String? _data;

  Meta? get meta => _meta;
  String? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_meta != null) {
      map['meta'] = _meta?.toJson();
    }
    map['data'] = _data;
    return map;
  }

}